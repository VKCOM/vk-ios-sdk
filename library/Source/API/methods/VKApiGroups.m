//
//  VKApiGroups.m
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKApiGroups.h"
#import "VKGroup.h"

@implementation VKApiGroups
- (VKRequest *)getById:(NSDictionary *)params {
    return [self prepareRequestWithMethodName:@"getById" parameters:params modelClass:[VKGroups class]];
}

- (VKRequest *)search:(NSDictionary *)params {
    return [self prepareRequestWithMethodName:@"search" parameters:params modelClass:[VKGroups class]];
}

- (VKRequest *)get {
    return [self prepareRequestWithMethodName:@"get" parameters:@{} modelClass:[NSArray class]];
}

- (VKRequest *)getExtended {
    return [self prepareRequestWithMethodName:@"get"
                                   parameters:@{
                                       VK_API_EXTENDED : @(1)
                                   }
                                   modelClass:[VKGroups class]];
}

- (VKRequest *)leaveGroupWithId:(NSInteger)groupId {
    return [self prepareRequestWithMethodName:@"leave"
                                   parameters:@{VK_API_GROUP_ID : @(groupId)}];
}

- (VKRequest *)searchGroupsWithMarketInCityWithId:(NSInteger)cityId count:(NSInteger)count {
    return [self prepareRequestWithMethodName:@"search"
                                   parameters:
  @{
      VK_API_Q    : @" ",
      VK_API_CITY   : @(cityId),
      VK_API_COUNT : @(count),
      VK_API_MARKET : @(1)
  }
                                   modelClass:[VKGroups class]];
}

@end
