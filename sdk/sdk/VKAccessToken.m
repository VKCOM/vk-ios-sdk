//
//  VKAccessToken.m
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

#import "VKAccessToken.h"
#import "NSData+AES256.h"
#import "VKUtil.h"
@implementation VKAccessToken

static NSString *const TOKEN_KEY = @"VK is the best";
+ (instancetype)tokenFromUrlString:(NSString *)urlString {
	NSDictionary *parameters   = [VKUtil explodeQueryString:urlString];
	VKAccessToken *token       = [VKAccessToken new];
	token.accessToken           = parameters[@"access_token"];
	token.expiresIn             = parameters[@"expires_in"];
	token.userId                = parameters[@"user_id"];
	token.secret                = parameters[@"secret"];
	token.httpsRequired         = NO;
	if (parameters[@"https_required"])
		token.httpsRequired = [parameters[@"https_required"] intValue] == 1;
    
	return token;
}

+ (instancetype)tokenFromFile:(NSString *)filePath {
	NSData *data = [[NSData dataWithContentsOfFile:filePath] decryptWithKey:TOKEN_KEY];
	if (!data)
		return nil;
	return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

+ (instancetype)tokenFromDefaults:(NSString *)defaultsKey {
	NSData *data = [[[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey] decryptWithKey:TOKEN_KEY];
	if (!data)
		return nil;
	return [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
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
}

- (NSData *)serialize {
	NSMutableString *tokenString = [NSMutableString stringWithFormat:@"access_token=%@&expires_in=%@&user_id=%@", self.accessToken, self.expiresIn, self.userId];
	if (self.secret)
		[tokenString appendFormat:@"&secret=%@", self.secret];
	if (self.httpsRequired)
		[tokenString appendString:@"&https_required=1"];
	NSData *data = [NSData dataWithData:[tokenString dataUsingEncoding:NSUTF8StringEncoding]];
	data          = [data encryptWithKey:TOKEN_KEY];
	return data;
}

@end
