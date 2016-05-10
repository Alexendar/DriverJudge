//
//  UIImage+Binarization.h
//  DriverJudge
//
//  Created by Aleksander on 06/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Binarization)
+ (UIImage *) doBinarize:(UIImage *)sourceImage;
+ (UIImage *) grayImage :(UIImage *)inputImage;
@end
