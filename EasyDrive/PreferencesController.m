//
//  PreferencesController.m
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id) init {
    if(self = [super initWithWindowNibName:@"Preferences"]) {
        
        //Close button handles as cancel
        [[self.window standardWindowButton:NSWindowCloseButton] setAction:@selector(cancelButtonClick:)];
        [[self.window standardWindowButton:NSWindowCloseButton] setTarget:self];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
//    [self updatePreferencesWindow];
}

- (void) showPreferences {
    [self updatePreferencesWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
    [NSApp runModalForWindow:self.window];
}

- (void) updatePreferencesWindow {
    [self setLocationComboBoxWithLocation:[Preferences appLocation]];
    [self setNotificationComboWithMountNotifications:[Preferences mountNotifications]];
    
    startsOnLogin = [Preferences loginItemExistsForPath:[[NSBundle mainBundle] bundlePath]];
    if(startsOnLogin) {
        [openAtLoginCheckbox setState:NSOnState];
    } else {
        [openAtLoginCheckbox setState:NSOffState];
    }
}


//Action for the OK button closing the pref window
-(IBAction) okButtonClick:(id)sender {
    [self close];
    [NSApp stopModal];
    
    
    //save the state of the dock position
    //dock position is stored in 2 variables InDock / InStatusBar
    NSInteger index = [appLocationPopUpButton indexOfSelectedItem];
    switch (index) {
        case 0:
            //Dock
            [userDef setBool:true forKey:kAppInDock];
            [userDef setBool:false forKey:kAppInStatusBar];
            break;
        case 1:
            //Status
            [userDef setBool:false forKey:kAppInDock];
            [userDef setBool:true forKey:kAppInStatusBar];
            break;
        case 2:
            //both
            [userDef setBool:true forKey:kAppInDock];
            [userDef setBool:true forKey:kAppInStatusBar];
            break;
        default:
            //both
            [userDef setBool:true forKey:kAppInDock];
            [userDef setBool:true forKey:kAppInStatusBar];
            break;
    }

    index = [notificationsPopUpButton indexOfSelectedItem];
    switch (index) {
        case 0:
            //PluggedIn
            [userDef setBool:true forKey:kNotifAtPluggedIn];
            [userDef setBool:false forKey:kNotifAtPluggedOut];
            break;
        case 1:
            //PluggedOut
            [userDef setBool:false forKey:kNotifAtPluggedIn];
            [userDef setBool:true forKey:kNotifAtPluggedOut];
            break;
        case 2:
            //Both
            [userDef setBool:true forKey:kNotifAtPluggedIn];
            [userDef setBool:true forKey:kNotifAtPluggedOut];
            break;
        case 3:
            //none;
            [userDef setBool:false forKey:kNotifAtPluggedIn];
            [userDef setBool:false forKey:kNotifAtPluggedOut];
            break;
        default:
            //Both
            [userDef setBool:true forKey:kNotifAtPluggedIn];
            [userDef setBool:true forKey:kNotifAtPluggedOut];
            break;
    }
    
    [userDef synchronize];
}


//Cancel what has been done on the preferences and goes back to the previous state
-(IBAction) cancelButtonClick:(id)sender{
    [self close];
    [NSApp stopModal];

    //back to previous options    
    if(startsOnLogin) {
        [Preferences enableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    } else {
        [Preferences disableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    }
}


//Should the app be launched at login ?
- (IBAction) openAtLoginChecking:(id) sender {
    NSInteger state = [openAtLoginCheckbox state];
    if( state == NSOnState) {
        [Preferences enableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    } else if (state == NSOffState) {
        [Preferences disableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    }
}

- (void) setLocationComboBoxWithLocation:(appLocation) loc {
    switch (loc) {
        case dock:
            [appLocationPopUpButton selectItemAtIndex:0];
            break;
        case statusbar:
            [appLocationPopUpButton selectItemAtIndex:1];
            break;
        case bothPositions:
            [appLocationPopUpButton selectItemAtIndex:2];
            break;
        default:
            break;
    }
}

-(void) setNotificationComboWithMountNotifications:(mountNotifications) notif {
    switch (notif) {
        case mount:
            [notificationsPopUpButton selectItemAtIndex:0];
            break;
        case unmount:
            [notificationsPopUpButton selectItemAtIndex:1];
            break;
        case bothNotifications:
            [notificationsPopUpButton selectItemAtIndex:2];
            break;
        case none:
            [notificationsPopUpButton selectItemAtIndex:3];
            break;
        default:
            break;
    }
}

@end
