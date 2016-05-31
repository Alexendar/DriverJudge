//
//  JudgerView.m
//  DriverJudge
//
//  Created by Aleksander on 21/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "JudgerView.h"
#import "LicensePlate.h"

@interface JudgerView()


@end
@implementation JudgerView

- (instancetype) initWithLicensePlate:(LicensePlate*) plate {
    self = [super init];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(plate.detectionFrame.origin.x, plate.detectionFrame.origin.y -30, plate.detectionFrame.size.width, 30)];
    scoreLabel.backgroundColor = [UIColor blueColor];
    plate.score = 0;
    scoreLabel.text = [[NSString stringWithFormat:@"%d : ", plate.score] stringByAppendingString:plate.plateNumbers];
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
    
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
    [aPath addLineToPoint:CGPointMake(160, 140)];
    [aPath addLineToPoint:CGPointMake(40.0, 140)];
    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
    [aPath closePath];

    
    
    UIImageView *frameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueFrame"]];
    frameView.frame = plate.detectionFrame;
    [self addSubview:scoreLabel];
    [self addSubview:frameView];
    
    
    self.backgroundColor = [UIColor blueColor];
    
   // UIImageView* imageFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueFrame"]];
  //  imageFrame.frame = plate.detectionFrame;
  //  [self addSubview: imageFrame];

    
    return self;
}



@end
