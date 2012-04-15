//
//  TutorialController.m
//  LucasKanadeV1
//
//  Created by TAUREAN SUTTON on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TutorialController.h"
#import "HomeController.h"

@interface TutorialController ()
@end

@implementation TutorialController
@synthesize animationInFlight;
@synthesize objectImageView;
@synthesize handImageView;
@synthesize tutorialView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //??? Do we want to have tutorials for each type of image?
    //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[HomeController sharedSelectedObjectValue] ofType:@"png"]];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Pig" ofType:@"png"]];
    
    if(image != nil)
    {
        [self.objectImageView setImage:image];
        UIImage *hand = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pointing_finger" ofType:@"png"]];
        [self.handImageView setImage: hand];
        [self.objectImageView addSubview:handImageView];
        [self doAnimation];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)doAnimation;
{
    self.animationInFlight = TRUE;
    CGPoint oldOrigin;
    CGFloat duration = 0.4;
    CGFloat totalDuration = 0.0;
    CGFloat pause = 1.0;
    CGFloat start = 0;
    
    //Start by hiding
    CABasicAnimation* hide =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    hide.removedOnCompletion = FALSE;
    hide.fillMode = kCAFillModeForwards;
    hide.duration = 0.01;
    hide.beginTime = start;
    start = start + 0.01 + pause;
    hide.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [hide setToValue: [NSNumber numberWithFloat: 0]];
    
    //Move the image to point 1 
    oldOrigin = handImageView.layer.position;
    CGPoint newOrigin = CGPointMake(oldOrigin.x + 130, oldOrigin.y - 290);
    CABasicAnimation* move1 =  [CABasicAnimation animationWithKeyPath: @"position"];
    move1.removedOnCompletion = FALSE;
    move1.fillMode = kCAFillModeForwards;
    move1.duration = duration;
    move1.beginTime = start;
    start = start + duration + pause;
    move1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [move1 setToValue: [NSValue valueWithCGPoint: newOrigin]];
    
    //Show the pointer on the first
    CABasicAnimation* show1 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    show1.removedOnCompletion = FALSE;
    show1.fillMode = kCAFillModeForwards;
    show1.duration = duration;
    show1.beginTime = start;
    start = start + duration + pause;
    show1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [show1 setToValue: [NSNumber numberWithFloat: 1.0]];
    
    CABasicAnimation* hide1 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    hide1.removedOnCompletion = FALSE;
    hide1.fillMode = kCAFillModeForwards;
    hide1.duration = 0.01;
    hide1.beginTime = start;
    start = start + 0.01 + pause;
    hide1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [hide1 setToValue: [NSNumber numberWithFloat: 0]];
    
    //Move it to the lowest point
    newOrigin = CGPointMake(newOrigin.x, newOrigin.y + 290);
    CABasicAnimation* move2 =  [CABasicAnimation animationWithKeyPath: @"position"];
    move2.removedOnCompletion = FALSE;
    move2.fillMode = kCAFillModeForwards;
    move2.duration = duration;
    move2.beginTime = start;
    move2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    start = start + duration + pause;
    [move2 setToValue: [NSValue valueWithCGPoint: newOrigin]];
    
    //Show the pointer on the second point
    CABasicAnimation* show2 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    show2.removedOnCompletion = FALSE;
    show2.fillMode = kCAFillModeForwards;
    show2.duration = duration;
    show2.beginTime = start;
    start = start + duration + pause;
    show2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [show2 setToValue: [NSNumber numberWithFloat: 1.0]];
    
    CABasicAnimation* hide2 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    hide2.removedOnCompletion = FALSE;
    hide2.fillMode = kCAFillModeForwards;
    hide2.duration = 0.01;
    hide2.beginTime = start;
    start = start + 0.01 + pause;
    hide2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [hide2 setToValue: [NSNumber numberWithFloat: 0]];
    
    //Move the pointer to the third point
    newOrigin = CGPointMake(newOrigin.x - 100, newOrigin.y - 270);
    CABasicAnimation* move3 =  [CABasicAnimation animationWithKeyPath: @"position"];
    move3.removedOnCompletion = FALSE;
    move3.fillMode = kCAFillModeForwards;
    move3.duration = duration;
    move3.beginTime = start;
    move3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    start = start + duration + pause;
    [move3 setToValue: [NSValue valueWithCGPoint: newOrigin]];
    
    //Show the pointer on the second point
    CABasicAnimation* show3 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    show3.removedOnCompletion = FALSE;
    show3.fillMode = kCAFillModeForwards;
    show3.duration = duration;
    show3.beginTime = start;
    start = start + duration + pause;
    show3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [show3 setToValue: [NSNumber numberWithFloat: 1.0]];
    
    CABasicAnimation* hide3 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    hide3.removedOnCompletion = FALSE;
    hide3.fillMode = kCAFillModeForwards;
    hide3.duration = 0.01;
    hide3.beginTime = start;
    start = start + 0.01 + pause;
    hide3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [hide3 setToValue: [NSNumber numberWithFloat: 0]];
    
    //Move the pointer to the third point
    newOrigin = CGPointMake(newOrigin.x + 225, newOrigin.y + 50);
    CABasicAnimation* move4 =  [CABasicAnimation animationWithKeyPath: @"position"];
    move4.removedOnCompletion = FALSE;
    move4.fillMode = kCAFillModeForwards;
    move4.duration = duration;
    move4.beginTime = start;
    move4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    start = start + duration + pause;
    [move4 setToValue: [NSValue valueWithCGPoint: newOrigin]];
    
    //Show the pointer on the second point
    CABasicAnimation* show4 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    show4.removedOnCompletion = FALSE;
    show4.fillMode = kCAFillModeForwards;
    show4.duration = duration;
    show4.beginTime = start;
    start = start + duration + pause;
    show4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [show4 setToValue: [NSNumber numberWithFloat: 1.0]];
    
    CABasicAnimation* hide4 =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    hide4.removedOnCompletion = FALSE;
    hide4.fillMode = kCAFillModeForwards;
    hide4.duration = 0.01;
    hide4.beginTime = start;
    totalDuration = start + duration + pause;
    hide4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [hide4 setToValue: [NSNumber numberWithFloat: 0]];
    
    //Put all the animations into a group.
    CAAnimationGroup* group = [CAAnimationGroup animation];
    [group setDuration: totalDuration];  //Set the duration of the group to the time for all animations
    group.removedOnCompletion = FALSE;
    group.fillMode = kCAFillModeForwards;
    [group setAnimations: [NSArray arrayWithObjects: hide, move1, show1, hide1, move2, show2, hide2, move3, show3, hide3, move4, show4, hide4, nil]];
    [handImageView.layer addAnimation: group forKey:  nil];
    //-----
    
    //Queue up a timer to do cleanup once the group animation is finished.
    [NSTimer scheduledTimerWithTimeInterval: totalDuration 
                                     target: self 
                                   selector: @selector(animationCleanup)
                                   userInfo: nil 
                                    repeats: NO];
}

- (void) animationCleanup;
{
    [handImageView.layer removeAllAnimations];
    self.animationInFlight = FALSE;
    [self.view removeFromSuperview];
    
}

- (void) setAnimationInFlight: (BOOL) newValue
{
    animationInFlight = newValue;
}

@end
