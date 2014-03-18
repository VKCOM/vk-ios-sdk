//
//  sdk.m
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

#import "VKSdk.h"
#import "VKAuthorizeController.h"
@implementation VKSdk
@synthesize delegate = _delegate;
static VKSdk *vkSdkInstance = nil;
static NSString * VK_ACCESS_TOKEN_DEFAULTS_KEY = @"VK_ACCESS_TOKEN_DEFAULTS_KEY_DONT_TOUCH_THIS_PLEASE";
#pragma mark Initialization
+ (void)initialize {
	NSAssert([VKSdk class] == self, @"Subclassing is not welcome");
	vkSdkInstance = [[super alloc] initUniqueInstance];
}

+ (instancetype)instance {
	if (!vkSdkInstance) {
		[NSException raise:@"VKSdk should be initialized" format:@"Use [VKSdk initialize:delegate] method"];
	}
	return vkSdkInstance;
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId {
	[self initializeWithDelegate:delegate andAppId:appId andCustomToken:nil];
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId andCustomToken:(VKAccessToken *)token {
	vkSdkInstance->_delegate            = delegate;
	vkSdkInstance->_currentAppId        = appId;
    
	if (token) {
		vkSdkInstance->_accessToken     = token;
		if ([delegate respondsToSelector:@selector(vkSdkAcceptedUserToken:)]) {
			[delegate vkSdkAcceptedUserToken:token];
		}
	}
}

- (instancetype)initUniqueInstance {
	return [super init];
}

#pragma mark Authorization
+ (void)authorize:(NSArray *)permissions {
	[self authorize:permissions revokeAccess:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess {
	[self authorize:permissions revokeAccess:revokeAccess forceOAuth:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth {
    [self authorize:permissions revokeAccess:revokeAccess forceOAuth:forceOAuth inApp:NO];
}
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp;
{
	[self authorize:permissions revokeAccess:revokeAccess forceOAuth:forceOAuth inApp:inApp display:VK_DISPLAY_MOBILE];
}
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp display:(VKDisplayType) displayType {
    NSString *clientId = vkSdkInstance->_currentAppId;
    
    if (!inApp) {
        NSURL *urlToOpen = [NSURL URLWithString:
                            [NSString stringWithFormat:@"vkauth://authorize?client_id=%@&scope=%@&revoke=%d",
                             clientId,
                             [permissions componentsJoinedByString:@","], revokeAccess ? 1:0]];
        if (!forceOAuth && [[UIApplication sharedApplication] canOpenURL:urlToOpen])
            [[UIApplication sharedApplication] openURL:urlToOpen];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        [VKAuthorizeController buildAuthorizationUrl:[NSString stringWithFormat:@"vk%@://authorize", clientId]
                                                                                            clientId:clientId
                                                                                               scope:[permissions componentsJoinedByString:@","]
                                                                                              revoke:revokeAccess
                                                                                             display:@"mobile"]]];
    } else {
        //Authorization through popup webview
        [VKAuthorizeController presentForAuthorizeWithAppId:clientId
                                             andPermissions:permissions
                                               revokeAccess:revokeAccess
                                                displayType:displayType];
    }
}

#pragma mark Access token
+ (void)setAccessToken:(VKAccessToken *)token {
    [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    id oldToken = vkSdkInstance->_accessToken;
	vkSdkInstance->_accessToken = token;
    BOOL respondsToRenew = [vkSdkInstance->_delegate respondsToSelector:@selector(vkSdkRenewedToken:)],
         respondsToReceive = [vkSdkInstance->_delegate respondsToSelector:@selector(vkSdkReceivedNewToken:)];
    
    if (oldToken && respondsToRenew)
        [vkSdkInstance->_delegate vkSdkRenewedToken:token];
	if ((!oldToken || (oldToken && !respondsToRenew)) && respondsToReceive)
		[vkSdkInstance->_delegate vkSdkReceivedNewToken:token];
}

+ (void)setAccessTokenError:(VKError *)error {
	vkSdkInstance->_accessToken = nil;
	[vkSdkInstance->_delegate vkSdkUserDeniedAccess:error];
}

+ (VKAccessToken *)getAccessToken {
	return vkSdkInstance->_accessToken;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl {
	NSString *urlString = [passedUrl absoluteString];
	NSString *parametersString = [urlString substringFromIndex:[urlString rangeOfString:@"#"].location + 1];
	if (parametersString.length == 0) {
		VKError *error = [VKError errorWithCode:VK_API_CANCELED];
		[VKSdk setAccessTokenError:error];
		return NO;
	}
	NSDictionary *parametersDict = [VKUtil explodeQueryString:parametersString];
    
	if (parametersDict[@"error"] || parametersDict[@"fail"]) {
		VKError *error     = [VKError errorWithQuery:parametersDict];
		[VKSdk setAccessTokenError:error];
		return NO;
	}
	else if (parametersDict[@"success"]) {
		VKAccessToken *token = [VKSdk getAccessToken];
		token.accessToken   = parametersDict[@"access_token"];
		token.secret        = parametersDict[@"secret"];
		token.userId        = parametersDict[@"user_id"];
        [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
	}
	else {
		VKAccessToken *token = [VKAccessToken tokenFromUrlString:parametersString];
		[VKSdk setAccessToken:token];
	}
	return YES;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication {
	if ([sourceApplication isEqualToString:@"com.vk.odnoletkov.client"] ||
         [sourceApplication isEqualToString:@"com.vk.client"] ||
         ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] &&
        [passedUrl.scheme isEqualToString:[NSString stringWithFormat:@"vk%@", vkSdkInstance->_currentAppId]])
        )
		return [self processOpenURL:passedUrl];
	return NO;
}

+(void)forceLogout {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for (NSHTTPCookie *cookie in cookies)
        if (NSNotFound != [cookie.domain rangeOfString:@"vk.com"].location)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]
             deleteCookie:cookie];
        }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    vkSdkInstance->_accessToken = nil;
}
+(BOOL)isLoggedIn {
    if (vkSdkInstance->_accessToken && ![vkSdkInstance->_accessToken isExpired]) return true;
    return false;
}
+(BOOL)wakeUpSession {
    VKAccessToken * token = [VKAccessToken tokenFromDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    if (!token || token.isExpired)
        return NO;
    vkSdkInstance->_accessToken = token;
    return YES;
}

@end
