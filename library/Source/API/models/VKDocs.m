//
//  VKDocs.m
//  Pods
//
//  Created by Mike on 1/6/16.
//
//


#import "VKDocs.h"

@implementation VKDocs

@end

@implementation VKDocsArray
- (instancetype)initWithDictionary:(NSDictionary *)dict {
  return [super initWithDictionary:dict objectClass:[VKDocs class]];
}
@end