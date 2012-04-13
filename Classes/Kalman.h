//
//  Kalman.h
//  LucasKanadeV1
//
//  Created by nikolay on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#include "cv.h"
//#include "highgui.h"
//#include <opencv2/opencv.hpp>
#include <stdio.h>
#include <ctype.h>

#ifndef LucasKanadeV1_Kalman_h
#define LucasKanadeV1_Kalman_h

void kftest();

void kalman1d(float *input, float *output, float procNoise, float measNoise, int size);
void kalman2d(CvPoint2D32f *input, CvPoint2D32f *output, float procNoise, float measNoise, int size);
void kalman3d(CvPoint3D32f *input, CvPoint3D32f *output, float procNoise, float measNoise, int size);

#endif
