//
//  VKGroup.m
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKGroup.h"

@implementation VKGeoPlace
@end

@implementation VKGroupContact
@end

@implementation VKGroupContacts
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [super initWithDictionary:dict objectClass:[VKGroupContact class]];
}
@end

@implementation VKGroupLink
@end

@implementation VKGroupLinks
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [super initWithDictionary:dict objectClass:[VKGroupLink class]];
}
@end

@implementation VKGroup

@synthesize description = _description;

@end

@implementation VKGroups
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [super initWithDictionary:dict objectClass:[VKGroup class]];
}
@end
