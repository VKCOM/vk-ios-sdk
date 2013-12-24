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

@implementation VKApiObject
- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init]))
    {
        if (dict[@"response"] && [dict[@"response"] isKindOfClass:[NSDictionary class]])
        {
            dict = dict[@"response"];
            self.fields = [dict mutableCopy];
        }
        
        [self enumPropertiesWithBlock:^(NSString *propertyName) {
            if ([dict objectForKey:propertyName] == nil)
                return;
            [self setValue:dict[propertyName] forKey:propertyName];
        }];
    }
    return self;
}

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [self enumPropertiesWithBlock:^(NSString *propertyName) {
        if (![self valueForKey:propertyName])
            return;
        dict[propertyName] = [self valueForKey:propertyName];
    }];
    return dict;
}

-(void) enumPropertiesWithBlock:(void(^)(NSString * propertyName)) processBlock
{
    unsigned int propertiesCount;
    //Get all properties of current class
    Class searchClass = [self class];
    NSArray * ignoredProperties = [self ignoredProperties];
    while (searchClass != [VKObject class]) {
        objc_property_t * properties = class_copyPropertyList(searchClass, &propertiesCount);
       
        for(int i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithCString:propName
                                                            encoding:[NSString defaultCStringEncoding]];
                //You can set list of ignored properties of each class with overriding -(NSArray*) ignoredProperties
                if ([ignoredProperties containsObject:propertyName])
                    continue;
                //Process current property name
                processBlock(propertyName);
            }
        }
        free(properties);
        searchClass = [searchClass superclass];
    }
}
-(NSArray*) ignoredProperties
{
    return @[@"fields"];
}
@end
