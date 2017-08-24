//
//  VKNonNSNullProtocol.h
//  VK-ios-sdk
//
//  Created by Александр Золотарёв on 24.08.17.
//  Copyright © 2017 VK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VKNonNSNullProtocol <NSObject>
@required
- (void)removeNSNullObjects;
@end
