//
//  UIImage+Binarization.m
//  DriverJudge
//
//  Created by Aleksander on 06/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "UIImage+Binarization.h"
#import "GPUImage.h"


@implementation UIImage(Binarization)


+ (UIImage *) doBinarize:(UIImage *)sourceImage
{
    //first off, try to grayscale the image using iOS core Image routine
    UIImage * grayScaledImg = [self grayImage:sourceImage];
    GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:grayScaledImg];
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];

    stillImageFilter.blurRadiusInPixels = 1.0;
    
    [imageSource addTarget:stillImageFilter];
    [imageSource processImage];
    [stillImageFilter useNextFrameForImageCapture];
    UIImage *retImage = [stillImageFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    return retImage;
}

+ (UIImage *) grayImage :(UIImage *)inputImage
{
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, 1.0);
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};


+ (UIImage *)rotateImage:(UIImage*)image byDegree:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(bitmap, rotatedSize.width, rotatedSize.height);
    
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width, -image.size.height, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
