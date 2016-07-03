//
//  Judgement.m
//  DriverJudge
//
//  Created by Aleksander on 06/05/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Judgement.h"
@interface Judgement()

@property (strong,nonatomic) NSString *plateNumbers;
@property BOOL isUp;
@property (strong,nonatomic) NSString *deviceId;

@end
@implementation Judgement

-(instancetype) initWithJudge: (BOOL) judgement number: (NSString*) numbers {
    self = [super init];
    self.isUp = judgement;
    self.plateNumbers = numbers;
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    self.deviceId = currentDeviceId;
    return self;
}

@end
