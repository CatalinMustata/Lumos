//
//  DisplayManager.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "DisplayManager.h"
#import <AppKit/NSScreen.h>

@interface DisplayManager()

@property (nonatomic, strong) NSMutableArray *displays;

@property (nonatomic, assign) io_service_t lidDisplay;

@end

@implementation DisplayManager

- (instancetype)init {
    if (self = [super init]) {
        _displays = [[NSMutableArray alloc] initWithCapacity:3]; //who has more than 3 external displays, really?
        [self getLidDisplay];
        [self getExternalDisplays];
    }

    return self;
}

- (void)dealloc {
    IOObjectRelease(_lidDisplay);
}

- (NSArray *)getDisplays {
    return [self.displays copy];
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
