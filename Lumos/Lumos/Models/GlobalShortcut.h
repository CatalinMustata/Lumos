//
//  GlobalShortcut.h
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

typedef void(^shortcutHandler)(void);

typedef enum {
    GlobalMinusKey = kVK_ANSI_Minus,
    GlobalPlusKey = kVK_ANSI_Equal,
} ShortcutKey;

typedef enum {
    GlobalControlKey = controlKey,
    GlobalShiftKey = shiftKey,
} ShortcutModifier;

@interface GlobalShortcut : NSObject

@property (nonatomic, assign, readonly) int keyCode;
@property (nonatomic, assign, readonly) int modifiers;

- (instancetype)initWithKey:(int)key modifiers:(int)modifiers handler:(shortcutHandler)handler;

- (int)getHotkeyID;

- (void)execute;

@end
