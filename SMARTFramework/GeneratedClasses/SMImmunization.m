/*
 SMImmunization.m
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2012-10-17.
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

#import "SMImmunization.h"
#import "SMARTObjects.h"

#import <Redland-ObjC.h>


@implementation SMImmunization


#pragma mark - Synthesized Lazy Getter
- (SMCodedValue *)administrationStatus
{
	if (!_administrationStatus) {
		
		// get the "administrationStatus" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#administrationStatus"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.administrationStatus = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _administrationStatus;
}

- (SMMedicalRecord *)belongsTo
{
	if (!_belongsTo) {
		
		// get the "belongsTo" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#belongsTo"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.belongsTo = [SMMedicalRecord newWithSubject:rslt.object inModel:self.model];
	}
	return _belongsTo;
}

- (NSString *)date
{
	if (!_date) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://purl.org/dc/terms/date"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.date = [rslt.object literalValue];
	}
	return _date;
}

- (NSArray *)productClass
{
	if (!_productClass) {
		
		// get the "productClass" elements
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#productClass"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop through the results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			
			// instantiate an item for each object
			SMCodedValue *newItem = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.productClass = arr;
	}
	return _productClass;
}

- (SMCodedValue *)productName
{
	if (!_productName) {
		
		// get the "productName" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#productName"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.productName = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _productName;
}

- (SMCodedValue *)refusalReason
{
	if (!_refusalReason) {
		
		// get the "refusalReason" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#refusalReason"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.refusalReason = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _refusalReason;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://smartplatforms.org/terms#Immunization";
}

+ (NSString *)basePath
{
	return @"/records/{record_id}/immunizations/{uuid}";
}


@end
