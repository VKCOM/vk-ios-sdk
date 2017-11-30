//
//  VKVideo.h
//
//  Copyright (c) 2016 VK.com
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

#import "VKApiObjectArray.h"

@interface VKVideo : VKApiObject

@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSNumber *owner_id;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong, readonly) NSString *description;
@property(nonatomic, strong) NSNumber *duration;
@property(nonatomic, strong) NSString *photo_130;
@property(nonatomic, strong) NSString *photo_320;
@property(nonatomic, strong) NSString *photo_640;
@property(nonatomic, strong) NSNumber *date;
@property(nonatomic, strong) NSNumber *adding_date;
@property(nonatomic, strong) NSNumber *views;
@property(nonatomic, strong) NSNumber *comments;
@property(nonatomic, strong) NSString *player;
@property(nonatomic, strong) NSString *access_key;
@property(nonatomic, strong) NSNumber *processing;
@property(nonatomic, strong) NSNumber *live;

@end

/**
 Array of API Videos
 */
@interface VKVideos : VKApiObjectArray
@end