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
static NSString *VkErrorDescriptionKey  = @"VkErrorDescriptionKey";
@interface NSError (VKError)

/// Returns vk error associated with that NSError
@property (nonatomic, readonly)  VKError * vkError;

/**
 Create new NSError with VKError
 @param vkError Source error
 @return New error with VKSdkErrorDomain domain
 */
+(NSError*) errorWithVkError:(VKError*) vkError;
/**
 Copies user info from this NSError into new error, with adding VKError
 @param vkError Source error
 @return New error with this error domain, code and user info
 */
-(NSError*) copyWithVkError:(VKError*) vkError;

@end
