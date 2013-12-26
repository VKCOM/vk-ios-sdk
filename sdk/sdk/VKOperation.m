//
//  VKOperation.m
//  sdk
//
//  Created by Roman Truba on 26.12.13.
//  Copyright (c) 2013 VK. All rights reserved.
//

#import "VKOperation.h"
static inline NSString *VKKeyPathFromOperationState(VKOperationState state) {
	switch (state) {
		case VKOperationReadyState:
			return @"isReady";
            
		case VKOperationExecutingState:
			return @"isExecuting";
            
		case VKOperationFinishedState:
			return @"isFinished";
            
		case VKOperationPausedState:
			return @"isPaused";
            
		default:
			return @"state";
	}
}

static inline BOOL VKStateTransitionIsValid(VKOperationState fromState, VKOperationState toState, BOOL isCancelled) {
	switch (fromState) {
		case VKOperationReadyState:
			switch (toState) {
				case VKOperationPausedState:
				case VKOperationExecutingState:
					return YES;
                    
				case VKOperationFinishedState:
					return isCancelled;
                    
				default:
					return NO;
			}
            
		case VKOperationExecutingState:
			switch (toState) {
				case VKOperationPausedState:
				case VKOperationFinishedState:
					return YES;
                    
				default:
					return NO;
			}
            
		case VKOperationFinishedState:
			return NO;
            
		case VKOperationPausedState:
			return toState == VKOperationReadyState;
            
		default:
			return YES;
	}
}

@interface VKOperation ()
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, assign, getter = isCancelled) BOOL cancelled;
@end
@implementation VKOperation
- (id)init {
	self = [super init];
	self.state = VKOperationReadyState;
	return self;
}
- (void)setState:(VKOperationState)state {
	if (!VKStateTransitionIsValid(self.state, state, [self isCancelled])) {
		return;
	}
    
	[self.lock lock];
	NSString *oldStateKey = VKKeyPathFromOperationState(self.state);
	NSString *newStateKey = VKKeyPathFromOperationState(state);
    
	[self willChangeValueForKey:newStateKey];
	[self willChangeValueForKey:oldStateKey];
	_state = state;
	[self didChangeValueForKey:oldStateKey];
	[self didChangeValueForKey:newStateKey];
	[self.lock unlock];
}

- (BOOL)isReady {
	return self.state == VKOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
	return self.state == VKOperationExecutingState;
}

- (BOOL)isFinished {
	return self.state == VKOperationFinishedState;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)cancel {
	[self willChangeValueForKey:@"isCancelled"];
	_cancelled = YES;
	[super cancel];
	[self didChangeValueForKey:@"isCancelled"];
}
- (void)setCompletionBlock:(void (^)(void))block {
	[self.lock lock];
	if (!block) {
		[super setCompletionBlock:nil];
	}
	else {
		__weak __typeof(& *self) weakSelf = self;
        
		[super setCompletionBlock: ^{
		    __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            
		    block();
		    [strongSelf setCompletionBlock:nil];
		}];
	}
	[self.lock unlock];
}
@end
