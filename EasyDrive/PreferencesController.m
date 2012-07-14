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
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    [self updatePreferencesWindow];

}



- (IBAction) showPreferences {
    [self updatePreferencesWindow];
    
    [NSApp runModalForWindow:self.window];
}

- (void) updatePreferencesWindow {
    [self setLocationComboBoxWithLocation:[Preferences appLocation]];
    
    oldStartsOnLogin = [Preferences loginItemExistsForPath:[[NSBundle mainBundle] bundlePath]];
    if(oldStartsOnLogin) {
        [openAtLoginCheckbox setState:NSOnState];
    } else {
        [openAtLoginCheckbox setState:NSOffState];
    }
}


-(IBAction) okButtonClick:(id)sender {
    [self close];
    [NSApp stopModal];
    
    NSInteger index = [appLocationPopUpButton indexOfSelectedItem];
    NSString* loc;
    switch (index) {
        case 0:
            loc= kDock;
            break;
        case 1:
            loc =kStatusBar;
            break;
        case 2:
            loc =kBoth;
            break;
        default:
            loc =kBoth;
            break;
    }
    NSString* appLocation = [userDef objectForKey:kAppLocation];
    if(![appLocation isEqualToString:loc]) {
        [userDef setValue:loc forKey:kAppLocation];
        [userDef synchronize];
    }
}

-(IBAction) cancelButtonClick:(id)sender{
    [self close];
    [NSApp stopModal];

    //back to previous options    
    if(oldStartsOnLogin) {
        [Preferences enableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    } else {
        [Preferences disableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    }
}

- (IBAction) openAtLoginChecking:(id) sender {
    NSInteger state = [openAtLoginCheckbox state];
    if( state == NSOnState) {
        [Preferences enableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    } else if (state == NSOffState) {
        [Preferences disableLoginItemForPath:[[NSBundle mainBundle] bundlePath]];
    }
}


-(IBAction) appLocationPopUpButton:(id)sender {

}

- (void) setLocationComboBoxWithLocation:(appLocation) loc {
    switch (loc) {
        case dock:
            [appLocationPopUpButton selectItemAtIndex:0];
            break;
        case statusbar:
            [appLocationPopUpButton selectItemAtIndex:1];
            break;
        case both:
            [appLocationPopUpButton selectItemAtIndex:2];
            break;
        default:
            break;
    }
}



#pragma mark Misc methods 





@end
