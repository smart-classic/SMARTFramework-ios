/*
 SMLoginViewController.h
 SMARTFramework
 
 Created by Pascal Pfiffner on 9/12/11.
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


#import "SMLoginViewController.h"
#import "SMART.h"
#import "INURLLoader.h"
#import "IndivoActionView.h"


@interface SMLoginViewController ()

@property (nonatomic, readwrite, assign) UIWebView *webView;
@property (nonatomic, readwrite, assign) UINavigationBar *titleBar;
@property (nonatomic, readwrite, assign) UINavigationItem *titleItem;
@property (nonatomic, readwrite, assign) UIBarButtonItem *backButton;
@property (nonatomic, readwrite, assign) UIBarButtonItem *cancelButton;

@property (nonatomic, assign) BOOL userDidLogout;

@property (nonatomic, strong) NSMutableArray *history;					///< Holds NSURLs (currently only used to reload the last page when an error occurred)
@property (nonatomic, strong) IndivoActionView *loadingView;			///< A private view overlaid during loading activity

- (void)showHideBackButton;
- (void)showStillLoadingHint;

@end


@implementation SMLoginViewController


/**
 *  The designated initializer
 */
- (id)init
{
	return [super initWithNibName:nil bundle:nil];
}



#pragma mark - View lifecycle
- (void)loadView
{
	self.title = @"SMART EMR";
	
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	appFrame.origin = CGPointZero;
	
	// the view
	UIView *v = [[UIView alloc] initWithFrame:appFrame];
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	v.backgroundColor = [UIColor whiteColor];
	
	//** navigation bar with cancel button
	UIBarButtonItem *cButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.title];
	navItem.rightBarButtonItem = cButton;
	self.cancelButton = cButton;
	self.titleItem = navItem;
	
	CGRect barFrame = CGRectMake(0.f, 0.f, appFrame.size.width, 44.f);
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:barFrame];
	navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	navBar.tintColor = [UIColor colorWithRed:0.42f green:0.69f blue:0.83f alpha:1.f];
	[navBar setItems:[NSArray arrayWithObject:_titleItem] animated:NO];
	self.titleBar = navBar;
	
	//** the web view
	appFrame.size.height -= barFrame.size.height;
	appFrame.origin.y = barFrame.size.height;
	UIWebView *wv = [[UIWebView alloc] initWithFrame:appFrame];
	wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	wv.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	wv.delegate = self;
	self.webView = wv;
	
	// compose
	[v addSubview:_webView];
	[v addSubview:_titleBar];
	self.view = v;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	_webView.delegate = nil;
	self.webView = nil;
	[_loadingView removeFromSuperview];
	self.loadingView = nil;
	
	self.titleBar = nil;
	self.titleItem = nil;
	self.backButton = nil;
	self.cancelButton = nil;
}

/*
 *  If the view appears and has never loaded a URL, we load the startURL or show a hint if there is none.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([_history count] < 1) {
		if (self.startURL) {
			[self loadURL:self.startURL];
		}
		else {
			[self.webView loadHTMLString:@"No URL" baseURL:nil];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Loading and Web View Delegate
/**
 *  Loads a given URL
 *  @param aURL The URL to load
 */
- (void)loadURL:(NSURL *)aURL
{
	NSURLRequest *request = [NSURLRequest requestWithURL:aURL];
	[self.webView loadRequest:request];
}

/**
 *  Reloads current URL
 *  @param sender The button sending the action (can be nil)
 */
- (void)reload:(id)sender
{
	if (_loadingView) {
		[_loadingView showSpinnerAnimated:YES];
		[_loadingView hideHintTextAnimated:YES];
	}
	[self loadURL:[_history lastObject]];
}

/**
 *  Reloads after a delay of half a second.
 *  This is needed to update the loading view so that the user sees that something happened, even if an error occurs immediately after reloading.
 *  @param sender The button sending the action (can be nil)
 */
- (void)reloadDelayed:(id)sender
{
	if (_loadingView) {
		[_loadingView showSpinnerAnimated:YES];
		[_loadingView hideHintTextAnimated:YES];
	}
	[self performSelector:@selector(reload:) withObject:sender afterDelay:0.5];
}


/*
 *  We intercept requests here
 */
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (aWebView != _webView) {
		return NO;
	}
	
	// intercept internal callbacks
	if ([[request.URL scheme] isEqualToString:[_delegate callbackSchemeForLoginView:self]]) {
		NSArray *urlComponents = [request.URL pathComponents];
		
		// ** callbacks are also called after logout - intercept here
		if (_userDidLogout) {
			[_delegate loginViewDidLogout:self];
			return NO;
		}
		
		// ** user did select a record
		if ([@"did_select_record" isEqualToString:[urlComponents lastObject]]) {
			NSDictionary *args = [INURLLoader queryFromRequest:request];
			//DLog(@"DID RECEIVE: %@", args);
			[_delegate loginView:self didSelectRecordId:[args objectForKey:@"record_id"]];
			// extract carenet_id here once supported
			return NO;
		}
		
		// ** received oauth verifier
		if ([@"did_receive_verifier" isEqualToString:[urlComponents lastObject]]) {
			NSDictionary *args = [INURLLoader queryFromRequest:request];
			//DLog(@"DID RECEIVE: %@", args);
			[_delegate loginView:self didReceiveVerifier:[args objectForKey:@"oauth_verifier"]];
			return NO;
		}
	}
	
	// show loading indicator if loading from web
	if (![[request.URL scheme] isEqualToString:@"file"]) {
		[self showLoadingIndicator:nil];
	}
	
	// intercept logout
	if ([@"logout" isEqualToString:[[request.URL pathComponents] lastObject]]) {
		_userDidLogout = YES;
	}
	
	// handle history
	if (UIWebViewNavigationTypeFormSubmitted == navigationType || UIWebViewNavigationTypeLinkClicked == navigationType) {
		[self.history addObject:request.URL];
	}
	
	// we're at the initial page
	else if ([_history count] < 1) {
		[self.history addObject:request.URL];
		
		/* delete old cookies for our URL, they might interfere
		NSHTTPCookieStorage *jar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (NSHTTPCookie *cookie in [jar cookiesForURL:self.startURL]) {
			[jar deleteCookie:cookie];
		}	//	*/
	}
	
