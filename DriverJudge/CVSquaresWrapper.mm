//
//  CVSquaresWrapper.m
//  DriverJudge
//
//  Created by Aleksander on 30/05/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

//  CVSquaresWrapper.h

//  CVSquaresWrapper.mm
//  wrapper that talks to c++ and to obj-c classes
#import "opencv2/imgcodecs/ios.h"
#import "CVSquaresWrapper.h"
#import "CVSquares.h"
#import "UIImage+OpenCV.h"

@implementation CVSquaresWrapper

@synthesize rectanglesDetectedBlock;


-(UIImage*) detectedSquaresInImage:(UIImage*) image
                          tolerance:(CGFloat)tolerance
                          threshold:(NSInteger)threshold
                             levels:(NSInteger)levels
{
    UIImage* result = nil;
    
    //convert from UIImage to cv::Mat openCV image format
    //this is a category on UIImage
    cv::Mat matImage = [UIImage CVMat:image];
    
    
    //call the c++ class static member function
    //we want this function signature to exactly
    //mirror the form of the calling method
    matImage = CVSquares::detectedSquaresInImage (matImage, tolerance, threshold, levels);
    
    
    //convert back from cv::Mat openCV image format
    //to UIImage image format (category on UIImage)
    result = [UIImage imageFromCVMat:matImage];
    
    return result;
}
-(NSArray*) squaresInImage:(UIImage*) image
tolerance:(CGFloat)tolerance
threshold:(NSInteger)threshold
                             levels:(NSInteger)levels {
    
    
    cv::Mat matImage = [UIImage CVMat:image];

    NSMutableArray *rectResults = [[NSMutableArray alloc] init];
    
    cv::Mat rotatedImage;
    
    rotate(matImage,180,rotatedImage);
    
    std::vector<std::vector<cv::Point> > points = CVSquares::squaresInImage(rotatedImage, tolerance, threshold, levels);
    
    for(int i = 0; i < points.size(); i++){
        for(int j = 0; j < points.at(i).size(); j++){
            CGPoint point = CGPointMake(points.at(i).at(j).x,points.at(i).at(j).y);
            NSValue *val = [NSValue valueWithCGPoint:point];
            [rectResults addObject:val];
        }
    }
    
    if (rectanglesDetectedBlock && rectResults)
    {
            rectanglesDetectedBlock(rectResults);
    }
    return rectResults;
}
void rotate(cv::Mat& src, double angle, cv::Mat& dst)
{
    cv::Point2f pt(src.cols/2., src.rows/2.);
    cv::Mat r = cv::getRotationMatrix2D(pt, angle, 1.0);
    
    cv::warpAffine(src, dst, r, src.size());
}

#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>

using namespace std;
using namespace cv;

/**
 * @function main
 */
- (void) histogram:(NSString *)path {

    [self histogramo:path];
}
-(int) histogramo:(NSString*) argv
{
    Mat src, dst;
    
    /// Load image
    const char *c = [argv UTF8String];
    src = imread( "jest.png", 1 );
    
    if( !src.data )
    { return -1; }
    
    /// Separate the image in 3 places ( B, G and R )
    vector<Mat> bgr_planes;
    split( src, bgr_planes );
    
    /// Establish the number of bins
    int histSize = 256;
    
    /// Set the ranges ( for B,G,R) )
    float range[] = { 0, 256 } ;
    const float* histRange = { range };
    
    bool uniform = true; bool accumulate = false;
    
    Mat b_hist, g_hist, r_hist;
    
    /// Compute the histograms:
    calcHist( &bgr_planes[0], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &bgr_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &bgr_planes[2], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );
    
    // Draw the histograms for B, G and R
    int hist_w = 512; int hist_h = 400;
    int bin_w = cvRound( (double) hist_w/histSize );
    
    Mat histImage( hist_h, hist_w, CV_8UC3, Scalar( 0,0,0) );
    
    /// Normalize the result to [ 0, histImage.rows ]
    normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    
    /// Draw for each channel
    for( int i = 1; i < histSize; i++ )
    {
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
             Scalar( 255, 0, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
             Scalar( 0, 255, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
             Scalar( 0, 0, 255), 2, 8, 0  );
    }
    cout << "M = "<< endl << " "  << histImage << endl << endl;
    waitKey(0);
    
    return 0;
}
@end