//
//  LicensePlate.m
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "LicensePlate.h"

@implementation LicensePlate

-(instancetype) initWithNumber:(NSString*)plateNumbers score:(int) score frame:(CGRect) detectionFrame {
    self.plateNumbers = plateNumbers;
    self.score = score;
    self.detectionFrame = detectionFrame;
    return self;
}


@end
