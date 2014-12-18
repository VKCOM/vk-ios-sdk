//
//  VKRequest.m
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

#import "VKSdk.h"
#import "VKRequest.h"
#import "NSString+MD5.h"
#import "OrderedDictionary.h"
#import "VKAuthorizeController.h"
#import "VKHTTPClient.h"
#import "VKError.h"
#import "NSError+VKError.h"

#define SUPPORTED_LANGS_ARRAY @[@"ru", @"en", @"ua", @"es", @"fi", @"de", @"it"]

@interface VKRequestTiming ()
{
    NSDate *_parseStartTime;
}
@end

@implementation VKRequestTiming

-(NSString *)description {
    return [NSString stringWithFormat:@"<VKRequestTiming: %p (load: %f, parse: %f, total: %f)>",
            self, _loadTime, _parseTime, self.totalTime];
}
-(void) started { _startTime = [NSDate new]; }
-(void) loaded  { _loadTime  = [[NSDate new] timeIntervalSinceDate:_startTime]; }
-(void) parseStarted { _parseStartTime = [NSDate new]; }
-(void) parseFinished { _parseTime = [[NSDate new] timeIntervalSinceDate:_parseStartTime]; }
-(void) finished { _finishTime = [NSDate new]; }
-(NSTimeInterval)totalTime { return [_finishTime timeIntervalSinceDate:_startTime]; }
@end

static NSOperationQueue * requestsProcessingQueue;

@interface VKRequest ()
{
    /// Semaphore for blocking current thread
    dispatch_semaphore_t _waitUntilDoneSemaphore;
}
@property (nonatomic, readwrite, strong) VKRequestTiming *requestTiming;
/// Selected method name
@property (nonatomic, strong) NSString *methodName;
/// HTTP method for loading
@property (nonatomic, strong) NSString *httpMethod;
/// Passed parameters for method
@property (nonatomic, strong) NSDictionary *methodParameters;
/// Method parametes with common parameters
@property (nonatomic, strong) OrderedDictionary *preparedParameters;
/// Url for uploading files
@property (nonatomic, strong) NSString *uploadUrl;
/// Requests that should be called after current request.
@property (nonatomic, strong) NSMutableArray *postRequestsQueue;
/// Class for model parsing
@property (nonatomic, strong) Class modelClass;
/// Paths to photos
@property (nonatomic, strong) NSArray *photoObjects;
/// How much times request was loaded
@property (readwrite, assign) int attemptsUsed;
/// This request response
@property (nonatomic, strong)   VKResponse *response;
/// This request error
@property (nonatomic, strong)   NSError    *error;

@end

@implementation VKRequest
@synthesize preferredLang = _preferredLang;

+ (NSOperationQueue*) processingQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestsProcessingQueue = [NSOperationQueue new];
        requestsProcessingQueue.maxConcurrentOperationCount = 3;
    });
    return requestsProcessingQueue;
}

#pragma mark Init
+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters andHttpMethod:(NSString *)httpMethod {
	VKRequest *newRequest = [self new];
	//Common parameters
	newRequest.parseModel       = YES;
    newRequest.requestTimeout   = 30;
    
	newRequest.methodName       = method;
	newRequest.methodParameters = parameters;
	newRequest.httpMethod       = httpMethod;
	return newRequest;
}

+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters andHttpMethod:(NSString *)httpMethod classOfModel:(Class)modelClass {
	VKRequest *request = [self requestWithMethod:method andParameters:parameters andHttpMethod:httpMethod];
	request.modelClass = modelClass;
	return request;
}

+ (instancetype)photoRequestWithPostUrl:(NSString *)url withPhotos:(NSArray *)photoObjects;
{
	VKRequest *newRequest   = [self new];
	newRequest.attempts     = 10;
	newRequest.httpMethod   = @"POST";
	newRequest.uploadUrl    = url;
	newRequest.photoObjects = photoObjects;
	return newRequest;
}
- (id)init {
	self = [super init];
	self.attemptsUsed       = 0;
	//If system language is not supported, we use english
	self.preferredLang      = @"en";
    //By default there is 1 attempt for loading.
	self.attempts           = 1;
    //By default we use system language.
    self.useSystemLanguage  = YES;
    self.secure             = YES;
	return self;
}

- (NSString *)description {
//	return [NSString stringWithFormat:@"<VKRequest: %p>\nMethod: %@ (%@)\nparameters: %@", self, _methodName, _httpMethod, _methodParameters];
    return [NSString stringWithFormat:@"<VKRequest: %p; Method: %@ (%@)>", self, self.methodName, self.httpMethod];
}

#pragma mark Execution
- (void)executeWithResultBlock:(void (^)(VKResponse *))completeBlock
                    errorBlock:(void (^)(NSError *))errorBlock {
	self.completeBlock = completeBlock;
	self.errorBlock    = errorBlock;
    
	[self start];
}

- (void)executeAfter:(VKRequest *)request
     withResultBlock:(void (^)(VKResponse *response))completeBlock
          errorBlock:(void (^)(NSError *error))errorBlock {
	self.completeBlock = completeBlock;
	self.errorBlock    = errorBlock;
	[request addPostRequest:self];
}

