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
#import "JudgerView.h"
#import "LicensePlate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "Line.h"
#import "CVSquaresWrapper.h"
#import "UIImage+fixOrientation.h"
@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *judgerView;
@property (strong, nonatomic) IBOutlet UIView *gestureView;

@property (weak, nonatomic) IBOutlet UILabel *status;


@property (strong,nonatomic) AVCaptureSession *session;

@property (strong,nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic) CALayer *overviewLayer;

@property (strong,nonatomic) ConnectionService *connectionService;
@property (strong,nonatomic) LicensePlate *recievedLicensePlate;
@property (strong,nonatomic) JudgerView *judgerFrameView;

@property (strong,nonatomic) NSMutableArray *linesArray;
@property (strong,nonatomic) NSMutableArray *verticalLineArray;
@property (strong,nonatomic) NSMutableArray *horizontalLineArray;

@property (strong,nonatomic) NSMutableArray *intersectedLines;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDownGesture;
- (IBAction)swipeDown:(id)sender;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUpGesture;

- (IBAction)swipeUp:(id)sender;

@property GLfloat* slopeAndIntercepts;
@property int fpsCaptureRate;
@property int numberOfCapturedFrames;
@property BOOL calculatedPreviousFrame;

@property (strong,nonatomic) UIImage* catchedImage;

@end

@implementation CameraViewController


-(void)viewDidLoad {
    
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
    
    BOOL connected = [getConnectionService() connect];
    if(connected)
        self.connectionStatusLabel.text = @"Connected";
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AVCaptureConnection *previewLayerConnection=self.previewLayer.connection;
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
}

- (void) receiveConnectionStatus:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ConnectionStatus"])
    {
        self.connectionStatusLabel.text = @"Connection refused";
    } else {
        self.connectionStatusLabel.text = @"Notification unrecognized";
    }
}

- (void) receiveJudgeNotification:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    NSData *recognizedData = [userInfo objectForKey:@"JudgeData"];
    LicensePlate *detectedPlate = [LicensePlate mapJudgePlate:recognizedData];
    [self plateSetup:(LicensePlate*) detectedPlate];
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
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
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
    // Create a UIImage from the sample buffer data
    if(self.fpsCaptureRate==[self calculateOptimalCaptureTime] && self.calculatedPreviousFrame){
        
        //This image is still flipped
        UIImage *sourceImage =[self imageFromSampleBuffer:sampleBuffer];
        UIImage *image =[UIImage imageWithCGImage:sourceImage.CGImage scale:sourceImage.scale orientation:UIImageOrientationUpMirrored];

        self.numberOfCapturedFrames++;
        
        CVSquaresWrapper *wrap = [[CVSquaresWrapper alloc] init];
        wrap.rectanglesDetectedBlock = ^(NSArray* pointsArray) {
            [self renderRectangles:pointsArray];
        };
        
        [wrap squaresInImage:image tolerance:0.01 threshold:50 levels:11];
        

        dispatch_async( dispatch_get_main_queue(), ^{
            [self displayLinesFromArray];
            //[getConnectionService() uploadPhoto:image];
        });
        self.fpsCaptureRate = 0;
        
    } else {
        self.fpsCaptureRate++;
    }
}
- (void)generateLineCoordinates;
{
    lineCoordinates = calloc(1024 * 4, sizeof(GLfloat));
}

-(void) renderRectangles:(NSArray*) pointsArray{
    self.linesArray = [NSMutableArray new];
    //podzielic na cztery
    if([pointsArray count]%4==0){
        for(int i = 0; i< [pointsArray count]; i+=4){
            Line *top = [Line new];
            Line *left = [Line new];
            Line *bot = [Line new];
            Line *right = [Line new];
            top.start = [[pointsArray objectAtIndex:i] CGPointValue];
            top.end = [[pointsArray objectAtIndex:i+1] CGPointValue];
            left.start = [[pointsArray objectAtIndex:i+1] CGPointValue];
            left.end = [[pointsArray objectAtIndex:i+2]CGPointValue];
            bot.start = [[pointsArray objectAtIndex:i+2] CGPointValue];
            bot.end = [[pointsArray objectAtIndex:i+3] CGPointValue];
            right.start = [[pointsArray objectAtIndex:i+3]CGPointValue];
            right.end = [[pointsArray objectAtIndex:i] CGPointValue];
            BOOL allInScreen = NO;
            if(CGRectContainsPoint(self.cameraView.frame, top.start) && CGRectContainsPoint(self.cameraView.frame, top.end)&& CGRectContainsPoint(self.cameraView.frame, left.start) && CGRectContainsPoint(self.cameraView.frame, left.end) && CGRectContainsPoint(self.cameraView.frame, bot.start) && CGRectContainsPoint(self.cameraView.frame, bot.end) && CGRectContainsPoint(self.cameraView.frame, right.start) && CGRectContainsPoint(self.cameraView.frame, right.end)){
                allInScreen = YES;
            }
                
            if(allInScreen){
                [self.linesArray addObject:top];
                [self.linesArray addObject:left];
                [self.linesArray addObject:bot];
                [self.linesArray addObject:right];
            }
        }
    }
}


-(void) displayLinesFromArray {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    shapeLayer.path = [[self setupLinesPath:path] CGPath];
    
    for(CAShapeLayer *lay in [self.judgerView.layer sublayers]){
        [lay removeFromSuperlayer];
    }
    [self.judgerView.layer addSublayer:shapeLayer];
    self.calculatedPreviousFrame = YES;
}

-(UIBezierPath*) setupLinesPath: (UIBezierPath*) path {
    NSArray *detectedLines = [self detectRectangles:[self.linesArray copy]];
    NSLog(@"Number of drawn lines %lu", (unsigned long)[detectedLines count]);
    for(Line *line in detectedLines){
        UIBezierPath *newPath = [UIBezierPath new];
        [newPath moveToPoint:line.start];
        [newPath addLineToPoint:line.end];
        [path appendPath:newPath];
    }
    return path;
}

-(NSArray*) detectRectangles: (NSMutableArray*) lineArray {
  
    NSLog(@"We got %lu lines", (unsigned long)[lineArray count]);
    
    NSMutableArray *rectanglePoints = [NSMutableArray new];
    for(Line *l in lineArray){
        for(Line *k in lineArray){
            if(![l isEqual:k]){
                NSValue *intersectionPoint = [Line intersectionOfLineFrom:l.start to:l.end withLineFrom:k.start to:k.end];
                if(intersectionPoint)
                    [rectanglePoints addObject:intersectionPoint];
            }
        }
    }

  
    return lineArray;
}




-(void) plateSetup:(LicensePlate*) detectedPlate {
    [self.judgerFrameView removeFromSuperview];
    if(detectedPlate){
        self.judgerFrameView = [[JudgerView alloc] initWithLicensePlate: detectedPlate];
        [self.judgerView addSubview:self.judgerFrameView];
    } else {
        self.judgerFrameView = [[JudgerView alloc] init];
        [self.judgerView addSubview:self.judgerFrameView];
    }
}

-(int) calculateOptimalCaptureTime {
    //  int pingTime = [getConnectionService() pingServer];
    return 30;
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
    CGPoint point = [sender locationInView:self.view];
    if(CGRectContainsPoint(self.judgerFrameView.frame, point) && self.recievedLicensePlate){
        //judge
    }
}
- (IBAction)swipeUp:(id)sender {
    CGPoint point = [sender locationInView:self.view];
    if(CGRectContainsPoint(self.judgerFrameView.frame, point) && self.recievedLicensePlate){
        //judge
    }
}


@end
