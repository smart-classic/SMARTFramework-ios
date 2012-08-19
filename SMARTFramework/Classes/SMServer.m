/*
 SMARTServer.m
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

#import "SMART.h"
#import "SMServer.h"
#import "SMRecord.h"
#import "SMARTDocuments.h"
#import "INURLLoader.h"
#import "INServerCall.h"
#import "MPOAuthAPI.h"
#import "MPOAuthAuthenticationMethodOAuth.h"			// to get ahold of dictionary key constants
#ifndef UNIT_TEST
# import "Config.h"
#endif


@interface SMServer ()

@property (nonatomic, readwrite, strong) NSMutableArray *knownRecords;

@property (nonatomic, strong) MPOAuthAPI *oauth;								/// Handle to our MPOAuth instance with App credentials
@property (nonatomic, strong) NSMutableArray *callQueue;						/// Calls are queued instead of performed in parallel to avoid getting inconsistent results
@property (nonatomic, strong) NSMutableArray *suspendedCalls;					/// Calls that were dequeued, we need to hold on to them to not deallocate them
@property (nonatomic, strong) INServerCall *currentCall;						/// Only one call at a time, this is the current one

@property (nonatomic, strong) SMLoginViewController *loginVC;					/// A handle to the currently shown login view controller
@property (nonatomic, readwrite, copy) NSString *lastOAuthVerifier;

- (void)_presentLoginScreenAtURL:(NSURL *)loginURL;
- (void)_dismissLoginScreenAnimated:(BOOL)animated;

- (MPOAuthAPI *)getOAuthOutError:(NSError * __autoreleasing *)error;

@end


@implementation SMServer

NSString *const INErrorKey = @"SMARTError";
NSString *const INRecordIDKey = @"record_id";
NSString *const INResponseStringKey = @"SMARTServerCallResponseText";
NSString *const INResponseArrayKey = @"SMARTResponseArray";
NSString *const INResponseDocumentKey = @"SMARTResponseDocument";

NSString *const SMARTInternalScheme = @"smart-app";
NSString *const SMARTOAuthRecordIDKey = @"smart_record_id";

NSString *const SMARTRecordDocumentsDidChangeNotification = @"SMARTRecordDocumentsDidChangeNotification";
NSString *const SMARTRecordUserInfoKey = @"SMARTRecordUserInfoKey";

@synthesize activeRecord, knownRecords;
@synthesize appId, callbackScheme, url;
@dynamic activeRecordId;
@synthesize oauth, callQueue, suspendedCalls, currentCall;
@synthesize lastOAuthVerifier;
@synthesize consumerKey, consumerSecret, storeCredentials;



#pragma mark - Initialization
/**
 *  A convenience constructor creating the server for the given delegate. Configuration is automatically read from "Config.h"
 */
+ (id)serverWithDelegate:(id<SMARTServerDelegate>)aDelegate
{
	SMServer *s = [self new];
	s.delegate = aDelegate;
	
	return s;
}


/**
 * The designated initializer
 */
- (id)init
{
	if ((self = [super init])) {
		if ([kSMARTAPIBaseURL length] > 0) {
			self.url = [NSURL URLWithString:kSMARTAPIBaseURL];
		}
		if ([kSMARTAppId length] > 0) {
			self.appId = kSMARTAppId;
		}
		if ([kSMARTConsumerKey length] > 0) {
			self.consumerKey = kSMARTConsumerKey;
		}
		if ([kSMARTConsumerSecret length] > 0) {
			self.consumerSecret = kSMARTConsumerSecret;
		}
		
		self.callQueue = [NSMutableArray arrayWithCapacity:2];
		self.suspendedCalls = [NSMutableArray arrayWithCapacity:2];
	}
	return self;
}



#pragma mark - Endpoint Locations/Manifests
/**
 *  Fetches the server and app manifests, if needed, then executes the block.
 *  Authentication calls are wrapped into this method since we need to know our endpoints before we can authenticate.
 */
- (void)performWhenReadyToConnect:(INCancelErrorBlock)callback
{
	if ([[url absoluteString] length] < 5) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, L_(@"No server URL provided"))		// Error 1001
		return;
	}
	if ([appId length] < 1) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, L_(@"No App id provided"))			// Error 1003
		return;
	}
	
	// need to fetch the manifest first?
	if (!_manifest) {
//	if (!_manifest || !_appManifest) {
		[self fetchServerManifest:^(BOOL userDidCancel, NSString *errorMessage) {
			CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, userDidCancel, errorMessage);
		}];
	}
	
	// all good, execute callback
	else {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, nil)
	}
}

