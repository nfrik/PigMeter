/*****************************************************************************
 
 Lucas Kanade 1.0
 January 2011
 (c) Copyright 2011, Success Software Solutions
 See LICENSE.txt for license information.
 
 *****************************************************************************/

#import "AVCamViewDelegate.h"
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#include <OpenGLES/ES1/glext.h>
#include "lkdemo.h"
									 
@interface MyVideoBuffer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{

	AVCaptureSession*		_session;
	id <AVCamViewDelegate> delegate;

	CMTime previousTimestamp;
	
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
	
	uint m_textureHandle;
	unsigned char bwImage[1280*720*4];
	int	numCorners;
	CvPoint2D32f* points;
    
    //my variables
    CvPoint3D32f* cartesianPoints[2]; //2 arrays for two set of cartesian points
    CvPoint2D32f* alphaPoints;
    CvPoint2D32f* dalphaPoints;
    CvPoint2D32f* ddalphaPoints;
    CvPoint3D32f* accelerationPoints;
    CvPoint2D32f* distancePoints;    
             int* xzeroesarr;
    double        programStartTime;
    NSMutableString* OutData;
    
    CMMotionManager* motionManager;
    CMAttitude* referenceAttitude;
    int pointCounter;
    //end my variables

	
	// FPS calculations
	double						startTime;
	double						endTime;
	double						fpsAverage;
	double						fpsAverageAgingFactor;
	int							framesInSecond;
}

@property (nonatomic, assign) id <AVCamViewDelegate> delegate;
@property (nonatomic, retain) AVCaptureSession* _session;
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;
@property (readwrite) CMTime previousTimestamp;

@property (readwrite) uint CameraTexture;

@property (nonatomic) int numCorners;

- (id) initWithSession: (AVCaptureSession*) session delegate:(id <AVCamViewDelegate>)_delegate;
- (void) setGLStuff:(EAGLContext*)c :(GLuint)rb :(GLuint)fb :(GLuint)bw :(GLuint)bh;
- (void)	captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
-(void)renderCameraToSprite:(uint)text renderNothing:(BOOL)renderNothing;
- (GLuint)	createVideoTextuerUsingWidth:(GLuint)w Height:(GLuint)h;
- (void)	resetWithSize:(GLuint)w Height:(GLuint)h;

@end
