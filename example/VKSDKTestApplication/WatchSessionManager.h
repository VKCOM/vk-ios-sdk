//
//  WatchSessionManager.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 31.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchConnectivity;

NS_ASSUME_NONNULL_BEGIN

@interface WatchSessionManager : NSObject <WCSessionDelegate>

+ (WatchSessionManager *)shared;

@end

NS_ASSUME_NONNULL_END
