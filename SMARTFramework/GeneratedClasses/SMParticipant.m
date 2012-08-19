/*
 SMParticipant.m
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2012-08-18.
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

#import "SMParticipant.h"
#import "SMARTDocuments.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMParticipant


#pragma mark - Synthesized Lazy Getter
- (SMPerson *)person
{
	if (!_person) {
		
		// get the "person" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#person"];
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
		
		self.person = [SMPerson newWithModel:newModel];
	}
	return _person;
}

- (SMOrganization *)organization
{
	if (!_organization) {
		
		// get the "organization" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#organization"];
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
		
		self.organization = [SMOrganization newWithModel:newModel];
	}
	return _organization;
}

- (NSString *)role
{
	if (!_role) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#role"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.role = [rslt.object literalValue];
	}
	return _role;
}


@end