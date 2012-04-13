/*****************************************************************************
 
 Lucas Kanade 1.0
 January 2011
 (c) Copyright 2011, Success Software Solutions
 See LICENSE.txt for license information.
 
 *****************************************************************************/

#import "MyVideoBuffer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AVCamViewController.h"
#import "derivatives.h"

#define MAX_POINTS 250

@implementation MyVideoBuffer

@synthesize _session;
@synthesize delegate;
@synthesize previousTimestamp;
@synthesize videoFrameRate;
@synthesize videoDimensions;
@synthesize videoType;
@synthesize CameraTexture=m_textureHandle;
@synthesize numCorners;


- (id) initWithSession: (AVCaptureSession*) session delegate:(id <AVCamViewDelegate>)_delegate
{
	if ((self = [super init]))
	{
		self._session = session;
		self.delegate = _delegate;
		
		[self._session beginConfiguration];
	
		//-- Create the output for the capture session.  We want 32bit BRGA
		AVCaptureVideoDataOutput * dataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
		[dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when we're recording
		[dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
		dataOutput.minFrameDuration = CMTimeMake(1, 30);
		
		// we want our dispatch to be on the main thread so OpenGL can do things with the data
		[dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
		
		[self._session addOutput:dataOutput];
		
		[self._session commitConfiguration];
		
		[self resetWithSize:640 Height:480];
        
        //Alloc 100 3d points where y is distance and x is time;
        cartesianPoints[0] = (CvPoint3D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint3D32f));
        cartesianPoints[1] = (CvPoint3D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint3D32f));        
        alphaPoints = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));
        dalphaPoints = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));        
        ddalphaPoints = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));                
        accelerationPoints = (CvPoint3D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint3D32f));  
        kfaccelerationPoints = (CvPoint3D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint3D32f));  
        distancePoints = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));              
        kfdistancePoints = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));              
        xzeroesarr = (int*)malloc(MAX_POINTS*sizeof(int));
        kalmanPoints1 = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));
        kalmanPoints2 = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));
        kalmanPoints3 = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));
        kalmanPoints4 = (CvPoint2D32f*)cvAlloc(MAX_POINTS*sizeof(CvPoint2D32f));        
        memset(xzeroesarr, 0, MAX_POINTS);
        
        
        //counter to get ~3 secs of data before computations
        pointCounter = 0;
        
        //test output of data
        OutData = [[NSMutableString alloc] init];
        
        programStartTime = [[NSDate date] timeIntervalSince1970];
        
        //init accelerometer and gyroscope
        motionManager = [[CMMotionManager alloc] init];
        
        CMDeviceMotion *deviceMotion = motionManager.deviceMotion;      
        CMAttitude *attitude = deviceMotion.attitude;
        referenceAttitude = [attitude retain];
        //[motionManager startGyroUpdates];
         motionManager.gyroUpdateInterval=0.005;
         motionManager.accelerometerUpdateInterval=0.005;        
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];                      
	}
    
	return self;

}

-(GLuint)createVideoTextuerUsingWidth:(GLuint)w Height:(GLuint)h
{	
	GLuint handle;
	glGenTextures(1, &handle);
	glBindTexture(GL_TEXTURE_2D, handle);
	glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glBindTexture(GL_TEXTURE_2D, 0);
	
	return handle;
}

- (void) resetWithSize:(GLuint)w Height:(GLuint)h
{
	NSLog(@"_session beginConfiguration");
	[_session beginConfiguration];
	
	//-- Match the wxh with a preset.
	if(w == 1280 && h == 720)
	{
		[_session setSessionPreset:AVCaptureSessionPreset1280x720];
	}
	else if(w == 640)
	{
		[_session setSessionPreset:AVCaptureSessionPreset640x480];
	}
	else if(w == 480)
	{
		[_session setSessionPreset:AVCaptureSessionPresetMedium];
	}
	else if(w == 192)
	{
		[_session setSessionPreset:AVCaptureSessionPresetLow];
	}
	
	[_session commitConfiguration];
	NSLog(@"_session commitConfiguration");
}


