//
//  HardwareDisplay.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "HardwareDisplay.h"

@interface HardwareDisplay()

@property (nonatomic, assign) CGDirectDisplayID displayID;
@property (nonatomic, assign) NSString *EDID;

@end

@implementation HardwareDisplay

- (instancetype)initWithDisplayID:(CGDirectDisplayID)displayID size:(NSSize)size highDPI:(BOOL)highDPI rotation:(int)rotation {
    if (self = [super init]) {
        _displayID = displayID;
        _size = size;
        _isHighDPI = highDPI;
        _rotation = rotation;

        [self queryForHWDetails];
    }

    return self;
}

#pragma mark - Private

- (void)queryForHWDetails {

}

@end
