/*
 SMObject.h
 SMARTFramework
 
 Created by Pascal Pfiffner on 8/15/12.
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
@class RedlandModel;


/**
 *  An abstract base class for objects being represented in an RDF graph
 */
@interface SMObject : NSObject

@property (nonatomic, readonly, strong) RedlandModel *model;			///< The redland model represented by this object

+ (id)newWithModel:(RedlandModel *)aModel;
+ (id)newWithRDFXML:(NSString *)rdfString;

- (id)initWithModel:(RedlandModel *)aModel;
- (id)initWithRDFXML:(NSString *)rdfString;


@end
