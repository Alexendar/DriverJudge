//
//  CameraViewController.m
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
@import AVFoundation;

#import "CameraViewController.h"

#import "GPUImage.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CameraViewController ()
@property (strong, nonatomic) IBOutlet UIView *cameraView;

//Tracking

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

//Setup? no idea wtf is happening yet

@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (strong, nonatomic) GPUImageVideoCamera* videoCamera;
@property (strong, nonatomic) GPUImageView *filteredVideoView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [self setupCameraStreamWithWidth: screenWidth andHeight: screenHeight];

}

-(void) setupCameraStreamWithWidth: (CGFloat) viewWidth andHeight: (CGFloat) viewHeight {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    
    self.filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, viewHeight)];
    
    [self.cameraView addSubview:self.filteredVideoView];
    
    [self.videoCamera addTarget:self.filteredVideoView];
    
    [self.videoCamera startCameraCapture];
    [self catchPhotos];
}

-(void) catchPhotos {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
      // Dispose of any resources that can be recreated.
}

- (void) drawJudgeRectangle: (CGRect*) detectedPlatesRect {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"JudgerComponent" owner:nil options:nil];
    
    // Find the view among nib contents (not too hard assuming there is only one view in it).
    
    UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    
    swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    
}

- (IBAction)didSwipe:(UISwipeGestureRecognizer*) sender {
    UISwipeGestureRecognizerDirection direction = sender.direction;
    
    if(direction==UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"UP");
    }
    if(direction ==UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"DOWN");
    }
}




@end
