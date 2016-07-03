//
//  CameraViewController.m
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import "CameraViewController.h"
#import "GPUImage.h"
#import "ConnectionService.h"
#import "LicensePlate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "Line.h"
#import "CVSquaresWrapper.h"
#import "UIImage+Binarization.h"

@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) UILabel * plateLabel;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *judgerView;
@property (strong, nonatomic) IBOutlet UIView *gestureView;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDownGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUpGesture;
- (IBAction)swipeDown:(id)sender;
- (IBAction)swipeUp:(id)sender;

@property (strong,nonatomic) AVCaptureSession *session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic) CALayer *overviewLayer;

@property (strong,nonatomic) ConnectionService *connectionService;
@property (strong,nonatomic) LicensePlate *recievedLicensePlate;

@property (strong,nonatomic) NSMutableArray *linesArray;
@property (strong,nonatomic) NSMutableArray *rectangleArray;


@property int fpsCaptureRate;
@property (strong,nonatomic) UIImage *calculatedImage;
@property BOOL calculatedPreviousFrame;
@property int numberOfCapturedFrames;


///Data for plate display
@property (strong,nonatomic) NSString *reconPlate;
@property CGRect cropRectangle;
@property (strong,nonatomic) UIColor *reconColor;

@property (strong, nonatomic) Judgement *judge;

@end

@implementation CameraViewController


-(void)viewDidLoad {
    
    self.judge = [Judgement new];
    self.reconColor = [UIColor yellowColor];
    self.calculatedImage = [UIImage new];
    self.calculatedPreviousFrame = YES;
    self.numberOfCapturedFrames = 0;
    self.fpsCaptureRate = 0;
    [self setupCaptureSession];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    self.overviewLayer = [[CALayer alloc] init];
    
    CGRect videoRect = CGRectMake(0,0,screenWidth,screenHeight);
    
    self.previewLayer.frame = videoRect;
    self.overviewLayer.frame = videoRect;
    
    [self.cameraView.layer addSublayer:self.previewLayer];
    [self.judgerView.layer addSublayer:self.overviewLayer];
    [self.gestureView addGestureRecognizer:self.swipeUpGesture];
    [self.gestureView addGestureRecognizer:self.swipeDownGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveConnectionStatus:)
                                                 name:@"ConnectionStatus"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveJudgeNotification:)
                                                 name:@"JudgeNotification"
                                               object:nil];
    
    }

-(void) viewDidAppear:(BOOL)animated
{
    [getConnectionService() connect];

    [super viewDidAppear:YES];
    AVCaptureConnection *previewLayerConnection=self.previewLayer.connection;
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
}

- (void) receiveConnectionStatus:(NSNotification *) notification
{
    NSDictionary *connectionInfo = notification.userInfo;
    NSString *connectionStatus = [[NSString alloc] initWithData:[connectionInfo objectForKey:@"ConnectionStatus"] encoding:kCFStringEncodingUTF8];
    self.connectionStatusLabel.text = connectionStatus;
}

- (void) receiveJudgeNotification:(NSNotification *) notification {
    
    NSDictionary *judgeInfo = notification.userInfo;
    NSData *recognizedData = [judgeInfo objectForKey:@"JudgeData"];
    
    LicensePlate *detectedPlate = [LicensePlate mapJudgePlate:recognizedData];
    self.reconPlate = detectedPlate.plateNumbers;
    
    if(detectedPlate.score > 0) {
        self.reconColor = [UIColor greenColor];
    } else if (detectedPlate.score < 0) {
        self.reconColor = [UIColor redColor];
    } else {
        self.reconColor = [UIColor yellowColor];
    }
}

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // Start the session running to start the flow of data
    [session startRunning];
    
    // Assign session to an ivar.
    [self setSession:session];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    if(self.fpsCaptureRate==[self calculateOptimalCaptureTime] && self.calculatedPreviousFrame){
        
     UIImage *sourceImage =[self imageFromSampleBuffer:sampleBuffer];
        UIImage *image =[UIImage imageWithCGImage:sourceImage.CGImage scale:sourceImage.scale orientation:UIImageOrientationDown];
        
        self.calculatedImage = image;
        self.numberOfCapturedFrames++;
        
        CVSquaresWrapper *wrap = [[CVSquaresWrapper alloc] init];
        
        wrap.rectanglesDetectedBlock = ^(NSArray* pointsArray) {
            [self renderRectangles:pointsArray];
        };
        
        [wrap squaresInImage:image tolerance:0.01 threshold:50 levels:3];
        
        dispatch_async( dispatch_get_main_queue(), ^{
           
            [self displayLinesFromArray];
            
            if([self.linesArray count]>0){
               [getConnectionService() uploadPhoto:image cropped:self.cropRectangle];
            }
        });
        self.fpsCaptureRate = 0;
        
    } else {
        self.fpsCaptureRate++;
    }

    
}

