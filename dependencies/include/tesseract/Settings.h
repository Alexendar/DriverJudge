//
//  Settings.h
//  Teutonica
//
//  Created by Aleksander on 13/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject
{
    BOOL isMusicOn;
}

@property BOOL isMusicOn;
+(Settings*)getInstance;
@end

