//
//  VKDocs.h
//  Pods
//
//  Created by Mike on 1/6/16.
//
//

#import <Foundation/Foundation.h>
#import "VKApiObject.h"
#import "VKApiObjectArray.h"

@class VKDocs;

/**
 Docs type of VK API. See descriptions here https://vk.com/dev/doc
 */
@interface VKDocs : VKApiObject
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSNumber *owner_id;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSNumber *size;
@property(nonatomic, strong) NSString *ext;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *photo_100;
@property(nonatomic, strong) NSString *photo_130;
@property(nonatomic, strong) NSNumber *date;
@end

/**
 Array of API docs objects
 */
@interface VKDocsArray : VKApiObjectArray
@end