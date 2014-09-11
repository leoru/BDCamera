//
//  BDVideoCameraViewController.m
//
//  Created by Kirill Kunst.
//  Copyright (c) 2014 Borodutch Studio. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "BDVideoCameraViewController.h"
#import "BDVideoCameraView.h"
#import "BDCameraBottomView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BDVideoCameraViewController () <BDCameraBottomViewDelegate, BDVideoCameraViewDelegate>

@property (weak, nonatomic) IBOutlet BDVideoCameraView *videoCameraView;
@property (nonatomic, strong) BDCameraBottomView *bottomView;

@end

@implementation BDVideoCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoCameraView.delegate = self;
    
    self.bottomView = [BDCameraBottomView bottomView];
    self.bottomView.delegate = self;
    CGRect frame = self.bottomView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - self.bottomView.frame.size.height;
    self.bottomView.frame = frame;
    [self.bottomView.actionButton setTitle:@"Start record" forState:UIControlStateNormal];
    
    [self.view addSubview:self.bottomView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showSuccessAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your video saved to your library" delegate:nil cancelButtonTitle:@"Good job" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - BottomView Delegate -
- (void)cameraBottomViewActionClickAction
{
    if (self.videoCameraView.isRecorning == NO) {
        [self.videoCameraView startRecording];
        [self.bottomView.actionButton setTitle:@"Stop record" forState:UIControlStateNormal];
    } else {
        [self.videoCameraView stopRecording];
        [self.bottomView.actionButton setTitle:@"Start record" forState:UIControlStateNormal];
    }
}

- (void)cameraBottomViewActionZoomIn
{
    self.videoCameraView.camera.zoom = 1.5f;
}

- (void)cameraBottomViewActionZoomOut
{
    self.videoCameraView.camera.zoom = 1.0f;
}

#pragma mark - BDVideoCameraViewDelegate - 
- (void)finishRecordningVideoForURL:(NSURL *)url
{
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [self showSuccessAlert];
    }];
}

@end
