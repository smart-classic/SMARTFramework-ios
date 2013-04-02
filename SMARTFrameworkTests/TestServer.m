/*
 TestServer.m
 SMARTFramework

 Created by Pascal Pfiffner on 8/3/12.
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

#import "TestServer.h"
#import "SMMockServer.h"

@implementation TestServer


- (void)testManifests
{
	SMMockServer *server = [SMMockServer serverWithDelegate:nil];
	
	[server fetchServerManifest:^(BOOL userDidCancel, NSString *__autoreleasing errorMessage) {
		STAssertEqualObjects(@"pascal.pfiffner@childrens.harvard.edu", [server.manifest objectForKey:@"admin"], @"Admin Email");
		STAssertEqualObjects(@"http://chip.org:7001/apps/unit-test/launch", [server.startURL absoluteString], @"Server's startURL");
		STAssertEqualObjects(@"http://chip.org:7000/oauth/request_token", [server.tokenRequestURL absoluteString], @"Server's tokenRequestURL");
		STAssertEqualObjects(@"http://chip.org:7001/oauth/authorize", [server.tokenAuthorizeURL absoluteString], @"Server's tokenAuthorizeURL");
		STAssertEqualObjects(@"http://chip.org:7000/oauth/access_token", [server.tokenExchangeURL absoluteString], @"Server's tokenExchangeURL");
	}];
}


@end
