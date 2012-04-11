//
//  GPUImagePostProcessor.h
//  GPUImage
//
//  Created by nikolay on 3/13/12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImageOpenGLESContext.h"
#import "GPUImage.h"

@interface GPUImagePostProcessor : NSObject <GPUImageInput>
{
    CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
    
    NSURL *movieURL;
	AVAssetWriter *assetWriter;
    //	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
	dispatch_queue_t movieWritingQueue;
    
    CGSize videoSize;
}

// Initialization and teardown
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;

// Movie recording
- (void)startRecording;
- (void)finishRecording;

@end

