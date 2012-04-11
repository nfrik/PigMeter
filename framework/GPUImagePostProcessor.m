//
//  GPUImagePostProcessor.m
//  GPUImage
//
//  Created by nikolay on 3/13/12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

#import "GPUImagePostProcessor.h"

#import "GPUImageOpenGLESContext.h"
#import "GLProgram.h"
#import "GPUImageFilter.h"

#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>


NSString *const kGPUImageColorSwizzlingFragmentShaderString2 = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate).bgra;
 }
 );

@interface GPUImagePostProcessor ()
{
    GLuint movieFramebuffer, movieRenderbuffer;
    
    GLProgram *colorSwizzlingProgram;
    GLint colorSwizzlingPositionAttribute, colorSwizzlingTextureCoordinateAttribute;
    GLint colorSwizzlingInputTextureUniform;
    
    GLuint inputTextureForMovieRendering;
    
    GLubyte *frameData;
    
    NSDate *startTime;
}

// Movie recording
- (void)initializeMovie;

// Frame rendering
- (void)createDataFBO;
- (void)destroyDataFBO;
- (void)setFilterFBO;

- (void)renderAtInternalSize;

@end

@implementation GPUImagePostProcessor

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    videoSize = newSize;
    movieURL = newMovieURL;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    colorSwizzlingProgram = [[GLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageColorSwizzlingFragmentShaderString2];
    
    [colorSwizzlingProgram addAttribute:@"position"];
	[colorSwizzlingProgram addAttribute:@"inputTextureCoordinate"];
    
    if (![colorSwizzlingProgram link])
	{
		NSString *progLog = [colorSwizzlingProgram programLog];
		NSLog(@"Program link log: %@", progLog); 
		NSString *fragLog = [colorSwizzlingProgram fragmentShaderLog];
		NSLog(@"Fragment shader compile log: %@", fragLog);
		NSString *vertLog = [colorSwizzlingProgram vertexShaderLog];
		NSLog(@"Vertex shader compile log: %@", vertLog);
		colorSwizzlingProgram = nil;
        NSAssert(NO, @"Filter shader link failed");
	}
    
    colorSwizzlingPositionAttribute = [colorSwizzlingProgram attributeIndex:@"position"];
    colorSwizzlingTextureCoordinateAttribute = [colorSwizzlingProgram attributeIndex:@"inputTextureCoordinate"];
    colorSwizzlingInputTextureUniform = [colorSwizzlingProgram uniformIndex:@"inputImageTexture"];
    
    [colorSwizzlingProgram use];    
	glEnableVertexAttribArray(colorSwizzlingPositionAttribute);
	glEnableVertexAttribArray(colorSwizzlingTextureCoordinateAttribute);
    
    [self initializeMovie];
    
    return self;
}

- (void)dealloc;
{
    if (frameData != NULL)
    {
        free(frameData);
    }
}

#pragma mark -
#pragma mark OpenCV Support Methods

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
    
    //[UIImage imageWithCIImage:[CIImage imageWithCVPixelBuffer:<#(CVPixelBufferRef)#>]];
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
    
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
    
	return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
-(UIImage *)UIImageFromIplImage:(IplImage *)image {
    NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
    
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
/*    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);*/
    
    UIImage* img = [UIImage imageWithData:data];
    
    
    return img;
   // return ret;
}


#pragma mark -
#pragma mark Movie recording

- (void)initializeMovie;
{
    frameData = (GLubyte *) malloc((int)videoSize.width * (int)videoSize.height * 4);
    
    //    frameData = (GLubyte *) calloc(videoSize.width * videoSize.height * 4, sizeof(GLubyte));
    
    NSError *error = nil;
    
    assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:AVFileTypeAppleM4V error:&error];
    //    assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error != nil)
    {
        NSLog(@"Error: %@", error);
    }
    
    
    NSMutableDictionary * outputSettings = [[NSMutableDictionary alloc] init];
    [outputSettings setObject: AVVideoCodecH264 forKey: AVVideoCodecKey];
    [outputSettings setObject: [NSNumber numberWithInt: videoSize.width] forKey: AVVideoWidthKey];
    [outputSettings setObject: [NSNumber numberWithInt: videoSize.height] forKey: AVVideoHeightKey];
    
    /*    NSMutableDictionary * compressionProperties = [[NSMutableDictionary alloc] init];
     [compressionProperties setObject: [NSNumber numberWithInt: 1000000] forKey: AVVideoAverageBitRateKey];
     [compressionProperties setObject: [NSNumber numberWithInt: 16] forKey: AVVideoMaxKeyFrameIntervalKey];
     [compressionProperties setObject: AVVideoProfileLevelH264Main31 forKey: AVVideoProfileLevelKey];
     
     [outputSettings setObject: compressionProperties forKey: AVVideoCompressionPropertiesKey];*/
    
    assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    //writerInput.expectsMediaDataInRealTime = NO;
    
    // You need to use BGRA for the video in order to get realtime encoding. I use a color-swizzling shader to line up glReadPixels' normal RGBA output with the movie input's BGRA.
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:videoSize.width], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:videoSize.height], kCVPixelBufferHeightKey,
                                                           nil];
    //    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey,
    //                                                           nil];
    
    assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    [assetWriter addInput:assetWriterVideoInput];
}

- (void)startRecording;
{
    startTime = [NSDate date];
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
}

