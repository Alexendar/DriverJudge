//
//  CameraViewController.m
//  DriverJudge
//
//  Created by Aleksander on 20/02/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraView.h"
@interface CameraViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cameraView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCamera];
}

- (void) loadCamera {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Took a photo");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
