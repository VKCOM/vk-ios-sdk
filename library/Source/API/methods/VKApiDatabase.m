//
//  VKApiDatabase.m
//  VKSdk
//
//  Created by Дмитрий Червяков on 24.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiDatabase.h"
#import "VKUser.h"

@implementation VKApiDatabase

- (VKRequest *)getCitiesForCountry:(NSInteger)countryId {
    return [self prepareRequestWithMethodName:@"getCities"
                                   parameters:@{VK_API_COUNTRY : @(countryId)}
                                   modelClass:[VKCitiesArray class]];
}

@end
