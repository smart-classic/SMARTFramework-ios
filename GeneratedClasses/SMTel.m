/*
 SMTel.m
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2013-02-20.
 Copyright (c) 2013 CHIP, Boston Children's Hospital
 
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

#import "SMTel.h"
#import "SMARTObjects.h"

#import <Redland-ObjC.h>


@implementation SMTel


#pragma mark - Synthesized Lazy Getter
- (NSString *)value
{
	if (!_value) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#value"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.value = [rslt.object literalValue];
	}
	return _value;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://www.w3.org/2006/vcard/ns#Tel";
}




@end