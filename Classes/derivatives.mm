//
//  derivatives.c
//  LucasKanadeV1
//
//  Created by nikolay on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "derivatives.h"

//first derivative
void fivepointmidpoint(CvPoint2D32f * input, CvPoint2D32f * output, int size){
    float h=0;
    if (size<10) {
        return;
    }
    output[0].y=0;
    output[1].y=0;
    output[size-2].y=0;
    output[size-1].y=0;
    
    for(int i=2;i<=size-3;i++){
        h=(input[i].x-input[i-1].x);
        output[i].y=(input[i-2].y-8.0*input[i-1].y+8.0*input[i+1].y-input[i+2].y)*1e3/(12.0*h);
        output[i].x=input[i].x;
    }
}

//second rerivative
void fivepointmidpointdd(CvPoint2D32f * input, CvPoint2D32f * output, int size){
    float h=0;
    if (size<10) {
        return;
    }
    output[0].y=0;
    output[1].y=0;
    output[size-2].y=0;
    output[size-1].y=0;    
    
    for(int i=2;i<=size-3;i++){
        h=(input[i].x-input[i-1].x);
        output[i].y=(-input[i-2].y+16.0*input[i-1].y-30.0*input[i].y+16*input[i+1].y-input[i+2].y)*1e6/(12.0*h*h);
        output[i].x=input[i].x;
    }    
}

//second rerivative
void threepointmidpointdd(CvPoint2D32f * input, CvPoint2D32f * output, int size){
    float h=0;
    if (size<10) {
        return;
    }
    output[0].y=0;
    output[1].y=0;
    output[size-2].y=0;
    output[size-1].y=0;        
    
    for(int i=1;i<=size-2;i++){
        h=(input[i].x-input[i-1].x);
        output[i].y=(input[i-1].y-2.0*input[i].y+input[i+1].y)*1e6/(h*h);
        output[i].x=input[i].x;
    }     
}

//converts pixel distance btw two points to angle distance btw 2 points
void pixtoangle(CvPoint3D32f * points1, CvPoint3D32f * points2, CvPoint2D32f * anglesout, int size){
    float aw,ah;
    for(int i=0;i<size;i++){
        //--------camera focus destabilizes the measurement---
        //--------vertical:~55.7 (old value 53.13)------------
        //--------horizontal:~39.0 (old value 36.8)-----------
        //----------------------------------------------------
        ah = atanf(sqrt(pow(points2[i].x-points1[i].x,2))/320*tan((55.7/180*M_PI)/2.0));
        aw = atanf(sqrt(pow(points2[i].y-points1[i].y,2))/215*tan((39.0/180*M_PI)/2.0));
//        anglesout[i].y = 2*atan(sqrt(pow(points2[i].x-points1[i].x,2)+pow(points2[i].y-points1[i].y,2))/320*tan((55.7/180*M_PI)/2.0));
//        anglesout[i].y = 2*atan(sqrt(pow(points2[i].x-points1[i].x,2))/320*tan((55.7/180*M_PI)/2.0));
          anglesout[i].y = 2*atanf(sqrtf(powf(ah, 2)+powf(aw, 2)));
          anglesout[i].x = points1[i].z;
        
    }
}

//calculate actual distance taking pixel data, transforming to meters
//@note: 1) current setup will work only for 420p resolution
//          taking into account point resolution w:210px h:320px
//       2) assuming perfect timing btw acceleration and point distance

//calculate actual distance taking pixel data, transforming to meters
void inertialpixeltransform(CvPoint2D32f * alpha, CvPoint2D32f * dalpha, CvPoint2D32f * ddalpha, CvPoint3D32f * acceleration, CvPoint2D32f * meterdistout, int size){
    
    for(int i=0;i<size;i++){
        meterdistout[i].y=2*acceleration[i].z*(cos(alpha[i].y)-1)/(ddalpha[i].y-pow(dalpha[i].y,2)*tan(M_PI_2-alpha[i].y/2.0));
        meterdistout[i].x=alpha[i].x;
    }
    
}


//find zeroes and return coordinates 
//return number of points found
int locatezeroeswithtolerance(CvPoint2D32f * input, int * xzeroes, float epsilon, int size){
    int k=0;
    for(int i=2; i<size-3; i++){
        if (fabs(input[i].y)<=epsilon) {
            xzeroes[k]=i;
            k++;
        }
    }
    return k;
}


//average for selected points
float averageforpoints(CvPoint2D32f * input, int * xzeroes, int size){
    float f=0;
    for(int i=0;i<size;i++){
        f+=fabs(input[xzeroes[i]].y);
        NSLog(@"i = %d, size = %d, f= %f",i,size,f);
    }
    return f/size;
}

//find average
float average(CvPoint2D32f * input, int which, int size){
    float accum=0;
    for (int i; i<size;i++) {
        switch (which) {
            case 0:
                    accum+=input[i].x;
                break;
            case 1:
                    accum+=input[i].y;
            default:
                break;
        }
    }
    return accum/size;
}

/*==============================================================
 Numerical integration of f(x) on [a,b]
 method: Simpson rule
 written by: Alex Godunov (February 2007)
 ----------------------------------------------------------------
 input:
 f   - a single argument real function (supplied by the user)
 a,b - the two end-points of the interval of integration
 n   - number of intervals
 output:
 s - result of integration
 ================================================================*/

double simpson(CvPoint2D32f * input, int n0, int n1)
{
    double s,dx;
    int n=n1-n0+1;
    // if n is odd - add +1 interval to make it even
    if((n/2)*2 != n) {n=n+1;}
    s = 0.0;
    for ( int i=2; i<=n-1; i=i+2)
    {
        dx=input[n0].x-input[n0+1].x;
        s = s + (2.0*input[i].y + 4.0*input[i+1].y)*dx/3.0;
    }
    dx=input[n0].x-input[n0+1].x;
    s = s + (input[n0].y+input[n1].y+4.0*input[n0+1].y)*dx/3.0;
    return s;
}


//simpson's rule for integration
double simpson(CvPoint2D32f * input, int n){
    return (input[n-1].y+4.0*input[n].y+input[n+1].y)*(input[n].x-input[n-1].x)/3.0;
}


//instant simpson's rule for integration
double instantsimpson(float f0, float f1, float f2, float dx){
    return (double)(f0+4.0*f1+f2)*dx/3.0;
}
