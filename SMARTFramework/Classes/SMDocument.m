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


@implementation SMDocument


#pragma mark - Handling Instances
/**
 *  Performs a GET for the receiver against the server.
 *
 *  The method determines the REST path describing the receiver and passes that path as first parameter to our "get:callback:" method.
 *  @param callback An INCancelErrorBlock to be called when the operation finishes
 */
- (void)get:(INCancelErrorBlock)callback
{
	NSString *basePath = [self basePath];
	if (!basePath) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, @"I don't have a basePath, cannot GET the object. Does it have a record and a uuid?")
		return;
	}
	
	[self get:basePath callback:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		NSError *anError = [userInfo objectForKey:INErrorKey];
		CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO(callback, (!success && !anError), userInfo)
	}];
}



#pragma mark - Data Fetching
/**
 *  The basic method to perform REST methods on the server with App credentials.
 *
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
 *  Shortcut for GETting data.
 *
 *  Calls "performMethod:withBody:orParameters:httpMethod:callback:" internally.
 *  @param aMethod The method to perform, e.g. "/records/id/documents/"
 *  @param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod callback:(INSuccessRetvalueBlock)callback
{
	[self performMethod:aMethod withBody:nil orParameters:nil httpMethod:@"GET" callback:callback];
}

/**
 *  Shortcut for GETting data with parameters.
 *
 *  Calls "performMethod:withBody:orParameters:httpMethod:callback:" internally.
 *  @param aMethod The method to perform, e.g. "/records/id/documents/"
 *  @param paramArray An array of NSString parameters in the form @"key=value"; will be URL-encoded automatically
 *  @param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod parameters:(NSArray *)paramArray callback:(INSuccessRetvalueBlock)callback
{
	[self performMethod:aMethod withBody:nil orParameters:paramArray httpMethod:@"GET" callback:callback];
}



#pragma mark - Server Path
/**
 *  Uses the class basePath and substitutes the placeholders with instance properties by default.
 *
 *  TODO: Use a nice text substitution method
 */
- (NSString *)basePath
{
	if (!_basePath && _record.record_id && _uuid) {
		NSString *foo = [[isa basePath] stringByReplacingOccurrencesOfString:@"{record_id}" withString:_record.record_id];
		self.basePath = [foo stringByReplacingOccurrencesOfString:@"{uuid}" withString:_uuid];
	}
	return _basePath;
}

/**
 *  Path template for instances of this class.
 *
 *  Subclasses must override this method, supported placeholders are:
 *
 *  - {record_id}
 *  - {uuid}
 */
+ (NSString *)basePath
{
	return nil;
}


@end
