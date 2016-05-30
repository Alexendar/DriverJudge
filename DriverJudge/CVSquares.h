//
//  CVSquares.hpp
//  DriverJudge
//
//  Created by Aleksander on 30/05/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

//  CVSquares.h
#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#endif

#include "TargetConditionals.h"
#ifndef __OpenCVClient__CVSquares__
#define __OpenCVClient__CVSquares__

//class definition
//in this example we do not need a class
//as we have no instance variables and just one static function.
//We could instead just declare the function but this form seems clearer
using namespace std;
using namespace cv;
class CVSquares
{
public:
    static cv::Mat detectedSquaresInImage (cv::Mat image, float tol, int threshold, int levels);
    static std::vector<std::vector<cv::Point> > squaresInImage(cv::Mat image, float tol, int threshold, int levels);
};

#endif /* defined(__OpenCVClient__CVSquares__) */