/**
 *  Fetches the server manifest.
 *  @warning You usually don't call this method manually, use "prepareToConnect:" and access the server manifest in "manifest" afterwards.
 */
- (void)fetchServerManifest:(INCancelErrorBlock)callback
{
	NSURL *manifestURL = [url URLByAppendingPathComponent:@"manifest"];
	INURLLoader *loader = [INURLLoader loaderWithURL:manifestURL];
	
	// fetch
	[loader getWithCallback:^(BOOL userDidCancel, NSString *errorMessage) {
		
		// upon success, parse the response into the manifest dictionary
		if (!errorMessage && !userDidCancel) {
			NSError *jsonError = nil;
			id resDict = [NSJSONSerialization JSONObjectWithData:loader.responseData options:0 error:&jsonError];
			if (!resDict) {
				errorMessage = [jsonError localizedDescription];
			}
			else if ([resDict isKindOfClass:[NSDictionary class]]) {
				self.manifest = (NSDictionary *)resDict;
			}
			else {
				errorMessage = [NSString stringWithFormat:@"Did not receive a dictionary for the manifest, but a %@:  %@", NSStringFromClass([resDict class]), resDict];
			}
		}
		
		// pass it all to the main callback
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, userDidCancel, errorMessage);
	}];
}

/**
 *  Fetches the app manifest.
 *  @warning You usually don't call this method, use "prepareToConnect:" which performs this method. Afterwards, "appManifest" contains the manifest.
 */
- (void)fetchAppManifest:(INCancelErrorBlock)callback
{
	if (!YES) {
	}
	
	NSURL *manifestURL = [url URLByAppendingPathComponent:@"manifest"];
	INURLLoader *loader = [INURLLoader loaderWithURL:manifestURL];
	
	// fetch
	[loader getWithCallback:^(BOOL userDidCancel, NSString *errorMessage) {
		
		// upon success, parse the response into the manifest dictionary
		if (!errorMessage && !userDidCancel) {
			NSError *jsonError = nil;
			id resDict = [NSJSONSerialization JSONObjectWithData:loader.responseData options:0 error:&jsonError];
			if (!resDict) {
				errorMessage = [jsonError localizedDescription];
			}
			else if ([resDict isKindOfClass:[NSDictionary class]]) {
				self.manifest = (NSDictionary *)resDict;
			}
			else {
				errorMessage = [NSString stringWithFormat:@"Did not receive a dictionary for the manifest, but a %@:  %@", NSStringFromClass([resDict class]), resDict];
			}
		}
		
		// pass it all to the main callback
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, userDidCancel, errorMessage);
	}];
}


/**
 *  The callback to feed to tokenAuthorizeURL
 */
- (NSURL *)authorizeCallbackURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@:///did_receive_verifier/", SMARTInternalScheme]];
}

- (NSString *)callbackScheme
{
	return callbackScheme ? callbackScheme : SMARTInternalScheme;
}

/**
 *  We need to associate a token with a given record id, so we provide that when performing the request token request
 */
- (NSDictionary *)additionalRequestTokenParameters
{
	if ([self activeRecordId]) {
		return [NSDictionary dictionaryWithObject:[self activeRecordId] forKey:SMARTOAuthRecordIDKey];
	}
	return nil;
}




#pragma mark - Record Selection
/**
 *  @return The record with the given id, nil if it is not found
 */
- (SMRecord *)recordWithId:(NSString *)recordId
{
	for (SMRecord *record in knownRecords) {
		if ([record.record_id isEqualToString:recordId]) {
			return record;
		}
	}
	return nil;
}


/**
 *  This is the main authentication entry point, this method will ask the delegate where to present a login view controller, if authentication is necessary, and
 *  handle all user interactions until login was successful or the user cancels the login operation.
 *  @param callback A block with a first BOOL argument, which will be YES if the user cancelled the action, and an error string argument, which will be nil if
 *  authentication was successful. By the time this callback is called, the "activeRecord" property will be set (if the call was successful).
 */
