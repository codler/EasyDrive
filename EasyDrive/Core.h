//
//  Core.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DiskArbitration/DiskArbitration.h>
#import "Device.h"
#import "FSEventsListener.h"
#import "Notifications.h"

void unmountCallback(DADiskRef disk, DADissenterRef dissenter, void *context);

@interface Core : NSObject
<FSEventListenerDelegate>
{
    NSMutableArray* deviceArray;
    
    @private
    NSNotificationCenter* notifCenter;
    NSFileManager* fileManager;
    
    id delegate;
    Boolean eject;
}

@property (readonly) NSMutableArray* deviceArray;


// inits methods
- (void) setDelegate:(id)delegate;
- (void) postponeDeviceInitWithPath:(NSURL*) path;


// core methods
- (void) unmountDevice: (Device*) device;
- (void) openDevice:(Device*) device;


// callbacks
- (void) loadMountedDevices;
- (void) discMounted:(NSNotification *)notification;
- (void) willUnmount:(NSNotification *)notification;
- (void) didUnmount:(NSNotification *)notification;





// private ??

- (void) addDevice:(Device*) path;
- (Device*) removeDeviceWithPath:(NSString*) path;
- (void) removeDevice:(Device*) device;



@end

@protocol CoreDelegate <NSObject>
@required
- (void) updateDockIcon;
- (void) addDeviceToMenu:(Device*) device;
- (void) removeDeviceFromMenu:(Device*) device;
@end