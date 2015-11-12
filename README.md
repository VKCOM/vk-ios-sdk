vk-ios-sdk
==========

Library for working with VK API, authorization through VK app, using VK functions. Supported iOS from 6.0
Prepare for Using VK SDK
----------

To use VK SDK primarily you need to create a new VK application [here](https://vk.com/editapp?act=create) by choosing the Standalone application type. Choose a title and confirm the action via SMS and you will be redirected to the application settings page. 
You will require your Application ID (referenced as API_ID in the documentation). Fill in the App Bundle for iOS field. 

Setup URL-schema of Your Application
----------

To use authorization via VK App you need to setup a url-schema of your application, which looks like vk+APP_ID (e.g. **vk1234567**).

[Read how to implement your own URL Scheme here] (https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10), Also there is [nice Twitter tutorial] (https://dev.twitter.com/cards/mobile/url-schemes)


Configuring application for iOS 9
----------
iOS 9 changes the way of applications security and way of using unsecured connections. Basically, you don't have to change anything in transport security settings. But, if you're planing to use VK API with "nohttps" scope, you have to change security settings that way (in your Info.plist file):
```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>vk.com</key>
        <dict>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

We're don't recommend you to use "nohttps" scope.

Also, for iOS 9 you have to enumerate app schemas which you app using (and checking for canOpenURL:) to have ability to open that apps. For VK SDK you should change your Info.plist in that way:
```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>vk</string>
    <string>vk-share</string>
    <string>vkauthorize</string>
</array>
```

Adding VK iOS SDK to your iOS application
==========

Installation with CocoaPods
----------

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like VK SDK in your projects. See the "[Getting Started](http://cocoapods.org/)" guide for more information.

Podfile

    platform :ios, '6.0'
    pod "VK-ios-sdk"
    
Then import the main header.

    #import <VKSdk/VKSdk.h>

Installation with source code
----------

Add `VKSdk.framework` and `VKSdkResources.bundle` files into your project. In the Application settings open **Build phases**, then the **Link Binary with Libraries** section, add `VKSdk.framework` there. Add `VKSdkResources.bundle` into **Copy bundle resources** section. Import the main header:

    #import <VKSdk/VKSdk.h>
    
    
Installation with framework project
----------

If you targeting an application only to iOS 8 and above, you can use the SDK framework target. Add `VK-ios-sdk.xcodeproj` as sub-project of your project. Open your project in Xcode, and on the "General" tab find the "Embedded Binaries" section. Press plus sign, and select "VKSdkFramework.framework" from the VK-ios-sdk project. Import the main header:
```
#import <VKSdkFramework/VKSdk.h>
```

Using SDK
==========

SDK Initialization
----------
1) Put this code to the application delegate method
```
//iOS 9 workflow
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    return YES;
}
//iOS 8 and lower
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}
```
2) Initialize SDK with your APP_ID for any delegate.
```
VKSdk *sdkInstance = [VKSdk initializeWithAppId:YOUR_APP_ID];
```

Starting from version 1.3 there are two types of delegates available: common delegate and UI delegate. You can register as much common delegates, as you need, but an UI delegate may be only one. After the SDK initialization you should register delegates separately:
```
[sdkInstance registerDelegate:delegate];
[sdkInstance setUiDelegate:uiDelegate];
```

See full description of `VKSdkDelegate` and `VKSdkUIDelegate` protocol here: http://cocoadocs.org/docsets/VK-ios-sdk


3) You need to check, if there is previous session available, so call asynchronous method `wakeUpSession:completeBlock:`:
```
[VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
    if (state == VKAuthorizationAuthorized) {
        // Authorized and ready to go
    } else if (error) {
        // Some error happend, but you may try later
    }
}];
``` 

Check out the VKAuthorizationState parameter. You can get several states:
* VKAuthorizationInitialized – means the SDK is ready to work, and you can authorize user with `+authorize:` method. Probably, an old session has expired, and we wiped it out. *This is not an error.*
* VKAuthorizationAuthorized - means a previous session is okay, and you can continue working with user data.
* VKAuthorizationError - means some error happened when we tried to check the authorization. Probably, the internet connection has a bad quality. You have to try again later.


User Authorization
----------

If you don't have a session yet, you have to authorize user with a next method: 
```
[VKSdk authorize:scope];
``` 

After authorization, all common delegates will be called with a next method:
```
- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result;
```

`VKAuthorizationResult` contains some initial information: new access token object, basic user information, and error (if authorization failed).


API Requests
==========

Requests Syntax
----------
Below we have listed the examples for several request types. 
1) Plain request.

    VKRequest * audioReq = [[VKApi users] get];

2) Request with parameters.

    VKRequest * audioReq = [[VKApi audio] get:@{VK_API_OWNER_ID : @"896232"}];

3) Request with predetermined maximum number of attempts.

    VKRequest * postReq = [[VKApi wall] post:@{VK_API_MESSAGE : @"Test"}]; 
    postReq.attempts = 10; 
    //or infinite 
    //postReq.attempts = 0;

It will take 10 attempts until succeeds or an API error occurs. 

4) Request that calls any method of VK API.

    VKRequest * getWall = [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_OWNER_ID : @"-1"}];

5) Request for uploading photos on user wall.

    VKRequest * request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"my_photo"] parameters:[VKImageParameters pngImage] userId:0 groupId:0 ];

Requests Sending
----------

    [audioReq executeWithResultBlock:^(VKResponse * response) { 
            NSLog(@"Json result: %@", response.json); 
        } errorBlock:^(NSError * error) { 
        if (error.code != VK_API_ERROR) { 
            [error.vkError.request repeat]; 
        } else { 
            NSLog(@"VK error: %@", error); 
        } 
    }];

Error Handling
----------
Every request can return `NSError` with domain equal to `VKSdkErrorDomain`. SDK can return networking error or internal SDK error (e.g. request was canceled). Category `NSError+VKError` provides vkError property that describes error event. Compare error code with the global constant `VK_API_ERROR`. If they equal that means you process vkError property as API error. Otherwise you should handle an http error. 

Some errors (e.g., captcha error, validation error) can be proccessed by the SDK. Appropriate ui delegate method will be called for this purpose. 
Below is an example of captcha error processing:

    -(void) vkSdkNeedCaptchaEnter:(VKError*) captchaError 
    { 
        VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError]; 
        [vc presentIn:self]; 
    }

Batch Processing Requests
----------
SDK gives a feature to execute several unrelated requests at the one call. 

1) Prepare requests
```
VKRequest * request1 = [[VKApi audio] get]; 
request1.completeBlock = ^(VKResponse*) { ... }; 

