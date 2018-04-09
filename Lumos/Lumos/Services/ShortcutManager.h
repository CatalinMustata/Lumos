//
//  ShortcutManager.h
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GlobalShortcut.h"

@interface ShortcutManager : NSObject

- (void)registerShortcut:(GlobalShortcut *)shortcut;

@end
