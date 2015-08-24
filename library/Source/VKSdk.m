//
//  VKSdk.m
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

#ifdef DEBUG

#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]

#else

#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)

#import "VKSdk.h"
#import "VKAuthorizeController.h"
#import "VKRequestsScheduler.h"

typedef enum : NSUInteger {
    VKAuthorizationInitialized = 1,
    VKAuthorizationVkApp = 1 << 1,
    VKAuthorizationWebview = 1 << 2,
    VKAuthorizationSafari = 1 << 3
} VKAuthorizationState;

@interface VKSdk ()

@property(nonatomic, assign) VKAuthorizationState authState;
@property(nonatomic, copy) NSString *currentAppId;
@property(nonatomic, readwrite, copy) NSString *apiVersion;
@property(nonatomic, strong) VKAccessToken *accessToken;
@property(nonatomic, strong) NSArray *permissions;

@end

@implementation VKSdk

static VKSdk *vkSdkInstance = nil;
static NSString *VK_ACCESS_TOKEN_DEFAULTS_KEY = @"VK_ACCESS_TOKEN_DEFAULTS_KEY_DONT_TOUCH_THIS_PLEASE";
static NSString *VK_AUTHORIZE_URL_STRING = @"vkauthorize://authorize";

#pragma mark Initialization

+ (void)initialize {
    ZAssert([VKSdk class] == self, @"Subclassing is not welcome");
}

+ (instancetype)instance {
    ZAssert(vkSdkInstance, @"VKSdk should be initialized. Use [VKSdk initialize:delegate] method");
    return vkSdkInstance;
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate andAppId:(NSString *)appId {
    [self initializeWithDelegate:delegate andAppId:appId apiVersion:VK_SDK_API_VERSION];
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate
                      andAppId:(NSString *)appId
                    apiVersion:(NSString *)version {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vkSdkInstance = [(VKSdk *) [super alloc] initUniqueInstance];
    });

    vkSdkInstance.delegate = delegate;
    vkSdkInstance.currentAppId = appId;
    vkSdkInstance.apiVersion = version;

    [[VKRequestsScheduler instance] setEnabled:YES];
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate>)delegate andAppId:(NSString *)appId andCustomToken:(VKAccessToken *)token {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vkSdkInstance = [(VKSdk *) [super alloc] initUniqueInstance];
    });

    vkSdkInstance.delegate = delegate;
    vkSdkInstance.currentAppId = appId;
    vkSdkInstance.apiVersion = VK_SDK_API_VERSION;

    if (token && token != vkSdkInstance.accessToken) {
        vkSdkInstance.accessToken = token;
        if ([delegate respondsToSelector:@selector(vkSdkAcceptedUserToken:)]) {
            [delegate vkSdkAcceptedUserToken:token];
        }
    }
    [[VKRequestsScheduler instance] setEnabled:YES];
}

- (instancetype)initUniqueInstance {
    self = [super init];
    self.authState = VKAuthorizationInitialized;
    return self;
}

#pragma mark Authorization

+ (void)authorize:(NSArray *)permissions {
    [self authorize:permissions revokeAccess:NO];
}

+ (void)authorize:(NSArray *)permissions
     revokeAccess:(BOOL)revokeAccess {

    [self authorize:permissions revokeAccess:revokeAccess forceOAuth:NO];
}

+ (void)authorize:(NSArray *)permissions
     revokeAccess:(BOOL)revokeAccess
       forceOAuth:(BOOL)forceOAuth {
    
    //pull #87
    if ([[VKSdk instance].delegate respondsToSelector:@selector(vkSdkAuthorizationAllowFallbackToSafari)]) {
        if (![[VKSdk instance].delegate vkSdkAuthorizationAllowFallbackToSafari])
            [VKSdk instance].authState = VKAuthorizationSafari;
    }

    //Если не VK app, то необходимо открыть сначала web view
    [self authorize:permissions
       revokeAccess:revokeAccess
         forceOAuth:forceOAuth
              inApp:![self vkAppMayExists] && [VKSdk instance].authState != VKAuthorizationSafari];
}

