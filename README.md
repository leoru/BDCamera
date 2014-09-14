<p align="center" >
  <img src="https://raw.githubusercontent.com/Borodutch/BDCamera/master/Images/BDCameraLogo.png" alt="BDCamera" title="BDCamera">
</p>

BDCamera is a simple video and photo camera with AVFoundation.

## Get Started

### Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like AFNetworking in your projects.

#### Podfile
```ruby
platform :ios, '7.0'
pod "BDCamera", "~> 0.1"
```

### Default installation
Drag the BDCamera folder to your project. This library must be ARC enabled.

## Usage
At first import class for photo
```objc
#import "BDStillImageCamera.h"
```
or video
```objc
#import "BDCamera.h"
```

Make property for your camera
```objc
@property (nonatomic, strong) BDStillImageCamera *camera;
// or
@property (nonatomic, strong) BDCamera *camera;
```

Next, all you need is a UIView container in your controller for camera preview layer.
```objc
UIView *cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
self.camera = [[BDStillImageCamera alloc] initWithPreviewView:self preset:AVCaptureSessionPresetPhoto];
//or
self.camera = [[BDCamera alloc] initWithPreviewView:self preset:AVCaptureSessionPreset1280x720];

[self.camera startCameraCapture];

[self.view addSubview:cameraView];
```

### Photo Camera
Make a photo
```objc
[self.camera captureImageWithCompletion:^(UIImage *capturedImage, NSError *error) {
        // your captured image
}];
```

### Video Camera
Video Camera has a delegate that gives you url for your recorded video.
You need to set a videoDelegate for camera.
```objc
  self.camera.videoDelegate = self;
```
Start record video
```objc
NSURL *movieURL = //url for video output file
self.camera startRecordingWithURL:movieURL];
```
Stop recording
```objc
[self.camera stopRecording];
```
Video output will we sended in videoDelegate
```objc
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error
{
    // here you can save your recorded video to Photos, for example.
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [self showSuccessAlert];
    }];
}
```
Examples of using BDCamera included in example project.

## Some useful things
#### Change recording FPS
You can recording slow motion videos with switching output FPS.
Max FPS for iPhone 5 - 60.
Max FPS for iPhone 5S - 120.
iPhone 5S: BDCamera recording video with AVCaptureMovieFileOutput and you can control your slow-motion videos in Photos.
```objc
[self.camera switchFPS:120.f];
```

#### Live previews feed
BDCamera has a functionality of live previews.
```objc
/*
    Every item in this array should be BDLivePreview for render live preview
 */
@property (nonatomic, strong) NSMutableArray *displayedPreviews;
```
BDLivePreview is a subclass of GLKView.
You can create BDLivePreview with videoCamera EAGLContext.
```objc
//You need to enable sample buffer capturing
[self.camera captureSampleBuffer:YES];

// then create preview views
CGRect frame = //some frame
BDLivePreview *preview = [[BDLivePreview alloc] initWithFrame:frame context:self.camera.eaglContext];
self.camera.displayedPreviews addObject:preview];
[self.view addSubview:preview];
```
That's all. 
I have tested BDCamera on 9 live previews.

### Maintainers

- [Kirill Kunst](https://github.com/leoru) ([@kirill_kunst](https://twitter.com/kirill_kunst))

## License

BDCamera is available under the MIT license. See the LICENSE file for more info.