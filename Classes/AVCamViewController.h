/*****************************************************************************
 
 Lucas Kanade 1.0
 January 2011
 (c) Copyright 2011, Success Software Solutions
 See LICENSE.txt for license information.
 
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MyVideoBuffer.h"
#import "AVCamTouchController.h"

@class AVCamCaptureManager, AVCamPreviewView, ExpandyButton, AVCaptureVideoPreviewLayer;

@interface AVCamViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, AVCamViewDelegate> {
    @private
    AVCamCaptureManager *_captureManager;
    AVCamPreviewView *_videoPreviewView;
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
    UIBarButtonItem *_cameraToggleButton;
    UIBarButtonItem *_recordButton;
    UIBarButtonItem *_stillButton;
    UIBarButtonItem *_infoButton;
    ExpandyButton *_downSampleFactor;
	ExpandyButton *_lkWinSize;
	ExpandyButton *_lkLevel;
	ExpandyButton *_lkMaxPoints;
	ExpandyButton *_displayMethod;
	ExpandyButton *_showCamera;
	ExpandyButton *_showInfo;
	ExpandyButton *_focus;
    ExpandyButton *_exposure;
    ExpandyButton *_whiteBalance;
    ExpandyButton *_preset;

    UIView *_adjustingFocus;
    UIView *_adjustingExposure;
    UIView *_adjustingWhiteBalance;
	
	UIImageView *debugImageView;
	UILabel *fpsLabel;
	UILabel *countLabel;
    UILabel *infoLabel;    
	EAGLView *openGLView;
	int videoFrameWidth;
	int videoFrameHeight;
	int processingFrameWidth;
	int processingFrameHeight;
	
	// Configurable parameters
	int		downSampleFactorParam;
	int		lkWinSizeParam;
	int		lkLevelParam;
	int		lkMaxPointsParam;
	int		displayMethodParam;
	BOOL	showCameraParam;
    
    UIView *_statView;
    
    
    NSNumberFormatter *_numberFormatter;
    BOOL _hudHidden;
    CALayer *_focusBox;
    CALayer *_exposeBox;    
    
    NSTimer *timer; // to change focus
    
    // Touch controller
    AVCamTouchController* touchController;
}

@property (nonatomic, retain) IBOutlet EAGLView *openGLView;
@property (nonatomic, retain) IBOutlet UILabel *fpsLabel;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIImageView *debugImageView;
@property (nonatomic) int videoFrameWidth;
@property (nonatomic) int videoFrameHeight;
@property (nonatomic) int processingFrameWidth;
@property (nonatomic) int processingFrameHeight;
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet AVCamPreviewView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *cameraToggleButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *stillButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *infoButton;
@property (nonatomic,retain) ExpandyButton *downSampleFactor;
@property (nonatomic,retain) ExpandyButton *lkWinSize;
@property (nonatomic,retain) ExpandyButton *lkLevel;
@property (nonatomic,retain) ExpandyButton *lkMaxPoints;
@property (nonatomic,retain) ExpandyButton *displayMethod;
@property (nonatomic,retain) ExpandyButton *showCamera;
@property (nonatomic,retain) ExpandyButton *showInfo;
@property (nonatomic,retain) ExpandyButton *focus;
@property (nonatomic,retain) ExpandyButton *exposure;
@property (nonatomic,retain) ExpandyButton *whiteBalance;
@property (nonatomic,retain) ExpandyButton *preset;
@property (nonatomic,assign) int downSampleFactorParam;
@property (nonatomic,assign) int lkWinSizeParam;
@property (nonatomic,assign) int lkLevelParam;
@property (nonatomic,assign) int lkMaxPointsParam;
@property (nonatomic,assign) int displayMethodParam;
@property (nonatomic,assign) BOOL showCameraParam;

@property (nonatomic,retain) IBOutlet UIView *statView;

@property (nonatomic,retain) NSTimer *timer;

#pragma mark Toolbar Actions
- (IBAction)hudViewToggle:(id)sender;
- (IBAction)still:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)cameraToggle:(id)sender;
- (IBAction)showAboutScreen:(id)sender;
- (IBAction)resetPoints:(id)sender;
+ (CGSize)sizeForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize;

#pragma mark HUD Actions
- (void)presetChange:(id)sender;


#pragma mark timer Actions
-(void)startTimer;
-(void)stopTimer;
-(void)timerMethod:(NSTimer *)theTimer;

@end

