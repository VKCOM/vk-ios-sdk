//
//  NSMutableArray+VKNonNSNullProtocol.h
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 24.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSObject+VKNonNSNullProtocol.h"

@interface NSMutableArray (VKNonNSNullProtocol)

- (void)removeNSNullObjects;

@end
