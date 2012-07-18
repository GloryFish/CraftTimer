//
//  CTTimer.h
//  CraftTimer
//
//  Created by Jay Roberts on 7/16/12.
//  Copyright (c) 2012 GloryFish.org. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CTCraftTimerStates {
    CTCraftTimerStateWorking,
    CTCraftTimerStateResting,
} CTCraftTimerState;

@interface CTCraftTimer : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval totalElapsedTime;
@property (nonatomic, assign) NSTimeInterval workInterval;
@property (nonatomic, assign) NSTimeInterval restInterval;
@property (nonatomic, assign, readonly) CTCraftTimerState state;
@property (nonatomic, assign, readonly) BOOL paused;

+ (id)sharedTimer;

- (void)start;
- (void)stop;
- (void)pause;

- (void)persist;

@end
