//
//  Unit.h
//  Teutonica
//
//  Created by Aleksander on 25/12/15.
//  Copyright © 2015 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Unit : NSObject

#pragma mark Unit Info
@property (nonatomic,weak) NSString *unitName;
@property (nonatomic, weak) NSString *unitHistory;
@property (nonatomic, weak) UIImage *unitAvatar;

#pragma mark Unit Statistics
@property (nonatomic) NSUInteger *health;
@property (nonatomic) NSUInteger *attack;
@property (nonatomic) NSUInteger *defence;
@property (nonatomic) NSUInteger *speed;

@property (nonatomic) NSInteger *morale;
@property (nonatomic) NSUInteger *luck;

@property (nonatomic) NSInteger *amount;
@property (nonatomic) NSString *type;
@end
