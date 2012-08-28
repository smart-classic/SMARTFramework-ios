/*
 INURLLoader.h
 IndivoFramework
 
 Created by Pascal Pfiffner on 10/13/11.
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

#import "INURLLoader.h"

@interface INURLLoader ()

@property (nonatomic, copy) INCancelErrorBlock callback;
@property (nonatomic, strong) NSMutableData *loadingCache;
@property (nonatomic, readwrite, copy) NSData *responseData;
@property (nonatomic, readwrite, copy) NSString *responseString;
@property (nonatomic, readwrite, assign) NSUInteger responseStatus;

@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSURLResponse *currentResponse;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong) NSTimer *timeout;

- (void)prepareWithCallback:(INCancelErrorBlock)aCallback;
- (void)didFinishWithError:(NSError *)anError wasCancelled:(BOOL)didCancel;
- (void)didTimeout:(NSTimer *)timer;

@end


@implementation INURLLoader

@synthesize url, callback, loadingCache;
@synthesize responseData, responseString, responseStatus;
@synthesize currentConnection, currentResponse, timeoutInterval, timeout;
@synthesize expectBinaryData;


- (id)initWithURL:(NSURL *)anURL
{
	if ((self = [super init])) {
		self.url = anURL;
	}
	return self;
}

+ (id)loaderWithURL:(NSURL *)anURL
{
	return [[self alloc] initWithURL:anURL];
}



#pragma mark - URL Loading
/**
 *  Praparations before beginning to load.
 *  This method is automatically called in performRequest:withCallback:, you most likely do not need to call it manually.
 *  @param aCallback The callback block to execute after loading has finished
 */
- (void)prepareWithCallback:(INCancelErrorBlock)aCallback
{
	self.responseData = nil;
	self.responseString = nil;
	self.responseStatus = 1000;
	self.currentConnection = nil;
	self.currentResponse = nil;
	self.callback = aCallback;
	[timeout invalidate];
	self.timeout = nil;
	self.loadingCache = [NSMutableData data];
}

/**
 *  Start loading data from an URL
 *  @param aCallback The callback block to execute after loading has finished
 */
- (void)getWithCallback:(INCancelErrorBlock)aCallback
{
	if (!url) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(aCallback, NO, @"No URL given");
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setTimeoutInterval:kINURLLoaderDefaultTimeoutInterval];
	
	[self performRequest:request withCallback:aCallback];
}

/**
 *  POST body values to our URL
 *  @param postBody The HTTP-body to post
 *  @param aCallback The callback block to execute after loading has finished
 */
- (void)post:(NSString *)postBody withCallback:(INCancelErrorBlock)aCallback
{
	if (!url) {
		CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(aCallback, NO, @"No URL given");
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.HTTPMethod = @"POST";
	request.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];			/// @todo Should we URL encode this?
	[request setTimeoutInterval:kINURLLoaderDefaultTimeoutInterval];
	
	[self performRequest:request withCallback:aCallback];
}

/**
 *  Perform an NSURLRequest asynchronically.
 *  This method is internally used as the endpoint of all convenience methods, all load operations start here.
 *  @param aRequest The request to be performed
 *  @param aCallback The callback block to execute after loading has finished
 */
- (void)performRequest:(NSURLRequest *)aRequest withCallback:(INCancelErrorBlock)aCallback
{
	if (!url) {
		self.url = aRequest.URL;
		if (!url) {
			CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(aCallback, NO, @"No URL given");
			return;
		}
	}
	
	// prepare and set a timeout timer manually
	[self prepareWithCallback:aCallback];
	self.timeoutInterval = fmin(kINURLLoaderDefaultTimeoutInterval, aRequest.timeoutInterval);
	self.timeout = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval target:self selector:@selector(didTimeout:) userInfo:nil repeats:NO];
	
	self.currentConnection = [NSURLConnection connectionWithRequest:aRequest delegate:self];
}


/**
 *  This finishing method creates an NSString from any loaded data and calls the callback, if one was given
 *  @param anError The error that was encountered, if any
 *  @param didCancel Is set to YES if the call was cancelled
 */
- (void)didFinishWithError:(NSError *)anError wasCancelled:(BOOL)didCancel
{
	[timeout invalidate];
	self.timeout = nil;
	
	// extract response
	if ([loadingCache length] > 0) {
		if ([currentResponse isKindOfClass:[NSHTTPURLResponse class]]) {
			self.responseStatus = [(NSHTTPURLResponse *)currentResponse statusCode];
		}
		
		// extract response string
		self.responseData = loadingCache;
		self.loadingCache = nil;
		if (!expectBinaryData) {
			self.responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		}
	}
	
	// finish up
	CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(callback, didCancel, [anError localizedDescription]);
	self.callback = nil;
	self.currentConnection = nil;
}


/**
 *  Our timer calls this method when the time is up
 *  @param timer The timer that timed out
 */
- (void)didTimeout:(NSTimer *)timer
{
	[self.currentConnection cancel];
	self.loadingCache = nil;
	
	[self didFinishWithError:nil wasCancelled:YES];
}


/**
 *  Aborting the loader
 */
- (void)cancel
{
	[self didTimeout:nil];
}



#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.currentResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[loadingCache appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self didFinishWithError:nil wasCancelled:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (!error) {
		error = nil;
		ERR(&error, @"Unknown Error", 0);
	}
	[self didFinishWithError:error wasCancelled:NO];
}



#pragma mark - Parsing URL Requests
/**
 *  Parses arguments from a request
 *  @param aRequest The request to search for arguments/parameter
 *  @return An NSDictionary containing all arguments found in the request
 */
+ (NSDictionary *)queryFromRequest:(NSURLRequest *)aRequest
{
	NSString *queryString = [aRequest.URL query];
	
	/// @todo look in header and body for more arguments
	
	return [self queryFromRequestString:queryString];
}


/**
 *  Parses arguments from a request URL string
 *  @param aString A string in the form "key=value&foo=bar" that should be parsed into a dictionary
 *  @return An NSDictionary containing all arguments found in the request string
 */
+ (NSDictionary *)queryFromRequestString:(NSString *)aString
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// parse args
	NSArray *params = [aString componentsSeparatedByString:@"&"];
	if ([params count] > 0) {
		for (NSString *param in params) {
			NSArray *hat = [param componentsSeparatedByString:@"="];
			if ([hat count] > 1) {
				NSString *key = [hat objectAtIndex:0];
				hat = [hat mutableCopy];
				[(NSMutableArray *)hat removeObjectAtIndex:0];
				NSString *val = [hat componentsJoinedByString:@"="];	// we split by '=', which SHOULD only occur once, but may occur more than that
				
				[dict setObject:[val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:key];
			}
		}
	}
	
	return dict;
}


@end
