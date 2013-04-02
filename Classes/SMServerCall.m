/*
 SMServerCall.h
 IndivoFramework
 
 Created by Pascal Pfiffner on 9/16/11.
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


#import "SMServerCall.h"
#import "SMServer.h"


@interface SMServerCall ()

@property (nonatomic, readwrite, assign) BOOL hasBeenFired;
@property (nonatomic, assign) BOOL retryWithNewTokenAfterFailure;
@property (nonatomic, assign) BOOL didRetryWithNewTokenAfterFailure;
@property (nonatomic, strong) NSDictionary *responseObject;

- (void)didFinishSuccessfully:(BOOL)success returnObject:(NSDictionary *)returnObject;

@end


@implementation SMServerCall


/**
 *  Convenience constructor, sets the server
 *  @param aServer An indivo server instance
 *  @return an autoreleased SMServerCall instance
 */
+ (SMServerCall *)newForServer:(id)aServer
{
	return [[self alloc] initWithServer:aServer];
}

/**
 *  The designated initializer
 *  @param aServer The server against which we'll run
 */
- (id)initWithServer:(id)aServer
{
	if ((self = [super init])) {
		self.server = aServer;
		self.HTTPMethod = @"GET";
	}
	return self;
}



#pragma mark - OAuth Setup
- (void)setOauth:(MPOAuthAPI *)newOAuth
{
	if (newOAuth != _oauth) {
		if (_oauth) {
			if (self == _oauth.authDelegate) {
				_oauth.authDelegate = nil;
			}
			if (self == _oauth.loadDelegate) {
				_oauth.loadDelegate = nil;
			}
			
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			[center removeObserver:self name:MPOAuthNotificationAccessTokenReceived object:nil];
			[center removeObserver:self name:MPOAuthNotificationAccessTokenRejected object:nil];
			[center removeObserver:self name:MPOAuthNotificationAccessTokenRefreshed object:nil];
			[center removeObserver:self name:MPOAuthNotificationOAuthCredentialsReady object:nil];
			[center removeObserver:self name:MPOAuthNotificationErrorHasOccurred object:nil];
		}
		
		_oauth = newOAuth;			// This certainly looks weird, holy new ARC technology...
		
		// we are the delegate of our oauth instance and we want to receive all its notifications
		if (_oauth) {
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			[center addObserver:self selector:@selector(oauthNotificationReceived:) name:MPOAuthNotificationAccessTokenReceived object:_oauth];
			[center addObserver:self selector:@selector(oauthNotificationReceived:) name:MPOAuthNotificationAccessTokenRejected object:_oauth];
			[center addObserver:self selector:@selector(oauthNotificationReceived:) name:MPOAuthNotificationAccessTokenRefreshed object:_oauth];
			[center addObserver:self selector:@selector(oauthNotificationReceived:) name:MPOAuthNotificationOAuthCredentialsReady object:_oauth];
			[center addObserver:self selector:@selector(oauthNotificationReceived:) name:MPOAuthNotificationErrorHasOccurred object:_oauth];
			
			_oauth.authDelegate = self;
			_oauth.loadDelegate = self;
		}
	}
}



#pragma mark - Connection Fire Methods
/**
 *  Sends off as a GET request
 *  @param inMethod The method to use, i.e. the REST path
 *  @param inParameters An array full of @"key=value" NSString objects, can be nil
 *  @param inOAuth The MPOAuthAPI instance to use for the call
 *  @param inCallback The callback block to call when the method has finished
 */
- (void)get:(NSString *)inMethod withParameters:(NSArray *)inParameters oauth:(MPOAuthAPI *)inOAuth callback:(SMSuccessRetvalueBlock)inCallback
{
	self.method = inMethod;
	self.parameters = inParameters;
	self.HTTPMethod = @"GET";
	self.oauth = inOAuth;
	self.myCallback = inCallback;
	
	[self fire];
}

/**
 *  Sends off as a POST request
 *  @param inMethod The method to use, i.e. the REST path
 *  @param inParameters An array full of @"key=value" NSString objects, can be nil
 *  @param inOAuth The MPOAuthAPI instance to use for the call
 *  @param inCallback The callback block to call when the method has finished
 */
