/*
 SMObject.m
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

#import "SMObject.h"

#import <RedlandParser.h>
#import <RedlandURI.h>


@interface SMObject ()

@property (nonatomic, readwrite, strong) RedlandModel *model;

@end


@implementation SMObject


+ (id)newWithModel:(RedlandModel *)aModel
{
	return [[self alloc] initWithModel:aModel];
}

+ (id)newWithRDFXML:(NSString *)rdfString;
{
	return [[self alloc] initWithRDFXML:rdfString];
}


/**
 *  @return An instance wrapping the given RDF model
 */
- (id)initWithModel:(RedlandModel *)aModel
{
	if ((self = [super init])) {
		self.model = aModel;
	}
	return self;
}

/**
 *  @return An instance containing a model initialized from the given RDF+XML string
 */
- (id)initWithRDFXML:(NSString *)rdfString
{
	if ((self = [super init])) {
		if ([rdfString length] > 0) {
			RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
			RedlandURI *uri = [RedlandURI URIWithString:@"http://www.smartplatforms.org/terms#"];
			self.model = [RedlandModel new];
			
			// parse
			@try {
				[parser parseString:rdfString intoModel:_model withBaseURI:uri];
			}
			@catch (NSException *exception) {
				DLog(@"Failed to parse RDF: %@", [exception reason]);
				return nil;
			}
		}
	}
	return self;
}


@end
