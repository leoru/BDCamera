//
//  BDVideoCameraView.m
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

#import "BDVideoCameraView.h"

@interface BDVideoCameraView() <BDCameraDelegate>

@end

@implementation BDVideoCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.camera = [[BDCamera alloc] initWithPreviewView:self preset:AVCaptureSessionPreset1280x720];
    self.camera.videoDelegate = self;
    [self.camera startCameraCapture];
}


- (NSURL *)getURLForNewVideo
{
    NSString *videoPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSString *newFilename = [NSString stringWithFormat:@"%@.mov", [[NSUUID UUID] UUIDString]];
    NSString *newFilepath = [NSString stringWithFormat:@"%@%@",videoPath, newFilename];
    unlink([newFilepath UTF8String]);
    return [NSURL fileURLWithPath:newFilepath];
}

#pragma Recorning -
- (void)startRecording
{
    self.recording = YES;
    NSURL *movieURL = [self getURLForNewVideo];
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        [self.camera startRecordingWithURL:movieURL];
    });
}

- (void)stopRecording
{
    self.recording = NO;
    [self.camera stopRecording];
}

#pragma mark - BDVideoCamera Delegate -
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishRecordningVideoForURL:)]) {
        [self.delegate finishRecordningVideoForURL:outputFileURL];
    }
}

@end