+ (void)authorize:(NSArray *)permissions
     revokeAccess:(BOOL)revokeAccess
       forceOAuth:(BOOL)forceOAuth
            inApp:(BOOL)inApp {

    [self authorize:permissions
       revokeAccess:revokeAccess
         forceOAuth:forceOAuth
              inApp:inApp
            display:VK_DISPLAY_MOBILE];
}

+ (void)authorize:(NSArray *)permissions
     revokeAccess:(BOOL)revokeAccess
       forceOAuth:(BOOL)forceOAuth
            inApp:(BOOL)inApp
          display:(VKDisplayType)displayType {

    if (![permissions containsObject:VK_PER_OFFLINE]) {
        permissions = [permissions mutableCopy];
        [(NSMutableArray *) permissions addObject:VK_PER_OFFLINE];
    }

    vkSdkInstance.permissions = permissions;

    NSString *clientId = vkSdkInstance.currentAppId;

    if (!inApp) {
        NSDictionary *params = @{@"client_id" : clientId ?: @"",
                @"scope" : [permissions componentsJoinedByString:@","],
                @"revoke" : @(revokeAccess),
                @"sdk_version" : VK_SDK_VERSION
        };

        NSURL *urlToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", VK_AUTHORIZE_URL_STRING, [VKUtil queryStringFromParams:params]]];
        if (!forceOAuth && [[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
            [VKSdk instance].authState = VKAuthorizationVkApp;
        } else {
            urlToOpen = [NSURL URLWithString:
                    [VKAuthorizeController buildAuthorizationUrl:[NSString stringWithFormat:@"vk%@://authorize", clientId]
                                                        clientId:clientId
                                                           scope:[permissions componentsJoinedByString:@","]
                                                          revoke:revokeAccess
                                                         display:@"mobile"]];
            [VKSdk instance].authState = VKAuthorizationSafari;
        }
        [[UIApplication sharedApplication] openURL:urlToOpen];
    } else {

        //Authorization through popup webview
        [VKAuthorizeController presentForAuthorizeWithAppId:clientId
                                             andPermissions:permissions
                                               revokeAccess:revokeAccess
                                                displayType:displayType];
        [VKSdk instance].authState = VKAuthorizationWebview;
    }
}

+ (BOOL)vkAppMayExists {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:VK_AUTHORIZE_URL_STRING]];
}

#pragma mark Access token

