//
//  CameraViewController.m
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
#import "CameraViewController.h"
#import "GPUImage.h"
#import "UIImage+Binarization.h"
#import "ConnectionService.h"
#import "JudgerView.h"
#import "LicensePlate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "Line.h"

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

@property (strong,nonatomic) NSMutableArray *intersectedLines;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDownGesture;
- (IBAction)swipeDown:(id)sender;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUpGesture;

- (IBAction)swipeUp:(id)sender;

@property GLfloat* slopeAndIntercepts;
@property int fpsCaptureRate;
@property int numberOfCapturedFrames;
@property BOOL calculatedPreviousFrame;

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
    
    self.cameraView.transform = CGAffineTransformMakeScale(1.12, 1.0);
    
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
    session.sessionPreset = AVCaptureSessionPreset640x480;
    
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
        UIImage *image =[UIImage imageWithCGImage:sourceImage.CGImage scale:sourceImage.scale orientation:UIImageOrientationDown];
        self.numberOfCapturedFrames++;
        
        GPUImageHoughTransformLineDetector *lineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
        
#warning CHANGE TO SET THRESHOLD
        lineDetector.lineDetectionThreshold = 0.2;
        lineDetector.edgeThreshold = 0.9;
        
        lineDetector.linesDetectedBlock = ^(GLfloat *linesArray, NSUInteger numberOfLines, CMTime timeFrame){
            [self renderLinesFromArray:linesArray count:numberOfLines frameTime:timeFrame];
            NSLog(@"Number of lines %lu", (unsigned long)numberOfLines);
        };
        
        [lineDetector imageByFilteringImage:[UIImage grayImage:image]];
        
        //crop the rect area
        //crop mock
        //CGRect cropRect = CGRectMake(100,100,400,400);
        //CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        // or use the UIImage wherever you like
        // UIImage *cropped= [UIImage imageWithCGImage:imageRef];
        // CGImageRelease(imageRef);
        
        //send it
        dispatch_async( dispatch_get_main_queue(), ^{
            [self displayLinesFromArray];
            [getConnectionService() uploadPhoto:image];
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

- (void)renderLinesFromArray:(GLfloat *)lineSlopeAndIntercepts count:(NSUInteger)numberOfLines frameTime:(CMTime)frameTime;
{
    self.linesArray = [[NSMutableArray alloc] init];
    self.calculatedPreviousFrame = NO;
    
    if (lineCoordinates == NULL)
    {
        [self generateLineCoordinates];
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.overviewLayer = [[CALayer alloc] init];
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 1.0;
    
    NSUInteger currentLineIndex = 0;
    NSUInteger maxLineIndex = numberOfLines *2;
    while(currentLineIndex < maxLineIndex)
    {
        GLfloat slope = lineSlopeAndIntercepts[currentLineIndex++];
        GLfloat intercept = lineSlopeAndIntercepts[currentLineIndex++];
        Line *line = [[Line alloc] init];
        line.slope = slope;
        line.intercept = intercept;
        if (slope > 9000.0)
        {
            line.start = CGPointMake(intercept,-1.0);
            line.end = CGPointMake(intercept,1.0);
        }
        else
        {
            line.start = CGPointMake(-1, slope * -1.0 + intercept);
            line.end = CGPointMake(1, slope * 1.0 + intercept);
        }
        BOOL orientationTestPassed = NO;
        BOOL similarityTestPassed = YES;
        if(![self.linesArray containsObject:line]){
            float tilt = line.start.y - line.end.y;
            if(line.start.y ==-1 && line.end.y == 1){
                orientationTestPassed = YES;
                for(Line *l in self.linesArray){
                    //check if there is a similar line
                    if([[NSString stringWithFormat:@"%.2f", l.intercept] floatValue] == [[NSString stringWithFormat:@"%.2f", line.intercept] floatValue]){
                        similarityTestPassed = NO;
                        break;
                    }
                }
            }
            else if(tilt > -0.2 && tilt < 0.2){
                orientationTestPassed = YES;
                for(Line *l in self.linesArray){
                    //check if there is a similar line, slopes should be checked too
                    if([[NSString stringWithFormat:@"%.2f", l.intercept] floatValue] == [[NSString stringWithFormat:@"%.2f", line.intercept] floatValue]){
                        similarityTestPassed = NO;
                        break;
                    }
                }
            }
            
            if(orientationTestPassed && similarityTestPassed)
                [self.linesArray addObject:line];
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
    for(Line *line in detectedLines){
        [line rescale:self.view.frame];
        UIBezierPath *newPath = [UIBezierPath new];
        [newPath moveToPoint:line.start];
        [newPath addLineToPoint:line.end];
        [path appendPath:newPath];
    }
    return path;
}

-(NSArray*) detectRectangles: (NSMutableArray*) lineArray {
    
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
    
    NSMutableArray *rectangleLines = [NSMutableArray new];
    
    for(int i = 0; i < [rectanglePoints count]; i++){
        Line *rectLine = [Line new];
        if(i%2==0)
            rectLine.start = [rectanglePoints[i] CGPointValue];
        else
            rectLine.end = [rectanglePoints[i] CGPointValue];
        [rectangleLines addObject:rectLine];
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
