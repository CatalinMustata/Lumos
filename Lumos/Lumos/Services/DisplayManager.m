//
//  DisplayManager.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "DisplayManager.h"
#import <AppKit/NSScreen.h>

#define TRACKING_UPDATE_INTERVAL 2.0f

@interface DisplayManager()

@property (nonatomic, strong) NSMutableArray *displays;

@property (nonatomic, assign) io_service_t lidDisplay;

@property (nonatomic, assign) BOOL autoModeOn;

@property (nonatomic, strong) NSThread *trackingThread;

@end

@implementation DisplayManager

- (instancetype)init {
    if (self = [super init]) {
        _displays = [[NSMutableArray alloc] initWithCapacity:3]; //who has more than 3 external displays, really?
        [self getLidDisplay];
        [self getExternalDisplays];

        _autoModeOn = NO;
    }

    return self;
}

- (void)dealloc {
    IOObjectRelease(_lidDisplay);
}

- (NSArray *)getDisplays {
    return [self.displays copy];
}

#pragma mark - Audo Tracking Mode

- (void)initAutoTrackingThread {
    __weak typeof(self) weakSelf = self;
    self.trackingThread = [[NSThread alloc] initWithBlock:^{
        NSTimer *trackingTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:TRACKING_UPDATE_INTERVAL repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || !strongSelf.isAutoModeOn) {
                [NSThread exit];
            }

            [strongSelf doTracking];
        }];
        [[NSRunLoop currentRunLoop] addTimer:trackingTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }];
}

- (void)doTracking {
    UInt8 mainDisplayBrightness = [self readLidBrightness];

    if (self.delegate) [self.delegate displayManager:self didTrackBrightnessChangeTo:mainDisplayBrightness];
}

- (BOOL)startAutoTrackingMode {
    if (!self.lidDisplay) {
        NSLog(@"No lid display available, cannot start auto mode");
        return NO;
    }

    self.autoModeOn = YES;
    [self initAutoTrackingThread];
    [self.trackingThread start];

    return YES;
}

- (void)stopAutoTrackingMode {
    self.autoModeOn = NO;
    self.trackingThread = nil;
}

- (BOOL)isAutoModeOn {
    return _autoModeOn;
}

#pragma mark Private

- (void)getLidDisplay {
    CFMutableDictionaryRef matching = IOServiceMatching("IODisplayConnect");
    _lidDisplay = IOServiceGetMatchingService(kIOMasterPortDefault, matching);

    if (!_lidDisplay) {
        NSLog(@"Failed to find a MacBook lid display");
    }

    IOObjectRetain(_lidDisplay);
}

- (UInt8)readLidBrightness {
    @synchronized (self) {
        if (!self.lidDisplay) {
            return 0;
        }

        float brightness;
        IODisplayGetFloatParameter(self.lidDisplay, 0, CFSTR(kIODisplayBrightnessKey), &brightness);

        return (UInt8)(brightness * 100);
    }
}

- (void)getExternalDisplays {
    for (NSScreen *screen in NSScreen.screens)
    {
        NSDictionary *description = [screen deviceDescription];
        if ([description objectForKey:NSDeviceIsScreen]) {
            CGDirectDisplayID screenNumber = [[description objectForKey:@"NSScreenNumber"] unsignedIntValue];
            if (CGDisplayIsBuiltin(screenNumber)) continue; // ignore MacBook screens because we're only looking at external displays now

            CGSize displayPhysicalSize = CGDisplayScreenSize(screenNumber); // dspPhySz only valid if EDID present!
            BOOL highDPI = ([screen backingScaleFactor] > 1);
            int rotation = (int)CGDisplayRotation(screenNumber);

            HardwareDisplay *display = [[HardwareDisplay alloc] initWithDisplayID:screenNumber size:displayPhysicalSize highDPI:highDPI rotation:rotation];
            [_displays addObject:display];
        }
    }
}

@end
