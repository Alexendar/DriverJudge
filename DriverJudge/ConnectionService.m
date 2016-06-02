//
//  ConnectionService.m
//  DriverJudge
//
//  Created by Aleksander on 13/03/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "ConnectionService.h"
#import "Constants.h"
#import "inttypes.h"

@interface ConnectionService()

@end
@implementation ConnectionService

static NSString * const host = @"192.168.8.104";
static int const port = 44444;

+(ConnectionService*) sharedInstance {
    static ConnectionService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[ConnectionService alloc] init];
        
    });

    return _sharedService;
}
-(BOOL) connect {
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
    
    return YES;
}

-(void) disconnect {
    CFReadStreamClose(readStream);
    CFWriteStreamClose(writeStream);
    [inputStream close];
    [outputStream close];
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
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
                       
                        if (nil != output)
                        {
                            NSString* newStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:theData forKey:@"JudgeData"];
                            [[NSNotificationCenter defaultCenter] postNotificationName: @"JudgeNotification" object:nil userInfo:userInfo];
                            NSLog(@"NSStreamEventHasBytesAvailable theData: %@", newStr);
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            
            NSLog(@"NSStreamEventHasSpaceAvailable called");
            
            if (theStream == outputStream)
            {
                NSUInteger length = [data length];
              
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^(void) {
                    
                    
                    NSLog(@"Length %lu", (unsigned long)length);
                    //buffor limit
                    if(length > 130000)
                        return;
                    
                    int num = [outputStream write:[data bytes] maxLength:length];
                    if (-1 == num) {
                        NSLog(@"Error %@", [outputStream streamError]);
                    } else {
                        [self stream:inputStream handleEvent:NSStreamEventHasBytesAvailable withData:nil];
                        NSLog(@"Wrote %i bytes to stream %@.", num, outputStream);
                    }
                    [self disconnect];
                    [self connect];
                });
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
-(void)uploadPhoto: (UIImage*) image cropped:(CGRect)cropRect{
    if(cropRect.size.width>0){
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        croppedImage = [UIImage imageWithCGImage:croppedImage.CGImage scale:croppedImage.scale orientation:UIImageOrientationDown];
        CGImageRelease(imageRef);
        NSData * data = UIImageJPEGRepresentation(image,0.8);
        [self stream:outputStream handleEvent:NSStreamEventHasSpaceAvailable withData: data];
    }
}
-(void) uploadJudge:(Judgement *)judge {
    NSString *judgeString = [NSString stringWithFormat: @"%@,%@,%hhd,%@", @"JUDGE", judge.plate, judge.isUp, judge.deviceId];
    NSData* data = [judgeString dataUsingEncoding:NSUTF8StringEncoding];
    [self stream:outputStream handleEvent:NSStreamEventHasSpaceAvailable withData: data];
}


-(int) pingServer {
    int pong  = 30;
    return pong;
}


@end

ConnectionService *getConnectionService() {
    
    return [ConnectionService sharedInstance];
}