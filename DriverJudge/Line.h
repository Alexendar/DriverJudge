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
@property GLfloat slope;
@property GLfloat intercept;

-(void) rescale:(CGRect) frameScale;
+ (NSValue *)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4;
+ (BOOL) isIntersecting: (Line*) l1 withLine: (Line*) l2;
@end
