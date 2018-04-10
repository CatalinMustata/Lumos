//
//  HardwareDisplay.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "HardwareDisplay.h"

#import "DDC.h"

@interface HardwareDisplay()

@property (nonatomic, assign) CGDirectDisplayID displayID;
@property (nonatomic, assign) NSString *EDIDserial;

@property (nonatomic, assign) UInt8 maxBrightness;
@property (nonatomic, assign) UInt8 currentBrightness;

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

- (void)changeBrightnessBy:(int)value {
    struct DDCReadCommand readCommand = { 0 };
    readCommand.control_id = BRIGHTNESS;
    NSLog(@"D: querying VCP control: #%u =?", readCommand.control_id);

    if (!DDCRead(self.displayID, &readCommand)) {
        NSLog(@"Failed to read current brightness");
    }

    self.currentBrightness = readCommand.current_value;
    [self setBrightnessTo:readCommand.current_value + value];
}

- (void)setBrightnessTo:(int)targetValue {
    if (self.isAutoManaged && self.currentBrightness == targetValue) return;

    struct DDCWriteCommand writeCommand;
    writeCommand.control_id = BRIGHTNESS;

    if (targetValue > self.maxBrightness) targetValue = self.maxBrightness;
    if (targetValue < 0) targetValue = 0;

    writeCommand.new_value = targetValue;

    NSLog(@"D: setting VCP control #%u => %u", writeCommand.control_id, writeCommand.new_value);
    if (!DDCWrite(self.displayID, &writeCommand)){
        NSLog(@"E: Failed to send DDC command!");
    }

    self.currentBrightness = targetValue;
}

#pragma mark - Private

NSString *EDIDString(char *string)
{
    NSString *temp = [NSString stringWithUTF8String:string]; // [[NSString alloc] initWithBytes:string length:13 encoding:NSASCIIStringEncoding];
    return ([temp rangeOfString:@"\n"].location != NSNotFound) ? [[temp componentsSeparatedByString:@"\n"] objectAtIndex:0] : temp;
}

- (void)queryForHWDetails {
    struct EDID edid = {};
    if (EDIDTest(self.displayID, &edid)) {
        for (union descriptor *des = edid.descriptors; des < edid.descriptors + sizeof(edid.descriptors); des++) {
            switch (des->text.type)
            {
                case 0xFF:
                    NSLog(@"I: got edid.serial: %@", EDIDString(des->text.data));
                    break;
                case 0xFC:
                    _name = EDIDString(des->text.data);
                    NSLog(@"I: got edid.name: %@", _name);
                    break;
            }
        }

        struct DDCReadCommand readCommand = { 0 };
        readCommand.control_id = BRIGHTNESS;
        NSLog(@"D: querying VCP control: #%u =?", readCommand.control_id);

        if (!DDCRead(self.displayID, &readCommand)) {
            NSLog(@"Failed to read current brightness");
        }

        self.currentBrightness = readCommand.current_value;
        self.maxBrightness = readCommand.max_value;
    }
}

@end
