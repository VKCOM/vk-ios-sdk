//
//  NSArray+FirstObject.h
//  VKSdk
//
//  Created by Andrey Filipenkov on 1/21/15.
//  Copyright (c) 2015 VK. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __IPHONE_7_0
@interface NSArray (FirstObject)
- (id)firstObject;
@end
@implementation NSArray (FirstObject)
- (id)firstObject { return self.count ? self[0] : nil; }
@end
#endif
