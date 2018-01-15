//
//  VKHTTPClientProtocol.h
//  VKSdk
//
//  Created by Александр Золотарёв on 15.01.2018.
//  Copyright © 2018 VK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VKHTTPClientProtocol <NSObject>

@property (copy, nonatomic, readwrite, null_resettable) NSString *basePath;
           
@end
