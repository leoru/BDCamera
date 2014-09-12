//
//  BDStillImageCamera.m
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

#import "BDStillImageCamera.h"

@interface BDStillImageCamera()

@property (nonatomic, strong, readwrite) AVCaptureStillImageOutput *photoOutput;

@end

@implementation BDStillImageCamera

- (id)initWithPreviewView:(UIView *)previewView preset:(NSString *)capturePreset
{
    self = [super initWithPreviewView:previewView preset:capturePreset];
    if (self) {
        [self.captureSession beginConfiguration];
        
        self.photoOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
        [self.photoOutput setOutputSettings:outputSettings];
        [self.captureSession addOutput:self.photoOutput];
        
        [self.captureSession commitConfiguration];
    }
    return self;
}

- (AVCaptureConnection *)stillImageConnection
{
    for (AVCaptureConnection *connection in [self.photoOutput connections] ) {
		for (AVCaptureInputPort *port in [connection inputPorts] ) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
				return connection;
			}
		}
	}
    return nil;
}

- (void)setOutputImageOrientation:(UIInterfaceOrientation)outputImageOrientation
{
    [super setOutputImageOrientation:outputImageOrientation];
    AVCaptureConnection *connection = [self stillImageConnection];
    if (connection.isVideoOrientationSupported) {
        AVCaptureVideoOrientation videoOrientation;
        switch (outputImageOrientation) {
            case UIInterfaceOrientationPortrait:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
                
            default:
                break;
        }
        connection.videoOrientation = videoOrientation;
    }
}

- (void)takeImageWithCompletion:(void (^)(UIImage *, NSError *))completion
{
    [self.photoOutput captureStillImageAsynchronouslyFromConnection:[self stillImageConnection]  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completion(image,nil);
        });
    }];
}

@end
