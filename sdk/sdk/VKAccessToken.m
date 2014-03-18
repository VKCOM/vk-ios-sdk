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

#import "VKAccessToken.h"
#import "VKUtil.h"
#import "VKSdk.h"


@interface VKAccessToken ()
@property (nonatomic, readwrite, assign) NSTimeInterval created;
@end

@implementation VKAccessToken
static NSString *const ACCESS_TOKEN = @"access_token";
static NSString *const EXPIRES_IN = @"expires_in";
static NSString *const USER_ID = @"user_id";
static NSString *const SECRET = @"secret";
static NSString *const HTTPS_REQUIRED = @"https_required";
static NSString *const CREATED = @"created";

+ (instancetype)tokenFromUrlString:(NSString *)urlString {
	NSDictionary *parameters   = [VKUtil explodeQueryString:urlString];
	VKAccessToken *token       = [VKAccessToken new];
	token.accessToken           = parameters[ACCESS_TOKEN];
	token.expiresIn             = parameters[EXPIRES_IN];
	token.userId                = parameters[USER_ID];
	token.secret                = parameters[SECRET];
	token.httpsRequired         = NO;
	if (parameters[HTTPS_REQUIRED])
		token.httpsRequired = [parameters[HTTPS_REQUIRED] intValue] == 1;
    
    if ([parameters objectForKey:CREATED])
        token.created = [parameters[CREATED] floatValue];
    else
        token.created = [[NSDate new] timeIntervalSince1970];
    [token checkIfExpired];
	return token;
}

+ (instancetype)tokenFromFile:(NSString *)filePath {
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	if (!data)
		return nil;
	return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

+ (instancetype)tokenFromDefaults:(NSString *)defaultsKey {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];
	if (!data)
		return nil;
	return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}
-(BOOL)isExpired {
    if (_accessToken == nil)
        return YES;
    int expiresIn = [self.expiresIn intValue];
    return  expiresIn > 0 && expiresIn + self.created < [[NSDate new] timeIntervalSince1970];
}
- (void) checkIfExpired
{
    if (self.isExpired)
        [[[VKSdk instance] delegate] vkSdkTokenHasExpired:self];
}
- (NSString *)accessToken
{
    [self checkIfExpired];
    return _accessToken;
}
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
    NSMutableDictionary * dict =
        [NSMutableDictionary dictionaryWithObjects:@[self.accessToken, self.expiresIn, self.userId, @(self.created)]
                                           forKeys:@[ACCESS_TOKEN, EXPIRES_IN, USER_ID, CREATED]];
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
