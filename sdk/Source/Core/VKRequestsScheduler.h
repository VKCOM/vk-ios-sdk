//
//  VKRequestsScheduler.h
//  VKSdk
//
//  Created by Roman Truba on 19.03.15.
//  Copyright (c) 2015 VK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKObject.h"

@class VKRequest;

/**
* A singletone class for simple schedule requests. It used for preventing "Too many requests per second" error.
*/
@interface VKRequestsScheduler : VKObject
/// Returns an instance of scheduler
+ (instancetype)instance;

/// Used for enabling or disabling scheduler. If scheduler disabled, all next added requests will be sent immediately
- (void)setEnabled:(BOOL)enabled;

/// Adds requests to queue. If scheduler disabled, request starts immediately
- (void)scheduleRequest:(VKRequest *)req;

- (NSTimeInterval)currentAvailableInterval;
@end