- (void) convertToBlackWhite:(unsigned char *)	pixels 
					   width:(int32_t)			width 
					  height:(int32_t)			height 
				  downSample:(int)				downSample
{	
	// Copy all memory to our buffer. It will be the source and destination for our calculations.
	// This improves performance significantly
	memcpy(bwImage,pixels,width*height*4);
	
	// Access the memory as an int to read 4 bytes at a time
	unsigned int * pntrBWImage= (unsigned int *)bwImage;
	unsigned int index = 0;
	unsigned int fourBytes;
	
	for (int j = 0; j < height / downSample; j++)
	{
		for (int i = 0; i < width / downSample; i++) 
		{
			index = width / downSample * j + i;
			fourBytes = pntrBWImage[j * downSample * width + i * downSample];
			bwImage[index] = (((unsigned char)fourBytes>>(2*8)) + 
							  ((unsigned char)fourBytes>>(1*8)) + 
							  ((unsigned char)fourBytes>>(0*8))) / 3;
		}
	}
}

//The following is under the assumption that we are dealing with 
//a screen that is 1280 in width and 720 in height
//and that the origin is in top left corner
GLfloat spriteTexcoords[] = {
	0,0,
	0,1,
	1,0,
	1,1};

GLfloat spriteVertices[] =  {
	0,0,   
	0,720,   
	1280,0, 
	1280,720};

GLfloat transpose[]={
	0,1,0,0,
	1,0,0,0,
	0,0,1,0,
	0,0,0,1
};

EAGLContext *acontext;
GLuint arb,afb;
GLint abw;
GLint abh;

- (void) setGLStuff:(EAGLContext*)c :(GLuint)rb :(GLuint)fb :(GLuint)bw :(GLuint)bh 
{
	acontext=c;
	arb=rb;
	afb=fb;
	abw=bw;
	abh=bh;
}

GLuint createNPOTTexture(GLuint width,GLuint height) 
{
	GLuint handle;
	glGenTextures(1, &handle);
	glBindTexture(GL_TEXTURE_2D, handle);
	glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, 
				 GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glBindTexture(GL_TEXTURE_2D, 0);
	
	return handle;
}

// Maximum corners drawn
#define MAX_CORNERS 50000

// Maximum neighbours searched in the array (X above, X below)
#define NEIGHBOURS_NEIGHBOURHOOD 30

// The threshold distance in pixel dimensions for 2 corners to be considered neighbours
#define NEIGHBOUR_THRESHOLD	320

// The length of trail to draw
#define TRAIL_LENGTH		20

// A buffer to hold corner information for OpenGL
static CGFloat cornersBuffer[2 * MAX_CORNERS];

// A buffer holding neighbour information for OpenGL
static CGFloat trailBuffer[1280*720*4];

// Buffers for drawing the trail with one OpenGL command
static CGFloat trailDrawingBuffer[MAX_CORNERS * TRAIL_LENGTH * 2];
static CGFloat trailColorBuffer[MAX_CORNERS * TRAIL_LENGTH * 4];


- (void) drawCornersWithFrameWidth:(float)frameWidth frameHeight:(float)frameHeight {
	
	// Translate corners to our coordinates
	for (int i = 0; i < numCorners && i < MAX_CORNERS; i++) {
		// Corner coordinates
		cornersBuffer[2*i + 1]	= points[i].x * delegate.downSampleFactorParam;
		cornersBuffer[2*i]		= points[i].y * delegate.downSampleFactorParam;
	}
	
	// Draw corners
	glVertexPointer(2, GL_FLOAT, 0, cornersBuffer);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColor4f(1,0,0,1);  
	glPointSize(5);
	
	glDrawArrays(GL_POINTS, 0, numCorners < MAX_CORNERS ? numCorners : MAX_CORNERS);
	glColor4f(1, 1, 1, 1);
}


