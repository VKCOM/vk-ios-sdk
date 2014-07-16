//
//  VKUploadImage.m
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKUploadImage.h"

@implementation VKUploadImage
+ (instancetype)uploadImageWithData:(NSData *)data andParams:(VKImageParameters *)params {
    VKUploadImage *image = [VKUploadImage new];
    image.imageData      = data;
    image.parameters     = params;
    return image;
}

+ (instancetype)uploadImageWithImage:(UIImage*)image andParams:(VKImageParameters *)params {
    VKUploadImage *upload = [VKUploadImage new];
    upload.parameters     = params;
    upload.sourceImage    = image;
    return upload;
}
@end