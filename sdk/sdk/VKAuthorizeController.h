//
//  VKAuthorizeController.h
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

#import <UIKit/UIKit.h>
#import "VKSdk.h"
/**
 Controller for authorization through webview (if VK app not available)
 */
@interface VKAuthorizeController : UIViewController <UIWebViewDelegate>

/**
 Causes UIWebView in standard UINavigationController be presented in SDK delegate
 @param appId Identifier of VK application
 @param permissions Permissions that user specified for application
 @param revoke If YES, user will see permissions list and allow to logout (if logged in already)
 @param displayType Defines view of authorization screen
 */
+ (void)presentForAuthorizeWithAppId:(NSString *)appId
                      andPermissions:(NSArray *)permissions
                        revokeAccess:(BOOL)revoke
                         displayType:(VKDisplayType) displayType;
/**
 Causes UIWebView in standard UINavigationController be presented for user validation
 @param validationError validation error returned by API
 */
+ (void)presentForValidation:(VKError *)validationError;
/**
 Builds url for oauth authorization
 @param redirectUri uri for redirect
 @param clientId id of your application
 @param scope requested scope for application
 @param revoke If YES, user will see permissions list and allow to logout (if logged in already)
 @param display select display type
 @return Complete url-string for grant authorization
 */
+ (NSString *)buildAuthorizationUrl:(NSString *)redirectUri
                           clientId:(NSString *)clientId
                              scope:(NSString *)scope
                             revoke:(BOOL)revoke
                            display:(VKDisplayType)display;
@end
