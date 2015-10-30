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
#import "VKAuthorizationResult.h"

typedef NS_OPTIONS(NSUInteger, VKAuthorizationOptions) {
    VKAuthorizationOptionsUnlimitedToken = 1 << 0,
    VKAuthorizationOptionsDisableSafariController = 1 << 1,
};

typedef NS_ENUM(NSUInteger, VKAuthorizationState) {
    VKAuthorizationUnknown, // Authorization state unknown, probably something went wrong
    VKAuthorizationInitialized, // SDK initialized and ready to authorize
    VKAuthorizationPending, // Authorization state pending, probably we're trying to load auth information
    VKAuthorizationExternal, // Started external authorization process
    VKAuthorizationSafariInApp, // Started in app authorization process, using SafariViewController
    VKAuthorizationWebview, // Started in app authorization process, using webview
    VKAuthorizationAuthorized, // User authorized
    VKAuthorizationError, // An error occured, try to wake up session later
};

/**
 SDK events delegate protocol.
 You should implement it, typically as main view controller or as application delegate.
*/
@protocol VKSdkDelegate <NSObject>
@required

/**
 Notifies delegate about authorization was completed successfully, and token received
 @param result contains new token or error, retrieved after VK authorization
 */
- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result;

/**
 Notifies delegate about access error, mostly connected with user deauthorized application
 */
- (void)vkSdkUserAuthorizationFailed:(VKError *)result;

@optional

/**
 Notifies delegate about access token changed
 @param newToken new token for API requests
 @param oldToken previous used token
 */
- (void)vkSdkAccessTokenUpdated:(VKAccessToken *)newToken oldToken:(VKAccessToken *)oldToken;

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken;

@end


@protocol VKSdkUIDelegate <NSObject>
/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller;

/**
 Calls when user must perform captcha-check
 @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
 After user answered current captcha, call answerCaptcha: method with user entered answer.
 */
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError;

@optional
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
@property(nonatomic, readwrite, weak) id <VKSdkUIDelegate> uiDelegate;

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
Initialize SDK with responder for global SDK events with default api version from VK_SDK_API_VERSION
@param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
*/
+ (instancetype)initializeWithAppId:(NSString *)appId;

/**
Initialize SDK with responder for global SDK events
@param appId your application id (if you haven't, you can create standalone application here https://vk.com/editapp?act=create )
@param apiVersion if you want to use latest API version, pass required version here
*/
+ (instancetype)initializeWithAppId:(NSString *)appId
                         apiVersion:(NSString *)version;

/**
 Adds a weak object reference to an object implementing the VKSdkDelegate protocol
 */
- (void)registerDelegate:(id <VKSdkDelegate>)delegate;

/**
 Removes an object reference SDK delegate
 */
- (void)unregisterDelegate:(id <VKSdkDelegate>)delegate;

///-------------------------------
/// @name Authentication in VK
///-------------------------------

/**
Starts authorization process to retrieve unlimited token. If VKapp is available in system, it will opens and requests access from user.
Otherwise Mobile Safari will be opened for access request.
@param permissions array of permissions for your applications. All permissions you can
*/
+ (void)authorize:(NSArray *)permissions;

/**
 Starts authorization process. If VKapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions array of permissions for your applications. All permissions you can
 @param options special options
 */
+ (void)authorize:(NSArray *)permissions withOptions:(VKAuthorizationOptions)options;

///-------------------------------
/// @name Access token methods
///-------------------------------

/**
Returns token for API requests
@return Received access token or nil, if user not yet authorized
*/
+ (VKAccessToken *)accessToken;

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
 Checks if somebody logged in with SDK (call after wakeUpSession)
 */
+ (BOOL)isLoggedIn;

/**
 This method is trying to retrieve token from storage, and check application still permitted to use user access token
 */
+ (void)wakeUpSession:(NSArray *)permissions completeBlock:(void (^)(VKAuthorizationState, NSError *))wakeUpBlock;

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
- (BOOL)hasPermissions:(NSArray *)permissions;

/**
Enables or disables scheduling for requests
*/
+ (void)setSchedulerEnabled:(BOOL)enabled;

// Deny allocating more SDK
+ (instancetype)alloc NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end

@interface VKAccessToken (HttpsRequired)
- (void)setAccessTokenRequiredHTTPS;

- (void)notifyTokenExpired;
@end

@interface VKError (CaptchaRequest)
- (void)notifyCaptchaRequired;

- (void)notiftAuthorizationFailed;
@end

@interface UIViewController (VKController)

- (void)vks_presentViewControllerThroughDelegate;

- (void)vks_viewControllerWillDismiss;

- (void)vks_viewControllerDidDismiss;

@end