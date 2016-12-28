//
//  VKApiWall.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VKApiWall.h"

@implementation VKApiWall
- (VKRequest *)post:(NSDictionary *)params {
    return [self prepareRequestWithMethodName:@"post" parameters:params];
}

- (VKRequest *)getByOwnerId:(NSInteger)ownerId
                     domain:(NSString *)domain
                     offset:(NSInteger)offset
                      count:(NSInteger)count {
    return [self getByOwnerId:ownerId
                       domain:domain
                       offset:offset
                        count:count
                       filter:VKSdkWallFilterAll
                     extended:NO
                       fields:@[]];
}

- (VKRequest *)getByOwnerId:(NSInteger)ownerId
                     domain:(NSString *)domain
                     offset:(NSInteger)offset
                      count:(NSInteger)count
                     filter:(VKSdkWallFilter)filter
                   extended:(BOOL)extended
                     fields:(NSArray *)fields {
    return [self prepareRequestWithMethodName:@"get"
                                   parameters:
            @{
              VK_API_OWNER_ID   : @(ownerId),
              VK_API_DOMAIN     : domain,
              VK_API_COUNT      : @(count),
              VK_API_OFFSET     : @(offset),
              VK_API_FILTER     : [self filterNameForEnum:filter],
              VK_API_EXTENDED   : @(extended),
              VK_API_FIELDS     : fields
              }
                                   modelClass:[VKDocsArray class]];
}


- (NSString *)filterNameForEnum:(VKSdkWallFilter)filter {
    NSString *result = nil;
    switch (filter) {
        case VKSdkWallFilterAll:
            result = @"all";
            break;
        case VKSdkWallFilterSuggests:
            result = @"suggests";
            break;
        case VKSdkWallFilterOthers:
            result = @"others";
            break;
        case VKSdkWallFilterOwner:
            result = @"owner";
            break;
        case VKSdkWallFilterPostponed:
            result = @"postponed";
            break;
        default:
            result = @"";
            break;
    }
    return result;
}

@end