+ (void)setAccessToken:(VKAccessToken *)token {
    [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    id oldToken = vkSdkInstance.accessToken;
    if (!token && oldToken) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:VK_ACCESS_TOKEN_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    vkSdkInstance.accessToken = token;
    BOOL respondsToRenew = [vkSdkInstance.delegate respondsToSelector:@selector(vkSdkRenewedToken:)],
            respondsToReceive = [vkSdkInstance.delegate respondsToSelector:@selector(vkSdkReceivedNewToken:)];

    if (oldToken && respondsToRenew)
        [vkSdkInstance.delegate vkSdkRenewedToken:token];
    if (!(oldToken && respondsToRenew) && respondsToReceive)
        [vkSdkInstance.delegate vkSdkReceivedNewToken:token];
}

+ (void)setAccessTokenError:(VKError *)error {
    vkSdkInstance.permissions = nil;
    [vkSdkInstance.delegate vkSdkUserDeniedAccess:error];
}

+ (VKAccessToken *)getAccessToken {
    return vkSdkInstance.accessToken;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl {
    NSString *urlString = [passedUrl absoluteString];
    NSRange rangeOfHash = [urlString rangeOfString:@"#"];
    if (rangeOfHash.location == NSNotFound) {
        return NO;
    }

    NSString *parametersString = [urlString substringFromIndex:rangeOfHash.location + 1];
    if (parametersString.length == 0) {
        VKError *error = [VKError errorWithQuery:@{@"cancel" : @1}];
        [VKSdk setAccessTokenError:error];
        return NO;
    }
    NSDictionary *parametersDict = [VKUtil explodeQueryString:parametersString];
    BOOL inAppCheck = [[passedUrl host] isEqual:@"oauth.vk.com"];

    void (^throwError)() = ^{
        VKError *error = [VKError errorWithQuery:parametersDict];
        [VKSdk setAccessTokenError:error];
    };

    if (!inAppCheck && parametersDict[@"error"]) {
        if ([parametersDict[@"error_reason"] isEqual:@"sdk_error"]) {
            //Try internal authorize
            [self authorize:vkSdkInstance.permissions revokeAccess:YES forceOAuth:NO inApp:YES display:VK_DISPLAY_IOS];
        } else {
            throwError();
        }
        return NO;
    }
    if (inAppCheck && (parametersDict[@"cancel"] || parametersDict[@"error"] || parametersDict[@"fail"])) {
        throwError();
        return NO;
    } else if (inAppCheck && parametersDict[@"success"]) {
        VKAccessToken *prevToken = [VKSdk getAccessToken];
        VKAccessToken *token = [VKAccessToken tokenWithToken:parametersDict[@"access_token"] ?: prevToken.accessToken
                                                      secret:parametersDict[@"secret"] ?: prevToken.secret
                                                      userId:parametersDict[@"user_id"] ?: prevToken.userId];
        token.expiresIn = prevToken.expiresIn;
        token.permissions = prevToken.permissions;
        token.httpsRequired = prevToken.httpsRequired;
        [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    } else {

        NSMutableString *newParametersString = [parametersString mutableCopy];
        [newParametersString appendFormat:@"&permissions=%@", [vkSdkInstance.permissions componentsJoinedByString:@","]];

        VKAccessToken *token = [VKAccessToken tokenFromUrlString:newParametersString];
        if (!token.accessToken) {
            return NO;
        }
        [VKSdk setAccessToken:token];
    }
    return YES;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication {
    if ([sourceApplication isEqualToString:VK_DEBUG_CLIENT_BUNDLE] ||
            [sourceApplication isEqualToString:VK_ORIGINAL_CLIENT_BUNDLE] ||
            [sourceApplication isEqualToString:VK_ORIGINAL_HD_CLIENT_BUNDLE] ||
            (
                    ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] || !sourceApplication) &&
                            [passedUrl.scheme isEqualToString:[NSString stringWithFormat:@"vk%@", vkSdkInstance.currentAppId]]
            )
            ) {
        BOOL result = [self processOpenURL:passedUrl];
        if (result) {
            [vkSdkInstance trackVisitor];
        }
        return result;
    }
    return NO;
}

+ (void)forceLogout {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    for (NSHTTPCookie *cookie in cookies)
        if (NSNotFound != [cookie.domain rangeOfString:@"vk.com"].location) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]
                    deleteCookie:cookie];
        }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (vkSdkInstance) {
        vkSdkInstance.accessToken = nil;
        vkSdkInstance.permissions = nil;
    }
}

+ (BOOL)isLoggedIn {
    if (vkSdkInstance.accessToken && ![vkSdkInstance.accessToken isExpired]) return true;
    return false;
}

+ (BOOL)wakeUpSession {
    VKAccessToken *token = [VKAccessToken tokenFromDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    if (!token || token.isExpired)
        return NO;
    BOOL firstCall = vkSdkInstance.accessToken == nil;
    vkSdkInstance.accessToken = token;
    if (token && firstCall) {
        [vkSdkInstance trackVisitor];
    }
    return YES;
}

+ (BOOL)wakeUpSession:(NSArray *)permissions {
    BOOL result = [self wakeUpSession];
    if (!result) return result;
    if (![self hasPermissions:permissions]) {
        return NO;
    }
    return YES;
}

+ (BOOL)hasPermissions:(NSArray *)permissions {
    for (NSString *p in permissions) {
        BOOL exists = NO;
        for (NSString *existingPemission in vkSdkInstance.accessToken.permissions) {
            if ([existingPemission isEqualToString:p]) {
                exists = YES;
                break;
            }
        }
        if (!exists) return NO;
    }
    return YES;
}

+ (void)setSchedulerEnabled:(BOOL)enabled {
    [[VKRequestsScheduler instance] setEnabled:enabled];
}

- (NSString *)currentAppId {
    return _currentAppId;
}

- (void)trackVisitor {
    [[VKRequest requestWithMethod:@"stats.trackVisitor" andParameters:nil andHttpMethod:@"GET"] executeWithResultBlock:nil errorBlock:^(NSError *error) {
        VKError *vkError = error.vkError;
        if (vkError.errorCode == 5) {
            [self setAccessToken:nil];
            self.authState = VKAuthorizationInitialized;
            [[self class] setAccessTokenError:vkError];
        }
    }];
}

@end
