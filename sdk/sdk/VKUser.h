//
//  VKUser.h
//
//  Copyright (c) 2013 VK.com
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

#import <Foundation/Foundation.h>
#import "VKApiObject.h"

@interface VKGeoObject : VKApiObject
@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * title;
@end

@interface VKCity : VKGeoObject
@end
@interface VKCountry : VKGeoObject
@end

/**
 User type of VK API. See descriptions here https://vk.com/dev/fields
 */
@interface VKUser : VKApiObject
#ifndef DOXYGEN_SHOULD_SKIP_THIS
//Original field - id
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSString *bdate;
@property (nonatomic, strong) VKCity *city;
@property (nonatomic, strong) VKCountry *country;
@property (nonatomic, strong) NSString *photo_50;
@property (nonatomic, strong) NSString *photo_100;
@property (nonatomic, strong) NSString *photo_200_orig;
@property (nonatomic, strong) NSString *photo_200;
@property (nonatomic, strong) NSString *photo_400_orig;
@property (nonatomic, strong) NSString *photo_max;
@property (nonatomic, strong) NSString *photo_max_orig;
@property (nonatomic, strong) NSNumber *online;
@property (nonatomic, strong) NSNumber *online_mobile;
@property (nonatomic, strong) NSArray  *lists;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSNumber *has_mobile;
@property (nonatomic, strong) NSDictionary *contacts;
@property (nonatomic, strong) NSString *connections;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSDictionary *education;
@property (nonatomic, strong) NSArray *universities;
@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) NSNumber *can_post;
@property (nonatomic, strong) NSNumber *can_see_all_posts;
@property (nonatomic, strong) NSNumber *can_see_audio;
@property (nonatomic, strong) NSNumber *can_write_private_message;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSDictionary *last_seen;
@property (nonatomic, strong) NSNumber *common_count;
@property (nonatomic, strong) NSNumber *relation;
@property (nonatomic, strong) NSArray  *relatives;
@property (nonatomic, strong) NSDictionary *counters;
#endif
@end
