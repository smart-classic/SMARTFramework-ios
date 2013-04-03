/*
 TestServerCalls.m
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

#import "TestServerCalls.h"
#import "SMMockServer.h"
#import "SMRecord+Calls.h"
#import "SMARTObjects.h"
#import <Redland-ObjC.h>

@implementation TestServerCalls


- (void)setUp
{
	self.server = [SMMockServer serverWithDelegate:nil];
	self.record = [_server activeRecord];
}

- (void)tearDown
{
	self.server = nil;
}


/**
 *  Test Allergies
 */
- (void)testAllergy
{
	[_record getAllergies:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		NSArray *response = [userInfo objectForKey:SMARTResponseArrayKey];
		STAssertTrue(2 == [response count], @"Should have gotten 2 allergies, but got %d", [response count]);
		
		SMAllergy *allergy1 = [response objectAtIndex:0];
		STAssertEqualObjects(@"Anaphylaxis", allergy1.allergicReaction.title, @"allergicReaction.title");
		
		STAssertTrue([allergy1.rdfTypes containsObject:[RedlandNode nodeWithURIString:allergy1.rdfType]], @"The main type has to be in the rdfTypes array, meaning %@ must be in %@", allergy1.rdfType, allergy1.rdfTypes);
	}];
}


@end
