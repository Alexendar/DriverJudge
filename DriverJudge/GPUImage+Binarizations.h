//
//  GPUImage+Binarizations.h
//  DriverJudge
//
//  Created by Aleksander on 25/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>
//TO DO to nie jest categoria gosciu
@interface GPUImage_Binarizations : NSObject
+ (UIImage *) doBinarize:(UIImage *)sourceImage;
+ (UIImage *) grayImage :(UIImage *)inputImage;
@end
