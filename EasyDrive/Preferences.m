//
//  Preferences.m
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"

// Keys 
NSString* const kAppLocation = @"appLocation";
NSString* const kStartsOnLogin = @"startsOnLogin";

//Values
NSString* const kBoth = @"both";
NSString* const kDock = @"dock";
NSString* const kStatusBar = @"statusBar";


@implementation Preferences

-(id) init {
    self = [super init]; 
    if (self) {
        
    }
    
    return self;
}

+ (void) checkPreferencesIntegrity {
    NSString* appLocation;
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults]; 
    
    if ((appLocation = [userDef objectForKey: kAppLocation]) && [appLocation isKindOfClass:[NSString class]]) { 
        if(!([appLocation isEqualToString:kDock] ||
            [appLocation isEqualToString:kStatusBar] ||
            [appLocation isEqualToString:kBoth])) {
            //If plist contains wrong value 
            [userDef setValue:[Preferences defaultValueForKey:kAppLocation] forKey:kAppLocation];
         }
    } else {
        //If Wrong type of value or if key is absent
        [userDef setValue:[Preferences defaultValueForKey:kAppLocation] forKey:kAppLocation];
    }
}

+ (id) defaultValueForKey:(NSString*) key {
    if([key isEqualToString:kAppLocation]) {
        return kBoth;
    } else {
        return nil;
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

+ (appLocation) appLocation {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* appLocation = [userDef stringForKey:kAppLocation];

    if ([appLocation isEqualToString:kDock]) {
        return dock;
    } else if ([appLocation isEqualToString:kStatusBar]){
        return statusbar;
    } else if ([appLocation isEqualToString:kBoth]) {
        return both;
    } else {
        return both;
    }
}


@end
