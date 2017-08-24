//
//  NSArray+VKNonNSNullProtocol.h
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 25.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import "NSObject+VKNonNSNullProtocol.h"

@interface NSArray (VKNonNSNullProtocol)

- (nonnull instancetype)withoutNSNullObjects;

@end
