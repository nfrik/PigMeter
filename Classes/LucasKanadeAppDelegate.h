/*****************************************************************************
 
 Lucas Kanade 1.0
 January 2011
 (c) Copyright 2011, Success Software Solutions
 See LICENSE.txt for license information.
 
 *****************************************************************************/

#import <UIKit/UIKit.h>

//@class AVCamViewController;
@class HomeController;

@interface LucasKanadeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    //AVCamViewController *viewController;
    HomeController *homeController;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet AVCamViewController *viewController;
@property (nonatomic, retain) IBOutlet HomeController *homeController;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