- (void) drawTrailWithFrameWidth:(float)frameWidth frameHeight:(float)frameHeight {
	// Set to full pixels that have corners in them (setting to more than full, so will be full after aging)
	for (int i = 0; i < numCorners; i++) {
		trailBuffer[(int)(points[i].y) * (int)frameWidth + (int)(points[i].x)] = 1.0 + 1.0 / TRAIL_LENGTH;
	}
	
	glPointSize(2);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	int	trailPixelCount = 0;
	
	// Iterate all pixels in screen
	for (int y = 0; y < frameHeight; y++) {
		for (int x = 0; x < frameWidth; x++) {
			int index = y * frameWidth + x;

			// If pixel is lit
			if (trailBuffer[index] > 0) {
				// Age
				trailBuffer[index] -= 1.0 / TRAIL_LENGTH;
			
				// Skip if pixel zerofied
				if (trailBuffer[index] == 0) {
					continue;
				}
				
				// Draw pixel
				trailDrawingBuffer[2 * trailPixelCount + 1]	= x * delegate.downSampleFactorParam;
				trailDrawingBuffer[2 * trailPixelCount    ]	= y * delegate.downSampleFactorParam;
				
				trailColorBuffer[trailPixelCount * 4]		= 0;
				trailColorBuffer[trailPixelCount * 4 + 1]	= 1;
				trailColorBuffer[trailPixelCount * 4 + 2]	= 0;
				trailColorBuffer[trailPixelCount * 4 + 3]	= trailBuffer[index];
			
				trailPixelCount++;
			}
		}
	}
		
	glVertexPointer(2, GL_FLOAT, 0, trailDrawingBuffer);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_FLOAT, 0, trailColorBuffer);
	glEnableClientState(GL_COLOR_ARRAY);
		
	glDrawArrays(GL_POINTS, 0, trailPixelCount);
	
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glColor4f(1, 1, 1, 1);
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	// Calculate FPS
	fpsAverageAgingFactor = 0.2;
	framesInSecond++;
	endTime = [[NSDate date] timeIntervalSince1970];
    
    
// -----------Measure acceleration-----------------    
// ---------------------------------------------------    
    
    //kftest();
    //accelerometer data taken at endTime
    accelerationPoints[pointCounter].x=motionManager.deviceMotion.userAcceleration.x*9.80665;
    accelerationPoints[pointCounter].y=motionManager.deviceMotion.userAcceleration.y*9.80665;
    accelerationPoints[pointCounter].z=motionManager.deviceMotion.userAcceleration.z*9.80665;
	//stop taking accelerometer data
    
// ---------------------------------------------------
// ---------------------------------------------------
    
	if (startTime <= 0) {
		startTime = [[NSDate date] timeIntervalSince1970];
	}
	else {
		if (endTime - startTime >= 1) {
			double currentFPS = framesInSecond / (endTime - startTime);
			fpsAverage = fpsAverageAgingFactor * fpsAverage + (1.0 - fpsAverageAgingFactor) * currentFPS;
			startTime = [[NSDate date] timeIntervalSince1970];
			framesInSecond = 0;
		}
		
		delegate.fpsLabel.text = [NSString stringWithFormat:@"FPS = %.2f", fpsAverage];
	}

	// Get video specs
	CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	self.videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc);
	
	CMVideoCodecType type = CMFormatDescriptionGetMediaSubType(formatDesc);
#if defined(__LITTLE_ENDIAN__)
	type = OSSwapInt32(type);
