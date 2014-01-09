//
//  Notifications.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 17/01/13.
//
//

#import "Notifications.h"

@implementation Notifications

+(Notifications *) getInstance {
    static Notifications* instance;
    
    @synchronized(self)
    {
        if(! instance) {
            instance = [[self alloc] init];
        }
        return instance;
    }
}

-(id) init {
    self = [super init];
    if (self) {
        userNotifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        [userNotifCenter setDelegate:self];
    
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults addObserver:self forKeyPath:kNotifAtPluggedIn options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:self forKeyPath:kNotifAtPluggedIn options:NSKeyValueObservingOptionNew context:NULL];

        notifAtPluggedIn = [userDefaults boolForKey:kNotifAtPluggedIn];
        notifAtPuggedOut = [userDefaults boolForKey:kNotifAtPluggedOut];
    }
    return self;
}


-(void) dealloc {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kNotifAtPluggedIn];
    [userDefaults removeObjectForKey:kNotifAtPluggedOut];
}



//For observing modification of UserDefaults
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([keyPath isEqualToString:kNotifAtPluggedIn]) {
        notifAtPluggedIn = [userDefaults boolForKey:kNotifAtPluggedIn];
    } else if ( [keyPath isEqualToString:kNotifAtPluggedOut]) {
        notifAtPuggedOut = [userDefaults boolForKey:kNotifAtPluggedOut];        
    } else {
        NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    }
}



-(void) sendPluggedInNotification:(Device*) device {
    if(userNotifCenter) { // if on 10.8
        NSUserNotification *notif = [[NSUserNotification alloc] init];

        [notif setTitle: NSLocalizedString(@"Connection", @"")];
        [notif setSubtitle: [NSString stringWithFormat:@"%@ %@", device.name, NSLocalizedString(@"Connected",@"")]];
        notif.contentImage = device.icon;
        //[notif setInformativeText: @"Informative Text"];
        
        [userNotifCenter deliverNotification:notif];
    } else {
        [NSApp requestUserAttention:NSInformationalRequest]; //simple notification
    }
}


-(void) sendPluggedOutNotification:(Device*) device {
    if(userNotifCenter) { // if on 10.8
        NSUserNotification *notif = [[NSUserNotification alloc] init];
        
        [notif setTitle: NSLocalizedString(@"Ejection", @"")];
        [notif setSubtitle: [NSString stringWithFormat:@"%@ %@", device.name, NSLocalizedString(@"Ejected",@"")]];
        notif.contentImage = device.icon;
        //[notif setInformativeText: @"Informative Text"];
        [userNotifCenter deliverNotification:notif];
    } else {
        [NSApp requestUserAttention:NSInformationalRequest]; //simple notification
    }
}


# pragma mark NSUserNotificationCenterDelegate methods
//Lets remove automaticaly all notification from the Center once they've been delivered
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    [userNotifCenter removeDeliveredNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    //Used to show UserNotifications when App is active
    return YES;
}

@end
