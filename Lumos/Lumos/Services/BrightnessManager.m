//
//  BrightnessManager.m
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "BrightnessManager.h"

#define BRIGHTNESS_STEP 10

@interface BrightnessManager()

@property (nonatomic, strong) DisplayManager *displayManager;

@end

@implementation BrightnessManager

- (void)setDisplayManager:(DisplayManager *)displayManager {
    _displayManager = displayManager;
}

- (void)setBrightnessTo:(int)value {
    NSArray<HardwareDisplay *> *allDisplays = [self.displayManager getDisplays];

    for (HardwareDisplay *display in allDisplays) {
        if (display.controlEnabled) {
            [display setBrightnessTo:value];
        }
    }
}

- (void)increaseBrightness {
    NSArray<HardwareDisplay *> *allDisplays = [self.displayManager getDisplays];

    for (HardwareDisplay *display in allDisplays) {
        if (display.controlEnabled) {
            [display changeBrightnessBy:BRIGHTNESS_STEP];
        }
    }
}

- (void)decreaseBrightness {
    NSArray<HardwareDisplay *> *allDisplays = [self.displayManager getDisplays];

    for (HardwareDisplay *display in allDisplays) {
        if (display.controlEnabled) {
            [display changeBrightnessBy:-BRIGHTNESS_STEP];
        }
    }
}

#pragma mark DisplayManagerDelegate

- (void)displayManager:(DisplayManager *)manager didTrackBrightnessChangeTo:(UInt8)newValue {
    NSLog(@"Setting external display brightness to %u", newValue);
    [self setBrightnessTo:newValue];
}

@end