- (void)post:(NSString *)inMethod withParameters:(NSArray *)inParameters oauth:(MPOAuthAPI *)inOAuth callback:(SMSuccessRetvalueBlock)inCallback
{
	self.method = inMethod;
	self.parameters = inParameters;
	self.HTTPMethod = @"POST";
	self.oauth = inOAuth;
	self.myCallback = inCallback;
	
	[self fire];
}

/**
 *  Sends off a POST request with the given body
 *  @param inMethod The method to use, i.e. the REST path
 *  @param bodyString The body string to POST
 *  @param inOAuth The MPOAuthAPI instance to use for the call
 *  @param inCallback The callback block to call when the method has finished
 */
- (void)post:(NSString *)inMethod body:(NSString *)bodyString oauth:(MPOAuthAPI *)inOAuth callback:(SMSuccessRetvalueBlock)inCallback
{
	self.method = inMethod;
	self.body = bodyString;
	self.HTTPMethod = @"POST";
	self.oauth = inOAuth;
	self.myCallback = inCallback;
	
	[self fire];
}

/**
 *  Most versatile fire method, used internally from the get: and post: methods.
 *  @param inMethod The method to use, i.e. the REST path
 *  @param inParameters An array full of @"key=value" NSString objects, can be nil
 *  @param httpMethod The HTTP-method (GET, PUT, POST) to use
 *  @param inOAuth The MPOAuthAPI instance to use for the call
 *  @param inCallback The callback block to call when the method has finished
 */
- (void)fire:(NSString *)inMethod withParameters:(NSArray *)inParameters httpMethod:(NSString *)httpMethod oauth:(MPOAuthAPI *)inOAuth callback:(SMSuccessRetvalueBlock)inCallback
{
	self.method = inMethod;
	self.parameters = inParameters;
	self.HTTPMethod = httpMethod;
	self.oauth = inOAuth;
	self.myCallback = inCallback;
	
	[self fire];
}

/**
 *  Fires the request as currently prepared.
 *  All get, post and fire methods go through this method in their last step.
 */
- (void)fire
{
	if (!_oauth) {
		DLog(@"Cannot fire without oauth property. Call: %@", self);
		return;
	}
	
	if (_HTTPMethod) {
		_oauth.defaultHTTPMethod = _HTTPMethod;
	}
	self.hasBeenFired = YES;
	self.didRetryWithNewTokenAfterFailure = _retryWithNewTokenAfterFailure;
	self.retryWithNewTokenAfterFailure = NO;
	
	// let MPOAuth do its magic
	if (![_oauth isAuthenticated]) {
		_oauth.defaultHTTPMethod = @"POST";
		[_oauth authenticate];
	}
	
	// the main work performing call
	else if (!self.finishIfAuthenticated) {
		NSData *bodyData = nil;
		if (_bodyData) {
			bodyData = _bodyData;
		}
		else if ([_body length] > 0) {
			bodyData = [_body dataUsingEncoding:NSUTF8StringEncoding];
		}
		
		if (bodyData) {
			NSURL *fullURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self.oauth.baseURL absoluteString], self.method]];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
			NSString *contType = ([_contentType length] > 0) ? _contentType : @"application/xml";
			[request setHTTPMethod:_HTTPMethod];
			[request setValue:contType forHTTPHeaderField:@"Content-Type"];
			[request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:bodyData];
			
			[self.oauth performURLRequest:request withDelegate:self];
		}
		else {
			[self.oauth performMethod:_method withParameters:_parameters delegate:self];
		}
	}
	
	// already authenticated and finishIfAuthenticated is set, finishing without round-trip to the server
	else {
		[self didFinishSuccessfully:YES returnObject:nil];
	}
}



#pragma mark - Finishing and Aborting
/**
 *  A method to finish the call early, but successfully.
 *  Use abortWithError: to finish a call early and unsuccessfully. This method provokes the same actions as if it was fired and returned successfully. This
 *  method is NOT being called when the URL connection finishes.
 *  @param returnObject The dictionary that we will return as userInfo with the callback
 */
