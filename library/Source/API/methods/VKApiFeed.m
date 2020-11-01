//
//  VKApiFeed.m
//  VK-ios-sdk
//
//  Created by Дмитрий Червяков on 31.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKApiFeed.h"

@implementation VKApiFeed

- (VKRequest *)get {
    return [self prepareRequestWithMethodName:@"get"
                                   parameters:
            @{
                VK_API_OWNER_ID : @"post,photo,photo_tag,wall_photo"
            }];

}

@end
