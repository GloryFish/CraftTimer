//
//  CTViewController.h
//  CraftTimer
//
//  Created by Jay Roberts on 7/16/12.
//  Copyright (c) 2012 GloryFish.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTTimerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTime;
@property (strong, nonatomic) NSTimer* displayTimer;
@property (weak, nonatomic) IBOutlet UILabel *currentState;
@property (weak, nonatomic) IBOutlet UILabel *timeRemaining;

- (IBAction)startPause;
- (IBAction)stop;

@end
