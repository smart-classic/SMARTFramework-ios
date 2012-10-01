/*
 SMQuantitativeResult.m
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

#import "SMQuantitativeResult.h"
#import "SMARTObjects.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMQuantitativeResult


#pragma mark - Synthesized Lazy Getter
- (SMValueRange *)nonCriticalRange
{
	if (!_nonCriticalRange) {
		
		// get the "nonCriticalRange" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#nonCriticalRange"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.nonCriticalRange = [SMValueRange newWithSubject:rslt.object inModel:self.model];
	}
	return _nonCriticalRange;
}

- (SMValueRange *)normalRange
{
	if (!_normalRange) {
		
		// get the "normalRange" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#normalRange"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.normalRange = [SMValueRange newWithSubject:rslt.object inModel:self.model];
	}
	return _normalRange;
}

- (SMValueAndUnit *)valueAndUnit
{
	if (!_valueAndUnit) {
		
		// get the "valueAndUnit" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#valueAndUnit"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.valueAndUnit = [SMValueAndUnit newWithSubject:rslt.object inModel:self.model];
	}
	return _valueAndUnit;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://smartplatforms.org/terms#QuantitativeResult";
}




@end
