//
//  VKAccessToken.m
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
//
//  --------------------------------------------------------------------------------
//
//  Modified by Ruslan Kavetsky

#import "VKAccessToken.h"
#import "VKUtil.h"
#import "VKSdk.h"


@implementation VKAccessToken {
    NSString *_accessToken;
}

static NSString *const ACCESS_TOKEN   = @"access_token";
static NSString *const EXPIRES_IN     = @"expires_in";
static NSString *const USER_ID        = @"user_id";
static NSString *const SECRET         = @"secret";
static NSString *const EMAIL          = @"email";
static NSString *const HTTPS_REQUIRED = @"https_required";
static NSString *const CREATED        = @"created";
static NSString *const PERMISSIONS    = @"permissions";

#pragma mark - Creating

+ (instancetype)tokenWithToken:(NSString *)accessToken
                        secret:(NSString *)secret
                        userId:(NSString *)userId {

    return [[VKAccessToken alloc] initWithToken:accessToken secret:secret userId:userId];
}

- (instancetype)initWithToken:(NSString *)accessToken
                       secret:(NSString *)secret
                       userId:(NSString *)userId {
    self = [super init];
    if (self) {
        _accessToken = accessToken;
        _secret = secret;
        _userId = userId;
    }
    return self;
}


+ (instancetype)tokenFromUrlString:(NSString *)urlString {
    return [[VKAccessToken alloc] initWithUrlString:urlString];
}

- (instancetype)initWithUrlString:(NSString *)urlString {

    self = [super init];
    if (self) {

        NSDictionary *parameters   = [VKUtil explodeQueryString:urlString];
        _accessToken           = parameters[ACCESS_TOKEN];
        _expiresIn             = parameters[EXPIRES_IN];
        _userId                = parameters[USER_ID];
        _secret                = parameters[SECRET];
        _email                 = parameters[EMAIL];
        _httpsRequired         = NO;

        NSString *permissionsString = parameters[PERMISSIONS];
        permissionsString = [permissionsString stringByReplacingOccurrencesOfString:@"(" withString:@""];
        permissionsString = [permissionsString stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *comp in [permissionsString componentsSeparatedByString:@","]) {
            [array addObject:[comp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        _permissions = [array copy];

        if (parameters[HTTPS_REQUIRED])
            _httpsRequired = [parameters[HTTPS_REQUIRED] intValue] == 1;

        if ([parameters objectForKey:CREATED]) {
            _created = [parameters[CREATED] floatValue];
        } else {
            _created = [[NSDate new] timeIntervalSince1970];
        }

        [self checkIfExpired];
    }

	return self;
}

+ (instancetype)tokenFromFile:(NSString *)filePath {
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	if (!data)
		return nil;
	return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

+ (instancetype)tokenFromDefaults:(NSString *)defaultsKey {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];

	if (!data) {
		return nil;
    } else {
        return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
}

#pragma mark - Expire

- (BOOL)isExpired {
    if (_accessToken == nil)
        return YES;
    int expiresIn = [self.expiresIn intValue];
    return  expiresIn > 0 && expiresIn + self.created < [[NSDate new] timeIntervalSince1970];
}

- (void)checkIfExpired {
    if (_accessToken && self.isExpired)
        [[[VKSdk instance] delegate] vkSdkTokenHasExpired:self];
}

#pragma mark -

- (NSString *)accessToken {
    if (_accessToken) [self checkIfExpired];
    return _accessToken;
}

#pragma mark - Save / Load

- (void)saveTokenToFile:(NSString *)filePath {
	NSError *error = nil;
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:filePath])
		[manager removeItemAtPath:filePath error:&error];

	[[self serialize] writeToFile:filePath atomically:YES];
}

- (void)saveTokenToDefaults:(NSString *)defaultsKey {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[self serialize] forKey:defaultsKey];
    [defaults synchronize];
}

- (NSData *)serialize {
    NSMutableDictionary * dict = [@{
                                    ACCESS_TOKEN : self.accessToken ? : @"",
                                    EXPIRES_IN : self.expiresIn  ? : @"0",
                                    USER_ID : self.userId  ? : @"0",
                                    CREATED : @(self.created),
                                    PERMISSIONS : self.permissions ? : @""
                                    } mutableCopy];

	if (self.secret)
		[dict setObject:self.secret forKey:SECRET];

	if (self.httpsRequired)
        [dict setObject:@(1) forKey:HTTPS_REQUIRED];

    NSMutableArray * result = [NSMutableArray new];

    for (NSString * key in dict)
        [result addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];

	return [[result componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
