/*
 SMName.m
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2012-10-01.
 Copyright (c) 2012 CHIP, Boston Children's Hospital
 
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

#import "SMName.h"
#import "SMARTObjects.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMName


#pragma mark - Synthesized Lazy Getter
- (NSArray *)additionalName
{
	if (!_additionalName) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#additional-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			NSString *newItem = [rslt.object literalValue];		// only works for NSString for now
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.additionalName = arr;
	}
	return _additionalName;
}

- (NSString *)familyName
{
	if (!_familyName) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#family-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.familyName = [rslt.object literalValue];
	}
	return _familyName;
}

- (NSString *)givenName
{
	if (!_givenName) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#given-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.givenName = [rslt.object literalValue];
	}
	return _givenName;
}

- (NSArray *)honorificPrefix
{
	if (!_honorificPrefix) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#honorific-prefix"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			NSString *newItem = [rslt.object literalValue];		// only works for NSString for now
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.honorificPrefix = arr;
	}
	return _honorificPrefix;
}

- (NSArray *)honorificSuffix
{
	if (!_honorificSuffix) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#honorific-suffix"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			NSString *newItem = [rslt.object literalValue];		// only works for NSString for now
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.honorificSuffix = arr;
	}
	return _honorificSuffix;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://www.w3.org/2006/vcard/ns#Name";
}




@end
