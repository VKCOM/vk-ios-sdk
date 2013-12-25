vk-ios-sdk
==========

Library for working with VK API, authorization through VK app, using VK functions.

Prepare for using VK SDK
----------

Before using VK SDK you need to create standalone application in VK ( https://vk.com/editapp?act=create ). Save your Application ID, fill "App Bundle for iOS" field.

Setting up URL-schema in your application
----------

For authorization through VK App you need to setup url-schema of your application.

<b>Xcode 5:</b>
Open your application settings, then select Info tab. In URL Types section press plus sign. Enter vk+YOUR_APP_ID (e.g. vk1234567) to Indentifier and URL Schemes fields.

<b>Xcode 4:</b>
Open your Info.plist, then add new row "URL Types". Set URL identifier to vk+YOUR_APP_ID

Adding VK iOS SDK to your iOS application
==========

Installation with CocoaPods
----------

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like AFNetworking in your projects. See the "Getting Started" guide for more information.

Podfile

    pod "VK-ios-sdk"

Installation with source code
----------

Add sdk/sdk.xcodeproj to your project. In your Application settings/Build phases/Link Binary with Libraries add libVKSdk.a
Import main header

    #import "VKSdk.h"

Working with SDK
==========
SDK initialization
----------
1) Add next code to application delegate method application:openURL:sourceApplication:annotation:
```
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}
```
2) Initialize SDK with your APP_ID for some delegate
    [VKSdk initialize:delegate andAppId:YOUR_APP_ID];
    
See reference of VKSdkDelegate protocol here: http://vkcom.github.io/vk-ios-sdk/Protocols/VKSdkDelegate.html

User authorization
----------

There are several methods for authorization:

    [VKSdk authorize:];
    [VKSdk authorize:revokeAccess:];
    [VKSdk authorize:revokeAccess:forceOAuth:];

Usually, [VKSdk authorize:]; is enougth for your needs.

In case of success will next method of delegate will be called

    -(void) vkSdkDidReceiveNewToken:(VKAccessToken*) newToken;

In case of error (e.g. used canceled authorization)

    -(void) vkSdkUserDeniedAccess:(VKError*) authorizationError;

API requests
==========

Preparing
----------
1) Simple

    VKRequest * audioReq = [[VKApi users] get];

2) Parametrized

    VKRequest * audioReq = [[VKApi audio] get:@{VK_OWNER_ID : @"896232"}];

3) Http (not https) loading (only if scope VK_PER_NOHTTPS was passed)

    VKRequest * audioReq = [[VKApi audio] get:@{VK_OWNER_ID : @"896232"}]; 
    audioReq.secure = NO;

4) Set maximum attempts count 

    VKRequest * postReq = [[VKApi wall] post:@{VK_MESSAGE : @"Test"}]; 
    postReq.attempts = 10; 
    //or infinite 
    //postReq.attempts = 0;

Request will take 10 attempts, until success or API error

5) Load any API method (don't forget about scope)

    VKRequest * getWall = [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_OWNER_ID : @"-1"} andHttpMethod:@"GET"];

6) Upload photo to user wall

    VKRequest * request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"my_photo"] parameters:[VKImageParameters pngImage] userId:0 groupId:0 ];

Sending
----------

    [audioReq executeWithResultBlock:^(VKResponse * response) { 
            NSLog(@"Json result: %@", response.json); 
        } errorBlock:^(VKError * error) { 
        if (error.code != VK_API_ERROR) { 
            [error.request repeat]; 
        } else { 
            NSLog(@"VK error: %@", error.apiError); 
        } 
    }];

Errors handling
----------
Class VKError contains errorCode property. Compare it with VK_API_ERROR. If it equals, process vkError propetry, otherwise you handling http error in httpError property.

SDK can process several errors (captcha error, validation error). Appropriate delegate methods will be called.
Example of processing captcha error:

    -(void) vkSdkNeedCaptchaEnter:(VKError*) captchaError 
    { 
        VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError]; 
        [vc presentIn:self]; 
    }

Batching requests
----------
SDK can build load bunch of requests, and return results as requests were passed

1) Prepare requests
```
VKRequest * request1 = [[VKApi audio] get]; 
request1.completeBlock = ^(VKResponse*) { ... }; 

VKRequest * request2 = [[VKApi users] get:@{VK_USER_IDS : @[@(1), @(6492), @(1708231)]}]; 
request2.completeBlock = ^(VKResponse*) { ... };
```
2) Batch requests

    VKBatchRequest * batch = [[VKBatchRequest alloc] initWithRequests:request1, request2, nil];

3) Load batch with blocks

    [batch executeWithResultBlock:^(NSArray *responses) { 
            NSLog(@"Responses: %@", responses); 
        } errorBlock:^(VKError *error) { 
            NSLog(@"Error: %@", error); 
    }];

4) Result of each method will be returned to completeBlock of that request, responses array will contains responses of requests as they were passed.

