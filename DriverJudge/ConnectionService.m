//
//  ConnectionService.m
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "ConnectionService.h"
#import "Constants.h"


@interface ConnectionService()

@property (strong,nonatomic)  AFHTTPRequestOperationManager *manager;


@end
@implementation ConnectionService

static NSString * const BaseURLString = @"192.168.0.2";

+(ConnectionService*) sharedInstance {
    static ConnectionService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[ConnectionService alloc] init];
        NSURL *baseURL = [NSURL URLWithString:BaseURLString];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        if(!_sharedService.manager){
            _sharedService.manager = manager;
        }
    });

    return _sharedService;
}


+(int) pingServer {
    static BOOL checkNetwork = YES;
    int pong  = 999;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;
        const char *host_name = "twitter.com"; // your data source host name
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
        if(success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired)){
            CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
            pong = before - after;
        }
        CFRelease(reachability);
    }
    NSLog(@"PONG: %d", pong);
   return pong;
}


@end

ConnectionService *getConnectionService() {
    return [ConnectionService sharedInstance];
}