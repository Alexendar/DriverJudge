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

@interface ConnectionService : NSObject <NSStreamDelegate>{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSData *dataForStream;
}
-(void) uploadPhoto:(UIImage*) photo;
-(void) uploadJudge:(Judgement*) judge;
-(int) pingServer;
-(void) connect;
@end
//Global accessor
#if defined __cplusplus
extern "C" {
#endif
ConnectionService *getConnectionService();
#if defined __cplusplus
}
#endif

