//
//  VKApiFeed.h
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 31.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKApiFeed : VKApiBase

/**
 Return array of the posts
 https://vk.com/dev/newsfeed.get
@return Request for execution
*/
- (VKRequest *)get;

@end

NS_ASSUME_NONNULL_END