#endif
	self.videoType = type;
	
	CGSize videoInViewDimensions = [AVCamViewController sizeForGravity:AVLayerVideoGravityResizeAspect
															 frameSize:CGSizeMake(videoDimensions.width, videoDimensions.height)
														  apertureSize:CGSizeMake(320, 480)];
	
	
	// Get the captured image
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	
	// If we haven't created the video texture, do so now.
	if(m_textureHandle == 0)
	{
		m_textureHandle = createNPOTTexture(1280,720);
	}
	
	// Get the pointer to the picture data
	unsigned char* linebase = (unsigned char *)CVPixelBufferGetBaseAddress( pixelBuffer );
	
	// Draw the frame to the texture if Show Camera is on
	if (delegate.showCameraParam) {
		glBindTexture(GL_TEXTURE_2D, m_textureHandle);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, videoDimensions.width, videoDimensions.height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, linebase);
	}
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	// Set view port according to back or front camera
	if ([self.delegate usingBackFacingCamera]) {
		glOrthof(videoInViewDimensions.height, 0, videoInViewDimensions.width,0, 0, 1);
	}
	else {
		glOrthof(0, videoInViewDimensions.height, videoInViewDimensions.width,0, 0, 1);
	}
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glLoadMatrixf(transpose);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);
	
	
	// Bind the texture if Show Camera is on
	if (delegate.showCameraParam) {
		glBindTexture(GL_TEXTURE_2D, m_textureHandle);
		glColor4f(1, 1, 1, 1);
	}
	else {
		glColor4f(0, 0, 0, 1);
	}

	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisable(GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	
	// Setup corners
	
	// Convert image to black and white (for FAST detection)
	[self convertToBlackWhite: linebase 
						width: videoDimensions.width 
					   height: videoDimensions.height 
				   downSample: delegate.downSampleFactorParam];
	
	// Wrap as OpenCV image
	CvSize imageSize;
	imageSize.width		= videoDimensions.width  / delegate.downSampleFactorParam;
	imageSize.height	= videoDimensions.height / delegate.downSampleFactorParam;
	IplImage* openCVImage = cvCreateImageHeader( imageSize, 8, 1 );
	openCVImage->imageData = (char*)bwImage;
	
	// Calc lkdemo
	points = processLKFrame(openCVImage, 
										  numCorners, 
										  [delegate lkWinSizeParam],
										  [delegate lkLevelParam],
										  [delegate lkMaxPointsParam]);
    
    
    //my code
//    distancePoints[pointCounter].y=sqrt(pow(points[1].x-points[0].x,2)+pow(points[1].y-points[0].y,2));
//    distancePoints[pointCounter].x=(endTime-programStartTime)*1000;
    cartesianPoints[0][pointCounter].x = points[0].x;
    cartesianPoints[0][pointCounter].y = points[0].y;
    cartesianPoints[1][pointCounter].x = points[1].x;
    cartesianPoints[1][pointCounter].y = points[1].y;
    cartesianPoints[0][pointCounter].z = (endTime-programStartTime)*1000;
    cartesianPoints[1][pointCounter].z = (endTime-programStartTime)*1000;

    pointCounter++;
    if (pointCounter>=MAX_POINTS) {
        pointCounter=0;        
        pixtoangle(cartesianPoints[0], cartesianPoints[1], alphaPoints, MAX_POINTS);        
        fivepointmidpoint(alphaPoints, dalphaPoints, MAX_POINTS);
        fivepointmidpointdd(alphaPoints, ddalphaPoints, MAX_POINTS);
        kalman2d(alphaPoints, kalmanPoints1, 1e-4, 1e-4, MAX_POINTS);
        kalman2d(dalphaPoints, kalmanPoints2, 1e-3, 1e-3, MAX_POINTS);
        kalman2d(ddalphaPoints, kalmanPoints3, 1e-2, 1e-2, MAX_POINTS);
        kalman3d(accelerationPoints, kfaccelerationPoints, 1e-2, 1e-2, MAX_POINTS);
        inertialpixeltransform(alphaPoints, dalphaPoints, ddalphaPoints, accelerationPoints, distancePoints, MAX_POINTS);
        inertialpixeltransform(kalmanPoints1, kalmanPoints2, kalmanPoints3, kfaccelerationPoints, kfdistancePoints, MAX_POINTS);        
        //locate zeroes
        int numofzeroes=locatezeroeswithtolerance(dalphaPoints, xzeroesarr, 0.02, MAX_POINTS);
        
     //output if there are actual zeroes
     if ((numofzeroes>0)&&(numofzeroes<MAX_POINTS)) {
            
        float avRealDistance = averageforpoints(distancePoints, xzeroesarr, numofzeroes);            
        float kfavRealDistance = averageforpoints(kfdistancePoints, xzeroesarr, numofzeroes);    

        delegate.infoLabel.text=[NSString stringWithFormat:@"RD=%3.2fm, KFD=%3.2fm, n=%d, a=%f",avRealDistance, kfavRealDistance,numofzeroes, accelerationPoints[0].z];            
         
         
        //prepare file                
//        for(int i=0;i<MAX_POINTS;i++){
//            [OutData appendFormat:@"%f  %f  %f  %f  %f  %f  %f  %f  %f\r",alphaPoints[i].y,dalphaPoints[i].y,ddalphaPoints[i].y,kalmanPoints1[i].y,kalmanPoints2[i].y,kalmanPoints3[i].y,accelerationPoints[i].z,kfaccelerationPoints[i].z,distancePoints[i].x];
//        }
//            //save file
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
//            if([paths count] > 0){
//                NSString *dataPath =[[paths objectAtIndex:0] stringByAppendingPathComponent:@"adaddakfadkfaddkfaacckfacc.txt"];
//                [OutData writeToFile:dataPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//                [OutData setString:@""];//clean all array and start with 0 length
//                //delegate.infoLabel.text = @"file is ready!";            
//            }       
         
         
         // -----------Implement Kalman Filter-----------------    
         // ---------------------------------------------------    
         float *kalmanZeroPointsInput = (float*)cvAlloc(numofzeroes*sizeof(float));
         float *kalmanZeroPointsOutput = (float*)cvAlloc(numofzeroes*sizeof(float));                 
         
         for(int i=0;i<numofzeroes;i++){
             kalmanZeroPointsInput[i]=distancePoints[xzeroesarr[i]].y;
         }         
         
         kalman1d(kalmanZeroPointsInput, kalmanZeroPointsOutput, 1e-4, 1e-1, numofzeroes);
                  
         
        //prepare file
        for(int i=0;i<numofzeroes;i++){
            [OutData appendFormat:@"%f %f %f %f %f %f %f \r",alphaPoints[xzeroesarr[i]].y,dalphaPoints[xzeroesarr[i]].y,ddalphaPoints[xzeroesarr[i]].y,distancePoints[xzeroesarr[i]].y,kfdistancePoints[xzeroesarr[i]].y, kalmanZeroPointsOutput[i],distancePoints[xzeroesarr[i]].x];
        }
         
         cvFree(&kalmanZeroPointsInput);
         cvFree(&kalmanZeroPointsOutput);
         //---------------------------------------------------         
         //---------------------------------------------------         
         
            
        //save file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
        if([paths count] > 0){
            NSString *dataPath =[[paths objectAtIndex:0] stringByAppendingPathComponent:@"kfzerdatout12.txt"];
            [OutData writeToFile:dataPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [OutData setString:@""];//clean all array and start with 0 length
            //delegate.infoLabel.text = @"file is ready!";            
        }
        }// if numofzeroes > 0
    }
    //end my code
	
	// Dispose of opencv header
	cvReleaseImageHeader(&openCVImage);
	
	delegate.countLabel.text = [NSString stringWithFormat:@"Points %d", numCorners];
	
    //NSLog(@"%f, %f",points[0].x,points[0].y);
	
	// Initialize drawing
	
	float frameWidth = self.videoDimensions.width / delegate.downSampleFactorParam;
	float frameHeight = self.videoDimensions.height / delegate.downSampleFactorParam;
	
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	// Draw corners
	switch (delegate.displayMethodParam) {
		case DM_CORNERS:
			[self drawCornersWithFrameWidth:frameWidth frameHeight:frameHeight];
			break;
		case DM_TRAIL:
			[self drawTrailWithFrameWidth:frameWidth frameHeight:frameHeight];
			break;
		default:
			break;
	}
	
	
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, arb);
	
	[acontext presentRenderbuffer:GL_RENDERBUFFER_OES];
}



