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
#import "SMServerCall.h"


@implementation SMBaseDocument


#pragma mark - Data Fetching
/**
 *  Performs a GET for the receiver against the server.
 *
 *  The method determines the REST path describing the receiver and passes that path as first parameter to our "get:callback:" method.
 *  @param callback An SMCancelErrorBlock to be called when the operation finishes
 */
- (void)get:(SMCancelErrorBlock)callback
{
	NSString *basePath = [self basePath];
	if (!basePath) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, @"I don't have a basePath, cannot GET the object. Does it have a record and a uuid?")
		return;
	}
	
	[self get:basePath callback:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		NSError *anError = [userInfo objectForKey:SMARTErrorKey];
		CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO(callback, (!success && !anError), userInfo)
	}];
}

/**
 *  Shortcut for GETting data.
 *
 *  Calls "performMethod:withBody:orParameters:ofType:httpMethod:callback:" internally.
 *  @param aMethod The method to perform, e.g. "/records/id/documents/"
 *  @param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod callback:(SMSuccessRetvalueBlock)callback
{
	if (!_record) {
		NSString *errStr = [NSString stringWithFormat:@"Fatal Error: I have no record! %@", self];
		SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(callback, errStr, 2100)
		return;
	}
	
	[_record performMethod:aMethod withBody:nil orParameters:nil ofType:nil httpMethod:@"GET" callback:callback];
}

/**
 *  Shortcut for GETting data with parameters.
 *
 *  Calls "performMethod:withBody:orParameters:ofType:httpMethod:callback:" internally.
 *  @param aMethod The method to perform, e.g. "/records/id/documents/"
 *  @param paramArray An array of NSString parameters in the form @"key=value"; will be URL-encoded automatically
 *  @param callback The callback block to execute when the call has finished
 */
- (void)get:(NSString *)aMethod parameters:(NSArray *)paramArray callback:(SMSuccessRetvalueBlock)callback
{
	if (!_record) {
		NSString *errStr = [NSString stringWithFormat:@"Fatal Error: I have no record! %@", self];
		SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(callback, errStr, 2100)
		return;
	}
	
	[_record performMethod:aMethod withBody:nil orParameters:paramArray ofType:nil httpMethod:@"GET" callback:callback];
}



#pragma mark - Server Path
/**
 *  Uses the class basePath and substitutes the placeholders with instance properties by default.
 *
 *  TODO: Use a nice text substitution method
 */
- (NSString *)basePath
{
	if (!_basePath) {
		NSString *base = [[self class] basePath];
		if (_record.server.appId) {
			base = [base stringByReplacingOccurrencesOfString:@"{smart_app_id}" withString:_record.server.appId];
		}
		if (_record.record_id) {
			base = [base stringByReplacingOccurrencesOfString:@"{record_id}" withString:_record.record_id];
		}
		if (_uuid) {
			base = [base stringByReplacingOccurrencesOfString:@"{uuid}" withString:_uuid];
		}
		self.basePath = base;
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
