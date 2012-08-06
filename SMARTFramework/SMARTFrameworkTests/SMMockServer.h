/*
 SMMockServer.h
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

#import "SMServer.h"


/**
 *	Mock Server to replace SMServer for unit testing.
 *	When performing a call it parses the request URL and immediately calls the "didFinishSuccessfully:returnObject:" method, supplying data of the respective
 *	call if the request URL was understood by the mock server.
 */
@interface SMMockServer : SMServer

@property (nonatomic, strong) SMRecord *mockRecord;
@property (nonatomic, copy) NSDictionary *mockMappings;				///< Two dimensional, first level is the method (GET, POST, ...), second a mapping path -> fixture.xml

- (NSString *)readFixture:(NSString *)fileName;


@end