- (void)finishWith:(NSDictionary *)returnObject
{
	[self didFinishSuccessfully:YES returnObject:returnObject];
}

/**
 *  Cancels the call; calling "abortWithError:nil" has the same effect
 */
- (void)cancel
{
	[self didFinishSuccessfully:NO returnObject:nil];
}

/**
 *  This method can be called to abort a call and have it send the provided error with its callback
 *  @param error An NSError object to be delivered through the callback
 */
- (void)abortWithError:(NSError *)error
{
	/// @todo truly abort loading, if in progress
	[self didFinishSuccessfully:NO returnObject:(error ? @{SMARTErrorKey: error} : nil)];
}

/**
 *  Internal finishing method.
 *  Calls the callback, if there is one, and informs the server that the call has finished.
 *  @param success A BOOL indicating whether the call was successful
 *  @param returnObject The dictionary that we will return as userInfo with the callback
 */
- (void)didFinishSuccessfully:(BOOL)success returnObject:(NSDictionary *)returnObject
{
	self.oauth = nil;
	
	// inform the server - the server will remove us from his pool, so we need to create a strong reference to ourselves which lasts for the scope
	SMServerCall *this = self;
	[_server callDidFinish:self];
	
	// send callback and inform the server
	SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(_myCallback, success, returnObject);
	self.myCallback = nil;
	this = nil;
}



#pragma mark - OAuth Delegate Methods -- Asking us for information
/**
 *  MPOAuth will call this method to know where to redirect after successfull authentication
 */
- (NSURL *)callbackURLForCompletedUserAuthorizationDISABLED
{
	return [_server authorizeCallbackURL];
}

/**
 *  MPOAuth will call this method to get ahold of the oAuth verifier.
 *  We must extract the verifier from the callback URL (specified in "- (NSURL *)callbackURLForCompletedUserAuthorization" and
 *  called on the App Delegate) and return it from this method
 */
- (NSString *)oauthVerifierForCompletedUserAuthorization
{
	return [_server lastOAuthVerifier];
}

- (NSDictionary *)additionalRequestTokenParameters
{
	return [_server additionalRequestTokenParameters];
}

/*
 *  If the server is our delegate, we return NO here and the server loads the login page
 */
- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL
{
	return [_server shouldAutomaticallyAuthenticateFrom:inAuthURL];
}



#pragma mark - OAuth Auth Delegate Methods -- Final Responses
/*
 *  Delegate method after successful authentication
 */
- (void)authenticationDidSucceed
{
	[self fire];			// will finish immediately if the call has "finishIfAuthenticated" set
}

/*
 *  Delegate method that gets called after failure to receive an access_token
 */
- (void)authenticationDidFailWithError:(NSError *)error
{
	if (!error) {
		error = nil;
		ERR(&error, @"Authentication did fail with an unknown error", 0);
	}
	[self didFinishSuccessfully:NO returnObject:@{SMARTErrorKey: error}];
}



#pragma mark - Receiving OAuth Notifications
/*
 *  One method to intercept all MPOAuth notifications.
 *  We only subscribe to receive notifications from "our" MPOAuthAPI object. The notifications will be delivered before the finishing
 *  authDelegate methods will be called.
 */