- (void)finishRecording;
{
    [assetWriterVideoInput markAsFinished];
    [assetWriter finishWriting];    
}

#pragma mark -
#pragma mark Frame rendering

- (void)createDataFBO;
{
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &movieFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, movieFramebuffer);
    
    glGenRenderbuffers(1, &movieRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, movieRenderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, (int)videoSize.width, (int)videoSize.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, movieRenderbuffer);	
	
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
}

- (void)destroyDataFBO;
{
    if (movieFramebuffer)
	{
		glDeleteFramebuffers(1, &movieFramebuffer);
		movieFramebuffer = 0;
	}	
    
    if (movieRenderbuffer)
	{
		glDeleteRenderbuffers(1, &movieRenderbuffer);
		movieRenderbuffer = 0;
	}	
}

- (void)setFilterFBO;
{
    if (!movieFramebuffer)
    {
        [self createDataFBO];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, movieFramebuffer);
    
    glViewport(0, 0, (int)videoSize.width, (int)videoSize.height);
}

- (void)renderAtInternalSize;
{
    [GPUImageOpenGLESContext useImageProcessingContext];
    [self setFilterFBO];
    
    [colorSwizzlingProgram use];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // This needs to be flipped to write out to video correctly
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
	glActiveTexture(GL_TEXTURE4);
	glBindTexture(GL_TEXTURE_2D, inputTextureForMovieRendering);
	glUniform1i(colorSwizzlingInputTextureUniform, 4);	
    
    glVertexAttribPointer(colorSwizzlingPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
	glVertexAttribPointer(colorSwizzlingTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReady;
{
    
    if (!assetWriterVideoInput.readyForMoreMediaData)
    {
        NSLog(@"Had to drop a frame");
        return;
    }
    
    
    // Render the frame with swizzled colors, so that they can be uploaded quickly as BGRA frames
    [GPUImageOpenGLESContext useImageProcessingContext];
    [self renderAtInternalSize];
    
    CVPixelBufferRef pixel_buffer = NULL;
    
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, [assetWriterPixelBufferInput pixelBufferPool], &pixel_buffer);
    if ((pixel_buffer == NULL) || (status != kCVReturnSuccess))
    {
        return;
        //        NSLog(@"Couldn't pull pixel buffer from pool");
        //        glReadPixels(0, 0, videoSize.width, videoSize.height, GL_RGBA, GL_UNSIGNED_BYTE, frameData);
        //
        //        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
        //                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, 
        //                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
        //
        //        CFDictionaryRef optionsDictionary = (__bridge_retained CFDictionaryRef)options;
        //        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, (int)videoSize.width, (int)videoSize.height, kCVPixelFormatType_32BGRA, frameData, 4 * (int)videoSize.width, NULL, 0, optionsDictionary, &pixel_buffer);
        //        CFRelease(optionsDictionary);
        //        CVPixelBufferLockBaseAddress(pixel_buffer, 0);
    }
    else
    {
        CVPixelBufferLockBaseAddress(pixel_buffer, 0);
        
        NSLog(@"Grabbing pixel buffer");
        
        GLubyte *pixelBufferData = (GLubyte *)CVPixelBufferGetBaseAddress(pixel_buffer);
        glReadPixels(0, 0, videoSize.width, videoSize.height, GL_RGBA, GL_UNSIGNED_BYTE, pixelBufferData);
    }
    
    // May need to add a check here, because if two consecutive times with the same value are added to the movie, it aborts recording
    CMTime currentTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSinceDate:startTime],120);
    
    if(![assetWriterPixelBufferInput appendPixelBuffer:pixel_buffer withPresentationTime:currentTime]) 
    {
        NSLog(@"Problem appending pixel buffer at time: %lld", currentTime.value);
    } 
    else 
    {
        //        NSLog(@"Recorded pixel buffer at time: %lld", currentTime.value);
        /*
        //[CGImage imageWithCVPixelBuffer:pixel_buffer];
      CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixel_buffer];
      CIContext *temporaryContext = [CIContext contextWithOptions:nil];
      CGImageRef videoImage = [temporaryContext
                                 createCGImage:ciImage
                                 fromRect:CGRectMake(0, 0, 
                                                     CVPixelBufferGetWidth(pixel_buffer),
                                                     CVPixelBufferGetHeight(pixel_buffer))];
      IplImage* imgA = [self CreateIplImageFromUIImage:[UIImage imageWithCGImage:videoImage]];
      CvSize img_sz = cvGetSize(imgA);
      IplImage* eig_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);
      IplImage* tmp_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);
      int corner_count = 10;
      CvPoint2D32f* cornersA = new CvPoint2D32f(10);
      cvGoodFeaturesToTrack(imgA, eig_image, tmp_image, cornersA, &corner_count, 0.05, 5.0, 0.0, 3.0, 0.0, 0.04);
      cvFindCornerSubPix(imgA, cornersA, corner_count, cvSize(15,15), cvSize(-1, -1), cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20, 0.03));        
      delete(cornersA);        */
        
    }
    CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
    
    CVPixelBufferRelease(pixel_buffer);
    
}

- (NSInteger)nextAvailableTextureIndex;
{
    return 0;
}

- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex;
{
    inputTextureForMovieRendering = newInputTexture;
}

- (void)setInputSize:(CGSize)newSize;
{
}

- (CGSize)maximumOutputSize;
{
    return CGSizeZero;
}

@end
