//
//  BDLivePreview.m
//  BDCameraExample
//
//  Created by Kirill Kunst on 11.09.14.
//  Copyright (c) 2014 Borodutch LLC. All rights reserved.
//

#import "BDLivePreview.h"

@implementation BDLivePreview

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.enableSetNeedsDisplay = NO;
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        [self bindDrawable];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
            self.transform = transform;
            self.frame = frame;
        });
    }
    return self;
}

@end
