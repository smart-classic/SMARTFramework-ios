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
#import <Redland-ObjC.h>


@interface SMObject () {
	BOOL initializedAsTopModel;
}

@property (nonatomic, readwrite, strong) RedlandNode *subject;
@property (nonatomic, readwrite, strong) RedlandModel *inModel;

@end


@implementation SMObject


/**
 *  Convenience allocator.
 */
+ (id)newWithSubject:(RedlandNode *)aSubject inModel:(RedlandModel *)aModel
{
	return [[self alloc] initWithSubject:aSubject inModel:aModel];
}

/**
 *  Convenience allocator when allocating from RDF+XML.
 *  @attention Note that if RDF+XML parsing fails, this method will return nil (i.e. it will catch the exception thrown in "initWithRDFXML:").
 */
+ (id)newWithRDFXML:(NSString *)rdfString;
{
	id obj = nil;
	@try {
		obj = [[self alloc] initWithRDFXML:rdfString];
	}
	@catch (NSException *exception) {
		DLog(@"Failed to parse RDF: %@", [exception reason]);
	}
	
	return obj;
}


/**
 *  Designated initializer.
 *
 *  An object is defined by anchoring to a subject in a model. This means a subject is needed if you want to be sure to get correct data from the model, and
 *  for this reason the initializer requires a subject or will return nil.
 *  @warning Will return nil if there is no subject.
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
		self.inModel = aModel;
	}
	return self;
}

/**
 *  Method to initialize an instance from an RDF+XML string
 *  @warning This method will raise an exception on invalid RDF+XML
 *  @param rdfString An RDF+XML string that should be parsed
 *  @return An instance containing a model initialized from the given RDF+XML string
 */
- (id)initWithRDFXML:(NSString *)rdfString
{
	if ((self = [super init])) {
		if ([rdfString length] > 0) {
			RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
			RedlandURI *uri = [RedlandURI URIWithString:@"http://www.smartplatforms.org/terms#"];
			self.inModel = [RedlandModel new];
			
			// parse (will raise on invalid input!)
			[parser parseString:rdfString intoModel:_inModel withBaseURI:uri];
			initializedAsTopModel = YES;
		}
	}
	return self;
}

/**
 *  To catch all "new" and "init" calls, we are going to forward to our designated initializer "initWithSubject:inModel:".
 */
- (id)init
{
	RedlandNode *blank = [RedlandNode nodeWithBlankID:nil];
	RedlandModel *model = [RedlandModel new];
	
	return [self initWithSubject:blank inModel:model];
}



#pragma mark - Model
/**
 *  Retrieve the submodel if the receiver is part of a model, the whole model if it has been initialized from RDF+XML as top-level model.
 */
- (RedlandModel *)model
{
	if (initializedAsTopModel) {
		return _inModel;
	}
	
	return [_inModel submodelForSubject:_subject];
}



#pragma mark - RDF Properties
/**
 *  The rdf:type getter for this class gets the class-wide type if it is not specifically set for this instance.
 *
 *  There is no need to specifically set the rdf-type for a single instance as the instance should always represent the same type of objects, but it is still
 *  possible.
 *
 *  **Note** that in RDF, things can be more than one type. The type retrieved here is the type that has been used to determine the class to be used for the
 *  receiver, and most of the time this will be the only type anyway. Use rdfTypes to get all types an object has.
 */
- (NSString *)rdfType
{
	if (!_rdfType) {
		self.rdfType = [[self class] rdfType];
	}
	return _rdfType	;
}

/**
 *  The standard rdf:type represented by instances of this class.
 */
+ (NSString *)rdfType
{
	return nil;
}

/**
 *  All the types (as RedlandNode objects) that apply to the receiver.
 */
- (NSArray *)rdfTypes
{
	if (!_rdfTypes) {
		RedlandNode *predicate = [RedlandNode typeNode];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:_subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [_inModel enumeratorOfStatementsLike:statement];
		
		// loop through the results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			if (rslt.object) {
				[arr addObject:rslt.object];
			}
		}
		self.rdfTypes = arr;
	}
	return _rdfTypes;
}


@end
