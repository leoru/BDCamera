//
//  BDCamera.m
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

#import "BDCamera.h"
#import <GLKit/GLKit.h>
#import "BDLivePreview.h"

@interface BDCamera() <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong, readwrite) CIContext *ciContext;
@property (nonatomic, strong, readwrite) EAGLContext *eaglContext;

@property (nonatomic, strong, readwrite) AVCaptureSession *captureSession;
@property (nonatomic, strong, readwrite) AVCaptureDevice *videoDevice;

@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong, readwrite) AVCaptureMovieFileOutput *fileOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong, readwrite) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) CMTime defaultVideoMaxFrameDuration;
@property (nonatomic, strong) NSString *capturePreset;
@property (nonatomic, strong) dispatch_queue_t captureSessionQueue;
@property (nonatomic, assign) CMVideoDimensions currentVideoDimensions;

@property (nonatomic, assign) BOOL isFaceCamera;

@end

@implementation BDCamera

#pragma mark - Initialize methods -
- (instancetype)initWithPreviewView:(UIView *)previewView
{
    return [self initWithPreviewView:previewView preset:AVCaptureSessionPresetInputPriority];
}

- (instancetype)initWithPreviewView:(UIView *)previewView preset:(NSString *)capturePreset
{
    self = [self init];
    if (self) {
        [self constructWithView:previewView preset:capturePreset];
    }
    return self;
}

- (void)constructWithView:(UIView *)view preset:(NSString *)capturePreset
{
    self.isFaceCamera = NO;
    NSError *error;
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    self.capturePreset = capturePreset;
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = capturePreset;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    [self.captureSession beginConfiguration];
    if (error) {
        NSLog(@"Video input creation failed");
    }
    
    if (![self.captureSession canAddInput:self.videoInput]) {
        NSLog(@"Video input add-to-session failed");
    }
    
    [self.captureSession addInput:self.videoInput];
    
    self.defaultFormat = self.videoDevice.activeFormat;
    self.defaultVideoMaxFrameDuration = self.videoDevice.activeVideoMaxFrameDuration;
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    [self.captureSession addInput:audioIn];
    
    self.fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.captureSession addOutput:self.fileOutput];
    
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.videoSettings = outputSettings;
    [_captureSession addOutput:self.videoDataOutput];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = view.bounds;
    self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.captureSession commitConfiguration];
    
    [self setupContexts];
}

#pragma mark - For preview copies -
- (void)setupContexts
{
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext
                                           options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
}

- (void)captureSampleBuffer:(BOOL)capture
{
    if (capture) {
        [self.videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    } else {
        [self.videoDataOutput setSampleBufferDelegate:nil queue:_captureSessionQueue];
    }
}

- (AVCaptureConnection *)videoCaptureConnection
{
    for (AVCaptureConnection *connection in [self.fileOutput connections] ) {
		for (AVCaptureInputPort *port in [connection inputPorts] ) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
				return connection;
			}
		}
	}
    return nil;
}

#pragma mark - Rotating Camera -
+ (BOOL)isFrontFacingCameraPresent
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == AVCaptureDevicePositionFront)
			return YES;
	}
	
	return NO;
}

- (BOOL)isFrontFacingCameraPresent
{
    return [[self class] isFrontFacingCameraPresent];
}

- (void)rotateCamera
{
	if (self.isFrontFacingCameraPresent == NO)
		return;
	
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = [self.videoInput.device position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        currentCameraPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == currentCameraPosition)
		{
			backFacingCamera = device;
		}
	}
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    if (newVideoInput != nil)
    {
        [_captureSession beginConfiguration];
        
        [_captureSession removeInput:self.videoInput];
        if ([_captureSession canAddInput:newVideoInput])
        {
            [_captureSession addInput:newVideoInput];
            self.videoInput = newVideoInput;
        }
        else
        {
            [_captureSession addInput:self.videoInput];
        }
        [_captureSession commitConfiguration];
    }
    
    self.videoDevice = backFacingCamera;
    [self setOutputImageOrientation:_outputImageOrientation];
    self.isFaceCamera = !self.isFaceCamera;
}

