/*
 SMMockServer.m
 SMARTFramework

 Created by Pascal Pfiffner on 3/27/12.
 Copyright (c) 2012 Harvard Medical School. All rights reserved.
 
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

#import "SMMockServer.h"
#import "SMRecord.h"


@implementation SMMockServer


- (id)init
{
	if ((self = [super init])) {
		
		// override the defines from Config.h
		self.url = [NSURL URLWithString:@"http://chip.org:7000"];
		self.appId = @"unit-test";
		self.consumerKey = @"unit-test-key";
		self.consumerSecret = @"unit-test-secret";
		
		// load the mappings
		NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mock-callbacks" ofType:@"plist"];
		if (!path) {
			NSException *e = [NSException exceptionWithName:@"File not found" reason:@"mock-callbacks.plist was not found" userInfo:nil];
			@throw e;
		}
		
		self.mockMappings = [NSDictionary dictionaryWithContentsOfFile:path];
	}
	return self;
}

/**
 *  We return an SMRecord object with a constructed ID that will match paths in mock-callbacks.plist
 */
- (SMRecord *)activeRecord
{
	if (!_mockRecord) {
		self.mockRecord = [[SMRecord alloc] initWithId:@"mock-record-id" onServer:self];
	}
	return _mockRecord;
}


/**
 *  We override perform call, which originally manages the call queue and supplies the OAuth object to server calls. The OAuth object is then responsible for
 *  performing the OAuth dance, if necessary, and then performing the actual call. We bypass this by just returning XML for all paths that are understood (as
 *  declared in mock-callbacks.plist)
 */
- (void)performCall:(SMServerCall *)aCall
{
	// which fixture did we want?
	NSDictionary *methodPaths = [_mockMappings objectForKey:aCall.HTTPMethod];
	if (!methodPaths) {
		NSString *errorString = [NSString stringWithFormat:@"The HTTP method \"%@\" is not defined in mock-callbacks, cannot test call", aCall.HTTPMethod];
		NSException *e = [NSException exceptionWithName:@"Fixture not defined" reason:errorString userInfo:nil];
		@throw e;
	}
	
	NSString *fixturePath = [methodPaths objectForKey:aCall.method];
	if (!fixturePath) {
		NSString *errorString = [NSString stringWithFormat:@"The REST method \"%@\" with HTTP method \"%@\" is not defined in mock-callbacks, cannot test call", aCall.method, aCall.HTTPMethod];
		NSException *e = [NSException exceptionWithName:@"Fixture not defined" reason:errorString userInfo:nil];
		@throw e;
	}
	
	/// @todo Also take arguments into consideration
	
	// ok, we know about this path, read the fixture...
	NSData *mockResponse = [self readFixture:fixturePath];
	NSMutableDictionary *response = [NSMutableDictionary dictionaryWithObject:mockResponse forKey:SMARTResponseDataKey];
	
	/* ...parse it...
	NSError *error = nil;
	INXMLNode *mockDoc = [INXMLParser parseXML:mockResponse error:&error];
	if (mockDoc) {
		[response setObject:mockDoc forKey:INResponseXMLKey];
	}
	*/
	
	// ...and hand it to the call
	[aCall finishWith:response];
}



#pragma mark - Utilities
- (NSData *)readFixture:(NSString *)fileName
{
	NSString *base = [[fileName lastPathComponent] stringByDeletingPathExtension];
	NSString *extension = [[fileName lastPathComponent] pathExtension];
	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:base withExtension:extension];
	if (!url) {
		NSException *e = [NSException exceptionWithName:@"File not found"
												 reason:[NSString stringWithFormat:@"The fixture \"%@.%@\" was not found for file name: %@", base, extension, fileName]
											   userInfo:nil];
		@throw e;
	}
	
	return [NSData dataWithContentsOfURL:url];
}


@end
