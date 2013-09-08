//
//  Preferences.m
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"

// Keys 
NSString* const kStartsOnLogin = @"startsOnLogin";
NSString* const kAppInDock = @"appInDock";
NSString* const kAppInStatusBar = @"appInStatusBar";
NSString* const kNotifAtPluggedIn = @"NotifAtPluggedIn";
NSString* const kNotifAtPluggedOut = @"NotifAtPluggedOut";


@implementation Preferences

+ (void) checkPreferencesIntegrity {
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    if ( !([userDef boolForKey: kAppInDock] && [userDef boolForKey:kAppInStatusBar])) {
        //[userDef setBool:true forKey:kAppInDock];
        //[userDef setBool:true forKey:kAppInStatusBar];
    }
}



#pragma mark Login Item

+ (BOOL)loginItemExistsForPath:(NSString *)appPath {
	BOOL found = NO;  
	UInt32 seedValue;
	CFURLRef thePath = NULL;
    
    LSSharedFileListRef loginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot( loginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {    
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				found = YES;
				break;
			}
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
		}
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
	return found;
}

+ (void)enableLoginItemForPath:(NSString *)appPath {
    LSSharedFileListRef loginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);		
	if (item)
		CFRelease(item);
}

+ (void)disableLoginItemForPath:(NSString *)appPath {
	UInt32 seedValue;
	CFURLRef thePath = NULL;
    LSSharedFileListRef loginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {		
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				LSSharedFileListItemRemove(loginItemsRefs, itemRef); // Deleting the item
			}
			// Docs for LSSharedFileListItemResolve say we're responsible
			// for releasing the CFURLRef that is returned
			if (thePath != NULL) CFRelease(thePath);
		}		
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);
}

#pragma mark lalallala

+ (appLocation) appLocation {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    bool appInDock = [userDef boolForKey:kAppInDock];
    bool appInStatusBar = [userDef boolForKey:kAppInStatusBar];

    
    if (appInDock && ! appInStatusBar) {
        return dock;
    } else if (appInStatusBar && ! appInDock){
        return statusbar;
    } else if (appInDock && appInStatusBar) {
        return bothPositions;
    } else {
        return bothPositions;
    }
}

+ (mountNotifications) mountNotifications {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    bool mountNotif = [userDef boolForKey:kNotifAtPluggedIn];
    bool unmountNotif = [userDef boolForKey:kNotifAtPluggedOut];
    
    if( mountNotif && unmountNotif) {
        return bothNotifications;
    } else if (mountNotif) {
        return mount;
    } else if (unmountNotif) {
        return unmount;
    } else {
        return none;
    }
}


@end
