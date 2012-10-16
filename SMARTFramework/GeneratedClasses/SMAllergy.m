/*
 SMAllergy.m
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

#import "SMAllergy.h"
#import "SMARTObjects.h"

#import <Redland-ObjC.h>


@implementation SMAllergy


#pragma mark - Synthesized Lazy Getter
- (SMCodedValue *)allergicReaction
{
	if (!_allergicReaction) {
		
		// get the "allergicReaction" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#allergicReaction"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.allergicReaction = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _allergicReaction;
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

- (SMCodedValue *)category
{
	if (!_category) {
		
		// get the "category" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#category"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.category = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _category;
}

- (SMCodedValue *)drugAllergen
{
	if (!_drugAllergen) {
		
		// get the "drugAllergen" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#drugAllergen"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.drugAllergen = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _drugAllergen;
}

- (SMCodedValue *)drugClassAllergen
{
	if (!_drugClassAllergen) {
		
		// get the "drugClassAllergen" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#drugClassAllergen"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.drugClassAllergen = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _drugClassAllergen;
}

- (SMCodedValue *)otherAllergen
{
	if (!_otherAllergen) {
		
		// get the "otherAllergen" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#otherAllergen"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.otherAllergen = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _otherAllergen;
}

- (SMCodedValue *)severity
{
	if (!_severity) {
		
		// get the "severity" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#severity"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.severity = [SMCodedValue newWithSubject:rslt.object inModel:self.model];
	}
	return _severity;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://smartplatforms.org/terms#Allergy";
}

+ (NSString *)basePath
{
	return @"/records/{record_id}/allergies/{uuid}";
}


@end
