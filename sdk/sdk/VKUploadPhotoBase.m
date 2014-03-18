//
//  VKPhotoUploadBase.m
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

#import "VKUploadPhotoBase.h"
#import "VKImageParameters.h"

extern inline NSString *VKKeyPathFromOperationState(VKOperationState state);
extern inline BOOL VKStateTransitionIsValid(VKOperationState fromState, VKOperationState toState, BOOL isCancelled);



@implementation VKUploadPhotoBase
- (NSOperation *)executionOperation {
	return _executionOperation = [VKUploadImageOperation operationWithUploadRequest:self];
}

- (VKRequest *)getServerRequest {
	@throw [NSException exceptionWithName:@"Abstract function" reason:@"getServerRequest should be overriden" userInfo:nil];
}

- (VKRequest *)getSaveRequest:(VKResponse *)response {
	@throw [NSException exceptionWithName:@"Abstract function" reason:@"getSaveRequest should be overriden" userInfo:nil];
}

@end

@interface VKUploadImageOperation ()
@property (nonatomic, strong) VKUploadPhotoBase *uploadRequest;
@property (readwrite, nonatomic, assign) VKOperationState state;
@property (nonatomic, strong) VKRequest *lastLoadingRequest;
@end
@implementation VKUploadImageOperation

+ (instancetype)operationWithUploadRequest:(VKUploadPhotoBase *)uploadRequest {
	VKUploadImageOperation *operation = [VKUploadImageOperation new];
	operation.uploadRequest = uploadRequest;
	return operation;
}



- (void)start {
	void (^originalErrorBlock)(NSError *) = [_uploadRequest.errorBlock copy];
	__weak VKUploadImageOperation *weakSelf = self;
	_uploadRequest.errorBlock = ^(NSError *error) {
		[weakSelf finish];
		if (originalErrorBlock)
			originalErrorBlock(error);
	};
	self.state = VKOperationExecutingState;
    
	VKRequest *serverRequest = [_uploadRequest getServerRequest];
	serverRequest.completeBlock = ^(VKResponse *response) {
		NSData *imageData = nil;
		switch (_uploadRequest.imageParameters.imageType) {
			case VKImageTypeJpg:
				imageData = UIImageJPEGRepresentation(_uploadRequest.image, _uploadRequest.imageParameters.jpegQuality);
				break;
                
			case VKImageTypePng:
				imageData = UIImagePNGRepresentation(_uploadRequest.image);
				break;
                
			default:
				break;
		}
		_uploadRequest.image = nil;
		VKRequest *postFileRequest = [VKRequest photoRequestWithPostUrl:response.json[@"upload_url"] withPhotos:@[[VKUploadImage objectWithData:imageData andParams:_uploadRequest.imageParameters]]];
		postFileRequest.progressBlock = _uploadRequest.progressBlock;
		self.lastLoadingRequest = postFileRequest;
		[postFileRequest executeWithResultBlock: ^(VKResponse *response) {
		    VKRequest *saveRequest = [_uploadRequest getSaveRequest:response];
		    self.lastLoadingRequest = saveRequest;
		    [saveRequest executeWithResultBlock: ^(VKResponse *response) {
		        response.request = _uploadRequest;
		        if (_uploadRequest.completeBlock) _uploadRequest.completeBlock(response);
		        [weakSelf finish];
			} errorBlock:_uploadRequest.errorBlock];
		} errorBlock:_uploadRequest.errorBlock];
	};
	serverRequest.errorBlock = _uploadRequest.errorBlock;
	self.lastLoadingRequest = serverRequest;
	[serverRequest start];
}

- (void)finish {
	self.state = VKOperationFinishedState;
    self.uploadRequest = nil;
    self.lastLoadingRequest = nil;
}

- (void)cancel {
	[super cancel];
	[self.lastLoadingRequest cancel];
}

@end
