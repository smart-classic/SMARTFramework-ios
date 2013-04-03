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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMART.h"
#import "SMServerCall.h"
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
 *  Represent the server you want to connect to.
 *
 *  This is the main interaction point of the framework with your targeted SMART Server. You typically initialize a SMServer instance upon app launch and
 *  provide access to it via AppDelegate. The server instance will read its URL and OAuth key/secret configuration from the file `Config.h` and will auto-
 *  configure itself when the first URL request is made. This happens via the server instance downloading the server manifest, which contains the app launch
 *  URL and the three OAuth endpoints.
 *
 *  The server object orchestrates all requests that you make, but you only rarely interact with the server itself. What you are interested in is getting a
 *  record object, and you then use that record object to work with patient data. When you request a record object from the server, the app user is prompted
 *  to login and select a record. You initiate this as follows:
 *
 *	SMServer *smart = [SMServer serverWithDelegate:self];
 *	
 *	[smart selectRecord:^(BOOL userDidCancel, NSString *errorMessage) {
 *
 *		// there was an error selecting the record
 *		if (errorMessage) {
 *			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect"
 *															message:errorMessage
 *														   delegate:nil
 *												  cancelButtonTitle:@"OK"
 *												  otherButtonTitles:nil];
 *			[alert show];
 *		}
 *
 *		// did successfully select a record
 *		else if (!userDidCancel) {
 *			// you can now use `smart.activeRecord`
 *		}
 *	}];
 */
@interface SMServer : NSObject <SMLoginViewControllerDelegate>

/// A delegate to receive notifications
@property (nonatomic, assign) id<SMARTServerDelegate> delegate;


/// @name Configuration
/// The server URL
@property (nonatomic, strong) NSURL *url;

/// The id of the app as it is known on the server
@property (nonatomic, copy) NSString *appId;

/// The consumer key for the app
@property (nonatomic, copy) NSString *consumerKey;

/// The consumer secret for the app
@property (nonatomic, copy) NSString *consumerSecret;


/// @name Manifests and Endpoints
// The server manifest, decoded from JSON
@property (nonatomic, copy) NSDictionary *manifest;

/// The app manifest, decoded from JSON
@property (nonatomic, copy) NSDictionary *appManifest;

/// The URL to load to display the login screen and record selection
@property (nonatomic, strong) NSURL *startURL;

/// Endpoint to request an OAuth request token
@property (nonatomic, strong) NSURL *tokenRequestURL;

/// Endpoint to authorize an OAuth request token
@property (nonatomic, strong) NSURL *tokenAuthorizeURL;

/// Endpoint to trade the request for an OAuth access token
@property (nonatomic, strong) NSURL *tokenExchangeURL;

/// Defaults to "smart-app", but you can use your own
@property (nonatomic, copy) NSString *callbackScheme;

/// Storing our OAuth verifier here until MPOAuth asks for it
@property (nonatomic, readonly, copy) NSString *lastOAuthVerifier;


/// @name Record Handling
// The currently active record
@property (nonatomic, strong) SMRecord *activeRecord;

// Shortcut method to get the id of the currently active record
@property (nonatomic, readonly, copy) NSString *activeRecordId;

/// A cache of the known records on this server
@property (nonatomic, readonly, strong) NSMutableArray *knownRecords;

- (void)selectRecord:(SMCancelErrorBlock)callback;
- (SMRecord *)recordWithId:(NSString *)recordId;


/// @name Allocator
+ (id)serverWithDelegate:(id<SMARTServerDelegate>)aDelegate;


/// @name Requests
- (void)performCall:(SMServerCall *)aCall;
- (void)callDidFinish:(SMServerCall *)aCall;
- (void)suspendCall:(SMServerCall *)aCall;

- (void)performWhenReadyToConnect:(SMCancelErrorBlock)callback;
- (void)fetchServerManifest:(SMCancelErrorBlock)callback;
- (void)fetchAppManifest:(SMCancelErrorBlock)callback;

/// @name Authentication
- (void)authenticate:(SMCancelErrorBlock)callback;
- (BOOL)shouldAutomaticallyAuthenticateFrom:(NSURL *)authURL;
- (NSURL *)authorizeCallbackURL;
- (NSDictionary *)additionalRequestTokenParameters;

/// @name App-specific storage
- (void)fetchAppSpecificDocumentsWithCallback:(SMSuccessRetvalueBlock)callback;

/// @name OAuth
- (MPOAuthAPI *)createOAuthWithAuthMethodClass:(NSString *)authClass error:(NSError *__autoreleasing *)error;


@end
