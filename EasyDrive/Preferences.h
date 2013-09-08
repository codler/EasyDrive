//
//  Preferences.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Keys 
FOUNDATION_EXPORT NSString* const kAppInDock;
FOUNDATION_EXPORT NSString* const kAppInStatusBar;
FOUNDATION_EXPORT NSString* const kNotifAtPluggedIn;
FOUNDATION_EXPORT NSString* const kNotifAtPluggedOut;
FOUNDATION_EXPORT NSString* const kStartsOnLogin;




typedef enum {
    dock = 0, 
    statusbar = 1,
    bothPositions = 2,
} appLocation;

typedef enum {
    none = 0,
    mount = 1,
    unmount = 2,
    bothNotifications = 3,
} mountNotifications;


@interface Preferences : NSObject {
    NSUserDefaults* userDefaults;
}

+ (void) checkPreferencesIntegrity; 

+ (BOOL)loginItemExistsForPath:(NSString *)appPath;
+ (void)disableLoginItemForPath:(NSString *)appPath;
+ (void)enableLoginItemForPath:(NSString *)appPath;

+ (appLocation) appLocation; 
+ (mountNotifications) mountNotifications;

@end
