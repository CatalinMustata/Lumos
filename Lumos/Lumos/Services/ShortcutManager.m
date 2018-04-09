//
//  ShortcutManager.m
//  Lumos
//
//  Created by Catalin Mustata on 09/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//
#import <Carbon/Carbon.h>

#import "ShortcutManager.h"

static OSStatus hotKeyEventHandler(EventHandlerCallRef handlerCall, EventRef event, void *shortcutManager);

#pragma mark - Shortcut Manager

@interface ShortcutManager()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GlobalShortcut *> *shortcuts;

- (void)handleShortcutEvent:(int)shortcutID;

@end

@implementation ShortcutManager

- (instancetype)init {
    if (self = [super init]) {
        _shortcuts = [[NSMutableDictionary alloc] init];
        [self initGlobalHandler];
    }

    return self;
}

- (void)registerShortcut:(GlobalShortcut * _Nonnull)shortcut {
    EventHotKeyRef hotkeyRef; //at one point, we'll need to store these, if we want customizable shortcuts
    OSStatus err;

    EventHotKeyID hotkeyID = { .signature='LUMO', .id = [shortcut getHotkeyID]};

    err = RegisterEventHotKey((unsigned int)shortcut.keyCode,
                              (unsigned int)shortcut.modifiers,
                              hotkeyID,
                              GetEventDispatcherTarget(),
                              kEventHotKeyNoOptions,
                              &hotkeyRef);

    if (!err) {
        [self.shortcuts setObject:shortcut forKey:@([shortcut getHotkeyID])];
    }
}

- (void)handleShortcutEvent:(int)shortcutID {
    GlobalShortcut *shortcut = [self.shortcuts objectForKey:@(shortcutID)];

    [shortcut execute];
}

#pragma mark Private

- (void)initGlobalHandler {
    EventTypeSpec typeSpec;
    typeSpec.eventClass = kEventClassKeyboard;
    typeSpec.eventKind  = kEventHotKeyPressed;
    InstallApplicationEventHandler(&hotKeyEventHandler, 1, &typeSpec, (__bridge void*)self, NULL);
}

@end

#pragma mark - Callback handler

static OSStatus hotKeyEventHandler(EventHandlerCallRef handlerCall, EventRef event, void *shortcutManager)
{
    EventHotKeyID hotkeyID;
    OSStatus err = GetEventParameter(event,
                                     kEventParamDirectObject,
                                     typeEventHotKeyID,
                                     NULL,
                                     sizeof(EventHotKeyID),
                                     NULL,
                                     &hotkeyID);

    if(!err) {
        [((__bridge ShortcutManager *)shortcutManager) handleShortcutEvent:hotkeyID.id];
    }

    return noErr;
}
