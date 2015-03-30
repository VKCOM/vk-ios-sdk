//
//  VKRequestsScheduler.m
//  VKSdk
//
//  Created by Roman Truba on 19.03.15.
//  Copyright (c) 2015 VK. All rights reserved.
//

#import "VKRequestsScheduler.h"
#import "VKRequest.h"
#import "VKSdk.h"

@implementation VKRequestsScheduler {
    dispatch_queue_t _schedulerQueue;
    NSInteger _currentLimitPerSecond;
    NSMutableDictionary *_scheduleDict;
    BOOL _enabled;
}
//+ (NSDictionary *)limits {
//    static NSDictionary *limitsDictionary;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        limitsDictionary = @{@5000 : @3, @10000 : @5, @100000 : @8, @1000000 : @20, @(INT_MAX) : @35};
//    });
//    return limitsDictionary;
//}

+ (instancetype)instance {
    static id sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[self alloc] init];
    });

    return sInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentLimitPerSecond = 3;
        _schedulerQueue = dispatch_queue_create("com.vk.requests-scheduler", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
//    if ([VKSdk instance].currentAppId) {
//        [[VKRequest requestWithMethod:@"apps.get" andParameters:@{@"app_id" : [VKSdk instance].currentAppId} andHttpMethod:@"GET"] executeWithResultBlock:^(VKResponse *response) {
//            NSInteger members = [response.json[@"members_count"] integerValue];
//            NSDictionary *limitsDict = [[self class] limits];
//            NSArray *limits = [[limitsDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                return [obj1 compare:obj2];
//            }];
//
//            for (NSNumber *curLimit in limits) {
//                if (members < curLimit.integerValue) {
//                    _currentLimitPerSecond = [limitsDict[curLimit] integerValue];
//                    break;
//                }
//            }
//
//        } errorBlock:nil];
//    }
}

- (NSTimeInterval)currentAvailableInterval {
    return 1.f / _currentLimitPerSecond;
}

- (void)scheduleRequest:(VKRequest *)req {
    if (!_enabled) {
        [req start];
        return;
    }
    dispatch_async(_schedulerQueue, ^{
        NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
        NSInteger thisSecond = (NSInteger) now;
        if (!_scheduleDict) {
            _scheduleDict = [NSMutableDictionary new];
        }
        NSArray *keysToRemove = [[_scheduleDict allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF < %d", thisSecond]];
        [_scheduleDict removeObjectsForKeys:keysToRemove];
        NSInteger countForSecond = [_scheduleDict[@(thisSecond)] integerValue];
        if (countForSecond < _currentLimitPerSecond) {
            _scheduleDict[@(thisSecond)] = @(++countForSecond);
            [req start];
        } else {
            CGFloat delay = [self currentAvailableInterval], step = delay;
            while ([_scheduleDict[@(thisSecond)] integerValue] >= _currentLimitPerSecond) {
                delay += step;
                thisSecond = (NSInteger) (now + delay);
            }
            NSInteger nextSecCount = [_scheduleDict[@(thisSecond)] integerValue];
            delay += step * nextSecCount;
            _scheduleDict[@(thisSecond)] = @(++nextSecCount);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [req performSelector:@selector(start) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes]];
            });
        }
    });
}
@end
