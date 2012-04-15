//
//  TutorialController.h
//  LucasKanadeV1
//
//  Created by TAUREAN SUTTON on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialController : UIViewController
    @property (nonatomic, retain) IBOutlet UIImageView *objectImageView;
    @property (nonatomic, retain) IBOutlet UIImageView *handImageView;
    @property (nonatomic, retain) IBOutlet UIView *tutorialView;
    @property (nonatomic) BOOL animationInFlight;
@end

