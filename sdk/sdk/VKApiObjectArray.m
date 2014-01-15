//
//  VKApiObjectArray.m
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

#import "VKApiObjectArray.h"

@implementation VKApiObjectArray
-(instancetype)initWithDictionary:(NSDictionary *)dict objectClass:(Class)objectClass
{
    self = [super initWithDictionary:dict];
    if (!self.items)
    {
        self.items = dict[@"response"];
        self.count = self.items.count;
    }
    
    NSMutableArray * listOfParsedUsers = [NSMutableArray new];
    for (id userDictionary in self.items) {
        if ([userDictionary isKindOfClass:[NSDictionary class]])
            [listOfParsedUsers addObject:[[objectClass alloc] initWithDictionary:userDictionary]];
        else
            [listOfParsedUsers addObject:userDictionary];
    }
    self.items = listOfParsedUsers;
    return self;
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.items countByEnumeratingWithState:state objects:buffer count:len];
}
-(id)objectAtIndex:(NSInteger)idx {
    return [self.items objectAtIndex:idx];
}
@end
