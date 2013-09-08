//
//  Notifications.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 17/01/13.
//
//

#import <Foundation/Foundation.h>
#import "Preferences.h"

@interface Notifications : NSObject<NSUserNotificationCenterDelegate>{
    NSUserNotificationCenter* userNotifCenter;
    bool notifAtPluggedIn;
    bool notifAtPuggedOut;
}


+(id) getInstance;
-(void) sendPluggedInNotification:(NSString*) deviceName;
-(void) sendPluggedOutNotification:(NSString*) deviceName;

@end
