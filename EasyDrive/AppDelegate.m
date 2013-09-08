//
//  AppDelegate.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 14/07/12.
//  Copyright (c) 2012 Kyro Corp. All rights reserved.
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
    
    [self deduplicateRunningInstances];
}

- (void)deduplicateRunningInstances {
	if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
		[[NSAlert alertWithMessageText:NSLocalizedString(@"DeduplicateMessageText", @"") 
                         defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"DeduplicateInformativeText", @"")] runModal];
        
		[NSApp terminate:nil];
	}
}


- (NSMenu*) applicationDockMenu: (id) sender; {     
    return mainController.contextualDockMenu;
}


- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{    
    CGPoint position;
    CGSize size;
    [AccessibilityUtilities dockIconIsAt:(CGPoint*) &position withSize: (CGSize*) &size];
    CGPoint mouseLoc = (CGPoint) [NSEvent mouseLocation]; //get current mouse position
    CGRect screenRect = [[NSScreen mainScreen] frame];
    CGFloat screenHeight = screenRect.size.height;
    
    mouseLoc.y = screenHeight - mouseLoc.y;
    bool clickOnIcon = CGRectContainsPoint(CGRectMake(position.x, position.y, size.width, size.height) ,mouseLoc);
    
    if(! clickOnIcon) {
        //Not on dock => called from .app
        return false;
    }
    
    NSTimeInterval interval = [mainController.lastDockMenuClose timeIntervalSinceNow];
    if(-interval > 0.2) {
      [mainController popUpTheDockMenu];
    }
    return true;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"App Will Terminate");
}


@end