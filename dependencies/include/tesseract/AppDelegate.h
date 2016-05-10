//
//  AppDelegate.h
//  Teutonica
//
//  Created by Aleksander on 27/01/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    AVAudioPlayer *menuAudioPlayer;
}
@property (nonatomic, retain) AVAudioPlayer *menuAudioPlayer;

@property (strong, nonatomic) UIWindow *window;


@end