VKRequest * request2 = [[VKApi users] get:@{VK_USER_IDS : @[@(1), @(6492), @(1708231)]}]; 
request2.completeBlock = ^(VKResponse*) { ... };
```
2) Combine created requests into one.

    VKBatchRequest * batch = [[VKBatchRequest alloc] initWithRequests:request1, request2, nil];

3) Load the obtained request.

    [batch executeWithResultBlock:^(NSArray *responses) { 
            NSLog(@"Responses: %@", responses); 
        } errorBlock:^(NSError *error) { 
            NSLog(@"Error: %@", error); 
    }];
    
4) The result of each method returns to a corresponding completeBlock. The responses array contains responses of the requests in order they have been passed.


Working with Share dialog
==========
Share dialog allows you to create a user friendly dialog for sharing text and photos from your application directly to VK. See the Share dialog usage example:
```
VKShareDialogController * shareDialog = [VKShareDialogController new]; //1
shareDialog.text         = @"This post created using #vksdk #ios"; //2
shareDialog.vkImages     = @[@"-10889156_348122347",@"7840938_319411365",@"-60479154_333497085"]; //3
shareDialog.shareLink    = [[VKShareLink alloc] initWithTitle:@"Super puper link, but nobody knows" link:[NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]]; //4
[shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
    [self dismissViewControllerAnimated:YES completion:nil];
}]; //5
[self presentViewController:shareDialog animated:YES completion:nil]; //6
```
1) create an instance of the dialog controller as usual.

2) attach some text information to a dialog. Notice that users can change this information.

3) attach images uploaded to VK earlier. If you want user to upload a new image, use the `uploadImages` property.

4) attach link at your pages

5) set the dialog completion handler

6) present the dialog viewcontroller in your view controller


Working with share activity
==========

VK SDK provides a special class for working with `UIActivityViewController` - `VKActivity`. 

Pay attention to the fact, that a VK app has it own Share extension starting from version 2.4. Starting from version 2.5 it will support special URL scheme to check, if Share extension is available. You should call `[VKActivity vkShareExtensionEnabled]` method to remove VKActivity from activities list, if a VK share extension available.

See example below for understand how it works:

```
NSArray *items = @[[UIImage imageNamed:@"apple"], @"Check out information about VK SDK" , [NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]]; //1
UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:items
                                                    applicationActivities:@[[VKActivity new]]]; //2
[activityViewController setValue:@"VK SDK" forKey:@"subject"]; //3
[activityViewController setCompletionHandler:nil]; //4
if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
    UIPopoverPresentationController *popover = activityViewController.popoverPresentationController;
    popover.sourceView = self.view;
    popover.sourceRect = [tableView rectForRowAtIndexPath:indexPath];
} //5
[self presentViewController:activityViewController animated:YES completion:nil]; //6
```

Lets see steps of the example:

1) Prepare your share information - `UIImage`, `NSString` and `NSURL`. That kind of information may be shared throught VK.

2) Prepare `UIActivityViewController` with new application `VKActivity`.

3) Set additional properties for `activityViewController`.

4) Set completion handler for `activityViewController`

5) Check if you're running above iOS 8. If user working with iPad, you must present the activity controller in popover, otherwise you'll get system error.

6) Present the activity controller as usual.