- (void)addPostRequest:(VKRequest *)postRequest {
	if (!_postRequestsQueue)
		_postRequestsQueue = [NSMutableArray new];
	[_postRequestsQueue addObject:postRequest];
}

- (NSURLRequest *)getPreparedRequest {
	//Add common parameters to parameters list
	if (!_preparedParameters && !_uploadUrl) {
		_preparedParameters = [[OrderedDictionary alloc] initWithCapacity:self.methodParameters.count * 2];
		for (NSString *key in self.methodParameters) {
			[_preparedParameters setObject:self.methodParameters[key] forKey:key];
		}
		VKAccessToken *token = [VKSdk getAccessToken];
		if (token != nil) {
            if (token.accessToken != nil) {
                [_preparedParameters setObject:token.accessToken forKey:VK_API_ACCESS_TOKEN];
            }
            if (!(self.secure || token.secret) || token.httpsRequired)
                self.secure = YES;
		}
        
		//Set actual version of API
		[_preparedParameters setObject:VK_SDK_API_VERSION forKey:@"v"];
		//Set preferred language for request
		[_preparedParameters setObject:self.preferredLang forKey:VK_API_LANG];
		//Set current access token from SDK object
        
		if (self.secure) {
			//If request is secure, we need all urls as https
			[_preparedParameters setObject:@"1" forKey:@"https"];
		}
		if (token && token.secret) {
			//If it not, generate signature of request
			NSString *sig = [self generateSig:_preparedParameters token:token];
			[_preparedParameters setObject:sig forKey:VK_API_SIG];
		}
		//From that moment you cannot modify parameters.
		//Specially for http loading
	}
    
	NSMutableURLRequest *request = nil;
	if (!_uploadUrl) {
		request = [[VKHTTPClient getClient] requestWithMethod:self.httpMethod path:self.methodName parameters:_preparedParameters secure:self.secure];
	}
	else {
		request = [[VKHTTPClient getClient] multipartFormRequestWithMethod:@"POST" path:_uploadUrl images:_photoObjects];
	}
    [request setTimeoutInterval:self.requestTimeout];
	[request setValue:nil forHTTPHeaderField:@"Accept-Language"];
	return request;
}
- (NSOperation*) executionOperation
{
    VKHTTPOperation * operation = [VKHTTPOperation operationWithRequest:self];
	if (!operation)
		return nil;
    if (_debugTiming) {
        _requestTiming = [VKRequestTiming new];
    }
    
	[operation setCompletionBlockWithSuccess: ^(VKHTTPOperation *operation, id JSON) {
        [[VKRequest processingQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
            [_requestTiming loaded];
            if ([JSON objectForKey:@"error"]) {
                VKError *error = [VKError errorWithJson:[JSON objectForKey:@"error"]];
                if ([self processCommonError:error]) return;
                [self provideError:[NSError errorWithVkError:error]];
                return;
            }
            [self provideResponse:JSON];
        }]];
	} failure: ^(VKHTTPOperation *operation, NSError *error) {
        [[VKRequest processingQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
            [_requestTiming loaded];
            if (operation.response.statusCode == 200) {
                [self provideResponse:operation.responseJson];
                return;
            }
            if (self.attempts == 0 || ++self.attemptsUsed < self.attempts) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), self.responseQueue,
                               ^(void) {
                                   [self start];
                               });
                return;
            }
            
            VKError *vkErr = [VKError errorWithCode:operation.response.statusCode];
            [self provideError:[error copyWithVkError:vkErr]];
            [_requestTiming finished];
        }]];
        
	}];
    [self setOperation:operation responseQueue:self.responseQueue];
	[self setupProgress:operation];
    return operation;
}
- (void)setOperation:(VKHTTPOperation*) operation responseQueue:(dispatch_queue_t)responseQueue {
    [operation setSuccessCallbackQueue:responseQueue];
    [operation setFailureCallbackQueue:responseQueue];
}
- (void)start {
	_executionOperation = self.executionOperation;
    if (_executionOperation == nil)
        return;

    if (self.debugTiming) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationDidStart:) name:VKNetworkingOperationDidStart object:nil];
    }
    if (!self.waitUntilDone) {
        [[VKHTTPClient getClient] enqueueOperation:_executionOperation];
    } else {
        [self setOperation:(VKHTTPOperation*)_executionOperation responseQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        _waitUntilDoneSemaphore = dispatch_semaphore_create(0);
        [[VKHTTPClient getClient] enqueueOperation:_executionOperation];
        dispatch_semaphore_wait(_waitUntilDoneSemaphore, DISPATCH_TIME_FOREVER);
        [self finishRequest];
    }
}
- (void)operationDidStart:(NSNotification*) notification {
    if (notification.object == _executionOperation)
        [self.requestTiming started];
}
- (void)provideResponse:(id)JSON {
    VKResponse *vkResp = [VKResponse new];
    vkResp.request      = self;
    if (JSON[@"response"]) {
        vkResp.json = JSON[@"response"];
        
        if (self.parseModel && _modelClass) {
            [_requestTiming parseStarted];
            id object = [_modelClass alloc];
            if ([object respondsToSelector:@selector(initWithDictionary:)]) {
                vkResp.parsedModel = [object initWithDictionary:JSON];
            }
            [_requestTiming parseFinished];
        }
    }
    else
        vkResp.json = JSON;
    
    for (VKRequest *postRequest in _postRequestsQueue)
        [postRequest start];
    [_requestTiming finished];
    self.response = vkResp;
    if (self.waitUntilDone) {
        dispatch_semaphore_signal(_waitUntilDoneSemaphore);
    } else {
        dispatch_async(self.responseQueue, ^{
            [self finishRequest];
        });
    }
}

