//
//  PreferencesController.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 07/07/12.
//  Copyright (c) 2012 7 Steps to Happines. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Preferences.h"

@interface PreferencesController : NSWindowController<NSWindowDelegate> {
    @private
    
    NSUserDefaults* userDef;
    
    BOOL oldStartsOnLogin;
    
    
    IBOutlet NSWindow *window;
    IBOutlet NSButton* okButton;
    IBOutlet NSButton* cancelButton;
    IBOutlet NSPopUpButton* appLocationPopUpButton; 
    IBOutlet NSButton* openAtLoginCheckbox;
}

- (IBAction) okButtonClick:(id) sender;
- (IBAction) cancelButtonClick:(id) sender;
- (IBAction) appLocationPopUpButton:(id) sender;
- (IBAction) openAtLoginChecking:(id) sender;
- (IBAction) showPreferences;

//- (appLocation) locationForString:(NSString*) location;
- (void) setLocationComboBoxWithLocation:(appLocation) loc;
- (void) updatePreferencesWindow;

@end
