/*
 SMRecord.m
 SMARTFramework

 Created by Pascal Pfiffner on 8/3/12.
 Copyright (c) 2012 Harvard Medical School. All rights reserved.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */


#import "SMRecord.h"
#import "SMServer.h"
#import "SMARTObjects.h"

#import <Redland-ObjC.h>


@interface SMRecord ()

@property (nonatomic, readwrite, strong) SMDemographics *demographics;
@property (nonatomic, readwrite, strong) SMScratchpadData *scratchpad;

@end


@implementation SMRecord


#pragma mark -

/**
 *  The designated initializer, initializes a record from given parameters
 *  @param anId The id to use for this record
 *  @param aServer The server on which this record lives
 */
- (id)initWithId:(NSString *)anId onServer:(SMServer *)aServer
{
	if ((self = [super init])) {
		self.record_id = anId;
		self.server = aServer;
		self.scratchpad = [SMScratchpadData new];
	}
	return self;
}



#pragma mark - Fetching
/**
 *  Fetches the record's demographics document from /records/{record_id}/demographics
 *  @param callback A SMCancelErrorBlock block to be executed after the call returns from the server
 */
- (void)getDemographicsWithCallback:(SMCancelErrorBlock)callback
{
	self.name = nil;			// to clear the composed name
	
	NSString *demoPath = [NSString stringWithFormat:@"/records/%@/demographics", _record_id];
	[self performMethod:demoPath withBody:nil orParameters:nil ofType:nil httpMethod:@"GET" callback:^(BOOL success, NSDictionary *userInfo) {
		NSString *errorMessage = nil;
		
		// error?
		if (!success) {
			errorMessage = [[userInfo objectForKey:SMARTErrorKey] localizedDescription];
			if ([errorMessage length] < 1) {
				errorMessage = @"An unknown error happened when fetching this record's demographics document";
			}
		}
		
		// success, create a demographics document
		else {
			NSData *rdfData = [userInfo objectForKey:SMARTResponseDataKey];
			NSString *rdf = [[NSString alloc] initWithData:rdfData encoding:NSUTF8StringEncoding];
			if ([rdf length] > 0) {
				self.demographics = [SMDemographics newWithRDFXML:rdf];
			}
			else {
				errorMessage = @"No RDF was returned for this record's demographics";
			}
		}
		
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, errorMessage)
	}];
}

/**
 *  Performs a GET request to the given path and tries to instantiate objects of the given class from the returned data.
 *  @param aClass An SMDocument subclass that can represent objects returned from aPath
 *  @param aPath The path to call on the server
 *  @param callback A block to execute when the call has finished, passing a success flag and a user dictionary containing the fetched objects
 */
- (void)getObjectsOfClass:(Class)aClass from:(NSString *)aPath callback:(SMSuccessRetvalueBlock)callback
{
	if (![aClass isSubclassOfClass:[SMObject class]]) {
		NSString *errMessage = [NSString stringWithFormat:@"Class %@ is not a subclass of SMObject, it cannot be used with this method", NSStringFromClass(aClass)];
		NSError *err = nil;
		ERR(&err, errMessage, 0)
		SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, NO, @{SMARTErrorKey: err})
	}
	
	// fetch
	[self performMethod:aPath
			   withBody:nil
		   orParameters:nil
				 ofType:nil
			 httpMethod:@"GET"
			   callback:^(BOOL success, NSDictionary * __autoreleasing userInfo) {
				   if (success) {
					   NSString *contentType = [userInfo objectForKey:SMARTResponseContentTypeKey];
					   
					   // if we get RDF-XML data back we parse it
					   if ([contentType hasPrefix:@"application/rdf+xml"]) {
						   NSData *rdfData = [userInfo objectForKey:SMARTResponseDataKey];
						   NSString *rdf = [[NSString alloc] initWithData:rdfData encoding:NSUTF8StringEncoding];
						   if ([rdf length] > 0) {
				//			   DLog(@"-->  GET  %@", aPath);
				//			   DLog(@"==>  %@", rdf);
							   RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
							   RedlandURI *uri = [RedlandURI URIWithString:@"http://www.smartplatforms.org/terms#"];
							   RedlandModel *model = [RedlandModel new];
							   
							   // parse RDF+XML
							   @try {
								   [parser parseString:rdf intoModel:model withBaseURI:uri];
							   }
							   @catch (NSException *exception) {
								   NSString *errMessage = [NSString stringWithFormat:@"Failed to parse RDF: %@", [exception reason]];
								   NSError *err = nil;
								   ERR(&err, errMessage, 0)
								   NSMutableDictionary *usrInf = [userInfo mutableCopy];
								   [usrInf setObject:err forKey:SMARTErrorKey];
								   SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, NO, usrInf)
								   return;
							   }
							   
							   // get the desired sub-models
							   RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#type"];
							   RedlandNode *object = [RedlandNode nodeWithURIString:[aClass rdfType]];
							   RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:object];
							   RedlandStreamEnumerator *query = [model enumeratorOfStatementsLike:statement];
							   
							   // create our objects wrapping those sub-models
							   NSMutableArray *array = [NSMutableArray array];
							   RedlandStatement *rslt = nil;
							   while ((rslt = [query nextObject])) {
								   id item = [aClass newWithSubject:rslt.subject inModel:model];
								   if (item) {
									   [array addObject:item];
								   }
							   }
							   
							   // complete the user-info dictionary and call the callback
							   NSMutableDictionary *usrInf = [userInfo mutableCopy];
							   [usrInf setObject:array forKey:SMARTResponseArrayKey];
							   SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, YES, usrInf)
							   return;
						   }
						   else {
							   DLog(@"Response is empty for GET call to %@", aPath);
						   }
					   }
					   
					   // An image might also have been returned, decode it as well
					   else if ([@"image/jpeg" isEqualToString:contentType] || [@"image/png" isEqualToString:contentType]) {
						   NSData *imageData = [userInfo objectForKey:SMARTResponseDataKey];
						   UIImage *image = [UIImage imageWithData:imageData];
						   if (image) {
							   
							   // got an image, complete the user-info dictionary and call the callback
							   NSMutableDictionary *usrInf = [userInfo mutableCopy];
							   [usrInf setObject:image forKey:SMARTResponseImageKey];
							   SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, YES, usrInf)
							   return;
						   }
						   else {
							   DLog(@"Failed to decode image with Content-Type \"%@\"", contentType);
						   }
					   }
					   
					   else {
						   DLog(@"Only content with Content-Type \"application/rdf+xml\" (and some images) will be automatically parsed. The response came back as \"%@\"", contentType);
					   }
				   }
				   
				   SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, success, userInfo)
			   }];
}

