//
//  NSError+VKError.h
//  sdk
//
//  Created by Roman Truba on 28.01.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKError.h"

static NSString *const VKSdkErrorDomain = @"VKSdkErrorDomain";
static NSString *VkErrorDescriptionKey      = @"VkErrorDescriptionKey";
@interface NSError (VKError)

@property (nonatomic, readonly)  VKError * vkError;

+(NSError*) errorWithVkError:(VKError*) vkError;
-(NSError*) copyWithVkError:(VKError*) vkError;

@end
