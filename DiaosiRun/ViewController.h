//
//  ViewController.h
//  DiaosiRun
//
//  Created by Yu Yichen on 5/28/13.
//  Copyright (c) 2013 Yu Yichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : GLKViewController

@property CMMotionManager *motionManager;
@property CMAttitude *attitude;
- (IBAction)restart:(UIButton *)sender;
- (IBAction)pause:(UIButton *)sender;
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveLabel;
@property (weak, nonatomic) IBOutlet UILabel *angerLabel;

@end
