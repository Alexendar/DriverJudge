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
    
    //convert from UIImage to cv::Mat openCV image format
    //this is a category on UIImage
    
    cv::Mat matImage = [UIImage CVMat:image];
    
    NSMutableArray *rectResults = [[NSMutableArray alloc] init];
    //call the c++ class static member function
    //we want this function signature to exactly
    //mirror the form of the calling method
    std::vector<std::vector<cv::Point> > points = CVSquares::squaresInImage(matImage, tolerance, threshold, levels);
    
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

@end