//
//  MainController.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 09/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "PreferencesController.h"
#import "Core.h"

typedef enum {
    left,
    bottom,
    right
} dockposition;


@interface MainController : NSObject <NSMenuDelegate> {
    PreferencesController* prefCon;
    
    NSUserDefaults *userDefaults;
    NSFileManager* fileManager;
    
    Core* core;
    
    NSMenu* _dockMenu, *_contextualDockMenu, *_statusBarMenu;    
    NSStatusItem* statusItem;
    
    bool menuIsOpen;
    bool doNotOpenMenu;
    NSMutableArray* iconArray;   
    
    dockposition dockPosition;
    appLocation currentAppLocation;
    appLocation previousAppLocation;
    
    id monitor; //Global monitor when menu is open
}

@property (readwrite) bool   doNotOpenMenu;
@property (readonly) NSMenu* contextualDockMenu;

- (IBAction) showPreferences:(id)sender;


- (void) unmountDeviceWithPath:(NSString *) path;
- (void) openDriveWithPath:(id) sender;
- (void) popUpTheDockMenu;
- (void) handleGlobalClickAtPoint:(NSPoint) point;
- (void) updateDockIcon;
- (void) watchConfigFile:(NSString*) path;
- (void) readDockPosition;
- (void) openDiskUtility;

- (void) updateAppLocation;
- (void) removeStatusBarMenu;
- (void) addStatusBarmenu;

- (void) removeQuitAboutItems;
- (void) addQuitAboutItems; 

//Accessbility API 
- (BOOL) dockIconIsAt:(CGPoint*) point withSize: (CGSize*) size;
- (NSArray *)subelementsFromElement:(AXUIElementRef)element forAttribute:(NSString *)attribute;
- (AXUIElementRef)appDockIconByName:(NSString *)appName;


@end
