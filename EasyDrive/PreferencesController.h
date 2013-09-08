//
//  PreferencesController.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 07/07/12.
//  Copyright (c) 2012 7 Steps to Happines. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Preferences.h"

@interface PreferencesController : NSWindowController {
    @private
    
    NSUserDefaults* userDef;
    
    BOOL startsOnLogin;
    
    IBOutlet NSWindow *window;
    IBOutlet NSButton* okButton;
    IBOutlet NSButton* cancelButton;
    IBOutlet NSPopUpButton* appLocationPopUpButton;
    IBOutlet NSPopUpButton* notificationsPopUpButton;
    IBOutlet NSButton* openAtLoginCheckbox;
}

- (IBAction) okButtonClick:(id) sender;
- (IBAction) cancelButtonClick:(id) sender;
- (IBAction) openAtLoginChecking:(id) sender;


- (void) showPreferences;
- (void) setLocationComboBoxWithLocation:(appLocation) loc;
- (void) updatePreferencesWindow;

@end
