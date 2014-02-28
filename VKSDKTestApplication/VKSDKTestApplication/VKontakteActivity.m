//
//  VKontakteActivity.m
//  VKActivity
//
//  Created by Denivip Group on 28.01.14.
//  Copyright (c) 2014 Denivip Group. All rights reserved.
//

#import "VKontakteActivity.h"
#import <VKSdk/VKSdk.h>
#import "MBProgressHUD.h"

@interface VKontakteActivity () <VKSdkDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) UIViewController *parent;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation VKontakteActivity

#pragma mark - NSObject

- (id)initWithParent:(UIViewController*)parent {
    if ((self = [super init])) {
        self.parent = parent;
    }
    
    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType {
    return @"VKActivityTypeVKontakte";
}

- (NSString *)activityTitle {
    return @"ВКонтакте";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"vk_activity"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
        else if ([item isKindOfClass:[NSString class]])
        {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.string = item;
        }
        else if([item isKindOfClass:[UIImage class]]) {
            self.image = item;
        }
        else if([item isKindOfClass:[NSURL class]]) {
            self.URL = item;
        }
    }
}

- (void)performActivity{
    [VKSdk initializeWithDelegate:self andAppId:@"3974615"];
    if ([VKSdk wakeUpSession])
    {
        [self postToWall];
    }
    else{
        [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
    }
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
	VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
	[vc presentIn:self.parent];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
}

- (void)vkSdkDidReceiveNewToken:(VKAccessToken *)newToken {
    [self postToWall];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
	[self.parent presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token {
    [self postToWall];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Доступ запрещён"
                                                        message:@"Доступ запрещён"
                                                       delegate:self
                                              cancelButtonTitle:@"Закрыть"
                                              otherButtonTitles:nil];
    [alertView show];
    
	[self end];
}

-(void)postToWall{
    if (self.image) {
        [self uploadPhoto];
    }
    else{
        [self uploadText];
    }
}

- (void)uploadPhoto {
    UIView *view = self.parent.view.window;
    self.HUD = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = @"Загрузка...";
	[self.HUD show:YES];
   
    NSString *userId = [VKSdk getAccessToken].userId;
    
    VKRequest *request = [VKApi uploadWallPhotoRequest:self.image parameters:[VKImageParameters jpegImageWithQuality:1.f] userId:[userId integerValue] groupId:0];
	[request executeWithResultBlock: ^(VKResponse *response) {
	    VKPhoto *photoInfo = [(VKPhotoArray*)response.parsedModel objectAtIndex:0];
	    NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
        NSMutableDictionary *params = @{ VK_API_ATTACHMENTS : photoAttachment, VK_API_FRIENDS_ONLY : @(0), VK_API_OWNER_ID : userId, VK_API_MESSAGE : [NSString stringWithFormat:@"%@ %@",self.string, [self.URL absoluteString]]}.mutableCopy;
        VKRequest *post = [[VKApi wall] post:params];
	    [post executeWithResultBlock: ^(VKResponse *response) {
	        NSNumber * postId = response.json[@"post_id"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall%@_%@", userId, postId]]];
            [self end];
        } errorBlock: ^(NSError *error) {
	        NSLog(@"Error: %@", error);
            [self end];
        }];
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
        [self end];
	}];
}

-(void)uploadText{
    UIView *view = self.parent.view.window;
    self.HUD = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = @"Загрузка...";
	[self.HUD show:YES];
    
    NSString *userId = [VKSdk getAccessToken].userId;
    NSMutableDictionary *params = @{ VK_API_FRIENDS_ONLY : @(0), VK_API_OWNER_ID : [VKSdk getAccessToken].userId, VK_API_MESSAGE : self.string}.mutableCopy;
    VKRequest *post = [[VKApi wall] post:params];
    [post executeWithResultBlock: ^(VKResponse *response) {
        NSNumber * postId = response.json[@"post_id"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall%@_%@", userId, postId]]];
        [self end];
    } errorBlock: ^(NSError *error) {
        NSLog(@"Error: %@", error);
        [self end];
    }];
}

-(void)end{
    [self.HUD hide:YES];
    [self activityDidFinish:YES];
}
@end
