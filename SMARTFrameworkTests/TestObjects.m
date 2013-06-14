/*
 TestObjects.m
 SMARTFramework

 Created by Pascal Pfiffner on 6/13/13.
 
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

#import "TestObjects.h"
#import "SMRecord+Calls.h"
#import "SMARTObjects.h"
#import <Redland-ObjC.h>

@implementation TestObjects


/**
 *  Test Object RDF Handling
 */
- (void)testModelHandling
{
	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SMAllergy" withExtension:@"rdf"];
	STAssertNotNil(url, nil);
	NSString *rdfxml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	STAssertNotNil(rdfxml, nil);
	SMAllergy *allerg = [SMAllergy newWithRDFXML:rdfxml];
	STAssertNotNil(allerg, nil);
	STAssertNotNil(allerg.inModel, nil);
	
	// test submodels
	SMCodedValue *reaction = allerg.allergicReaction;
	STAssertNotNil(reaction, nil);
	RedlandModel *submodel = reaction.model;
	STAssertNotNil(submodel, nil);
	int subsize = [submodel size];
	STAssertTrue(subsize > 0, nil);
	int before = [allerg.model size];
	STAssertTrue(subsize < before, nil);
	STAssertTrue([allerg.model removeSubmodel:submodel], nil);
	int after = [allerg.model size];
	STAssertTrue(after > 0, nil);
	STAssertTrue(before > after, nil);
	STAssertEquals(before - after, subsize, nil);
	NSLog(@"Model: %d, after: %d, sub: %d", before, after, subsize);
}

/**
 *  Test object creation
 */
- (void)testCreation
{
	SMRecord *record = [SMRecord new];
	SMClinicalNote *note = [SMClinicalNote newForRecord:record];
	note.title = @"THIS IS DA TITLE";
	note.date = @"2013-06-14";
	STAssertEquals(3, [note.model size], nil);
//	NSLog(@"--  1  -- (%d)\n%@", [note.model size], [note rdfXMLRepresentation]);
	
	SMResource *resource = [SMResource new];
	resource.location = @"http://www.chip.org/files/abc.data";
	note.resource = @[resource];
	STAssertEquals(5, [note.model size], nil);
//	NSLog(@"--  2  -- (%d)\n%@", [note.model size], [note rdfXMLRepresentation]);
	
	note.resource = nil;
	STAssertEquals(3, [note.model size], nil);
//	NSLog(@"--  3  -- (%d)\n%@", [note.model size], [note rdfXMLRepresentation]);
}


@end
