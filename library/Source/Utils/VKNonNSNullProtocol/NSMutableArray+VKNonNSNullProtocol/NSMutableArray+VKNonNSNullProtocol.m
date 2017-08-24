//
//  NSMutableArray+VKNonNSNullProtocol.m
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 24.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSMutableArray+VKNonNSNullProtocol.h"

@implementation NSMutableArray (VKNonNSNullProtocol)

- (void)removeNSNullObjects {
    [self removeObject:NSNull.null];
    for (NSObject *child in self) {
        [child removeNSNullObjects];
    }
}

@end
