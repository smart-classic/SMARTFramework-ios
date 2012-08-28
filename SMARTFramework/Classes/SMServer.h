/*
 SMServer.h
 SMARTFramework
 
 Created by Pascal Pfiffner on 9/2/11.
 Copyright (c) 2011 Children's Hospital Boston
 
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

/**
 *  SMARTFramework-ios
 *  ==================
 *  Welcome to the API documentation of the SMART framework for iOS.
 *  
 *  Instructions
 *  ------------
 *  Instructions an how to setup the framework can be found in README.md also provided with the project, which can be viewed nicely formatted on our github
 *  page: https://github.com/chb/SMARTFramework-ios
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMART.h"
#import "INServerCall.h"
#import "SMLoginViewController.h"

@class SMServer;
@class SMRecord;


/**
 *  The SMART Server Delegate Protocol
 */
@protocol SMARTServerDelegate <NSObject>

/**
 *  Return a view controller from which you want to present the login view controller.
 *  The login view controller will be passed into this method so you can customize its chrome.
 *  @warning The delegate MUST respond to this method.
 *  @param loginViewController The login view controller about to load the login screen
 *  @return A view controller from which to present the login view controller
 */
- (UIViewController *)viewControllerToPresentLoginViewController:(SMLoginViewController *)loginViewController;

/**
 *  This delegate method is called when the user logs out. You must implement this method in your delegate, and ideally unload all record data once the user
 *  logs out.
 *  @warning The delegate MUST respond to this method.
 *  @param fromServer The server from which the user disconnected
 */
- (void)userDidLogout:(SMServer *)fromServer;

@end



/**
 *  A class to represent the server you want to connect to.
 *
 *  This is the main interaction point of the framework with your targeted SMART Server.
 */
@interface SMServer : NSObject <SMLoginViewControllerDelegate>

@property (nonatomic, assign) id<SMARTServerDelegate> delegate;					///< A delegate to receive notifications

@property (nonatomic, strong) NSURL *url;										///< The server URL
@property (nonatomic, copy) NSString *appId;									///< The id of the app as it is known on the server

@property (nonatomic, copy) NSDictionary *manifest;								///< The server manifest, decoded from JSON
@property (nonatomic, copy) NSDictionary *appManifest;							///< The app manifest, decoded from JSON

@property (nonatomic, copy) NSString *consumerKey;								///< The consumer key for the app
@property (nonatomic, copy) NSString *consumerSecret;							///< The consumer secret for the app

@property (nonatomic, strong) NSURL *startURL;									///< The URL to load to display the login screen and record selection
@property (nonatomic, strong) NSURL *tokenRequestURL;							///< Endpoint to request an OAuth request token
@property (nonatomic, strong) NSURL *tokenAuthorizeURL;							///< Endpoint to authorize an OAuth request token
@property (nonatomic, strong) NSURL *tokenExchangeURL;							///< Endpoint to trade the request for an OAuth access token
@property (nonatomic, copy) NSString *callbackScheme;							///< Defaults to "smart-app", but you can use your own

@property (nonatomic, strong) SMRecord *activeRecord;							///< The currently active record
@property (nonatomic, readonly, copy) NSString *activeRecordId;					///< Shortcut method to get the id of the currently active record
@property (nonatomic, readonly, strong) NSMutableArray *knownRecords;			///< A cache of the known records on this server. Not currently used by the framework.

@property (nonatomic, assign) BOOL storeCredentials;							///< NO by default. If you set this to YES, a successful login will save credentials to the system keychain
@property (nonatomic, readonly, copy) NSString *lastOAuthVerifier;				///< Storing our OAuth verifier here until MPOAuth asks for it


+ (id)serverWithDelegate:(id<SMARTServerDelegate>)aDelegate;

- (void)selectRecord:(INCancelErrorBlock)callback;
- (void)authenticate:(INCancelErrorBlock)callback;

// authentication
- (void)performWhenReadyToConnect:(INCancelErrorBlock)callback;
- (void)fetchServerManifest:(INCancelErrorBlock)callback;
- (void)fetchAppManifest:(INCancelErrorBlock)callback;
- (BOOL)shouldAutomaticallyAuthenticateFrom:(NSURL *)authURL;
- (NSURL *)authorizeCallbackURL;
- (NSDictionary *)additionalRequestTokenParameters;

// records
- (SMRecord *)recordWithId:(NSString *)recordId;

// app-specific storage
- (void)fetchAppSpecificDocumentsWithCallback:(INSuccessRetvalueBlock)callback;

// performing calls
- (void)performCall:(INServerCall *)aCall;
- (void)callDidFinish:(INServerCall *)aCall;
- (void)suspendCall:(INServerCall *)aCall;

// OAuth
- (MPOAuthAPI *)createOAuthWithAuthMethodClass:(NSString *)authClass error:(NSError *__autoreleasing *)error;


@end
