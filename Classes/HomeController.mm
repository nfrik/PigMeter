//
//  HomeController.m
//  LucasKanadeV1
//
//  Created by TAUREAN SUTTON on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeController.h"
#import <QuartzCore/QuartzCore.h>
#import "TutorialController.h"
#import "AVCamViewController.h"

@interface HomeController ()
{

}

@end

@implementation HomeController
static NSString *selectedObjectValue;

@synthesize splashView;
@synthesize selectObject;
@synthesize selectObjects;
@synthesize viewButtonTutorial;
@synthesize viewTutorial;

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
    self.selectObjects = [[NSArray alloc] initWithObjects:@"", @"Pig", @"Cow", @"Bottle", nil];
    
    [splashView.layer setCornerRadius:25.0f];
    [splashView.layer setMasksToBounds:YES];
    splashView.backgroundColor = [UIColor whiteColor]; 
    // Do any additional setup after loading the view from its nib.
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

-(IBAction)btnViewTutorial_Clicked:(id)sender
{
    
    viewTutorial = [[TutorialController alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview:viewTutorial.view];
}

-(IBAction)btnSelectObject_Clicked:(id)sender
{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"selectObject" delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    
    UIPickerView *selectObjectView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
    selectObjectView.delegate = self;
    selectObjectView.showsSelectionIndicator = YES;
    [menu addSubview:selectObjectView];
    [menu showInView:self.view];
    [menu setBounds:CGRectMake(0, 0, 320, 700)];

    [selectObjectView release];
    [menu release];
}

-(IBAction)btnStartWeighing:(id)sender
{
    AVCamViewController *controller = [[AVCamViewController alloc] initWithNibName:nil bundle:nil];
    [self presentModalViewController:controller animated:NO];
    [controller release];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Handle the selection
    selectedObjectValue  = [selectObjects objectAtIndex:row];
    selectObject.titleLabel.text = selectedObjectValue;

}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [selectObjects count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [selectObjects objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = 300;
    return sectionWidth;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

}

+(NSString *) sharedSelectedObjectValue
{
    if(!selectedObjectValue)
    {
        selectedObjectValue = [[NSString alloc] init];
    }
    return selectedObjectValue;
}

-(void) dealloc
{
    [viewTutorial release];
    [super dealloc];
}
@end
