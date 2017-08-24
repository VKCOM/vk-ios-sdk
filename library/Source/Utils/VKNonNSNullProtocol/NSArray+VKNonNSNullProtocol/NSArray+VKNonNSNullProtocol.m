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
    NSMutableArray *returned = [NSMutableArray array];
    for (NSObject *child in self) {
        [returned addObject:[child withoutNSNullObjects]];
    }
    [returned removeObject:NSNull.null];
    return returned.copy;
}

@end
