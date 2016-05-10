//
//  Line.m
//  DriverJudge
//
//  Created by Aleksander on 26/04/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "Line.h"

@implementation Line
-(void) rescale:(CGRect)frameScale {
    
#warning przesunac te punkty o polowe ekranu? najpierw te z slope>900000
//teraz jest lustrzene odbicie albo przesuniecie
    if(_start.x<=1 && _start.y <=1 && _end.x <=1 && _end.y <=1){
    _start.x =(frameScale.size.width/2)*_start.x +frameScale.size.width/2;
    _start.y =(frameScale.size.height/2)*_start.y +frameScale.size.height/2;
    _end.x =(frameScale.size.width/2)*_end.x + frameScale.size.width/2;
    _end.y =(frameScale.size.height/2)*_end.y + frameScale.size.height/2;
    NSLog(@"od %f,%f do %f,%f", _start.x, _start.y, _end.x, _end.y );
    }
}

- (NSValue *)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4
{
    CGFloat d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0)
        return nil; // parallel lines
    CGFloat u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    CGFloat v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    if (u < 0.0 || u > 1.0)
        return nil; // intersection point not between p1 and p2
    if (v < 0.0 || v > 1.0)
        return nil; // intersection point not between p3 and p4
    CGPoint intersection;
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return [NSValue valueWithCGPoint:intersection];
}

@end
