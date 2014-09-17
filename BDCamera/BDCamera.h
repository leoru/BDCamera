//
//  BDCamera.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol BDCameraDelegate <NSObject>

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error;

@end

@interface BDCamera : NSObject

/*
 This contexts will be used for live previews
 */
@property (nonatomic, strong, readonly) CIContext *ciContext;
@property (nonatomic, strong, readonly) EAGLContext *eaglContext;

/*
    Every item in this array should be BDLivePreview for render live preview
 */
@property (nonatomic, strong) NSMutableArray *displayedPreviews;

@property (nonatomic, strong, readonly) AVCaptureMovieFileOutput *fileOutput;
@property (nonatomic, strong, readonly) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, strong, readonly) AVCaptureDevice *videoDevice;

/*
 You can change orientation of output
 */
@property (nonatomic, assign) UIInterfaceOrientation outputImageOrientation;

/*
 Support of video zooming.
 Zoom can't be more than of videoDevice.activeFormat.videoMaxZoomFactor
 */
@property (nonatomic, assign) CGFloat zoom;

/*
 You can change videoGravity of previewLayer
 */
@property (nonatomic, strong) NSString *videoGravity;

/*
 Detect if camera is recodning now
 */
@property (nonatomic, readonly) BOOL isRecording;

@property (nonatomic, weak) id<BDCameraDelegate> videoDelegate;

/*
 Initializers
 */
- (instancetype)initWithPreviewView:(UIView *)previewView preset:(NSString *)capturePreset;
- (instancetype)initWithPreviewView:(UIView *)previewView;


/*
 Video Capture connection
 */
- (AVCaptureConnection *)videoCaptureConnection;

/*
 Enable delegate for capturing sample buffer and output to live previews
 */
- (void)captureSampleBuffer:(BOOL)capture;


/*
 Toggle content gravity of previewLayer
 */
- (void)toggleContentsGravity;


/*
 Reset FPS to default
 */
- (void)resetToDefaultFormat;

/*
 Switching of video recording FPS
 */
- (void)switchFPS:(CGFloat)desiredFPS;

/*
 Start recording with giver url
 */
- (void)startRecordingWithURL:(NSURL *)url;

/*
 Stop recording
 */
- (void)stopRecording;

/* 
 Stop capturing
 */
- (void)stopCameraCapture;

/*
 Start capturing
 */
- (void)startCameraCapture;

/*
 You can rotate camera, back of front
 */
- (void)rotateCamera;

@end
