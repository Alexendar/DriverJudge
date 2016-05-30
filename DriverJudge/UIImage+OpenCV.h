//
//  UIImage+OpenCV.h
//  DriverJudge
//
//  Created by Aleksander on 30/05/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
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


@interface UIImage (UIImage_OpenCV)

//cv::Mat to UIImage
+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;

//UIImage to cv::Mat
+ (cv::Mat)CVMat:(UIImage *)image;




@end