//
//  JudgerView.h
//  DriverJudge
//
//  Created by Aleksander on 21/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LicensePlate.h"

@interface JudgerView : UIView
- (instancetype) initWithLicensePlate:(LicensePlate*) plate;
@end
