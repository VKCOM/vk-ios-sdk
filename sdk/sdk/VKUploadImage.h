//
//  VKUploadImage.h
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKImageParameters.h"
/**
 Contains image data with image description
 */
@interface VKUploadImage : VKObject

/// Bytes of image
@property (nonatomic, strong) NSData *imageData;
/// Source image
@property (nonatomic, strong) UIImage *sourceImage;
/// Image basic info
@property (nonatomic, strong) VKImageParameters *parameters;
/**
 Create new image data representation used for upload
 @param data Bytes of image
 @param params Image basic info
 @return Prepared object for using in upload
 */
+ (instancetype)uploadImageWithData:(NSData *)data andParams:(VKImageParameters *)params;

/**
 Create new image representation used for upload
 @param image Source image
 @param params Image basic info
 @return Prepared object for using in upload
 */
+ (instancetype)uploadImageWithImage:(UIImage*)image andParams:(VKImageParameters *)params;
@end