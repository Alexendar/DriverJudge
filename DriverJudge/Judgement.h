//
//  Judgement.h
//  DriverJudge
//
//  Created by Aleksander on 06/05/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LicensePlate.h"

@interface Judgement : NSObject
@property (strong,nonatomic) LicensePlate *plate;
@property BOOL isUp;
@property (strong,nonatomic) NSString* deviceId;
@end
