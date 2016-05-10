//
//  Hero.h
//  Teutonica
//
//  Created by Aleksander on 31/12/15.
//  Copyright © 2015 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Hero : NSObject

@property (nonatomic,weak) NSString* heroName;
@property (nonatomic, weak) NSString* heroStory;
@property (nonatomic,weak) UIImage* heroAvatar;
@property (nonatomic,weak) UIImage* mapAvatar;
@property (nonatomic,weak) NSString* loyalTo;

@property NSInteger* command;
@property NSInteger* movePoints;
@property NSInteger* loyalty;
@property NSInteger* zealotry;

@end
