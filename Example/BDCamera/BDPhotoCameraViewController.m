//
//  BDViewController.m
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

#import "BDPhotoCameraViewController.h"
#import "BDCameraBottomView.h"
#import "BDPhotoCameraView.h"

@interface BDPhotoCameraViewController () <BDCameraBottomViewDelegate>

@property (weak, nonatomic) IBOutlet BDPhotoCameraView *cameraView;
@property (nonatomic, strong) BDCameraBottomView *bottomView;

@end

@implementation BDPhotoCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.bottomView = [BDCameraBottomView bottomView];
    self.bottomView.delegate = self;
    CGRect frame = self.bottomView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - self.bottomView.frame.size.height;
    self.bottomView.frame = frame;
    
    [self.view addSubview:self.bottomView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showSuccessAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your photo saved to your photo library" delegate:nil cancelButtonTitle:@"Good job" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - BottomView Delegate - 
- (void)cameraBottomViewActionClickAction
{
    __weak BDPhotoCameraViewController *weakSelf = self;
    [self.cameraView takePhotoWithCompletion:^(UIImage *image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [weakSelf showSuccessAlert];
            });
        });
    }];
}

- (void)cameraBottomViewActionZoomIn
{
    self.cameraView.camera.zoom = 1.5f;
}

- (void)cameraBottomViewActionZoomOut
{
    self.cameraView.camera.zoom = 1.0f;
}

@end