- (void)selectRecord:(INCancelErrorBlock)callback
{
	// dequeue current call
	if (currentCall) {
		[self suspendCall:currentCall];
	}
	
	// we use a INServerCall object to capture the callback block and fire it automatically when the OAuth process has completed
	__unsafe_unretained SMServer *this = self;
	[self performWhenReadyToConnect:^(BOOL userDidCancel, NSString * errorMessage) {
		if (errorMessage) {
			DLog(@"Error getting ready to connect: %@", errorMessage)
			CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, userDidCancel, errorMessage)
			return;
		}
		else if (userDidCancel) {
			DLog(@"User did cancel, should I stop?")
		}
		
		this.currentCall = [INServerCall newForServer:this];
		this.currentCall.HTTPMethod = @"POST";
		this.currentCall.finishIfAuthenticated = YES;
		
		// here's the callback once record selection has finished
		this.currentCall.myCallback = ^(BOOL success, NSDictionary *userInfo) {
			BOOL didCancel = NO;
			
			// successfully selected a record
			if (success) {
				NSString *forRecordId = [userInfo objectForKey:INRecordIDKey];
				if (forRecordId && [this.activeRecord is:forRecordId]) {
					this.activeRecord.accessToken = [userInfo objectForKey:@"oauth_token"];
					this.activeRecord.accessTokenSecret = [userInfo objectForKey:@"oauth_token_secret"];
				}
				
				// fetch record info to get the record label (this non-authentication call will make the login view controller disappear, don't forget that if you remove it)
				if (this.activeRecord) {
					[this.activeRecord fetchRecordInfoWithCallback:^(BOOL userDidCancel2, NSString * errorMessage2) {
						
						// errors will only be logged, not passed on to the callback as the record was still selected successfully
						if (errorMessage2) {
							DLog(@"Error fetching contact document: %@", errorMessage2);
						}
						
						CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, nil)
						[this _dismissLoginScreenAnimated:YES];
					}];
				}
				else {
					DLog(@"There is no active record!");
					CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, @"No active record")
					[this _dismissLoginScreenAnimated:YES];
				}
			}
			
			// failed: Cancelled or other failure
			else {
				didCancel = (nil == [userInfo objectForKey:INErrorKey]);
				CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO(callback, didCancel, userInfo)
				[this _dismissLoginScreenAnimated:YES];
			}
		};
		
		// show the login screen
		[this _presentLoginScreenAtURL:this.startURL];
	}];
}


/**
 *  Strips current credentials and then does the OAuth dance again. The authorize screen is automatically shown if necessary.
 *  @warning This call is only useful if a call is in progress (but has hit an invalid access token), so it will not do anything without a current call.
 *  @param callback An INCancelErrorBlock callback
 */
- (void)authenticate:(INCancelErrorBlock)callback
{
	NSError *error = nil;
	
	// dequeue current call
	if (!currentCall) {
		NSString *errorStr = error ? [error localizedDescription] : @"No current call";
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, NO, errorStr)
		return;
	}
	[self suspendCall:currentCall];
	
	// construct the call
	__unsafe_unretained SMServer *this = self;
	[self performWhenReadyToConnect:^(BOOL userDidCancel, NSString *__autoreleasing errorMessage) {
		if (errorMessage) {
			DLog(@"Error getting ready to connect: %@", errorMessage)
			CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, userDidCancel, errorMessage)
			return;
		}
		else if (userDidCancel) {
			DLog(@"User did cancel, should I stop?")
		}
		
		this.currentCall = [INServerCall newForServer:this];
		this.currentCall.HTTPMethod = @"POST";
		this.currentCall.finishIfAuthenticated = YES;
		
		// here's the callback once authentication has finished
		this.currentCall.myCallback = ^(BOOL success, NSDictionary *userInfo) {
			BOOL didCancel = NO;
			
			// successfully authenticated
			if (success) {
				NSString *forRecordId = [userInfo objectForKey:INRecordIDKey];
				if (forRecordId && [this.activeRecord is:forRecordId]) {
					this.activeRecord.accessToken = [userInfo objectForKey:@"oauth_token"];
					this.activeRecord.accessTokenSecret = [userInfo objectForKey:@"oauth_token_secret"];
				}
				
				userInfo = nil;
			}
			else if (![userInfo objectForKey:INErrorKey]) {
				didCancel = YES;
			}
			
			CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO(callback, didCancel, userInfo)
		};
		
		// force authentication by wiping current credentials
		this.currentCall.oauth = [this getOAuthOutError:nil];
		[this.currentCall.oauth discardCredentials];
		
		[this performCall:this.currentCall];
	}];
}


