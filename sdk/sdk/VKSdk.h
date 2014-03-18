//
//  sdk.h
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@import Foundation;
@import UIKit;
#import <Foundation/Foundation.h>
#import "VKAccessToken.h"
#import "VKPermissions.h"
#import "VKUtil.h"
#import "VKApi.h"
#import "VKApiConst.h"
#import "VKSdkVersion.h"
#import "VKCaptchaViewController.h"
#import "VKRequest.h"
#import "VKBatchRequest.h"
#import "NSError+VKError.h"
#import "VKApiModels.h"

/**
 Global SDK events delegate protocol.
 You should implement it, typically as main view controller or as application delegate.
 */
@protocol VKSdkDelegate <NSObject>
@required
/**
 Calls when user must perform captcha-check
 @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
 After user answered current captcha, call answerCaptcha: method with user entered answer.
 */
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError;

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken;

/**
 Notifies delegate about user authorization cancelation
 @param authorizationError error that describes authorization error
 */
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError;

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller;

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken;

@optional
/**
 Notifies delegate about receiving predefined token (initializeWithDelegate:andAppId:andCustomToken: token is not nil)
 @param token used token for API requests
 */
- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token;
/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkRenewedToken:(VKAccessToken *)newToken;

@end

/**
 Entry point for using VK sdk. Should be initialized at application start
 */
@interface VKSdk : NSObject
{
@private
	VKAccessToken *_accessToken;            ///< access token for API-requests
	NSString *_currentAppId;                ///< app id for current application
}
///-------------------------------
/// @name Delegate
///-------------------------------

/// Responder for global SDK events
@property (nonatomic, weak) id <VKSdkDelegate> delegate;

///-------------------------------
/// @name Initialization
///-------------------------------
/**
 Returns instance of VK sdk. You should never use that directly
 */
+ (instancetype)instance;
/**
 Initialize SDK with responder for global SDK events
 @param delegate responder for global SDK events
 @param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
 */
+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate
                      andAppId:(NSString *)appId;
/**
 Initialize SDK with responder for global SDK events and custom token key
 (e.g., saved from other source or for some test reasons)
 @param delegate responder for global SDK events
 @param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
 @param token custom-created access token
 */
+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate
                      andAppId:(NSString *)appId
                andCustomToken:(VKAccessToken *)token;

///-------------------------------
/// @name Authentication in VK
///-------------------------------

/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions array of permissions for your applications. All permissions you can
 */
+ (void)authorize:(NSArray *)permissions;

/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions Array of permissions for your applications. All permissions you can
 @param revokeAccess If YES, user will allow logout (to change user)
 */
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess;
/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions Array of permissions for your applications. All permissions you can
 @param revokeAccess If YES, user will allow logout (to change user)
 @param forceOAuth SDK will use only oauth authorization, through uiwebview
 */
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth;

/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions Array of permissions for your applications. All permissions you can
 @param revokeAccess If YES, user will allow logout (to change user)
 @param forceOAuth SDK will use only oauth authorization, through uiwebview
 @param inApp If YES, SDK will try to open modal window with webview to authorize. This method strongly not recommended as user should enter his account data in your application. For use modal view add VKSdkResources.bundle to your project.
 */
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp;

/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions Array of permissions for your applications. All permissions you can
 @param revokeAccess If YES, user will allow logout (to change user)
 @param forceOAuth SDK will use only oauth authorization, through uiwebview
 @param inApp If YES, SDK will try to open modal window with webview to authorize. This method strongly not recommended as user should enter his account data in your application. For use modal view add VKSdkResources.bundle to your project.
 @param displayType Defines view of authorization screen
 */
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp display:(VKDisplayType) displayType;

///-------------------------------
/// @name Access token methods
///-------------------------------

/**
 Set API token to passed
 @param token token must be used for API requests
 */
+ (void)setAccessToken:(VKAccessToken *)token;

/**
 Notify SDK that user denied login
 @param error Descripbes error which was happends while trying to recieve token
 */
+ (void)setAccessTokenError:(VKError *)error;

/**
 Returns token for API requests
 @return Received access token or nil, if user not yet authorized
 */
+ (VKAccessToken *)getAccessToken;

///-------------------------------
/// @name Other methods
///-------------------------------

/**
 Checks passed URL for access token
 @param passedUrl url from external application
 @param sourceApplication source application
 @return YES if parsed successfully
 */
+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication;

/**
 * Checks if somebody logged in with SDK
 */
+ (BOOL) isLoggedIn;
/**
 Make try to read token from defaults and start session again.
 */
+ (BOOL) wakeUpSession;
/**
 Forces logout using OAuth (with VKAuthorizeController). Removes all cookies for *.vk.com.
 Has no effect for logout in VK app
 */
+ (void) forceLogout;
// Deny allocating more SDK
#ifndef DOXYGEN_SHOULD_SKIP_THIS
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call initialize: or instance instead")));

- (instancetype)init __attribute__((unavailable("init not available, call initialize: or instance instead")));

+ (instancetype)new __attribute__((unavailable("new not available, call initialize: or instance instead")));

#endif /* DOXYGEN_SHOULD_SKIP_THIS */
@end
