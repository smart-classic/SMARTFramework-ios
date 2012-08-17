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
#import "SMARTDocuments.h"


@interface SMRecord ()

@property (nonatomic, readwrite, strong) SMDemographics *demographics;

@end


@implementation SMRecord


#pragma mark -

/**
 *  Initializes a record from given parameters
 */
- (id)initWithId:(NSString *)anId onServer:(SMServer *)aServer
{
	if ((self = [super init])) {
		self.record_id = anId;
		self.server = aServer;
	}
	return self;
}



#pragma mark - Fetching
/**
 *  Fetches the record's demographics document from /records/{record_id}/demographics
 *  @param callback The block to be executed after the call returns from the server
 */
- (void)fetchRecordInfoWithCallback:(INCancelErrorBlock)callback
{
	self.name = nil;			// to clear the composed name
	
	NSString *demoPath = [NSString stringWithFormat:@"/records/%@/demographics", _record_id];
	[self performMethod:demoPath withBody:nil orParameters:nil httpMethod:@"GET" callback:^(BOOL success, NSDictionary *userInfo) {
		NSString *errorMessage = nil;
		
		// error?
		if (!success) {
			errorMessage = [[userInfo objectForKey:INErrorKey] localizedDescription];
			if ([errorMessage length] < 1) {
				errorMessage = @"An unknown error happened when fetching this record's demographics document";
			}
		}
		
		// success, create a demographics document
		else {
			NSString *rdf = [userInfo objectForKey:INResponseStringKey];
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
 *  The basic method to perform REST methods on the server with App credentials.
 *  Uses a INServerCall instance to handle the loading; INServerCall only allows a body string or parameters, but not both, with
 *  the body string taking precedence.
 *  @param aMethod The path to call on the server
 *  @param body The body string
 *  @param parameters An array full of strings in the form "key=value"
 *  @param httpMethod The http method, for now GET, PUT or POST
 *  @param callback A block to execute when the call has finished
 */
- (void)performMethod:(NSString *)aMethod withBody:(NSString *)body orParameters:(NSArray *)parameters httpMethod:(NSString *)httpMethod callback:(INSuccessRetvalueBlock)callback
{
	if (!_server) {
		NSString *errStr = [NSString stringWithFormat:@"Fatal Error: I have no server! %@", self];
		SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(callback, errStr, 2000)
		return;
	}
	
	// create the desired INServerCall instance
	INServerCall *call = [INServerCall new];
	call.method = aMethod;
	call.body = body;
	call.parameters = parameters;
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



#pragma mark - Utilities
/**
 *  Shortcut method to test if the document has the given ID
 */
- (BOOL)is:(NSString *)anId
{
	return [self.record_id isEqualToString:anId];
}


@end