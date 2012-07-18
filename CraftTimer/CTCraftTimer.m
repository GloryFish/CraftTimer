//
//  CTTimer.m
//  CraftTimer
//
//  Created by Jay Roberts on 7/16/12.
//  Copyright (c) 2012 GloryFish.org. All rights reserved.
//

#import "CTCraftTimer.h"

@interface CTCraftTimer ()

@property (nonatomic, assign, readonly) NSTimeInterval accumulatedTime;
@property (nonatomic, strong, readonly) NSDate* segmentStartTime;

- (void)reset;
- (NSString*)dataPath;
- (void)persist;

@end

@implementation CTCraftTimer

@synthesize accumulatedTime = _accumulatedTime;
@synthesize segmentStartTime = _segmentStartTime;
@synthesize totalElapsedTime = _totalElapsedTime;
@synthesize workInterval = _workInterval;
@synthesize restInterval = _restInterval;
@synthesize state = _state;
@synthesize paused = _paused;

#pragma mark - Initialization

+ (id)sharedTimer {
    static dispatch_once_t onceQueue;
    static CTCraftTimer *cTTimer = nil;
    
    dispatch_once(&onceQueue, ^{ cTTimer = [[self alloc] init]; });
    return cTTimer;
}

- (id)init { 
    if ( (self = [super init]) ) {
        // Load coded data
        NSData *codedData = [[NSData alloc] initWithContentsOfFile:[[self dataPath] stringByAppendingPathComponent:@"ctCraftTimer.dat"]];
        
        if (codedData == nil) {
            [self reset];
        } else {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
            self = [unarchiver decodeObjectForKey:@"ctCraftTimer"];
        }

    }
    return self;
}

#pragma mark - Timer

- (NSTimeInterval)totalElapsedTime {
    NSTimeInterval totalTime = self.accumulatedTime;
    if (!self.paused) {
        // Include any time accumulated in the current segment
        totalTime += [[NSDate date] timeIntervalSinceDate:self.segmentStartTime];
    }
    return totalTime;
}

- (void)start {
    // Begin workign for the day or resume from pause
    if (_paused) {
        _segmentStartTime = [NSDate date];
        _paused = NO;
    }
}

- (void)stop {
    // Done working for the day
    [self reset];
}

- (void)pause {
    // Still working but stop accumulating time
    _paused = YES;
    
    // Store the accumulated time since the last time we unpaused
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.segmentStartTime];
    _accumulatedTime += elapsed;
}

- (void)reset {
    _state = CTCraftTimerStateWorking;
    _paused = YES;
    _accumulatedTime = 0;
    _workInterval = 10;
    _restInterval = 15;
}

- (CTCraftTimerState)state {
    NSTimeInterval totalTime = [self totalElapsedTime];
    
    // Simulate running through the states
    _state = CTCraftTimerStateWorking;
    
    while (totalTime > 0) {
        if (_state == CTCraftTimerStateWorking) {
            totalTime = totalTime - self.workInterval;
            if (totalTime > 0) {
                _state = CTCraftTimerStateResting;
            }
        } else {
            totalTime = totalTime - self.restInterval;
            if (totalTime > 0) {
                _state = CTCraftTimerStateWorking;
            }
        }
    }
    
    return _state;
}

#pragma mark - NSCoding

static const NSInteger currentClassVersion = 1; // Current class version

+ (void)initialize {
    if (self == [CTCraftTimer class]) {
        self.version = currentClassVersion;
    }
}

-(void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeDouble:self.accumulatedTime forKey:@"accumulatedTime"];
    [coder encodeObject:self.segmentStartTime forKey:@"segmentStartTime"];
    [coder encodeDouble:self.workInterval forKey:@"workInterval"];
    [coder encodeDouble:self.restInterval forKey:@"restInterval"];
    [coder encodeInt:self.state forKey:@"state"];
    [coder encodeBool:self.paused forKey:@"paused"];
}

-(id)initWithCoder:(NSCoder*)coder {
    if (self=[super init]) {
        //        NSInteger version = [coder versionForClassName:@"OCCheckbook"];
        _accumulatedTime = [coder decodeDoubleForKey:@"accumulatedTime"];
        _segmentStartTime = [coder decodeObjectForKey:@"segmentStartTime"];
        _workInterval = [coder decodeDoubleForKey:@"workInterval"];
        _restInterval = [coder decodeDoubleForKey:@"restInterval"];
        _state = [coder decodeIntForKey:@"state"];
        _paused = [coder decodeBoolForKey:@"paused"];
    }
    return self;
}

- (NSString*)dataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0]; 
}

- (void)persist {
    // Generate archive
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:self forKey:@"ctCraftTimer"];
    [archiver finishEncoding];
    
    // Save archive to disk
    [data writeToFile:[[self dataPath] stringByAppendingPathComponent:@"ctCraftTimer.dat"] atomically:YES];
}

@end