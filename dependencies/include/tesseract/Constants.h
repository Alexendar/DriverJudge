//
//  Constants.h
//  Teutonica
//
//  Created by Aleksander on 15/01/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
#pragma mark: Factions
@property NSString *const kTeutons;
@property NSString *const kPagans;

#pragma mark: Hierarchy
//Teutonic
@property NSString *const kPeasant;
@property NSString *const kCitizen;
@property NSString *const kLord;
@property NSString *const kGrandMaster;
@property NSString *const kPriest;
//Pagan
@property NSString *const kSlave;
@property NSString *const kFreeman;
@property NSString *const kNoble;
@property NSString *const kWarlord;
@property NSString *const kDruid;

#pragma mark: Buildings
@property NSString *const kVillage;
@property NSString *const kCity;

@property NSString *const kStronghold;
@property NSString *const kCastle;

@property NSString *const kGoldQuarry;
@property NSString *const kSilverQuerry;
@property NSString *const kSawmill;

@property NSString *const kChurch;
@property NSString *const kHolyGround;

#pragma mark: Units
//Teutonic
@property NSString *const kFootman;
@property NSString *const kHunter;
@property NSString *const kRider;

@property NSString *const kSwordsman;
@property NSString *const kArcher;
@property NSString *const kKnight;

@property NSString *const kBrother;
@property NSString *const kCrossbowman;
@property NSString *const kKomtur;
//Pagan
@property NSString *const kTribesman;
@property NSString *const kSpearthrower;
@property NSString *const kSkirmisher;

@property NSString *const kShieldbearer;
@property NSString *const kAxethrower;
@property NSString *const kMercanary;

@property NSString *const kWarlordGuard;
@property NSString *const kTrapmaster;
@property NSString *const kBerserker;

//no binding
@property NSString *const kBandit;
@property NSString *const kSlinger;
@property NSString *const kMountedBandit;


#pragma mark: Story


#pragma mark: History



@end
