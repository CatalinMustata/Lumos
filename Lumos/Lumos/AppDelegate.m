//
//  AppDelegate.m
//  Lumos
//
//  Created by Catalin Mustata on 07/04/2018.
//  Copyright © 2018 BearSoft. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *appStatusItem;

@property (nonatomic, strong) NSMenu *barMenu;
@property (nonatomic, strong) NSMenuItem *autoModeMenuItem;

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

    self.barMenu = [[NSMenu alloc] init];

    [self.barMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Enable Auto" action:@selector(toggleAutoMode) keyEquivalent:@""]];
    [self.barMenu addItem:NSMenuItem.separatorItem];
    [self.barMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@"q"]];

    self.appStatusItem.menu = self.barMenu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)quit {
    [NSApp terminate:self];
}

- (void)toggleAutoMode {
    [self.barMenu.itemArray.firstObject setState:NSControlStateValueOn];
}


@end
