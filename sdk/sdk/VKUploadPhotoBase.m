//
//  VKPhotoUploadBase.m
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

#import "VKUploadPhotoBase.h"

@implementation VKUploadPhotoBase
- (void)start {
	VKRequest *serverRequest = [self getServerRequest];
	serverRequest.completeBlock = ^(VKResponse *response) {
		NSData *imageData = nil;
		switch (_imageParameters.imageType) {
			case VKImageTypeJpg:
				imageData = UIImageJPEGRepresentation(_image, _imageParameters.jpegQuality);
				break;
                
			case VKImageTypePng:
				imageData = UIImagePNGRepresentation(_image);
				break;
                
			default:
				break;
		}
		self->_image = nil;
		VKRequest *postFileRequest = [VKRequest photoRequestWithPostUrl:response.json[@"upload_url"] withPhotos:@[[VKUploadImage objectWithData:imageData andParams:_imageParameters]]];
		postFileRequest.progressBlock = self.progressBlock;
		[postFileRequest executeWithResultBlock: ^(VKResponse *response) {
		    VKRequest *saveRequest = [self getSaveRequest:response];
		    [saveRequest executeWithResultBlock: ^(VKResponse *response) {
		        response.request = self;
		        if (self.completeBlock) self.completeBlock(response);
			} errorBlock:self.errorBlock];
		} errorBlock:self.errorBlock];
	};
	serverRequest.errorBlock = self.errorBlock;
	[serverRequest start];
}

- (VKRequest *)getServerRequest {
	@throw [NSException exceptionWithName:@"Abstract function" reason:@"getServerRequest should be overriden" userInfo:nil];
}

- (VKRequest *)getSaveRequest:(VKResponse *)response {
	@throw [NSException exceptionWithName:@"Abstract function" reason:@"getSaveRequest should be overriden" userInfo:nil];
}

@end
