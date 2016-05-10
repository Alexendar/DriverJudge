//
//  Line.h
//  DriverJudge
//
//  Created by Aleksander on 26/04/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Line : NSObject
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;

-(void) rescale:(CGRect) frameScale;
- (NSValue *)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4;
@end