/**
 *  Asks our delegate where to place the login screen, then shows the login screen and loads the given URL
 *  @param loginURL The URL to load to show a login interface
 *  @param callbackURL The URL to load after successful authentication
 *  @return Returns NO if the login screen could not be presented, YES if it's being shown
 */
- (void)_presentLoginScreenAtURL:(NSURL *)loginURL
{
	// already showing a login screen, just load the URL
	if (_loginVC) {
		[_loginVC loadURL:loginURL];
		return;
	}
	
	// newly display a login screen
	SMLoginViewController *vc = [SMLoginViewController new];
	UIViewController *pvc = [_delegate viewControllerToPresentLoginViewController:vc];
	if (pvc) {
		vc.delegate = self;
		vc.startURL = loginURL;
		self.loginVC = vc;
		if ([pvc respondsToSelector:@selector(presentViewController:animated:completion:)]) {		// iOS 5+ only
			[pvc presentViewController:_loginVC animated:YES completion:NULL];
		}
		else {
			[pvc presentModalViewController:_loginVC animated:YES];
		}
	}
	else {
		DLog(@"Delegate did not provide a view controller, cannot present login screen");
	}
}

/**
 *  Dismisses the login screen, if present
 */
- (void)_dismissLoginScreenAnimated:(BOOL)animated
{
	if (_loginVC) {
		[_loginVC dismissAnimated:animated];
		self.loginVC = nil;
	}
}



#pragma mark - Login View Controller Delegate
/**
 *  Called when the user selected a record
 */
- (void)loginView:(SMLoginViewController *)aLoginController didSelectRecordId:(NSString *)recordId
{
	NSError *error = nil;
	
	// got a record
	if ([recordId length] > 0) {
		[self.oauth discardCredentials];
		
		// set the active record
		SMRecord *selectedRecord = [self recordWithId:recordId];
		if (selectedRecord) {
			if (selectedRecord.accessToken) {
				[self.oauth setCredential:selectedRecord.accessToken withName:kMPOAuthCredentialAccessToken];
				[self.oauth setCredential:selectedRecord.accessTokenSecret withName:kMPOAuthCredentialAccessTokenSecret];
			}
		}
		
		// instantiate new record
		else {
			selectedRecord = [[SMRecord alloc] initWithId:recordId onServer:self];
			if (!knownRecords) {
				self.knownRecords = [NSMutableArray array];
			}
			[knownRecords addObject:selectedRecord];
		}
		self.activeRecord = selectedRecord;
		
		// finish the record selection process
		[self performCall:currentCall];
	}
	
	// failed to select a record
	else {
		ERR(&error, @"Did not receive a record", 0)
	}
}

/**
 *  A delegate method which gets called when the callback is received
 */
- (void)loginView:(SMLoginViewController *)aLoginController didReceiveVerifier:(NSString *)aVerifier
{
	self.lastOAuthVerifier = aVerifier;
	
	// we should have an active call and an active record here, warn if not
	if (!currentCall) {
		DLog(@"WARNING -- did receive verifier, but no call is in place! Verifier: %@", aVerifier);
	}
	if (!self.activeRecord) {
		DLog(@"WARNING -- no active record");
	}
	
	// continue the auth call by firing it again
	if (_loginVC) {
		[_loginVC showLoadingIndicator:nil];
	}
	[self performCall:currentCall];
}

/**
 *  Delegate method called when the user dismisses the login screen, i.e. cancels the record selection process
 */
- (void)loginViewDidCancel:(SMLoginViewController *)loginController
{
	if (currentCall) {
		[currentCall cancel];
	}
	
	// dismiss login view controller
	if (loginController != _loginVC) {
		DLog(@"Very strange, an unknown login controller did just cancel...");
	}
	[loginController dismissAnimated:YES];
	self.loginVC = nil;
}

/**
 *  The user logged out
 */
- (void)loginViewDidLogout:(SMLoginViewController *)aLoginController
{
	self.activeRecord = nil;
	[currentCall cancel];
	[_delegate userDidLogout:self];
	
	if (_loginVC) {
		[_loginVC dismissAnimated:YES];
		self.loginVC = nil;
	}
}

/**
 *  The scheme for URL that we treat differently internally (by default this is "smart-app")
 */
- (NSString *)callbackSchemeForLoginView:(SMLoginViewController *)aLoginController
{
	return self.callbackScheme;
}



