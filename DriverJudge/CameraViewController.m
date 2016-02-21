//
//  CameraViewController.m
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//
@import AVFoundation;
#import "CameraViewController.h"
#import "AAPLPreviewView.h"
#import "JudgerView.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CameraViewController ()  <AVCaptureFileOutputRecordingDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet
    AAPLPreviewView *previewView;
@property (strong, nonatomic) IBOutlet UIView *overView;

//Tracking

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

//Setup? no idea wtf is happening yet
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect mockRect = CGRectMake(55,55,155,55);
    [self drawJudgeRectangle:&mockRect];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
      // Dispose of any resources that can be recreated.
}

- (void) drawJudgeRectangle: (CGRect*) detectedPlatesRect {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"judgerComponent" owner:nil options:nil];
    
    // Find the view among nib contents (not too hard assuming there is only one view in it).
    
    UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    
    swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    JudgerView* plainView = [nibContents lastObject];
    plainView.frame = *(detectedPlatesRect);
    [plainView addGestureRecognizer:swipeUpRecognizer];
    [plainView addGestureRecognizer:swipeDownRecognizer];
    
    
    [self.view addSubview:plainView];
}


//TO DO Recognize swipe 

-(void) didSwipe: (UISwipeGestureRecognizer*) sender {
    UISwipeGestureRecognizerDirection direction = sender.direction;
    
    if(direction==UISwipeGestureRecognizerDirectionUp) {
        
    }
    if(direction ==UISwipeGestureRecognizerDirectionDown) {
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