- (void)oauthNotificationReceived:(NSNotification *)aNotification
{
	NSString *nName = [aNotification name];
	NSDictionary *nDict = [aNotification userInfo];
	
	// credentials are now ready, that's what we've been waiting for
	if ([MPOAuthNotificationOAuthCredentialsReady isEqualToString:nName]) {
		self.responseObject = nDict;
	}
	
	// we finally got an access token, that's what we've been waiting for
	else if ([MPOAuthNotificationAccessTokenReceived isEqualToString:nName]) {
		if (![nDict objectForKey:SMARTRecordIDKey]) {
			DLog(@"Got access token but no record id??\n%@", nDict);
		}
		self.responseObject = nDict;
	}
	
	// **access** token rejected, let's retry once
	else if ([MPOAuthNotificationAccessTokenRejected isEqualToString:nName]) {
		NSError *error = nil;
		//ERR(&error, [nDict objectForKey:NSLocalizedDescriptionKey] ? [nDict objectForKey:NSLocalizedDescriptionKey] : @"Access Token Rejected", 403);	// server does always send "Permission Denied"
		ERR(&error, @"Access Token Rejected", 403);
		self.responseObject = @{SMARTErrorKey: error};
		
		if (!_didRetryWithNewTokenAfterFailure) {
			DLog(@"WARNING: The access token was rejected. I will try to get a new token, show the \"Authorize App\" page to the user if necessary and then re-perform the call.");
			_retryWithNewTokenAfterFailure = YES;
		}
	}
	
	// general error
	else if ([MPOAuthNotificationErrorHasOccurred isEqualToString:nName]) {
		NSError *error = nil;
		ERR(&error, [nDict objectForKey:NSLocalizedDescriptionKey] ? [nDict objectForKey:NSLocalizedDescriptionKey] : @"OAuth Error", 400);
		self.responseObject = @{SMARTErrorKey: error};
	}
	
	/// @todo unhandled notification, ignore as soon as everything works
	else {
		DLog(@"UNHANDLED NOTIFICATION RECEIVED: %@", aNotification);
	}
}



#pragma mark - OAuth Load Delegate
- (void)connectionFinishedWithResponse:(NSURLResponse *)aResponse data:(NSData *)inData
{
	// set response data
	NSMutableDictionary *retDict = _responseObject ? [_responseObject mutableCopy] : [NSMutableDictionary dictionary];
	[retDict setObject:inData forKey:SMARTResponseDataKey];
	
	// set response Content-Type
	if ([aResponse isKindOfClass:[NSHTTPURLResponse class]]) {
		[retDict setObject:[[(NSHTTPURLResponse *)aResponse allHeaderFields] objectForKey:@"Content-Type"] forKey:SMARTResponseContentTypeKey];
	}
	
	self.responseObject = retDict;
	[self didFinishSuccessfully:YES returnObject:_responseObject];
}

- (void)connectionFailedWithResponse:(NSURLResponse *)aResponse error:(NSError *)inError
{
	// get the correct error (if we have one in responseObject alread, we ignore inError)
	NSError *prevError = [_responseObject objectForKey:SMARTErrorKey];
	NSError *actualError = prevError ? prevError : inError;
	DLog(@"%@ to server %@  method: %@ failed  xxxxx  %@", _HTTPMethod, _server.url, _method, [actualError localizedDescription]);
	
	// we should arrive here if the token was rejected
	if (_retryWithNewTokenAfterFailure) {
		[_server authenticate:^(BOOL userDidCancel, NSString *__autoreleasing errorMessage) {
			if (userDidCancel || errorMessage) {
				NSError *error = actualError;
				if (errorMessage) {
					ERR(&error, errorMessage, 403);
				}
				[self authenticationDidFailWithError:error];
			}
			else {
				[self authenticationDidSucceed];
			}
		}];
		return;
	}
	
	// set the response object
	if (!prevError) {
		self.responseObject = [NSDictionary dictionaryWithObject:inError forKey:SMARTErrorKey];
	}
	else {
		DLog(@"Failed with error %@, but will return previously encountered error %@", inError, prevError);
	}
	[self didFinishSuccessfully:NO returnObject:_responseObject];
}



#pragma mark - Utilities
- (BOOL)isAuthenticationCall
{
	return (nil == _method);			// seems hackish...
}

- (NSString *)description
{
	NSString *action = _method ? [@"\n" stringByAppendingString:_method] : @"Authentication";
	NSString *bodyString = _body ? [@"\n" stringByAppendingString:_body] : @"";
	NSString *paramString = _parameters ? [NSString stringWithFormat:@" with %@", _parameters] : @"";
	return [NSString stringWithFormat:@"%@ <%p> %@: \"%@\"%@%@", NSStringFromClass([self class]), self, _HTTPMethod, action, paramString, bodyString];
}


@end