-(void) renderRectangles:(NSArray*) pointsArray{
    self.linesArray = [NSMutableArray new];
    self.rectangleArray = [NSMutableArray new];

    if([pointsArray count]%4==0 && [pointsArray count]>=4){
        for(int i = 0; i< [pointsArray count]; i+=4){
            //points are detected randomly. those top,left,right names mean nothing
            Line *top = [Line new];
            Line *left = [Line new];
            Line *bot = [Line new];
            Line *right = [Line new];
            
            top.start = [self scalePoint:[[pointsArray objectAtIndex:i] CGPointValue]];
            top.end = [self scalePoint:[[pointsArray objectAtIndex:i+1] CGPointValue]];

            right.start = [self scalePoint:[[pointsArray objectAtIndex:i+1] CGPointValue]];
            right.end = [self scalePoint:[[pointsArray objectAtIndex:i+2]CGPointValue]];
            
            bot.start = [self scalePoint:[[pointsArray objectAtIndex:i+2] CGPointValue]];
            bot.end = [self scalePoint:[[pointsArray objectAtIndex:i+3] CGPointValue]];
            
            left.start = [self scalePoint:[[pointsArray objectAtIndex:i+3]CGPointValue]];
            left.end = [self scalePoint:[[pointsArray objectAtIndex:i] CGPointValue]];
            BOOL allInScreen = NO;
            if(CGRectContainsPoint(self.cameraView.frame, top.start) && CGRectContainsPoint(self.cameraView.frame, top.end)&& CGRectContainsPoint(self.cameraView.frame, left.start) && CGRectContainsPoint(self.cameraView.frame, left.end) && CGRectContainsPoint(self.cameraView.frame, bot.start) && CGRectContainsPoint(self.cameraView.frame, bot.end) && CGRectContainsPoint(self.cameraView.frame, right.start) && CGRectContainsPoint(self.cameraView.frame, right.end)){
                allInScreen = YES;
            }
                
            if(allInScreen){
                NSMutableArray *rectangle = [NSMutableArray new];
                
                [rectangle addObject:top];
                [rectangle addObject:left];
                [rectangle addObject:bot];
                [rectangle addObject:right];
                int smallestX =self.cameraView.frame.size.width;
                int biggestX =0;
                int smallestY = self.cameraView.frame.size.height;
                int biggestY =0;
                for(Line *l in rectangle){
                    if(l.start.x < smallestX)
                        smallestX = l.start.x;
                    
                    if(l.start.x>biggestX)
                        biggestX = l.start.x;
                    
                    if(l.start.y < smallestY)
                        smallestY = l.start.y;
                    if(l.start.y > biggestY)
                        biggestY = l.start.y;
                    
                }
                
                int checkRatio = (biggestX-smallestX)/(biggestY-smallestY);
                int diff = kPerfectPlateRatio - checkRatio;
                
                if(diff <3 && diff > -3){
                    Line *topLine = [Line new];
                    Line *botLine = [Line new];
                    Line *leftLine = [Line new];
                    Line *rightLine = [Line new];
                    
                    topLine.start = CGPointMake(smallestX, smallestY);
                    
                    topLine.end = CGPointMake(biggestX,smallestY);
                    
                    botLine.start = CGPointMake(smallestX, biggestY);
                    botLine.end = CGPointMake(biggestX, biggestY);
                    
                    leftLine.start = topLine.start;
                    leftLine.end = botLine.start;
                    
                    rightLine.start = topLine.end;
                    rightLine.end = botLine.end;
                    
                    //rectangle has addded safety space
                    self.cropRectangle = CGRectMake([self scalePoint:topLine.start].x,[self scalePoint:topLine.start].y, [self scalePoint:botLine.end].x, [self scalePoint:botLine.end].y);
                    
                    [self.linesArray addObject:topLine];
                    [self.linesArray addObject:botLine];
                    [self.linesArray addObject:rightLine];
                    [self.linesArray addObject:leftLine];
                     break;
                }
            }
        }
    }
}

-(CGPoint) scalePoint:(CGPoint) point {
    float imageSizeX = self.calculatedImage.size.width;
    float imageSizeY = self.calculatedImage.size.height;
    float screenSizeX = self.cameraView.frame.size.width;
    float screenSizeY = self.cameraView.frame.size.height;
    
    float scaleX = screenSizeX/imageSizeX;
    float scaleY = screenSizeY/imageSizeY;
    
    point.x*=scaleX;
    point.y*=scaleY;
    return point;
}

-(void) displayLinesFromArray {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [self.reconColor CGColor];
    shapeLayer.lineWidth = 3.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    shapeLayer.path = [[self setupLinesPath:path] CGPath];
    
    for(CAShapeLayer *lay in [self.judgerView.layer sublayers]){
        [lay removeFromSuperlayer];
    }
    [self.judgerView.layer addSublayer:shapeLayer];
    self.calculatedPreviousFrame = YES;
}

-(UIBezierPath*) setupLinesPath: (UIBezierPath*) path {
    [self.plateLabel removeFromSuperview];
    if([self.linesArray count] >0){
        if(self.reconPlate){
            Line *top = [self.linesArray objectAtIndex:0];
            self.plateLabel = [[UILabel alloc ] init];
            self.plateLabel.frame = CGRectMake(top.start.x, top.start.y-30, 280, 40);
            self.plateLabel.text = self.reconPlate;
            self.plateLabel.numberOfLines = 2;
            self.plateLabel.textColor = [UIColor yellowColor];
            [self.cameraView addSubview:self.plateLabel];
            self.reconPlate = @"";
        }
        for(Line *line in self.linesArray){
            UIBezierPath *newPath = [UIBezierPath new];
            [newPath moveToPoint:line.start];
            [newPath addLineToPoint:line.end];
            [path appendPath:newPath];
        }
    }
    return path;
}


-(int) calculateOptimalCaptureTime {
    int pingTime = [getConnectionService() pingServer];
    return pingTime;
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}
-(void)setSession:(AVCaptureSession *)session
{
    NSLog(@"setting session...");
    _session=session;
}

- (IBAction)swipeDown:(id)sender {
    [getConnectionService() uploadJudge:nil];
}
- (IBAction)swipeUp:(id)sender {
    [getConnectionService() uploadJudge:nil];
}


@end
