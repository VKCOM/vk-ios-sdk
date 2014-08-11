//
//  VKUploadMessagesPhotoRequest.m
//  sdk
//
//  Created by Roman Truba on 05.08.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKUploadMessagesPhotoRequest.h"
#import "VKPhoto.h"
@implementation VKUploadMessagesPhotoRequest
- (VKRequest *)getServerRequest {
	return [VKRequest requestWithMethod:@"photos.getMessagesUploadServer" andParameters:nil andHttpMethod:@"POST"];
}

- (VKRequest *)getSaveRequest:(VKResponse *)response {
	return [VKRequest requestWithMethod:@"photos.saveMessagesPhoto" andParameters:response.json andHttpMethod:@"POST" classOfModel:[VKPhotoArray class]];

}
@end
