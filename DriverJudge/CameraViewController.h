//
//  CameraViewController.h
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController :  UIViewController <UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
-(CGSize) scaleSize: (CGSize) size;
-(CGPoint) scalePoint:(CGPoint) point;
-(CGRect) scaleRectUpSize: (CGRect) rect;
@end
