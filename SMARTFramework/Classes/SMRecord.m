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

@implementation SMRecord

@synthesize uuid = _uuid;
@synthesize accessToken = _accessToken, accessTokenSecret = _accessTokenSecret;

#pragma mark -

/**
 *	Initializes a record from given parameters
 */
- (id)initWithId:(NSString *)anId onServer:(SMServer *)aServer
{
	if ((self = [super init])) {
		self.uuid = anId;
	}
	return self;
}



#pragma mark - Fetching
- (void)fetchRecordInfoWithCallback:(INCancelErrorBlock)callback
{
	CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, YES, @"Not implemented");
}



#pragma mark - Utilities
/**
 *	Shortcut method to test if the document has the given ID
 */
- (BOOL)is:(NSString *)anId
{
	return [self.uuid isEqualToString:anId];
}


@end
