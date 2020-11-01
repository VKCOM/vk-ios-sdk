//
//  VKApiDatabase.h
//  VKSdk
//
//  Created by Дмитрий Червяков on 24.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKApiDatabase : VKApiBase

/**
 Return array of the cities for country
https://vk.com/dev/database.getCities
@return Request for execution
*/
- (VKRequest *)getCitiesForCountry:(NSInteger)countryId;

@end

NS_ASSUME_NONNULL_END
