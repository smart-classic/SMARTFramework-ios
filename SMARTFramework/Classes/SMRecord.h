/*
 SMRecord.h
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

#import <Foundation/Foundation.h>
#import "SMART.h"

@class SMServer;
@class SMDemographics;
@class SMScratchpadData;


/**
 *  Represents a SMART record on a SMART server
 */
@interface SMRecord : NSObject

/// The record id
@property (nonatomic, copy) NSString *record_id;

/// The server this record lives on
@property (nonatomic, weak) SMServer *server;

/// The OAuth token tied to this record and its server
@property (nonatomic, copy) NSString *accessToken;

/// The OAuth secret
@property (nonatomic, copy) NSString *accessTokenSecret;

/// The demographics document for this record
@property (nonatomic, readonly, strong) SMDemographics *demographics;

/// Composed name from givenName and familyName, taken from the demographics document
@property (nonatomic, copy) NSString *name;

/// The scratchpad document for this record - to get the data you will need to call "get:" on this first!
@property (nonatomic, readonly, strong) SMScratchpadData *scratchpad;


- (id)initWithId:(NSString *)anId onServer:(SMServer *)aServer;

// data fetching
- (void)getDemographicsWithCallback:(SMCancelErrorBlock)callback;
- (void)getObjectsOfClass:(Class)aClass from:(NSString *)aPath callback:(SMSuccessRetvalueBlock)callback;
- (void)performMethod:(NSString *)aMethod withBody:(NSString *)body orParameters:(NSArray *)parameters ofType:(NSString *)contentType httpMethod:(NSString *)httpMethod callback:(SMSuccessRetvalueBlock)callback;

// utilities
- (BOOL)is:(NSString *)anId;


@end