#pragma mark - App Specific Documents
/**
 *  Fetches global, app-specific documents.
 *  GETs documents from /apps/{app id}/documents/ with a two-legged OAuth call.
 */
- (void)fetchAppSpecificDocumentsWithCallback:(INSuccessRetvalueBlock)callback
{
	// create the desired INServerCall instance
	INServerCall *call = [INServerCall new];
	call.method = [NSString stringWithFormat:@"/apps/%@/documents/", self.appId];
	call.HTTPMethod = @"GET";
	
	// create callback
	call.myCallback = ^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		NSDictionary *usrIfo = nil;
		
		// fetched successfully...
		if (success) {
			DLog(@"Incoming: %@", [userInfo objectForKey:INResponseStringKey]);
			//usrIfo = [NSDictionary dictionaryWithObject:appDocArr forKey:INResponseArrayKey];
		}
		else {
			usrIfo = userInfo;
		}
		
		SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(callback, success, usrIfo)
	};
	
	// shoot!
	[self performCall:call];
}



#pragma mark - Call Handling
/**
 *  Perform a method on our server
 *  This method is usally called by INServerObject subclasses, but you can use it bare if you wish
 *  @param aCall The call to perform
 */
- (void)performCall:(INServerCall *)aCall
{
	if (!aCall) {
		DLog(@"No call to perform");
		return;
	}
	
	// performing an arbitrary call, we can dismiss any login view controller
	if (_loginVC && ![aCall isAuthenticationCall]) {
		[_loginVC dismissAnimated:YES];
		self.loginVC = nil;
	}
	
	// maybe this call was suspended, remove it from the store
	[suspendedCalls removeObject:aCall];
	
	// there already is a call in progress
	if (aCall != currentCall && [currentCall hasBeenFired]) {
		[callQueue addObject:aCall];
		return;
	}
	
	// assure our OAuthAPI is correctly setup
	NSError *error = nil;
	if (!aCall.oauth) {
		aCall.oauth = [self getOAuthOutError:&error];
	}
	if (!aCall.oauth) {
		[aCall abortWithError:error];
		return;
	}
	
	// setup and fire
	aCall.server = self;
	self.currentCall = aCall;
	
	[aCall fire];
}

/**
 *  Callback to let us know a call has finished.
 *  The call will have called the callback by now, no need for us to do any further handling
 */
- (void)callDidFinish:(INServerCall *)aCall
{
	[callQueue removeObject:aCall];
	if (aCall == currentCall) {
		self.currentCall = nil;
	}
	
	// move on
	INServerCall *nextCall = nil;
	if ([callQueue count] > 0) {
		nextCall = [callQueue objectAtIndex:0];
	}
	else if ([suspendedCalls count] > 0) {
		nextCall = [suspendedCalls objectAtIndex:0];
	}
	
	if (nextCall) {
		[self performCall:nextCall];
	}
}

/**
 *  Dequeues a call without finishing it. This is useful for calls that need to be re-performed after another call has been made, e.g. if the token was
 *  rejected and we'll be retrying the call after obtaining a new token. In this case, we don't want the call to finish, but we can't leave it in the queue
 *  because it would block subsequent calls.
 *  @warning Do NOT use this to cancel a call because the callback will not be called!
 */
- (void)suspendCall:(INServerCall *)aCall
{
	[suspendedCalls addObject:aCall];
	[callQueue removeObject:aCall];
	
	if (aCall == currentCall) {
		self.currentCall = nil;
	}
}

/**
 *  Callback when the call is stuck at user authorization
 *  @return We always return NO here, but display the login screen ourselves, loaded from the provided URL
 */
- (BOOL)shouldAutomaticallyAuthenticateFrom:(NSURL *)authURL
{
	[self _presentLoginScreenAtURL:authURL];
	return NO;
}



#pragma mark - MPOAuth Creation
/**
 *  Returns our standard oauth instance or fills the error, if it couldn't be created
 *  @param error An error pointer to be filled if OAuth creation fails
 *  @return self.oauth
 */
- (MPOAuthAPI *)getOAuthOutError:(NSError *__autoreleasing *)error
{
	if (!oauth) {
		self.oauth = [self createOAuthWithAuthMethodClass:nil error:error];
	}
	return oauth;
}


