//
//  HomeController.h
//  LucasKanadeV1
//
//  Created by TAUREAN SUTTON on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialController.h"

@interface HomeController : UIViewController
<UIPickerViewDelegate, UIActionSheetDelegate>
@property (nonatomic, retain) IBOutlet UIView *splashView;
@property (nonatomic, retain) IBOutlet UIButton *selectObject;
@property (nonatomic, retain) NSArray *selectObjects;
@property (nonatomic, retain) IBOutlet UIButton *viewButtonTutorial;
@property (nonatomic, retain) TutorialController *viewTutorial;

-(IBAction)btnSelectObject_Clicked:(id)sender;
-(IBAction)btnViewTutorial_Clicked:(id)sender;
-(IBAction)btnStartWeighing:(id)sender;

+(NSString *) sharedSelectedObjectValue;

@end

