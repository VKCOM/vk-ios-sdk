//
//  VKAuthorizationResult.h
//  VK-ios-sdk
//
//  Created by Roman Truba on 27.10.15.
//  Copyright © 2015 VK. All rights reserved.
//

#import "VKAccessToken.h"
#import "VKError.h"

@interface VKAuthorizationResult : VKObject
@property (nonatomic, strong) VKAccessToken *token;
@property (nonatomic, strong) VKError *error;
@end
