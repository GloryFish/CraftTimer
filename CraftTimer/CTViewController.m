//
//  CTViewController.m
//  CraftTimer
//
//  Created by Jay Roberts on 7/16/12.
//  Copyright (c) 2012 GloryFish.org. All rights reserved.
//

#import "CTViewController.h"
#import "CTCraftTimer.h"

@interface CTViewController ()

@end

@implementation CTViewController

@synthesize elapsedTime = _elapsedTime;
@synthesize displayTimer = _displayTimer;
@synthesize currentState = _currentState;
@synthesize startStopButton = _startStopButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.elapsedTime.text = [[NSString alloc] initWithFormat:@"%02d:%02d", 0, 0];
}

- (void)viewDidUnload
{
    [self setElapsedTime:nil];
    [self setStartStopButton:nil];
    [self setCurrentState:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - NSTimer

- (void)scheduleDisplayTimer {
    if (![[self displayTimer] isValid]) {
        self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    }
}

- (void)invalidateDisplayTimer {
    if (self.displayTimer) {
        [self.displayTimer invalidate];
    }
}

- (void)tick:(NSTimer*)timer {
    CTCraftTimer* craftTimer = [CTCraftTimer sharedTimer];
    
    long min  = (long)craftTimer.totalElapsedTime / 60;    // divide two longs, truncates
    long sec  = (long)craftTimer.totalElapsedTime % 60;    // remainder of long divide

    self.elapsedTime.text = [[NSString alloc] initWithFormat:@"%02d:%02d", min, sec];
    
    
    if (craftTimer.state == CTCraftTimerStateWorking) {
        self.currentState.text = @"Working";
    } else {
        self.currentState.text = @"Resting";
    }
    
}

#pragma mark - UIActions

- (IBAction)startPause {
    CTCraftTimer* timer = [CTCraftTimer sharedTimer];
    
    if (timer.paused) {
        [timer start];
        [self.startStopButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self scheduleDisplayTimer];
    } else {
        [timer pause];
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [self invalidateDisplayTimer];
    }    
}

- (IBAction)stop {
    CTCraftTimer* timer = [CTCraftTimer sharedTimer];
    [timer stop];
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    [self invalidateDisplayTimer];
    self.elapsedTime.text = [[NSString alloc] initWithFormat:@"%02d:%02d", 0, 0];

}

@end
