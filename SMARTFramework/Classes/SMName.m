/*
 SMName.m
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

#import "SMName.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMName


- (NSString *)givenName
{
	if (!_givenName) {
		RedlandNode *subject = nil;
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#given-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.givenName = [rslt.object literalValue];
	}
	return _givenName;
}

- (NSString *)familyName
{
	if (!_familyName) {
		RedlandNode *subject = nil;
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#family-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.familyName = [rslt.object literalValue];
	}
	return _familyName;
}

- (NSString *)additionalName
{
	if (!_additionalName) {
		RedlandNode *subject = nil;
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#additional-name"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.additionalName = [rslt.object literalValue];
	}
	return _additionalName;
}


@end
