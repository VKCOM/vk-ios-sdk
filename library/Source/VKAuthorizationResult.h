//
//  VKAuthorizationResult.h
//
//  Copyright (c) 2015 VK.com
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

#import "VKAccessToken.h"
#import "VKError.h"

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
 
 */
@interface VKAuthorizationResult : VKObject
@property(nonatomic, readonly, strong) VKAccessToken *token;
@property(nonatomic, readonly, strong) VKUser *user;
@property(nonatomic, readonly, strong) NSError *error;
@property(nonatomic, readonly, assign) VKAuthorizationState state;
@end

@interface VKMutableAuthorizationResult : VKAuthorizationResult
@property(nonatomic, readwrite, strong) VKAccessToken *token;
@property(nonatomic, readwrite, strong) VKUser *user;
@property(nonatomic, readwrite, strong) NSError *error;
@property(nonatomic, readwrite, assign) VKAuthorizationState state;

@end