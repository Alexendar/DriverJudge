//
//  Building.h
//  Teutonica
//
//  Created by Aleksander on 31/12/15.
//  Copyright © 2015 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Building : NSObject

@property (nonatomic,weak) NSString* buildingName;
@property (nonatomic,weak) NSString* buildingDescription;
@property (nonatomic,weak) UIImage* avatar;
@property (nonatomic,weak) UIImage* mapAvatar;



@end
