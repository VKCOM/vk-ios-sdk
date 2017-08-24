//
//  NSMutableDictionary+VKNonNSNullProtocol.m
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 24.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSMutableDictionary+VKNonNSNullProtocol.h"

@implementation NSMutableDictionary (VKNonNSNullProtocol)

- (void)removeNSNullObjects {
    NSNull *null = NSNull.null;
    for (NSObject *key in self.allKeys) {
        NSObject *value = self[key];
        if (value == null) {
            [self removeObjectForKey:key];
        } else {
            [value removeNSNullObjects];
        }
    }
}

@end
