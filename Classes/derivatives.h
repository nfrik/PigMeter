//
//  derivatives.h
//  LucasKanadeV1
//
//  Created by nikolay on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef LucasKanadeV1_derivatives_h
#define LucasKanadeV1_derivatives_h

#include "cv.h"
#include "highgui.h"
#include <stdio.h>
#include <ctype.h>


//first derivative
void fivepointmidpoint(CvPoint2D32f * input, CvPoint2D32f * output, int size);

//second rerivative
void fivepointmidpointdd(CvPoint2D32f * input, CvPoint2D32f * output, int size);

//second rerivative
void threepointmidpointdd(CvPoint2D32f * input, CvPoint2D32f * output, int size);

//pixel distance to angles
//@note: 1) current setup will work only for 420p resolution
//          taking into account point resolution w:210px h:320px
//       2) assuming perfect timing btw acceleration and point distance
void pixtoangle(CvPoint3D32f * points1, CvPoint3D32f * points2, CvPoint2D32f * anglesout, int size);

//calculate actual distance taking pixel data, transforming to meters
void inertialpixeltransform(CvPoint2D32f * alpha, CvPoint2D32f * dalpha, CvPoint2D32f * ddalpha, CvPoint3D32f * acceleration, CvPoint2D32f * meterdistout, int size);

//find zeroes and return coordinates
int locatezeroeswithtolerance(CvPoint2D32f * input, int * xzeroes, float epsilon, int size);

//average on selected points
float averageforpoints(CvPoint2D32f * input, int * xzeroes, int size);

//getting average of an array
float average(CvPoint2D32f * input, int which, int size);

#endif
