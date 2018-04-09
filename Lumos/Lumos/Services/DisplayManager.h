//
//  DisplayManager.h
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HardwareDisplay.h"

@class DisplayManager;

@protocol DisplayManagerDelegate

- (void)displayManager:(DisplayManager *)manager didTrackBrightnessChangeTo:(UInt8)newValue;

@end

@interface DisplayManager : NSObject

@property (nonatomic, weak) id<DisplayManagerDelegate> delegate;

- (NSArray<HardwareDisplay *> *)getDisplays;

- (BOOL)startAutoTrackingMode;

- (void)stopAutoTrackingMode;

- (BOOL)isAutoModeOn;

@end