/**
 *  Performs a POST request to the given path, posting the data as body data.
 *  @param bodyString The string data to post as body data
 *  @param contentType The Content-Type to use
 *  @param path The REST method path to post to
 *  @param callback A SMSuccessRetvalueBlock callback to execute when the request is done
 */
- (void)postBodyString:(NSString *)bodyString ofType:(NSString *)contentType to:(NSString *)path callback:(SMSuccessRetvalueBlock)callback
{
	if ([bodyString length] < 1) {
		SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(callback, @"Need body data to perform a POST request but got none", 1200)
		return;
	}
	
	[self performMethod:path
			   withBody:bodyString
		   orParameters:nil
				 ofType:contentType
			 httpMethod:@"POST"
			   callback:callback];
}


/**
 *  The basic method to perform REST methods on the server with App credentials.
 *
 *  All convenience methods invoke this method. It uses a SMServerCall instance to handle the loading; SMServerCall only allows a body string or parameters,
 *  but not both, with the body string taking precedence if both are present.
 *  @param aMethod The path to call on the server
 *  @param body The body data, has to be either NSData or NSString
 *  @param parameters An array full of strings in the form "key=value"
 *  @param contentType The optional contentType of the data for PUT or POST
 *  @param httpMethod The http method, for now GET, PUT or POST
 *  @param callback A block to execute when the call has finished
 */
- (void)performMethod:(NSString *)aMethod withBody:(id)body orParameters:(NSArray *)parameters ofType:(NSString *)contentType httpMethod:(NSString *)httpMethod callback:(SMSuccessRetvalueBlock)callback
{
	if (!_server) {
		NSString *errStr = [NSString stringWithFormat:@"Fatal Error: I have no server! %@", self];
		SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(callback, errStr, 2000)
		return;
	}
	
	// create the desired SMServerCall instance
	SMServerCall *call = [SMServerCall new];
	call.method = aMethod;
	call.body = [body isKindOfClass:[NSString class]] ? body : nil;
	call.bodyData = [body isKindOfClass:[NSData class]] ? body : nil;
	call.parameters = parameters;
	call.contentType = contentType;
	call.HTTPMethod = httpMethod;
	call.myCallback = callback;
	
	// let the server do the work
	[_server performCall:call];
}



#pragma mark - KVC
- (NSString *)name
{
	if (!_name) {
		NSMutableArray *names = [NSMutableArray arrayWithCapacity:2];
		NSString *givenName = _demographics.n.givenName;
		NSString *familyName = _demographics.n.familyName;
		if ([givenName length] > 0) {
			[names addObject:givenName];
		}
		if ([familyName length] > 0) {
			[names addObject:familyName];
		}
		
		if ([names count] > 0) {
			self.name = [names componentsJoinedByString:@" "];
		}
		else {
			self.name = @"Anonymous";
		}
	}
	return _name;
}

- (void)setScratchpad:(SMScratchpadData *)scratchpad
{
	if (scratchpad != _scratchpad) {
		_scratchpad = scratchpad;
		_scratchpad.record = self;
	}
}



#pragma mark - Utilities
/**
 *  Shortcut method to test if the document has the given ID
 *  @param anId The id to test
 */
- (BOOL)is:(NSString *)anId
{
	return [self.record_id isEqualToString:anId];
}


@end
