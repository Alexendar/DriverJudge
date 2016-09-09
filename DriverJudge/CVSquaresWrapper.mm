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
    cv::Mat matImage = [UIImage CVMat:image];
    matImage = CVSquares::detectedSquaresInImage (matImage, tolerance, threshold, levels);
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

@end