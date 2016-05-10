//
//  GameMap.h
//  Teutonica
//
//  Created by Aleksander on 05/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameMap : NSObject

@property (weak, nonatomic) NSString* mapName;
@property (weak,nonatomic) NSString* mapDescription;
@property (weak,nonatomic) NSArray* mapTiles; //of Dictionaries of Tiles

@end
