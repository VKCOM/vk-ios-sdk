//
//  VKBatchRequest.m
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

#import "VKBatchRequest.h"

@implementation VKBatchRequest
- (instancetype)initWithRequests:(VKRequest *)firstRequest, ...
{
	self = [super init];
	_requests = [NSMutableArray new];
	va_list args;
	va_start(args, firstRequest);
	for (VKRequest *arg = firstRequest; arg != nil; arg = va_arg(args, VKRequest *)) {
		[_requests addObject:arg];
	}
	va_end(args);
	return self;
}
- (void)executeWithResultBlock:(void (^)(NSArray *responses))completeBlock errorBlock:(void (^)(VKError *))errorBlock {
	self.completeBlock  = completeBlock;
	self.errorBlock     = errorBlock;
	_responses = [NSMutableArray arrayWithCapacity:_requests.count];
	for (int i = 0; i < _requests.count; i++)
		[_responses addObject:[NSNull null]];
    
	for (VKRequest *request in _requests)
		[request executeWithResultBlock: ^(VKResponse *response) {
		    [self provideResponse:response];
		} errorBlock: ^(VKError *error) {
		    [self cancel];
		}];
}

- (void)cancel {
	for (VKRequest *request in _requests)
		[request cancel];
	[self provideError:[VKError errorWithCode:VK_API_CANCELED]];
}

- (void)provideResponse:(VKResponse *)response {
	_responses[[_requests indexOfObject:response.request]] = response;
	for (id response in _responses)
		if (response == [NSNull null]) return;
    
	if (self.completeBlock)
		self.completeBlock(_responses);
}

- (void)provideError:(VKError *)error {
	if (self.errorBlock)
		self.errorBlock(error);
}

@end
