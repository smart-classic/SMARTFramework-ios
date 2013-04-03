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


#import <UIKit/UIKit.h>

@class SMLoginViewController;


/**
 *  A protocol to receive notifications from an SMLoginViewController
 */
@protocol SMLoginViewControllerDelegate <NSObject>

/**
 *  Called when the user selected a record.
 *  @param aLoginController The login controller from which the user did select the record
 *  @param recordId The id for the record
 */
- (void)loginView:(SMLoginViewController *)aLoginController didSelectRecordId:(NSString *)recordId;

/**
 *  Called when the login screen gets called with our verifier callback URL.
 *  @param aLoginController The login controller that received the verifier
 *  @param aVerifier The verifier
 */
- (void)loginView:(SMLoginViewController *)aLoginController didReceiveVerifier:(NSString *)aVerifier;

/**
 *  Called when the user dismisses the login screen, i.e. cancels the record selection process.
 *  @param aLoginController The login controller that did cancel
 */
- (void)loginViewDidCancel:(SMLoginViewController *)aLoginController;

/**
 *  Called when the user logged out.
 *  This is your chance to discard cached data
 *  @param aLoginController The login controller from which the user logged out
 */
- (void)loginViewDidLogout:(SMLoginViewController *)aLoginController;

/**
 *  The scheme for URL that we catch internally (by default this is "smart-app").
 *  @param aLoginController The login controller that asks for the scheme
 */
- (NSString *)callbackSchemeForLoginView:(SMLoginViewController *)aLoginController;

@end


/**
 *  This class provides the view controller to log the user in
 */
@interface SMLoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id <SMLoginViewControllerDelegate> delegate;			//< The delegate to receive callbacks
@property (nonatomic, strong) NSURL *startURL;										//< The URL to load initially

@property (nonatomic, readonly, assign) UIWebView *webView;							//< The web view to present HTML
@property (nonatomic, readonly, assign) UINavigationBar *titleBar;					//< A handle to the title bar being displayed
@property (nonatomic, readonly, assign) UIBarButtonItem *backButton;				//< To navigate back
@property (nonatomic, readonly, assign) UIBarButtonItem *cancelButton;				//< The cancel button which dismisses the login view

- (void)loadURL:(NSURL *)aURL;
- (void)reload:(id)sender;
- (void)cancel:(id)sender;
- (void)dismiss:(id)sender;
- (void)dismissAnimated:(BOOL)animated;

- (void)showLoadingIndicator:(id)sender;
- (void)hideLoadingIndicator:(id)sender;


@end
