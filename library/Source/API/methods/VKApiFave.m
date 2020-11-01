//
//  VKApiFave.m
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiFave.h"

@implementation VKApiFave

- (VKRequest *)addProductToFavourite:(VKMarket *)product {
    return [self prepareRequestWithMethodName:@"addProduct"
                                   parameters:
            @{
                VK_API_OWNER_ID : @(product.owner_id.integerValue),
                VK_API_ID       : @(product.id.integerValue)
            }];
}

- (VKRequest *)removeProductFromFavourite:(VKMarket *)product {
    return [self prepareRequestWithMethodName:@"removeProduct"
                                   parameters:
            @{
                VK_API_OWNER_ID : @(product.owner_id.integerValue),
                VK_API_ID       : @(product.id.integerValue)
            }];
}

@end
