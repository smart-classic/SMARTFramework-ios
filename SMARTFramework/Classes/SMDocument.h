/*
 SMDocument.h
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

#import <Foundation/Foundation.h>
#import "SMART.h"

@class SMRecord;


/**
 *	The base class for all our documents
 */
@interface SMDocument : NSObject

@property (nonatomic, copy) NSString *uuid;				///< This document's ID on the server
@property (nonatomic, weak) SMRecord *record;			///< The record this document belongs to

// performing server calls
- (void)get:(NSString *)aMethod callback:(INSuccessRetvalueBlock)callback;
- (void)get:(NSString *)aMethod parameters:(NSArray *)paramArray callback:(INSuccessRetvalueBlock)callback;

- (void)performMethod:(NSString *)aMethod withBody:(NSString *)body orParameters:(NSArray *)parameters httpMethod:(NSString *)httpMethod callback:(INSuccessRetvalueBlock)callback;


@end
