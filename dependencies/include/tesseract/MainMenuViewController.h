//
//  MainMenuViewController.h
//  Teutonica
//
//  Created by Aleksander on 30/01/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>

@interface MainMenuViewController : UIViewController
@property (weak, nonatomic) NSString* string;

@property (weak, nonatomic) AVPlayer* player;
@property (weak,nonatomic) AVPlayerLayer *playerLayer;
@end