#pragma mark - Public
- (void)stopCameraCapture
{
    if ([self.captureSession isRunning])
    {
        [self.captureSession stopRunning];
    }
}

- (void)startCameraCapture
{
    if (![self.captureSession isRunning])
	{
		[self.captureSession startRunning];
	};
}

- (void)setVideoGravity:(NSString *)videoGravity
{
    _videoGravity = videoGravity;
    self.previewLayer.videoGravity = videoGravity;
}

- (void)toggleContentsGravity
{
    if ([self.previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)setZoom:(CGFloat)zoom
{
    _zoom = zoom;
    CGFloat maxZoom = self.videoDevice.activeFormat.videoMaxZoomFactor;
    if (zoom < maxZoom) {
        if ([self.videoDevice lockForConfiguration:nil]) {
            self.videoDevice.videoZoomFactor = zoom;
            [self.videoDevice unlockForConfiguration];
        }
    }
}

#pragma mark - FPS Control -
- (void)resetToDefaultFormat
{
    BOOL isRunning = self.captureSession.isRunning;
    if (isRunning) {
        [self.captureSession stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    videoDevice.activeFormat = self.defaultFormat;
    videoDevice.activeVideoMaxFrameDuration = self.defaultVideoMaxFrameDuration;
    [videoDevice unlockForConfiguration];
    
    if (isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)switchFPS:(CGFloat)desiredFPS
{
    BOOL isRunning = self.captureSession.isRunning;
    if (isRunning)  [self.captureSession stopRunning];
    
    AVCaptureDevice *videoDevice = self.videoDevice;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    
    if (isRunning) [self.captureSession startRunning];
}

#pragma mark - Recordning
- (void)startRecordingWithURL:(NSURL *)url
{
    [self.fileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

- (void)stopRecording
{
    [self.fileOutput stopRecording];
}

#pragma mark - Orientation
- (void)setOutputImageOrientation:(UIInterfaceOrientation)outputImageOrientation
{
    _outputImageOrientation = outputImageOrientation;
    [self updateOrientationWithInterfaceOrientation:outputImageOrientation];
}

- (void)updateOrientationWithInterfaceOrientation:(UIInterfaceOrientation)outputImageOrientation
{
    AVCaptureConnection *connection = [self videoCaptureConnection];
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

#pragma mark - CaptureBuffer
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    _currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    
    if (self.isFaceCamera) {
       sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, sourceImage.extent.size.height)];
    }
    
    CGRect sourceExtent = sourceImage.extent;
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    
    for (id view in self.displayedPreviews) {
        BOOL viewIsGLKView = [view isKindOfClass:[BDLivePreview class]] == YES;
        NSAssert(viewIsGLKView, @"[BDCamera] -> Feed view should be GLKView or BDLivePreview");
        
        BDLivePreview *feedView = (BDLivePreview *)view;
        CGFloat previewAspect = feedView.drawableWidth  / feedView.drawableHeight;
        CGRect drawRect = sourceExtent;
        if (sourceAspect > previewAspect) {
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * sourceAspect) / 2.0;
            drawRect.size.width = drawRect.size.height * sourceAspect;
        } else {
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
            drawRect.size.height = drawRect.size.width / previewAspect;
        }
        
        [feedView bindDrawable];
        
        if (_eaglContext != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:_eaglContext];
        }
        
        glClearColor(0.5, 0.5, 0.5, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        if (sourceImage) {
            [_ciContext drawImage:sourceImage inRect:CGRectMake(0, 0, feedView.drawableWidth, feedView.drawableHeight) fromRect:drawRect];
        }
        [feedView display];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    _isRecording = YES;
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    _isRecording = NO;
    
    if ([self.videoDelegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
        [self.videoDelegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
    }
}

#pragma mark - Lazy array property
- (NSMutableArray *)displayedPreviews
{
    if (!_displayedPreviews) {
        _displayedPreviews = [NSMutableArray array];
    }
    return _displayedPreviews;
}

@end
