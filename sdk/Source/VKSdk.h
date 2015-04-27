//
//  VKSdk.h
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
//
//  --------------------------------------------------------------------------------
//
//  Modified by Ruslan Kavetsky

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
#import "VKUploadImage.h"
#import "VKShareDialogController.h"
#import "VKActivity.h"

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

/**
Requests delegate about redirect to Safari during authorization procedure.
By default returns YES
*/
- (BOOL)vkSdkAuthorizationAllowFallbackToSafari;

/**
Applications which not using VK SDK as main way of authentication should override this method and return NO.
By default returns YES.
*/
- (BOOL)vkSdkIsBasicAuthorization;

/**
* Called when a controller presented by SDK will be dismissed
*/
- (void)vkSdkWillDismissViewController:(UIViewController *)controller;

/**
* Called when a controller presented by SDK did dismiss
*/
- (void)vkSdkDidDismissViewController:(UIViewController *)controller;
@end

/**
Entry point for using VK sdk. Should be initialized at application start
*/
@interface VKSdk : NSObject

///-------------------------------
/// @name Delegate
///-------------------------------

/// Responder for global SDK events
@property(nonatomic, weak) id <VKSdkDelegate> delegate;

/// Returns a last app_id used for initializing the SDK
@property(nonatomic, readonly, copy) NSString *currentAppId;

/// API version for making requests
@property(nonatomic, readonly, copy) NSString *apiVersion;
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
+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate
                      andAppId:(NSString *)appId;

/**
Initialize SDK with responder for global SDK events and custom token key
(e.g., saved from other source or for some test reasons)
@param delegate responder for global SDK events
@param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
@param token custom-created access token
*/
+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate
                      andAppId:(NSString *)appId
                andCustomToken:(VKAccessToken *)token DEPRECATED_ATTRIBUTE;

/**
Initialize SDK with responder for global SDK events
@param delegate responder for global SDK events
@param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
@param apiVersion if you want to use latest API version, pass required version here
*/
+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate
                      andAppId:(NSString *)appId
                    apiVersion:(NSString *)version;

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
Starts authorization process.
@param permissions Array of permissions for your applications. All permissions you can
@param revokeAccess If YES, user will allow logout (to change user)
@param forceOAuth If YES, SDK will use only oauth authorization through mobile safari. Otherwise, it will try to authorize through VK application
*/
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth;

/**
Starts authorization process.
@param permissions Array of permissions for your applications. All permissions you can
@param revokeAccess If YES, user will allow logout (to change user)
@param forceOAuth If YES, SDK will use only oauth authorization through mobile safari. Otherwise, it will try to authorize through VK application
@param inApp If YES, SDK will try to open modal window with webview to authorize. This method strongly not recommended as user should enter his account data in your application. For use modal view add VKSdkResources.bundle to your project.
*/
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL)inApp;

/**
Starts authorization process.
@param permissions Array of permissions for your applications. All permissions you can
@param revokeAccess If YES, user will allow logout (to change user)
@param forceOAuth If YES, SDK will use only oauth authorization through mobile safari. Otherwise, it will try to authorize through VK application
@param inApp If YES, SDK will try to open modal window with webview to authorize. This method strongly not recommended as user should enter his account data in your application. For use modal view add VKSdkResources.bundle to your project.
@param displayType Defines view of authorization screen
*/
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL)inApp display:(VKDisplayType)displayType;

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
+ (BOOL)isLoggedIn;

/**
 Make try to read token from defaults and start session again.
 */
+ (BOOL)wakeUpSession;
/**
 Try to read token from defaults, then check for required permissions.
 */
+ (BOOL)wakeUpSession:(NSArray *)permissions;

/**
Forces logout using OAuth (with VKAuthorizeController). Removes all cookies for *.vk.com.
Has no effect for logout in VK app
*/
+ (void)forceLogout;

/**
* Checks if there is some application, which may process authorize url
*/
+ (BOOL)vkAppMayExists;

/**
Check existing permissions
@param permissions array of permissions you want to check
*/
+ (BOOL)hasPermissions:(NSArray *)permissions;

/**
Enables or disables scheduling for requests
*/
+ (void)setSchedulerEnabled:(BOOL)enabled;

// Deny allocating more SDK
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call initialize: or instance instead")));

- (instancetype)init __attribute__((unavailable("init not available, call initialize: or instance instead")));

+ (instancetype)new __attribute__((unavailable("new not available, call initialize: or instance instead")));


@end
