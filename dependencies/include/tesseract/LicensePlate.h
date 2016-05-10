//
//  LicensePlate.h
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LicensePlate : NSObject

@property (nonatomic, strong) NSString* plateNumbers;
@property int score;
@property (nonatomic) CGRect detectionFrame;

@end
