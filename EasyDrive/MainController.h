//
//  MainController.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 09/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>
#import "PreferencesController.h"
#import "Core.h"
#import "DrivesWindow.h"
#import "AccessibilityUtilities.h"
#import "DrivesViewController.h"
#import <Sparkle/SUUpdater.h>

typedef enum {
    left,
    bottom,
    right
} dockposition;


@interface MainController : NSObject <CoreDelegate> {

    DrivesWindow * dw;
    PreferencesController* prefCon;
    Core* core;
    
    NSMenu *_contextualDockMenu, *_statusBarMenu;
    NSStatusItem* statusItem;
    NSMutableArray* iconArray;
    
    appLocation currentAppLocation;
    appLocation previousAppLocation;
    
    @private
    DrivesViewController* viewController;
    
}

@property (readonly) NSMenu* contextualDockMenu;

- (IBAction) showPreferences:(id)sender;
- (IBAction) unmountDevice:(id) sender;
- (IBAction) openDevice:(id) sender;
- (IBAction) openDiskUtility:(id) sender;
- (IBAction) checkUpdates;


- (void) popUpTheDockMenu;
- (void) updateDockIcon;

- (void) updateAppLocation;
- (void) removeStatusBarMenu;
- (void) addStatusBarmenu;

- (void) removeQuitAboutItems;
- (void) addQuitAboutItems;

@end

//@interface NSMenuItem (representedWasUpdated)
//    <DeviceDelegate> {}
//@end