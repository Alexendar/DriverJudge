//
//  Player.h
//  Teutonica
//
//  Created by Aleksander on 06/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (weak, nonatomic) NSString* factionName;

@property NSInteger gold;
@property NSInteger stone;
@property NSInteger wood;
@property NSInteger iron;
@property NSInteger men;


@end
