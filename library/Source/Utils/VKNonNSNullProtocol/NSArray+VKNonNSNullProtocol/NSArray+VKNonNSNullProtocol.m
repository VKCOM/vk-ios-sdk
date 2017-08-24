//
//  NSArray+VKNonNSNullProtocol.m
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 25.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSArray+VKNonNSNullProtocol.h"

@implementation NSArray (VKNonNSNullProtocol)

- (nonnull instancetype)withoutNSNullObjects {
    NSMutableArray *returned = self.mutableCopy;
    [returned removeObject:NSNull.null];
    for (NSObject *child in self) {
        [child removeNSNullObjects];
    }
    return returned.copy;
}

@end
