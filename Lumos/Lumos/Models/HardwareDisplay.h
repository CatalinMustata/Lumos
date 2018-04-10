//
//  HardwareDisplay.h
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HardwareDisplay : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSSize size;
@property (nonatomic, assign, readonly) BOOL isHighDPI;
@property (nonatomic, assign, readonly) int rotation;

@property (nonatomic, assign) BOOL controlEnabled;
@property (nonatomic, assign) BOOL isAutoManaged;

- (instancetype)initWithDisplayID:(CGDirectDisplayID)displayID size:(NSSize)size highDPI:(BOOL)highDPI rotation:(int)rotation;

- (void)changeBrightnessBy:(int)value;

- (void)setBrightnessTo:(int)value;

@end
