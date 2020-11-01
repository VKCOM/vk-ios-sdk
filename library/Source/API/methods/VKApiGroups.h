//
//  VKApiGroups.h
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKApiBase.h"

@interface VKApiGroups : VKApiBase
/**
https://vk.com/dev/groups.get
@param params use parameters from description with VK_API prefix, e.g. VK_API_GROUP_ID, VK_API_FIELDS
@return Request for load
*/
- (VKRequest *)getById:(NSDictionary *)params;

/**
Returns array of the  user groups ids
https://vk.com/dev/groups.get
@return Request for load
*/
- (VKRequest *)get;

/**
Returns array of group with detailed information
https://vk.com/dev/groups.get
@return Request for load
*/
- (VKRequest *)getExtended;

/**
Leave group with id
https://vk.com/dev/groups.leave
@return Request for load
*/
- (VKRequest *)leaveGroupWithId:(NSInteger)groupId;

/**
Return requested amount of groups with enabled market
https://vk.com/dev/groups.search
@return Request for load
*/
- (VKRequest *)searchGroupsWithMarketInCityWithId:(NSInteger)cityId count:(NSInteger)count;
@end
