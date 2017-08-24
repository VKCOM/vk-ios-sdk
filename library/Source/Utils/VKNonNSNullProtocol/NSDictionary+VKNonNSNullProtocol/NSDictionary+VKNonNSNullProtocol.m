//
//  NSDictionary+VKNonNSNullProtocol.m
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 25.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSDictionary+VKNonNSNullProtocol.h"

@implementation NSDictionary (VKNonNSNullProtocol)

- (nonnull instancetype)withoutNSNullObjects {
    NSMutableDictionary *returned = self.mutableCopy;
    NSNull *null = NSNull.null;
    for (NSObject *key in returned.allKeys) {
        NSObject *value = returned[key];
        if (value == null) {
            [returned removeObjectForKey:key];
        } else {
            [value removeNSNullObjects];
        }
    }
    return returned.copy;
}

@end
