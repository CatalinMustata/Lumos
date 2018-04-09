//
//  GlobalShortcut.m
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "GlobalShortcut.h"

static int hotkeyID = 0;

@interface GlobalShortcut()

@property (nonatomic, assign) int hotkeyID;

@property (nonatomic, copy) shortcutHandler handler;


@end

@implementation GlobalShortcut

- (instancetype)initWithKey:(int)key modifiers:(int)modifiers handler:(shortcutHandler)handler {
    if (self = [super init]) {
        _keyCode = key;
        _modifiers = modifiers;
        _handler = handler;
        _hotkeyID = ++hotkeyID;
    }

    return self;
}

- (int)getHotkeyID {
    return _hotkeyID;
}

- (void)execute {
    if (!self.handler) return;

    self.handler();
}

@end
