/*
 SMDemographics.m
 SMARTFramework
 
 Created by Pascal Pfiffner on 8/10/12.
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


#import "SMDemographics.h"
#import "SMARTDocuments.h"

#import <RedlandModel-Convenience.h>
#import <RedlandNode-Convenience.h>
#import <RedlandStatement.h>
#import <RedlandStreamEnumerator.h>


@implementation SMDemographics


#pragma mark - Names
- (SMName *)n
{
	if (!_n) {
		
		// get the "n" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#n"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the name statements
		RedlandModel *nameModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *nameStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *nameStream = [self.model enumeratorOfStatementsLike:nameStmt];
		
		// add statements to name model
		@try {
			for (RedlandStatement *stmt in nameStream) {
				[nameModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@\n%@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.n = [SMName newWithModel:nameModel];
	}
	return _n;
}


@end
