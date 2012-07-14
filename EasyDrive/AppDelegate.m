//
//  AppDelegate.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AXAlertController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"DidFinishLaunching");
    
    //Always checking if AXAPI is enabled at lauching
    if (! AXAPIEnabled()) {
        AXAlertController* ax = [[AXAlertController alloc] init];
        [ax showAlert];  
    }
}


- (NSMenu*) applicationDockMenu: (id) sender; {     
    return mainController.contextualDockMenu;
}


- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    //trick to handle the click on the dock icon reported by the global monitor when the dockmenu is open
    if(mainController.doNotOpenMenu) {
        mainController.doNotOpenMenu = false;
        return true;
    }
    [mainController popUpTheDockMenu];    
    return true;
}

@end