//
//  VKApiObject.m
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

#import <objc/runtime.h>
#import "VKApiObject.h"
#import "VKApiObjectArray.h"

#define PRINT_PARSE_DEBUG_INFO false

static NSString *getPropertyType(objc_property_t property) {
	const char *type = property_getAttributes(property);
	NSString *typeString = [NSString stringWithUTF8String:type];
	NSArray *attributes = [typeString componentsSeparatedByString:@","];
	NSString *typeAttribute = [attributes objectAtIndex:0];
	NSString *propertyType = [typeAttribute substringFromIndex:1];
	const char *rawPropertyType = [propertyType UTF8String];
    
	if (strcmp(rawPropertyType, @encode(float)) == 0) {
		return @"float";
	}
	else if (strcmp(rawPropertyType, @encode(int)) == 0) {
		return @"int";
	}
	else if (strcmp(rawPropertyType, @encode(id)) == 0) {
		return @"id";
	}
    
	if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
		NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length] - 4)];  //e.g. turns @"NSDate" into NSDate
		if (typeClassName != nil) {
			return typeClassName;
		}
	}
	return nil;
}

@implementation VKApiObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
	if ((self = [super init])) {
		[self parse:dict];
	}
	return self;
}

- (void)parse:(NSDictionary *)dict {
	__block NSMutableArray *warnings = [NSMutableArray new];
	[self enumPropertiesWithBlock: ^(NSString *propertyName, NSString *propertyClassName) {
	    if (![dict objectForKey:propertyName]) {
	        [warnings addObject:[NSString stringWithFormat:@"no object for property with name %@", propertyName]];
	        return;
		}
	    id resultObject = nil;
	    id parseObject = [dict objectForKey:propertyName];
        
        if ([@[@"int", @"float", @"double", @"long", @"id"] containsObject:propertyClassName]) {
            [self setValue:parseObject forKey:propertyName];
            return;
        }
        Class propertyClass = NSClassFromString(propertyClassName);
	    if ([propertyClass isSubclassOfClass:[VKApiObjectArray class]]) {
	        if ([parseObject isKindOfClass:[NSDictionary class]]) {
	            resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
			}
	        else if ([parseObject isKindOfClass:[NSArray class]]) {
	            resultObject = [[propertyClass alloc] initWithArray:parseObject];
			}
	        else {
	            [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
			}
		}
	    else if ([propertyClass isSubclassOfClass:[VKApiObject class]]) {
	        if ([parseObject isKindOfClass:[NSDictionary class]]) {
	            resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
			}
	        else {
	            [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
			}
		}
	    else {
	        resultObject = parseObject;
	        if (![resultObject isKindOfClass:propertyClass]) {
	            [warnings addObject:[NSString stringWithFormat:@"property with name %@ expected class %@, result class %@", propertyName, propertyClass, [resultObject class]]];
			}
		}
	    [self setValue:resultObject forKey:propertyName];
	}];
	if (PRINT_PARSE_DEBUG_INFO && warnings.count)
		NSLog(@"Parsing complete. Warnings: %@", warnings);
}

- (void)enumPropertiesWithBlock:(void (^)(NSString *propertyName, NSString *propertyClassName))processBlock {
	unsigned int propertiesCount;
	//Get all properties of current class
	Class searchClass = [self class];
	NSArray *ignoredProperties = [self ignoredProperties];
	while (searchClass != [VKApiObject class]) {
		objc_property_t *properties = class_copyPropertyList(searchClass, &propertiesCount);
        
		for (int i = 0; i < propertiesCount; i++) {
			objc_property_t property = properties[i];
			const char *propName = property_getName(property);
			if (propName) {
				NSString *propertyName = [NSString stringWithCString:propName
				                                            encoding:[NSString defaultCStringEncoding]];
                
				//You can set list of ignored properties of each class with overriding -(NSArray*) ignoredProperties
				if ([ignoredProperties containsObject:propertyName])
					continue;
				//Process current property name
				if (processBlock)
					processBlock(propertyName, getPropertyType(property));
			}
		}
		free(properties);
		searchClass = [searchClass superclass];
	}
}

- (NSArray *)ignoredProperties {
	return @[@"fields"];
}

- (NSMutableDictionary *)serialize {
	NSMutableDictionary *result = [NSMutableDictionary new];
	[self enumPropertiesWithBlock: ^(NSString *propertyName, NSString *propertyClassName) {
	    if (![self valueForKey:propertyName])
			return;
        Class propertyClass = NSClassFromString(propertyClassName);
	    if ([propertyClass isSubclassOfClass:[VKApiObjectArray class]]) {
	        [[self valueForKey:propertyName] serializeTo:result withName:propertyName];
		}
	    else if ([propertyClass isSubclassOfClass:[VKApiObject class]]) {
	        [result setObject:[[self valueForKey:propertyName] serialize] forKey:propertyName];
		}
	    else {
	        [result setObject:[self valueForKey:propertyName] forKey:propertyName];
		}
	}];
	return result;
}
@end
