/*
 SMMediaTypeOrExtent.m
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

#import "SMMediaTypeOrExtent.h"
#import "SMARTObjects.h"

#import <Redland-ObjC.h>


@implementation SMMediaTypeOrExtent


#pragma mark - Synthesized Lazy Getter
- (NSString *)label
{
	if (!_label) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2000/01/rdf-schema#label"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.label = [rslt.object literalValue];
	}
	return _label;
}



#pragma mark - Class Properties
+ (NSString *)rdfType
{
	return @"http://purl.org/dc/terms/MediaTypeOrExtent";
}




@end
