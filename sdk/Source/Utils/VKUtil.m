//
//  VKUtil.m
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

#import "VKUtil.h"

@implementation VKUtil

+ (NSDictionary *)explodeQueryString:(NSString *)queryString {
    NSArray *keyValuePairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (NSString *keyValueString in keyValuePairs) {
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        parameters[keyValueArray[0]] = keyValueArray[1];
    }
    return parameters;
}

+ (NSString *)generateGUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef str = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    NSString *uuidString = [NSString stringWithFormat:@"%@", (__bridge NSString *) str];
    CFRelease(uuid);
    CFRelease(str);
    return uuidString;
}

+ (NSNumber *)parseNumberString:(id)number {
    if ([number isKindOfClass:[NSNumber class]])
        return (NSNumber *) number;
    static dispatch_once_t onceToken;
    static NSNumberFormatter *formatter;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
    });
    return [formatter numberFromString:number];
}

+ (UIColor *)colorWithRGB:(NSInteger)rgb {
    return [UIColor colorWithRed:((CGFloat) ((rgb & 0xFF0000) >> 16)) / 255.f green:((CGFloat) ((rgb & 0xFF00) >> 8)) / 255.f blue:((CGFloat) (rgb & 0xFF)) / 255.f alpha:1.0f];
}

static NSString *const kCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

+ (NSString *)escapeString:(NSString *)value {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) value, NULL, (__bridge CFStringRef) kCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSString *)queryStringFromParams:(NSDictionary *)params {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:params.count];
    for (NSString *key in params) {
        if ([params[key] isKindOfClass:[NSString class]])
            [array addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeString:params[key]]]];
        else
            [array addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    return [array componentsJoinedByString:@"&"];
}
@end
