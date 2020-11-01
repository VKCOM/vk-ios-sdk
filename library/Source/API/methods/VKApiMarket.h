//
//  VKApiMarket.h
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKApiMarket : VKApiBase

/**
 Return array of the products for specified community
https://vk.com/dev/market.get
@return Request for execution
*/
- (VKRequest *)marketProductsForCommunityWithId:(NSInteger)communityId;

@end

NS_ASSUME_NONNULL_END
