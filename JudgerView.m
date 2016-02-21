//
//  JudgerView.m
//  DriverJudge
//
//  Created by Aleksander on 21/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "JudgerView.h"
@interface JudgerView()
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageFrame;

@end
@implementation JudgerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGRect newFrame = CGRectMake(self.imageFrame.frame.origin.x, self.imageFrame.frame.origin.y, self.imageFrame.frame.size.width, self.imageFrame.frame.size.height/4);
    self.markLabel.frame = newFrame;
    [super drawRect:rect];
}


@end
