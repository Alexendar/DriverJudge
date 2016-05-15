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


@end
@implementation ConnectionService

static NSString * const host = @"192.168.8.103";
static int const port = 4444;

+(ConnectionService*) sharedInstance {
    static ConnectionService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[ConnectionService alloc] init];
    });

    return _sharedService;
}
-(void) connect {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
}
-(void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent withData: (NSData*) data {
    NSString *io;
    if (theStream == inputStream) io = @">>";
    else io = @"<<";
    
    NSString *event;
    switch (streamEvent)
    {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            NSLog(@"NSStreamEventNone - Can not connect to the host");
            break;
            
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            NSLog(@"Connected");
            break;
            
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            NSLog(@"NSStreamEventHasBytesAvailable called");
            if (theStream == inputStream)
            {
                //read data
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
                        
                        if (nil != output)
                        {
                            NSLog(@"NSStreamEventHasBytesAvailable theData: %@", theData);
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            
            NSLog(@"NSStreamEventHasSpaceAvailable called");
            
            NSLog(@"space : %d",[outputStream hasSpaceAvailable]);
            
            if (theStream == outputStream)
            {
                int num = [outputStream write:[data bytes] maxLength:[data length]];
                if (-1 == num) {
                    NSLog(@"Error writing to stream %@: %@", outputStream, [outputStream streamError]);
                }else{
                    NSLog(@"Wrote %i bytes to stream %@.", num, outputStream);
                    //[outputStream close];
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            NSLog(@"NSStreamEventErrorOccurred - Can not connect to the host");
            break;
            
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            NSLog(@"NSStreamEventEndEncountered - Connection closed by the server");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
            
        default:
            event = @"** Unknown";
    }
    
    NSLog(@"%@ : %@", io, event);
}
-(void)uploadPhoto: (UIImage*) image{
    NSData * data = UIImagePNGRepresentation(image);
    [self stream:outputStream handleEvent:NSStreamEventHasSpaceAvailable withData: data];
}
-(void) uploadJudge:(Judgement *)judge {
    NSString *judgeString = [NSString stringWithFormat: @"%@,%@,%hhd,%@", @"JUDGE", judge.plate, judge.isUp, judge.deviceId];
    NSData* data = [judgeString dataUsingEncoding:NSUTF8StringEncoding];
    [self stream:inputStream handleEvent:NSStreamEventHasSpaceAvailable withData: data];
}


-(int) pingServer {
    int pong  = 20;
    return pong;
}


@end

ConnectionService *getConnectionService() {
    
    return [ConnectionService sharedInstance];
}