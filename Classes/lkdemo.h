//
//  lkdemo.h
//  AR Benchmark
//
//  Created by Oded Ben Dov on 6/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#include "cv.h"
//#include "highgui.h"
//#include <opencv2/opencv.hpp>
#include <stdio.h>
#include <ctype.h>

extern int lkcount;
extern int need_to_init;
extern int night_mode;
extern float p1x;
extern float p1y;
extern float p2x;
extern float p2y;
extern float p3x;
extern float p3y;
extern float p4x;
extern float p4y;

CvPoint2D32f* processLKFrame(IplImage* frame, 
							 int &pointCount, 
							 int win_size, 
							 int level, 
							 int maxPoints);