-(void)renderCameraToSprite:(uint)text renderNothing:(BOOL)renderNothing
{
	float vW=videoDimensions.width;
	float vH=videoDimensions.height;
	float tW=1280;
	float tH=720;
	
	GLfloat spriteTexcoords[] = {
		vW/tW,vH/tH,   
		vW/tW,0.0f,
		0,vH/tH,   
		0.0f,0,};
	
	GLfloat spriteVertices[] =  {
		0,0,0,   
		320,0,0,   
		0,480,0, 
		320,480,0};
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, 320, 0, 480, 0, 1);
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	if (renderNothing) {
		return;
	}
		
	glDisable(GL_DEPTH_TEST);
	glDisableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, spriteVertices);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);	
	glBindTexture(GL_TEXTURE_2D, text);
	glEnable(GL_TEXTURE_2D);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
}


- (void)dealloc 
{
    [OutData release];
    cvFree(&cartesianPoints[0]);
    cvFree(&cartesianPoints[1]);    
    cvFree(&alphaPoints);    
    cvFree(&dalphaPoints);
    cvFree(&ddalphaPoints);
    cvFree(&accelerationPoints);
    cvFree(&kfaccelerationPoints);    
    cvFree(&distancePoints);
    cvFree(&kfdistancePoints);    
    free(&xzeroesarr);
    cvFree(&kalmanPoints1);
    cvFree(&kalmanPoints2);
    cvFree(&kalmanPoints3);
    cvFree(&kalmanPoints4);
    
	[_session release];
	
	[super dealloc];
}

@end
