//
//  VKActivity.m
//  sdk
//
//  Created by Roman Truba on 17.12.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKActivity.h"
#import "VKBundle.h"
#import "VKShareDialogController.h"
#import "VKUtil.h"

@implementation VKActivity {
    VKShareDialogController *shareDialog;
}
+(UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}
-(NSString *)activityType {
    return VKActivityTypePost;
}
-(UIImage *)activityImage {
    if (VK_SYSTEM_VERSION_LESS_THAN(@"8.0"))
        return VKImageNamed(@"ic_vk_ios7_activity_logo");
    
    return VKImageNamed(@"ic_vk_activity_logo");
}
-(NSString *)activityTitle {
    return VKLocalizedString(@"VK");
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) return YES;
        else if ([item isKindOfClass:[NSString class]]) return YES;
        else if ([item isKindOfClass:[NSURL class]])    return YES;
    }
    return NO;
}
-(void)prepareWithActivityItems:(NSArray *)activityItems {
    shareDialog = [VKShareDialogController new];
    NSMutableArray *uploadImages = [NSMutableArray new];
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            shareDialog.text = item;
        } else if ([item isKindOfClass:[NSAttributedString class]]) {
            shareDialog.text = [(NSAttributedString*)item string];
        } else if([item isKindOfClass:[UIImage class]]) {
            [uploadImages addObject:[VKUploadImage uploadImageWithImage:item andParams:[VKImageParameters jpegImageWithQuality:0.95]]];
        } else if([item isKindOfClass:[NSURL class]]) {
            shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:nil link:item];
        }
    }
    shareDialog.uploadImages = uploadImages;
    __weak VKActivity *wself = self;
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result){
        [wself activityDidFinish:result == VKShareDialogControllerResultDone];
    }];
}
-(UIViewController *)activityViewController {
    return shareDialog;
}
@end
