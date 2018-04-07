//
//  DisplayManager.h
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HardwareDisplay.h"

@interface DisplayManager : NSObject

- (NSArray<HardwareDisplay *> *)getDisplays;

@end
