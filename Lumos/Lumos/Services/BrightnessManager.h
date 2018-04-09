//
//  BrightnessManager.h
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DisplayManager.h"

@interface BrightnessManager : NSObject

- (void)setDisplayManager:(DisplayManager *)displayManager;

- (void)increaseBrightness;
- (void)decreaseBrightness;

- (void)setBrightnessTo:(int)value;

@end
