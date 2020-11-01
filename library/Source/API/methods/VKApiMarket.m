//
//  VKApiMarket.m
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiMarket.h"
#import "VKGroup.h"

@implementation VKApiMarket

- (VKRequest *)marketProductsForCommunityWithId:(NSInteger)communityId {
    return [self prepareRequestWithMethodName:@"get"
                                   parameters:
            @{
                VK_API_OWNER_ID    : @(communityId),
            }
                                   modelClass:[VKMarkets class]];
}

@end
