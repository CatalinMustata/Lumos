//
//  AppDelegate.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "AppDelegate.h"

#import "DisplayManager.h"
#import "ShortcutManager.h"
#import "BrightnessManager.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *appStatusItem;

@property (nonatomic, strong) NSMenu *barMenu;
@property (nonatomic, strong) NSMenuItem *autoModeMenuItem;

@property (nonatomic, strong) DisplayManager *displayManager;
@property (nonatomic, strong) ShortcutManager *shortcutManager;
@property (nonatomic, strong) BrightnessManager *brightnessManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.appStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    NSStatusBarButton *barButton = self.appStatusItem.button;

    if (!barButton) {
        NSLog(@"Could not create status bar button");
        abort();
    }

    barButton.image = [NSImage imageNamed:@"barButtonIcon"];

    [self checkAccesibility];

    self.displayManager = [[DisplayManager alloc] init];
    self.shortcutManager = [[ShortcutManager alloc] init];

    GlobalShortcut *increaseBrightness = [[GlobalShortcut alloc] initWithKey:GlobalPlusKey modifiers:(GlobalControlKey | GlobalShiftKey) handler:^{
        [self increaseBrightness];
    }];
    GlobalShortcut *decreaseBrightness = [[GlobalShortcut alloc] initWithKey:GlobalMinusKey modifiers:(GlobalControlKey | GlobalShiftKey) handler:^{
        [self decreaseBrightness];
    }];

    [self.shortcutManager registerShortcut:increaseBrightness];
    [self.shortcutManager registerShortcut:decreaseBrightness];

    [self buildMenu];

    self.brightnessManager = [[BrightnessManager alloc] init];
    self.displayManager.delegate = self.brightnessManager;

    self.appStatusItem.menu = self.barMenu;
}

#pragma mark Private

- (BOOL)checkAccesibility {
    NSDictionary *options = @{CFBridgingRelease(kAXTrustedCheckOptionPrompt): @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);

    return accessibilityEnabled;
}

- (void)buildMenu {
    self.barMenu = [[NSMenu alloc] init];

    [self.barMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Enable Auto Mode" action:@selector(toggleAutoMode) keyEquivalent:@""]];

    [self.barMenu addItem:NSMenuItem.separatorItem];
    NSMenuItem *increaseBrightnessItem = [[NSMenuItem alloc] initWithTitle:@"Increase Brightness" action:@selector(increaseBrightness) keyEquivalent:@"="];
    increaseBrightnessItem.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagControl;
    [self.barMenu addItem:increaseBrightnessItem];

    NSMenuItem *decreaseBrightnessItem = [[NSMenuItem alloc] initWithTitle:@"Decrease Brightness" action:@selector(decreaseBrightness) keyEquivalent:@"-"];
    decreaseBrightnessItem.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagControl;
    [self.barMenu addItem:decreaseBrightnessItem];

    [self.barMenu addItem:NSMenuItem.separatorItem];
    NSArray<HardwareDisplay *> *displays = [self.displayManager getDisplays];
    if (displays.count == 0) {
        NSMenuItem *noDisplaysItem = [[NSMenuItem alloc] initWithTitle:@"No external displays" action:nil keyEquivalent:@""];
        noDisplaysItem.enabled = NO;
        [self.barMenu addItem:noDisplaysItem];
    } else {
        for (HardwareDisplay *hwDisplay in displays) {
            NSMenuItem *displayMenuItem = [[NSMenuItem alloc] initWithTitle:hwDisplay.name action:@selector(toggleDisplayControl:) keyEquivalent:@""];
            displayMenuItem.representedObject = hwDisplay;
            [self.barMenu addItem:displayMenuItem];
        }
    }
    [self.barMenu addItem:NSMenuItem.separatorItem];
    [self.barMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""]];
}

- (void)quit {
    [NSApp terminate:self];
}

- (void)toggleAutoMode {
    if (self.displayManager.isAutoModeOn) {
        [self.displayManager stopAutoTrackingMode];
        [self.barMenu.itemArray.firstObject setTitle:@"Enable Auto Mode"];
    } else {
        if ([self.displayManager startAutoTrackingMode]) {
            [self.barMenu.itemArray.firstObject setTitle:@"Disable Auto Mode"];
        }
    }

}

- (void)increaseBrightness {
    NSLog(@"Increasing brightness");
    [self.brightnessManager increaseBrightness];

}

- (void)decreaseBrightness {
    NSLog(@"Decrease brightness");
    [self.brightnessManager decreaseBrightness];
}

- (void)toggleDisplayControl:(NSMenuItem *)sender {
    if (!sender.representedObject || ![sender.representedObject isKindOfClass:[HardwareDisplay class]]) {
        return;
    }

    HardwareDisplay *display = (HardwareDisplay *)sender.representedObject;

    display.controlEnabled = !display.controlEnabled;
    [sender setState:(display.controlEnabled ? NSControlStateValueOn : NSControlStateValueOff)];
}


@end
