//
//  AppDelegate.h
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import <UIKit/UIKit.h>
@class GCDAsyncSocket;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    GCDAsyncSocket *asyncSocket;
}


@property (strong, nonatomic) UIWindow *window;


@end

