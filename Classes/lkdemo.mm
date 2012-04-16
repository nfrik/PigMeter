/* Demo of modified Lucas-Kanade optical flow algorithm.
   See the printf below */

#ifdef _CH_
#pragma package <opencv>
#endif

#define CV_NO_BACKWARD_COMPATIBILITY

#include "lkdemo.h"

IplImage *image = 0, 
		 *grey = 0, 
		 *prev_grey = 0, 
		 *pyramid = 0, 
		 *prev_pyramid = 0, 
		 *swap_temp = 0, 
		 *velx = 0, 
		 *vely = 0;

const int MAX_COUNT = 150;
CvPoint2D32f* points[2] = {0,0}, *swap_points;
char* status = 0;
int lkcount = 0;
int need_to_init = 0;
int night_mode = 0;
int flags = 0;
int add_remove_pt = 0;
float p1x=0;
float p1y=0;
float p2x=0;
float p2y=0;
float p3x=0;
float p3y=0;
float p4x=0;
float p4y=0;
CvPoint pt;

CvSize currentFrameSize;

CvPoint2D32f* processLKFrame(IplImage* frame, 
							 int &pointCount, 
							 int win_size, 
							 int level, 
							 int maxPoints)
{
	int i, k;
	
	// If frame size has changed, release all resources (they will be reallocated further on)
	if (grey &&
		((currentFrameSize.width != cvGetSize(frame).width) ||
		 (currentFrameSize.height != cvGetSize(frame).height))) {
			// Release images	
			cvReleaseImage(&grey); 
			cvReleaseImage(&prev_grey);
			cvReleaseImage(&pyramid);
			cvReleaseImage(&prev_pyramid);
			cvReleaseImage(&velx);
			cvReleaseImage(&vely);
			
			// Release buffers
			cvFree(&(points[0]));
			cvFree(&(points[1]));
			cvFree(&status);
			
			// Zerofiy grey so initialization will occur
			grey = NULL;
		
	}

	// Initialize
	if( !grey )
	{
		/* allocate all the buffers */
		currentFrameSize	= cvGetSize(frame);
		grey				= cvCreateImage( currentFrameSize, 8, 1 );
		prev_grey			= cvCreateImage( currentFrameSize, 8, 1 );
		pyramid				= cvCreateImage( currentFrameSize, 8, 1 );
		prev_pyramid		= cvCreateImage( currentFrameSize, 8, 1 );
		velx				= cvCreateImage(currentFrameSize, 32, 1);
		vely				= cvCreateImage(currentFrameSize, 32, 1);
		points[0]			= (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(points[0][0]));
		points[1]			= (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(points[0][0]));
		status				= (char*)cvAlloc(MAX_COUNT);
		flags				= 0;
	}
		
	// Copy the given frame
	cvCopy( frame, grey, 0 );
 
	if( need_to_init )
	{
		/* automatic initialization */
		IplImage* eig = cvCreateImage( cvGetSize(grey), 32, 1 );
		IplImage* temp = cvCreateImage( cvGetSize(grey), 32, 1 );
		//double quality = 0.01;
		//double min_distance = 20;

		/* Finds a sparse set of points within the selected region
		 that seem to be easy to track */
//		CVAPI(void)  cvGoodFeaturesToTrack( const CvArr* image, CvArr* eig_image,
//										   CvArr* temp_image, CvPoint2D32f* corners,
//										   int* corner_count, double  quality_level,
//										   double  min_distance,
//										   const CvArr* mask CV_DEFAULT(NULL),
//										   int block_size CV_DEFAULT(3),
//										   int use_harris CV_DEFAULT(0),
//										   double k CV_DEFAULT(0.04) );
		lkcount = MAX_COUNT;

// ----------		
//		cvGoodFeaturesToTrack( grey, eig, temp, points[1], &lkcount,
//							   quality, min_distance, 0, 3, 0, 0.04 );
// ----------		
        
        points[1][0].x=p1x;
        points[1][0].y=p1y;
        points[1][1].x=p2x;
        points[1][1].y=p2y;        
        points[1][2].x=p3x;
        points[1][2].y=p3y;
        points[1][3].x=p4x;
        points[1][3].y=p4y;        
        lkcount=2;
    
        
		// Use FAST Corner detection for initial features to track
		/*
		xy *corners;
		int fastThreshold = 20;
		while (lkcount > maxPoints) {
			corners = fast9_detect_nonmax((const byte*)grey->imageData, 
										  cvGetSize(frame).width,
										  cvGetSize(frame).height, 
										  cvGetSize(frame).width, 
										  fastThreshold,
										  &lkcount);
			fastThreshold += 10;
		}
		
		
		for (int i = 0; i < lkcount; i++) {
			(points[1])[i].x = corners[i].x;
			(points[1])[i].y = corners[i].y;
		}
		*/
		
//		cvFindCornerSubPix( grey, points[1], lkcount,
//			cvSize(win_size,win_size), cvSize(-1,-1),
//			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.1));
		cvReleaseImage( &eig );
		cvReleaseImage( &temp );

		add_remove_pt = 0;
	}
	else if( lkcount > 0 )
	{
//		/* Calculates optical flow for 2 images using classical Lucas & Kanade algorithm */
//		CVAPI(void)  cvCalcOpticalFlowLK( const CvArr* prev, const CvArr* curr,
//										 CvSize win_size, CvArr* velx, CvArr* vely );
//		
//		/* Calculates optical flow for 2 images using block matching algorithm */
//		CVAPI(void)  cvCalcOpticalFlowBM( const CvArr* prev, const CvArr* curr,
//										 CvSize block_size, CvSize shift_size,
//										 CvSize max_range, int use_previous,
//										 CvArr* velx, CvArr* vely );
//		
//		/* Calculates Optical flow for 2 images using Horn & Schunck algorithm */
//		CVAPI(void)  cvCalcOpticalFlowHS( const CvArr* prev, const CvArr* curr,
//										 int use_previous, CvArr* velx, CvArr* vely,
//										 double lambda, CvTermCriteria criteria );
//		CVAPI(void)  cvCalcOpticalFlowPyrLK( const CvArr*  prev, const CvArr*  curr,
//											CvArr*  prev_pyr, CvArr*  curr_pyr,
//											const CvPoint2D32f* prev_features,
//											CvPoint2D32f* curr_features,
//											int       count,
//											CvSize    win_size,
//											int       level,
//											char*     status,
//											float*    track_error,
//											CvTermCriteria criteria,
//											int       flags );
		
//		cvCalcOpticalFlowLK( prev_grey, grey, cvSize(win_size,win_size), velx, vely);
		
//		for (int i = 0; i < lkcount; i++) {
//			points[1][i].x = points[0][i].x+velx[points[0][i]
//		}
		
		
		// Calc movement of tracked points
		cvCalcOpticalFlowPyrLK( prev_grey, grey, prev_pyramid, pyramid,
			points[0], points[1], lkcount, cvSize(win_size,win_size), level, status, 0,
			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03), flags );
		flags |= CV_LKFLOW_PYR_A_READY;
		for( i = k = 0; i < lkcount; i++ )
		{
			if( add_remove_pt )
			{
				double dx = pt.x - points[1][i].x;
				double dy = pt.y - points[1][i].y;

				if( dx*dx + dy*dy <= 25 )
				{
					add_remove_pt = 0;
					continue;
				}
			}

			if( !status[i] ) {
				// Mark point as not relevant
				//[pointIndices setObject:[NSNumber numberWithInt:-1 forKey:[NSNumber
				
				// CONTINUE HERE: NEED A FAST WAY TO KNOW WHICH POINT TO UPDATE. MY MODEL IS WRONG.
				//				  (I was supposed to set a -1 to the appropriate point)
				//
				//
				
				continue;
			}

			points[1][k++] = points[1][i];
		}
		lkcount = k;
	}

	if( add_remove_pt && lkcount < MAX_COUNT )
	{
		points[1][lkcount++] = cvPointTo32f(pt);
		cvFindCornerSubPix( grey, points[1] + lkcount - 1, 1,
			cvSize(win_size,win_size), cvSize(-1,-1),
			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
		add_remove_pt = 0;
	}

	CV_SWAP( prev_grey, grey, swap_temp );
	CV_SWAP( prev_pyramid, pyramid, swap_temp );
	CV_SWAP( points[0], points[1], swap_points );
	need_to_init = 0;
	
	pointCount = lkcount;
	return points[0];
}
