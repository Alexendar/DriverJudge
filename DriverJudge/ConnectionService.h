//
//  ConnectionService.h
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import "GCDAsyncSocket.h"
#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LicensePlate.h"
#import "Judgement.h"

@interface ConnectionService : AFHTTPSessionManager<NSStreamDelegate>

+(int) pingServer;

@end
//Global accessor
#if defined __cplusplus
extern "C" {
#endif
ConnectionService *getConnectionService();
#if defined __cplusplus
}
#endif