//	[self showHideBackButton];
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	// did we logout?
	if (_userDidLogout) {
		[_delegate loginViewDidLogout:self];
	}
	
	[self hideLoadingIndicator:nil];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	// don't show cancel message
	if ([[error domain] isEqualToString:NSURLErrorDomain] && NSURLErrorCancelled == [error code]) {
		return;
	}
	
	// this is an interrupt error that we are provoking, don't display (figure out the constant for "WebKitErrorFrameLoadInterruptedByPolicyChange")
	if ([[error domain] isEqualToString:@"WebKitErrorDomain"] && 102 == [error code]) {
		return;
	}
	
	// show error
	if (_loadingView && error) {
		[_loadingView showIn:_webView mainText:[error localizedDescription] hintText:@"Tap to try again" animated:YES];
	}
	else {
		DLog(@"Failed loading URL: %@", [error localizedDescription]);
	}
}



#pragma mark - Dismissal
/**
 *  Dismisses the login view as a cancel operation
 *  @param sender The button sending the action (can be nil)
 */
- (void)cancel:(id)sender
{
	[_delegate loginViewDidCancel:self];		// this will also dismiss the view controller
}

/**
 *  Dismisses the view.
 *  The dismissal will be animated if sender is not nil.
 *  @param sender The button sending the action (can be nil)
 */
- (void)dismiss:(id)sender
{
	[self dismissAnimated:(nil != sender)];
}

/**
 *  Dismisses the view controller
 *  @param animated A BOOL indicating whether the dismissal should be animated
 */
- (void)dismissAnimated:(BOOL)animated
{
	[_webView stopLoading];
	[self hideLoadingIndicator:nil];
	
	if ([self respondsToSelector:@selector(presentingViewController)]) {			// iOS 5+ only
		[[self presentingViewController] dismissViewControllerAnimated:animated completion:NULL];
	}
	else {
		[[self parentViewController] dismissModalViewControllerAnimated:animated];
	}
}



#pragma mark - History
/**
 *  Go back in time.
 *  @param sender The button sending the action (can be nil)
 */
- (void)goBack:(id)sender
{
	[_webView stopLoading];
	if ([_history count] > 1) {
		[_history removeLastObject];
		[self loadURL:[_history lastObject]];
	}
}

/**
 *  Show or hide the back button based on whether we have history URLs or not.
 */
- (void)showHideBackButton
{
	if ([_history count] > 1) {
		_titleItem.leftBarButtonItem = self.backButton;
	}
	else {
		_titleItem.leftBarButtonItem = nil;
	}
}



#pragma mark - KVC
/*
 *  Setting the startURL when the view is already loaded loads that URL, if nothing else has been loaded.
 */
- (void)setStartURL:(NSURL *)newURL
{
	if (newURL != _startURL) {
		_startURL = newURL;
		
		if (_startURL && [self isViewLoaded] && [_history count] < 1) {
			[self loadURL:self.startURL];
		}
	}
}

- (NSMutableArray *)history
{
	if (!_history) {
		self.history = [NSMutableArray array];
	}
	return _history;
}

- (void)setTitle:(NSString *)newTitle
{
	_titleItem.title = newTitle;
	[super setTitle:newTitle];
}

- (UIBarButtonItem *)backButton
{
	if (!_backButton) {
		UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack:)];
		self.backButton = bb;
	}
	return _backButton;
}



#pragma mark - Progress Indicator
/**
 *  <#comment#>
 *  @param sender The button sending the action (can be nil)
 */
- (void)showLoadingIndicator:(id)sender
{
	if (!_loadingView) {
		self.loadingView = [[IndivoActionView alloc] initWithFrame:_webView.bounds];
		[_loadingView addTarget:self action:@selector(reloadDelayed:) forControlEvents:UIControlEventTouchUpInside];
	}
	[_loadingView showActivityIn:_webView animated:YES];
	
	// timer to show loading details if it takes long
	[self performSelector:@selector(showStillLoadingHint) withObject:nil afterDelay:8.0];
}

- (void)showStillLoadingHint
{
	if (_webView.loading && _webView == [_loadingView superview]) {
		NSString *hintText = [NSString stringWithFormat:@"Still contacting %@", ([_history count] > 0) ? ((NSURL *)[_history lastObject]).host : @"server"];
		[_loadingView showHintText:hintText animated:YES];
	}
}

/**
 *  <#comment#>
 *  @param sender The button sending the action (can be nil)
 */
- (void)hideLoadingIndicator:(id)sender
{
	[_loadingView removeFromSuperview];
	self.loadingView = nil;
}


@end
