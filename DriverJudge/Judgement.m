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
    if (self = [super init]) {
        self.isUp = judgement;
        self.plateNumbers = numbers;
        UIDevice *device = [UIDevice currentDevice];
        NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
        self.deviceId = currentDeviceId;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.plateNumbers = [decoder decodeObjectForKey:@"plateNumbers"];
        self.isUp = [decoder decodeBoolForKey:@"isUp"];
        self.deviceId = [decoder decodeObjectForKey:@"deviceId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.plateNumbers forKey:@"plateNumbers"];
    [coder encodeInt:self.isUp forKey:@"isUp"];
    [coder encodeObject:self.deviceId forKey:@"deviceId"];
}

@end
