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

#import "SMObject.h"


/**
 *  The base class for all SMART server documents.
 *
 *  This class implements the basics for URL requests, which are all funnelled via SMRecord 's performMethod:withBody:orParameters:ofType:httpMethod:callback:
 *  method.
 */
@interface SMBaseDocument : SMObject

/// This document's ID on the server
@property (nonatomic, copy) NSString *uuid;

/// The record this document belongs to
@property (nonatomic, weak) SMRecord *record;

/// Uses the class basePath and substitutes the placeholders with instance properties by default
@property (nonatomic, copy) NSString *basePath;

// Creating a new document
+ (id)newForRecord:(SMRecord *)aRecord;

// Serialization
- (NSString *)rdfXMLRepresentation;
- (NSData *)rdfXMLData;

// Performing server calls
- (void)get:(SMCancelErrorBlock)callback;
- (void)get:(NSString *)aMethod callback:(SMSuccessRetvalueBlock)callback;
- (void)get:(NSString *)aMethod parameters:(NSArray *)paramArray callback:(SMSuccessRetvalueBlock)callback;
- (void)post:(SMCancelErrorBlock)callback;

+ (NSString *)basePath;


@end
