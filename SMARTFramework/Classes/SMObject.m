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

@property (nonatomic, readwrite, strong) RedlandNode *subject;
@property (nonatomic, readwrite, strong) RedlandModel *model;

@end


@implementation SMObject


+ (id)newWithSubject:(RedlandNode *)aSubject inModel:(RedlandModel *)aModel
{
	return [[self alloc] initWithSubject:aSubject inModel:aModel];
}

+ (id)newWithRDFXML:(NSString *)rdfString;
{
	return [[self alloc] initWithRDFXML:rdfString];
}


/**
 *  Designated initializer.
 *
 *  An object is defined by anchoring to a subject in a model. This means a subject is needed if you want to be sure to get correct data from the model, and
 *  for this reason the initializer requires a subject or will return nil.
 *  @attention Will return nil if there is no subject.
 *  @param aSubject The node that represents the subject being wrapped by this class, can not be nil!
 *  @param aModel The complete model from which to pull properties for the instance
 *  @return An instance wrapping the given RDF model
 */
- (id)initWithSubject:(RedlandNode *)aSubject inModel:(RedlandModel *)aModel
{
	if (!aSubject) {
		return nil;
	}
	
	if ((self = [super init])) {
		self.subject = aSubject;
		self.model = aModel;
	}
	return self;
}

/**
 *  Method to initialize an instance from an RDF+XML string
 *  @param rdfString An RDF+XML string that should be parsed
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



#pragma mark - RDF Properties
/**
 *  The rdf:type getter for this class gets the class-wide type if it is not specifically set for this instance; there is no need to specifically set the rdf-
 *  type for a single instance as the instance should always represent the same type of objects, but it is still possible.
 */
- (NSString *)rdfType
{
	if (!_rdfType) {
		self.rdfType = [[self class] rdfType];
	}
	return _rdfType	;
}

/**
 *  The standard rdf:type represented by instances of this class
 */
+ (NSString *)rdfType
{
	return nil;
}


@end
