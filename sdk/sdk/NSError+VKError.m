//
//  NSError+VKError.m
//  sdk
//
//  Created by Roman Truba on 28.01.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "NSError+VKError.h"

@implementation NSError (VKError)

+(NSError*) errorWithVkError:(VKError*) vkError {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    int originalCode = vkError.errorCode;
    if (vkError.apiError)
        vkError = vkError.apiError;
    userInfo[NSLocalizedDescriptionKey] = vkError.errorMessage ? vkError.errorMessage : NSLocalizedStringFromTable(@"Something went wrong", nil, @"");
    userInfo[VkErrorDescriptionKey] = vkError;
    
    return [[NSError alloc] initWithDomain:VKSdkErrorDomain code:originalCode userInfo:userInfo];
}
-(NSError*) copyWithVkError:(VKError*) vkError {
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    userInfo[VkErrorDescriptionKey] = vkError;
    
    return [[NSError alloc] initWithDomain:self.domain code:self.code userInfo:userInfo];
}
-(VKError *)vkError {
    return (VKError*)self.userInfo[VkErrorDescriptionKey];
}

@end
