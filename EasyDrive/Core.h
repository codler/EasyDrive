//
//  Core.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
@interface Core : NSObject 
{
    NSMutableArray* deviceArray;
    NSNotificationCenter* notifCenter;
    NSFileManager* fileManager;
    
    NSString* pathToUnmount;
    id delegate;
}



@property (readonly) NSMutableArray* deviceArray;

- (void) setDelegate:(id)delegate;
- (void) loadMountedDevices;
- (void) discMounted:(NSNotification *)notification;
- (void) willUnmount:(NSNotification *)notification;
- (void) didUnmount:(NSNotification *)notification;
- (void) postponeDeviceInitWithPath:(NSURL*) path;
- (Device*) addDeviceWithPath:(NSString*) path;
- (Device*) removeDeviceWithPath:(NSString*) path;

@end

@interface NSObject(CoreMethods)
- (void) updateDockIcon;
- (void) setMenuNeedsUpdate:(boolean_t) b;
- (void) addDeviceToMenu:(Device*) device;
- (void) removeDeviceFromMenu:(Device*) device;
@end