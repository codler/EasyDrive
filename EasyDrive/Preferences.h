//
//  Preferences.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Keys 
FOUNDATION_EXPORT NSString* const kAppLocation;
FOUNDATION_EXPORT NSString* const kStartsOnLogin;

//Values
FOUNDATION_EXPORT NSString* const kBoth;
FOUNDATION_EXPORT NSString* const kDock;
FOUNDATION_EXPORT NSString* const kStatusBar;

typedef enum {
    dock = 0, 
    statusbar = 1,
    both = 2,
} appLocation;



@interface Preferences : NSObject {
    NSUserDefaults* userDefaults;
}

+ (void) checkPreferencesIntegrity; 
+ (id) defaultValueForKey:(NSString*) key;

+ (BOOL)loginItemExistsForPath:(NSString *)appPath;
+ (void)disableLoginItemForPath:(NSString *)appPath;
+ (void)enableLoginItemForPath:(NSString *)appPath;

+ (appLocation) appLocation; 

@end
