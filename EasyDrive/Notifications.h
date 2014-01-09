//
//  Notifications.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 17/01/13.
//
//

#import <Foundation/Foundation.h>
#import "Preferences.h"
#import "Device.h"

@interface Notifications : NSObject<NSUserNotificationCenterDelegate>{
    NSUserNotificationCenter* userNotifCenter;
    bool notifAtPluggedIn;
    bool notifAtPuggedOut;
}


+(id) getInstance;
-(void) sendPluggedInNotification:(Device*) deviceName;
-(void) sendPluggedOutNotification:(Device*) deviceName;

@end