/**
 *  Creates a new MPOAuthAPI instance with our current settings.
 *  @param authClass An MPOAuthAuthenticationMethod class name. If nil picks three-legged oauth.
 *  @param error A pointer to an error object, which will be filled if the method returns null
 */
- (MPOAuthAPI *)createOAuthWithAuthMethodClass:(NSString *)authClass error:(NSError *__autoreleasing *)error;
{
	MPOAuthAPI *api = nil;
	NSString *errStr = nil;
	NSUInteger errCode = 0;
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
								 self.consumerKey, kMPOAuthCredentialConsumerKey,
								 self.consumerSecret, kMPOAuthCredentialConsumerSecret,
								 nil];
	
	// we need a URL
	if (!url) {
		errStr = @"Cannot create our oauth instance: No URL set";
		errCode = 1001;
	}
	
	// and we certainly need consumer key and secret
	else if ([[credentials objectForKey:kMPOAuthCredentialConsumerKey] length] < 1) {
		errStr = @"Cannot create our oauth instance: No consumer key provided";
		errCode = 1004;
	}
	else if ([[credentials objectForKey:kMPOAuthCredentialConsumerSecret] length] < 1) {
		errStr = @"Cannot create our oauth instance: No consumer secret provided";
		errCode = 1005;
	}
	
	// create our instance with credentials and configured with the correct URLs
	else {
		NSMutableDictionary *config = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [self.tokenRequestURL absoluteString], MPOAuthRequestTokenURLKey,
									   [self.tokenAuthorizeURL absoluteString], MPOAuthUserAuthorizationURLKey,
									   [self.tokenExchangeURL absoluteString], MPOAuthAccessTokenURLKey,
									   self.tokenAuthorizeURL, MPOAuthAuthenticationURLKey,
									   url, MPOAuthBaseURLKey,
									   nil];
		
		// specify authentication method
		if ([authClass length] > 0) {
			[config setObject:authClass forKey:MPOAuthAuthenticationMethodKey];
		}
		
		// create
		api = [[MPOAuthAPI alloc] initWithCredentials:credentials withConfiguration:config autoStart:NO];
		[api discardCredentials];
		
		if (!api) {
			errStr = @"Failed to create OAuth API";
			errCode = 2001;
		}
	}
	
	// report an error
	if (errCode > 0) {
		if (error) {
			ERR(error, errStr, errCode)
		}
		else {
			DLog(@"Error %d: %@", errCode, errStr);
		}
	}
	return api;
}



#pragma mark - KVC
/**
 *  Sets the active record and resets the oauth instance upon logout
 */
- (void)setActiveRecord:(SMRecord *)aRecord
{
	if (aRecord != activeRecord) {
		activeRecord = aRecord;
		
		if (!activeRecord) {
			self.oauth = nil;
		}
	}
}

/**
 *  Shortcut to the active record id
 */
- (NSString *)activeRecordId
{
	return activeRecord.record_id;
}

/**
 *  Setting the server manifest automatically updates the endpoint URLs
 */
- (void)setManifest:(NSDictionary *)manifest
{
	if (_manifest != manifest) {
		_manifest = [manifest copy];
		
		// extract data
		if (_manifest) {
			NSDictionary *endpoints = [_manifest objectForKey:@"launch_urls"];
			if ([endpoints isKindOfClass:[NSDictionary class]]) {
				NSString *start = [endpoints objectForKey:@"app_launch"];
				NSString *tokenRequest = [endpoints objectForKey:@"request_token"];
				NSString *tokenAuthorize = [endpoints objectForKey:@"authorize_token"];
				NSString *tokenExchange = [endpoints objectForKey:@"exchange_token"];
				
				// set endpoint URLs
				if ([start length] > 0) {
					start = [start stringByReplacingOccurrencesOfString:@"{{app_id}}" withString:self.appId];
					self.startURL = [NSURL URLWithString:start];
				}
				if ([tokenRequest length] > 0) {
					self.tokenRequestURL = [NSURL URLWithString:tokenRequest];
				}
				if ([tokenAuthorize length] > 0) {
					self.tokenAuthorizeURL = [NSURL URLWithString:tokenAuthorize];
				}
				if ([tokenExchange length] > 0) {
					self.tokenExchangeURL = [NSURL URLWithString:tokenExchange];
				}
			}
		}
	}
}



#pragma mark - Utilities
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <%p> Server at %@", NSStringFromClass([self class]), self, url];
}


@end
