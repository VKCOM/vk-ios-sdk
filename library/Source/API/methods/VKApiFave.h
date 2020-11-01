//
//  VKApiFave.h
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiBase.h"
#import "VKGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKApiFave : VKApiBase

/**
 Add product  to users favourite
https://vk.com/dev/fave.addProduct
@return Request for execution
*/
- (VKRequest *)addProductToFavourite:(VKMarket *)product;

/**
 Remove product from users favourite
https://vk.com/dev/fave.addProduct
@return Request for execution
*/
- (VKRequest *)removeProductFromFavourite:(VKMarket *)product;

@end

NS_ASSUME_NONNULL_END
