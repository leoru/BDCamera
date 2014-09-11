//
//  BDCameraBottomView.m
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

#import "BDCameraBottomView.h"

@interface BDCameraBottomView()

- (IBAction)actionZoomOut:(id)sender;
- (IBAction)actionZoomIn:(id)sender;

@end

@implementation BDCameraBottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (BDCameraBottomView *)bottomView
{
    BDCameraBottomView *customView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] lastObject];
    if ([customView isKindOfClass:[BDCameraBottomView class]])
        return customView;
    else
        return nil;
}

- (IBAction)actionZoomOut:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomViewActionZoomOut)]) {
        [self.delegate cameraBottomViewActionZoomOut];
    }
}

- (IBAction)actionZoomIn:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomViewActionZoomIn)]) {
        [self.delegate cameraBottomViewActionZoomIn];
    }
}

- (IBAction)actionClickAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomViewActionClickAction)]) {
        [self.delegate cameraBottomViewActionClickAction];
    }
}

@end
