//
//  LicensePlate.m
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "LicensePlate.h"

@implementation LicensePlate
@synthesize score;
@synthesize plateNumbers;
@synthesize detectionFrame;
+(LicensePlate*) mapJudgePlate: (NSData*)data{
    LicensePlate *p = [LicensePlate new];
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
    p.plateNumbers = dataAsString;
    p.score = 0;
    return p;
}


@end
