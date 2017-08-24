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
    NSMutableDictionary *returned = [NSMutableDictionary dictionary];
    NSNull *null = NSNull.null;
    for (NSObject<NSCopying> *key in self.allKeys) {
        NSObject *value = self[key];
        if (value != null) {
            returned[key] = [value withoutNSNullObjects];
        }
    }
    return returned.copy;
}

@end
