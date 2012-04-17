//
//  derivatives.h
//  LucasKanadeV1
//
//  Created by nikolay on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef LucasKanadeV1_derivatives_h
#define LucasKanadeV1_derivatives_h

//#include "cv.h"
//#include "highgui.h"
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


//test function to calculate angle of the point
float ppvisangl(float y, float pitch);

//distance
float getdistance(float h, float alpha);

//height
float getheight(float h, float d,float alpha);

//calculate actual distance taking pixel data, transforming to meters
void inertialpixeltransform(CvPoint2D32f * alpha, CvPoint2D32f * dalpha, CvPoint2D32f * ddalpha, CvPoint3D32f * acceleration, CvPoint2D32f * meterdistout, int size);

//find zeroes and return coordinates
int locatezeroeswithtolerance(CvPoint2D32f * input, int * xzeroes, float epsilon, int size);

//average on selected points
float averageforpoints(CvPoint2D32f * input, int * xzeroes, int size);

//average on selected points with kalman filtering
float averageforpoints(CvPoint2D32f * input, int * xzeroes, int size);

//getting average of an array
float average(CvPoint2D32f * input, int which, int size);

//set zero
void settozero(CvPoint2D32f * input, int size);

//set zero overloaded
void settozero(CvPoint3D32f * input, int size);

//simpson's rule for integration
double simpson(CvPoint2D32f * input, int n0, int n1);

//simpson's rule for integration with timeline value
void simpson(CvPoint3D32f * input, CvPoint2D32f * output, CvPoint2D32f * time, int n0, int n1);

//simpson's rule for integration
double simpson(CvPoint2D32f * input, int n);

//instant simpson's rule for integration
double instantsimpson(float f0, float f1, float f2, float dx);



#endif
