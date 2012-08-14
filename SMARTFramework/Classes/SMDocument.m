/*
 SMDocument.m
 SMARTFramework
 
 Created by Pascal Pfiffner on 8/10/12.
 Copyright (c) 2012 CHIP, Boston Children's Hospital. All rights reserved.
 
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

#import "SMDocument.h"
#import "SMART.h"
#import "SMServer.h"
#import "SMRecord.h"
#import "INServerCall.h"

#import <RedlandParser.h>
#import <RedlandURI.h>


@interface SMDocument ()

@property (nonatomic, readwrite, strong) RedlandModel *model;

@end


@implementation SMDocument


+ (id)newWithRDF:(NSString *)rdfString;
{
	return [[self alloc] initWithRDF:rdfString];
}

/**
 *	@return An instance containing a model initialized from the given RDF+XML string
 */
- (id)initWithRDF:(NSString *)rdfString
{
	if ((self = [super init])) {
		if ([rdfString length] > 0) {
			RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
			RedlandURI *uri = [RedlandURI URIWithString:@"http://www.smartplatforms.org/terms#"];
			self.model = [RedlandModel new];
			
			// parse
			@try {
				[parser parseString:rdfString intoModel:_model withBaseURI:uri];
			}
			@catch (NSException *exception) {
				DLog(@"Failed to parse RDF: %@", [exception reason]);
				return nil;
			}
		}
	}
	return self;
}



#pragma mark - Data Fetching
/**
 *	The basic method to perform REST methods on the server with App credentials.
 *	Uses a INServerCall instance to handle the loading; INServerCall only allows a body string or parameters, but not both, with
 *	the body string taking precedence.
 *	@param aMethod The path to call on the server
 *	@param body The body string
 *	@param parameters An array full of strings in the form "key=value"
 *	@param httpMethod The http method, for now GET, PUT or POST
 *	@param callback A block to execute when the call has finished
 */
- (void)performMethod:(NSString *)aMethod withBody:(NSString *)body orParameters:(NSArray *)parameters httpMethod:(NSString *)httpMethod callback:(INSuccessRetvalueBlock)callback
{
	if (!_record.server) {
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
	[_record.server performCall:call];
}


/**
 *	Shortcut for GETting data.
 *	Calls "performMethod:withBody:orParameters:httpMethod:callback:" internally.
 *	@param aMethod The method to perform, e.g. "/records/id/documents/"
 *	@param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod callback:(INSuccessRetvalueBlock)callback
{
	[self performMethod:aMethod withBody:nil orParameters:nil httpMethod:@"GET" callback:callback];
}

/**
 *	Shortcut for GETting data with parameters.
 *	Calls "performMethod:withBody:orParameters:httpMethod:callback:" internally.
 *	@param aMethod The method to perform, e.g. "/records/id/documents/"
 *	@param paramArray An array of NSString parameters in the form @"key=value"; will be URL-encoded automatically
 *	@param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod parameters:(NSArray *)paramArray callback:(INSuccessRetvalueBlock)callback
{
	[self performMethod:aMethod withBody:nil orParameters:paramArray httpMethod:@"GET" callback:callback];
}


@end