- (void)provideError:(NSError *)error {
	error.vkError.request = self;
    self.error = error;
    if (self.waitUntilDone) {
        dispatch_semaphore_signal(_waitUntilDoneSemaphore);
    }
    else {
        dispatch_async(self.responseQueue, ^{
            [self finishRequest];
        });
    }
}
- (void) finishRequest {
    if (self.error) {
        if (self.errorBlock) {
            self.errorBlock(self.error);
        }
        for (VKRequest *postRequest in _postRequestsQueue)
            if (postRequest.errorBlock) postRequest.errorBlock(self.error);
    } else {
        if (self.completeBlock)
            self.completeBlock(self.response);
    }
    self.response = nil;
    self.error    = nil;
}

- (void)repeat {
	_attemptsUsed = 0;
	_preparedParameters = nil;
	[self start];
}

- (void)cancel {
	[_executionOperation cancel];
	[self provideError:[NSError errorWithVkError:[VKError errorWithCode:VK_API_CANCELED]]];
}

- (void)setupProgress:(VKHTTPOperation *)operation {
	if (self.progressBlock) {
		[operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             self.progressBlock(VKProgressTypeUpload, totalBytesWritten, totalBytesExpectedToWrite);
         }];
		[operation setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             self.progressBlock(VKProgressTypeDownload, totalBytesRead, totalBytesExpectedToRead);
         }];
	}
}

- (void)addExtraParameters:(NSDictionary *)extraParameters {
	if (!_methodParameters)
		_methodParameters = [extraParameters mutableCopy];
	else {
		NSMutableDictionary *params = [_methodParameters mutableCopy];
		[params addEntriesFromDictionary:extraParameters];
		_methodParameters = params;
	}
}

#pragma mark Sevice
- (NSString *)generateSig:(OrderedDictionary *)params token:(VKAccessToken *)token {
	//Read description here https://vk.com/dev/api_nohttps
	//First of all, we need key-value pairs in order of request
	NSMutableArray *paramsArray = [NSMutableArray arrayWithCapacity:params.count];
	for (NSString *key in params) {
		[paramsArray addObject:[key stringByAppendingFormat:@"=%@", params[key]]];
	}
	//Then we generate "request string" /method/{METHOD_NAME}?{GET_PARAMS}{POST_PARAMS}
	NSString *requestString = [NSString stringWithFormat:@"/method/%@?%@", _methodName, [paramsArray componentsJoinedByString:@"&"]];
	requestString = [requestString stringByAppendingString:token.secret];
	return [requestString MD5];
}

- (BOOL)processCommonError:(VKError *)error {
	if (error.errorCode == VK_API_ERROR) {
        error.apiError.request = self;
        if (error.apiError.errorCode == 6) {
            //Too many requests per second
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.responseQueue, ^{
                [self repeat];
            });
            return YES;
        }
		if (error.apiError.errorCode == 14) {
            //Captcha
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[VKSdk instance].delegate vkSdkNeedCaptchaEnter:error.apiError];
            });
			return YES;
		}
		else if (error.apiError.errorCode == 16) {
            //Https required
			VKAccessToken *token = [VKSdk getAccessToken];
			token.httpsRequired = YES;
			[self repeat];
			return YES;
		}
		else if (error.apiError.errorCode == 17) {
            //Validation needed
            dispatch_sync(dispatch_get_main_queue(), ^{
                [VKAuthorizeController presentForValidation:error.apiError];
            });
			
			return YES;
		}
	}
    
	return NO;
}

#pragma mark Properties
- (NSString *)preferredLang {
	NSString *lang = _preferredLang;
	if (self.useSystemLanguage) {
		lang = [NSLocale preferredLanguages][0];
		if ([lang isEqualToString:@"uk"])
			lang = @"ua";
		if (![SUPPORTED_LANGS_ARRAY containsObject:lang])
			lang = _preferredLang;
	}
	return lang;
}
-(dispatch_queue_t)responseQueue {
    if (!_responseQueue) {
        return dispatch_get_main_queue();
    }
    return _responseQueue;
}

- (void)setPreferredLang:(NSString *)preferredLang {
	_preferredLang = preferredLang;
	self.useSystemLanguage = NO;
}
-(BOOL)isExecuting {
    return _executionOperation.isExecuting;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.responseQueue = nil;
}

@end
