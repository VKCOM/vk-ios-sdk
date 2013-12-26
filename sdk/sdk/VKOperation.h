//
//  VKOperation.h
//  sdk
//
//  Created by Roman Truba on 26.12.13.
//  Copyright (c) 2013 VK. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
	VKOperationPausedState      = -1,
	VKOperationReadyState       = 1,
	VKOperationExecutingState   = 2,
	VKOperationFinishedState    = 3,
} VKOperationState;
/**
 Basic class for operations
 */
@interface VKOperation : NSOperation
/// This operation state. Value from VKOperationState enum
@property (readwrite, nonatomic, assign) VKOperationState state;
/// Operation working lock
@property (readonly, nonatomic, strong) NSRecursiveLock *lock;
@end
