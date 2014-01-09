//
//  AppDelegate.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 14/07/12.
//  Copyright (c) 2012 Kyro Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "AccessibilityUtilities.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Only allows one instance of the app to be run
    [self deduplicateRunningInstances];
}

- (void)deduplicateRunningInstances {
	if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        //If the app is already running, it kills this current instance
		[[NSAlert alertWithMessageText:NSLocalizedString(@"DeduplicateMessageText", @"")
                         defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"DeduplicateInformativeText", @"")] runModal];
        
		[NSApp terminate:nil];
	}
}

//return the menu to display using the right click on the dock
- (NSMenu*) applicationDockMenu: (id) sender; {     
    return mainController.contextualDockMenu;
}


//When clicking left on the icon on the dock
- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [AccessibilityUtilities isAxApiEnabled];
    
    //retrive the position of the icon on the dock
    CGPoint position;
    CGSize size;
    [AccessibilityUtilities dockIconIsAt:(CGPoint*) &position withSize: (CGSize*) &size];
    
    CGPoint mouseLoc = (CGPoint) [NSEvent mouseLocation]; //get current mouse position
    CGRect screenRect = [[NSScreen mainScreen] frame];
    CGFloat screenHeight = screenRect.size.height;
    mouseLoc.y = screenHeight - mouseLoc.y;
    
    //did I click on the icon in the dock ?
    bool clickOnIcon = CGRectContainsPoint(CGRectMake(position.x, position.y, size.width, size.height) ,mouseLoc);
    
    if(! clickOnIcon) {
        //Not on dock => called from open the .app
        return false;
    }
    
//    NSTimeInterval interval = [mainController.lastDockMenuClose timeIntervalSinceNow];
//    if(-interval > 0.2) {
//      [mainController popUpTheDockMenu];
//    }
    [mainController popUpTheDockMenu];
    
    return true;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"App Will Terminate");
}


@end