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

vector<cv::Point2f> values,kalmanv;

void kftest(){
    
    //init
    KalmanFilter KF(4, 2, 0);
    Mat_<float> state(4, 1); /* (x, y, Vx, Vy) */
    Mat processNoise(4, 1, CV_32F);
    Mat_<float> measurement(2,1); measurement.setTo(cv::Scalar(0));

//    KF.statePre.at<float>(0) = kf1inputx;
//    KF.statePre.at<float>(1) = kf1inputy;
    KF.statePre.at<float>(2) = 0;
    KF.statePre.at<float>(3) = 0;
    
    KF.transitionMatrix = *(Mat_<float>(4, 4) << 1,0,1,0,   0,1,0,1,  0,0,1,0,  0,0,0,1);
    
    setIdentity(KF.measurementMatrix);
    setIdentity(KF.processNoiseCov, Scalar::all(1e-4));
    setIdentity(KF.measurementNoiseCov, Scalar::all(1e-2));
    setIdentity(KF.errorCovPost, Scalar::all(.1));
    
    values.clear();
    kalmanv.clear();
    
    //end init
    
    for(int i=0;i<30;i++){
        Mat prediction = KF.predict();
        cv::Point2f predictPt(prediction.at<float>(0),prediction.at<float>(1));
        
//        measurement(0) = kf1inputx;
//        measurement(1) = kf1inputy;
        
        //Get & Push measurement
        cv::Point2f measPt(measurement(0),measurement(1));
        values.push_back(measPt);
        
        //Get & Push prediction
        Mat estimated = KF.correct(measurement);
        cv::Point2f statePt(estimated.at<float>(0),estimated.at<float>(1));
        kalmanv.push_back(statePt);
        
        
        
       // img = Scalar::all(0);
       // drawCross( statePt, Scalar(255,255,255), 5 );
       // drawCross( measPt, Scalar(0,0,255), 5 );
        
//        for (int i = 0; i < mousev.size()-1; i++) {
//            line(img, mousev[i], mousev[i+1], Scalar(255,255,0), 1);
//        }
//        
//        for (int i = 0; i < kalmanv.size()-1; i++) {
//            line(img, kalmanv[i], kalmanv[i+1], Scalar(0,255,0), 1);
//        }
        
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
    
    values.clear();
    kalmanv.clear();
    
    //end init
    
    for(int i=0;i<size;i++){
        Mat prediction = KF.predict();
        //cv::Point predictPt(prediction.at<float>(0),prediction.at<float>(1));
        
        measurement(0) = input[i].x;
        measurement(1) = input[i].y;
        
        //Get & Push measurement
        cv::Point2f measPt(measurement(0),measurement(1));
        values.push_back(measPt);
        
        //Get & Push prediction
        Mat estimated = KF.correct(measurement);
        cv::Point2f statePt(estimated.at<float>(0),estimated.at<float>(1));
        kalmanv.push_back(statePt);
        
        //save output point
        output[i].x=(float)statePt.x;
        output[i].y=(float)statePt.y;
        
        
        // img = Scalar::all(0);
        // drawCross( statePt, Scalar(255,255,255), 5 );
        // drawCross( measPt, Scalar(0,0,255), 5 );
        
        //        for (int i = 0; i < mousev.size()-1; i++) {
        //            line(img, mousev[i], mousev[i+1], Scalar(255,255,0), 1);
        //        }
        //        
        //        for (int i = 0; i < kalmanv.size()-1; i++) {
        //            line(img, kalmanv[i], kalmanv[i+1], Scalar(0,255,0), 1);
        //        }
        
    }

}
