/*
 SMLabResult.m
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2012-08-21.
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

#import "SMLabResult.h"
#import "SMARTObjects.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMLabResult


#pragma mark - Synthesized Lazy Getter
- (SMCodedValue *)abnormalInterpretation
{
	if (!_abnormalInterpretation) {
		
		// get the "abnormalInterpretation" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#abnormalInterpretation"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.abnormalInterpretation = [SMCodedValue newWithModel:newModel];
	}
	return _abnormalInterpretation;
}

- (SMMedicalRecord *)belongsTo
{
	if (!_belongsTo) {
		
		// get the "belongsTo" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#belongsTo"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.belongsTo = [SMMedicalRecord newWithModel:newModel];
	}
	return _belongsTo;
}

- (SMCodedValue *)labName
{
	if (!_labName) {
		
		// get the "labName" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#labName"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.labName = [SMCodedValue newWithModel:newModel];
	}
	return _labName;
}

- (SMCodedValue *)labStatus
{
	if (!_labStatus) {
		
		// get the "labStatus" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#labStatus"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.labStatus = [SMCodedValue newWithModel:newModel];
	}
	return _labStatus;
}

- (SMNarrativeResult *)narrativeResult
{
	if (!_narrativeResult) {
		
		// get the "narrativeResult" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#narrativeResult"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.narrativeResult = [SMNarrativeResult newWithModel:newModel];
	}
	return _narrativeResult;
}

- (SMQuantitativeResult *)quantitativeResult
{
	if (!_quantitativeResult) {
		
		// get the "quantitativeResult" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#quantitativeResult"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.quantitativeResult = [SMQuantitativeResult newWithModel:newModel];
	}
	return _quantitativeResult;
}

- (NSString *)accessionNumber
{
	if (!_accessionNumber) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#accessionNumber"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.accessionNumber = [rslt.object literalValue];
	}
	return _accessionNumber;
}

- (NSString *)date
{
	if (!_date) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://purl.org/dc/terms/date"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.date = [rslt.object literalValue];
	}
	return _date;
}

- (NSString *)notes
{
	if (!_notes) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#notes"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.notes = [rslt.object literalValue];
	}
	return _notes;
}

+ (NSString *)basePath
{
	return @"/records/{record_id}/lab_results/{lab_result_id}";
}


@end