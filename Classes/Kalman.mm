//
//  Kalman.cpp
//  LucasKanadeV1
//
//  Created by nikolay on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#include "Kalman.h"

#include <iostream>
#include <vector>

//#include <opencv2/video/tracking.hpp>

using namespace cv;
//using namespace std;

vector<float> values1d,kalmanv1d;
vector<cv::Point2f> values2d,kalmanv2d;
vector<cv::Point3f> values3d,kalmanv3d;


void kalman1d(float *input, float *output, float procNoise, float measNoise, int size){
    //init
    KalmanFilter KF(4, 1, 0);
    Mat_<float> state(4, 1); /* (x, y, Vx, Vy) */
    Mat processNoise(4, 1, CV_32F);
    Mat_<float> measurement(1,1); measurement.setTo(cv::Scalar(0));
    
    KF.statePre.at<float>(0) = input[0];
    KF.statePre.at<float>(1) = 0;
    KF.statePre.at<float>(2) = 0;
    KF.statePre.at<float>(3) = 0;
    
    KF.transitionMatrix = *(Mat_<float>(4, 4) << 1,0,1,0,   0,1,0,1,  0,0,1,0,  0,0,0,1);
    
    setIdentity(KF.measurementMatrix);
    setIdentity(KF.processNoiseCov, Scalar::all(procNoise));
    setIdentity(KF.measurementNoiseCov, Scalar::all(measNoise));
    setIdentity(KF.errorCovPost, Scalar::all(.1));
    
    values1d.clear();
    kalmanv1d.clear();
    
    //end init
    
    for(int i=0;i<size;i++){
        Mat prediction = KF.predict();
        
        measurement(0) = input[i];
        
        //Get & Push measurement
        float measPt(measurement(0));
        values1d.push_back(measPt);
        
        //Get & Push prediction
        Mat estimated = KF.correct(measurement);
        float statePt(estimated.at<float>(0));
        kalmanv1d.push_back(statePt);
        
        //save output point
        output[i]=(float)statePt;
        
    }    
}

void kalman2d(CvPoint2D32f *input, CvPoint2D32f *output, float procNoise, float measNoise, int size){
    
    //init
    KalmanFilter KF(4, 2, 0);
    Mat_<float> state(4, 1); /* (x, y, Vx, Vy) */
    Mat processNoise(4, 1, CV_32F);
    Mat_<float> measurement(2,1); measurement.setTo(cv::Scalar(0));
    
    KF.statePre.at<float>(0) = input[0].x;
    KF.statePre.at<float>(1) = input[0].y;
    KF.statePre.at<float>(2) = 0;
    KF.statePre.at<float>(3) = 0;
    
    KF.transitionMatrix = *(Mat_<float>(4, 4) << 1,0,1,0,   0,1,0,1,  0,0,1,0,  0,0,0,1);
    
    setIdentity(KF.measurementMatrix);
    setIdentity(KF.processNoiseCov, Scalar::all(procNoise));
    setIdentity(KF.measurementNoiseCov, Scalar::all(measNoise));
    setIdentity(KF.errorCovPost, Scalar::all(.1));
    
    values2d.clear();
    kalmanv2d.clear();
    
    //end init
    
    for(int i=0;i<size;i++){
        Mat prediction = KF.predict();
        //cv::Point predictPt(prediction.at<float>(0),prediction.at<float>(1));
        
        measurement(0) = input[i].x;
        measurement(1) = input[i].y;
        
        //Get & Push measurement
        cv::Point2f measPt(measurement(0),measurement(1));
        values2d.push_back(measPt);
        
        //Get & Push prediction
        Mat estimated = KF.correct(measurement);
        cv::Point2f statePt(estimated.at<float>(0),estimated.at<float>(1));
        kalmanv2d.push_back(statePt);
        
        //save output point
        output[i].x=(float)statePt.x;
        output[i].y=(float)statePt.y;
        
    }

}


void kalman3d(CvPoint3D32f *input, CvPoint3D32f *output, float procNoise, float measNoise, int size){
    
    //init
    KalmanFilter KF(4, 3, 0);
    Mat_<float> state(4, 1); /* (x, y, Vx, Vy) */
    Mat processNoise(4, 1, CV_32F);
    Mat_<float> measurement(3,1); measurement.setTo(cv::Scalar(0));
    
    KF.statePre.at<float>(0) = input[0].x;
    KF.statePre.at<float>(1) = input[0].y;
    KF.statePre.at<float>(2) = input[0].z;
    KF.statePre.at<float>(3) = 0;
    
    KF.transitionMatrix = *(Mat_<float>(4, 4) << 1,0,1,0,   0,1,0,1,  0,0,1,0,  0,0,0,1);
    
    setIdentity(KF.measurementMatrix);
    setIdentity(KF.processNoiseCov, Scalar::all(procNoise));
    setIdentity(KF.measurementNoiseCov, Scalar::all(measNoise));
    setIdentity(KF.errorCovPost, Scalar::all(.1));
    
    values3d.clear();
    kalmanv3d.clear();
    
    //end init
    
    for(int i=0;i<size;i++){
        Mat prediction = KF.predict();
        //cv::Point predictPt(prediction.at<float>(0),prediction.at<float>(1));
        
        measurement(0) = input[i].x;
        measurement(1) = input[i].y;
        measurement(2) = input[i].z;        
        
        //Get & Push measurement
        cv::Point3f measPt(measurement(0),measurement(1),measurement(2));
        values3d.push_back(measPt);
        
        //Get & Push prediction
        Mat estimated = KF.correct(measurement);
        cv::Point3f statePt(estimated.at<float>(0),estimated.at<float>(1),estimated.at<float>(2));
        kalmanv3d.push_back(statePt);
        
        //save output point
        output[i].x=(float)statePt.x;
        output[i].y=(float)statePt.y;
        output[i].z=(float)statePt.z;        
        
        
    }
    
}

