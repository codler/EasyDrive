//
//  MainController.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 09/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"

@implementation MainController

@synthesize contextualDockMenu=_contextualDockMenu;

-(id) init {
    self = [super init]; 
    if (self) {
        //Prefs
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [Preferences checkPreferencesIntegrity];
        
        //watch for app location change in the preferences
        [userDefaults addObserver:self forKeyPath:kAppInDock options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:self forKeyPath:kAppInStatusBar options:NSKeyValueObservingOptionNew context:NULL];

        iconArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        
        ///////  UI INIT
        
        //Contextual Dock menu
        _contextualDockMenu = [[NSMenu alloc] init];
        
        [_contextualDockMenu addItem:[NSMenuItem separatorItem]];
        NSMenuItem* item = [_contextualDockMenu addItemWithTitle:NSLocalizedString(@"Preferences",@"") action:@selector(showPreferences:) keyEquivalent:@""];
        item.target=self;
        
        NSString *appName = [[NSFileManager defaultManager] displayNameAtPath:@"/Applications/Utilities/Disk Utility.app"];
        //appName = [appName substringWithRange:NSMakeRange(0, [appName length]-4)]; //Remove .app extention for 10.7 ?
        item = [_contextualDockMenu addItemWithTitle:appName action:@selector(openDiskUtility:) keyEquivalent:@""];
        item.target=self;
        
        //StatusBar menu
        _statusBarMenu   = [[NSMenu alloc] init];
        
        
        //////////////////////////////////////////////
        
        core = [[Core alloc] init];
        [core setDelegate:self];
        [core performSelectorOnMainThread:@selector(loadMountedDevices) withObject:nil waitUntilDone:NO];
        
        //_lastDockMenuClose = [NSDate date];
        
        currentAppLocation = [Preferences appLocation];
        [self updateAppLocation];
        
        viewController = [[DrivesViewController alloc] initWithNibName:@"Collection" bundle:nil];
        [viewController setDrives:core.deviceArray];

        NSLog(@"end init mainController");
    }
    return self;
}

//Draws the new dock icon when drives are add or removed
- (void) updateDockIcon {
    [iconArray removeAllObjects];
    @synchronized(core.deviceArray) {
        if([core.deviceArray count] < 1) { //In case of no device are mounted. 
            return;
        }
        for(Device* device in core.deviceArray) {
            if(device.icon){
                NSImage* icon = device.icon;
                [icon setSize:NSMakeSize(256.0,256.0)];
                [iconArray addObject:icon];
            }
        }
    }
    
    //TODO ARRAY
    NSImage* icon1, *icon2, *icon3, *icon4, *icon5, *icon6;
    if([iconArray count] > 0) {
        icon1 =[iconArray objectAtIndex:0];
    }
    if([iconArray count] > 1) {
        icon2 =[iconArray objectAtIndex:1];
    }
    if([iconArray count] > 2) {
        icon3 =[iconArray objectAtIndex:2];
    }
    if([iconArray count] > 3) {
        icon4 =[iconArray objectAtIndex:3];
    }
    if([iconArray count] > 4) {
        icon5 =[iconArray objectAtIndex:4];
    }
    if([iconArray count] > 5) {
        icon6 =[iconArray objectAtIndex:5];
    }
    
    
    NSImage *newIcon = [[NSImage alloc]
                         initWithSize:NSMakeSize(icon1.size.width, icon1.size.height)];
    
    NSSize halfSize = NSMakeSize(icon1.size.width/2, icon1.size.height/2);
    CGFloat half = icon1.size.width/2;
    [newIcon lockFocus];
    
    switch([iconArray count]) {
        case 1:
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 2: 
            [icon1 setSize:NSMakeSize(2*newIcon.size.width/3, 2*newIcon.size.height/3)];
            [icon2 setSize:NSMakeSize(2*newIcon.size.width/3, 2*newIcon.size.height/3)];
            
            [icon1 drawAtPoint:NSMakePoint(0,newIcon.size.height/3) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(newIcon.size.width/3,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 3:
            [icon1 setSize:halfSize];
            [icon2 setSize:halfSize];
            [icon3 setSize:halfSize];        
            
            [icon1 drawAtPoint:NSMakePoint(0,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(half,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon3 drawAtPoint:NSMakePoint(half/2,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 4:
            [icon1 setSize:halfSize];
            [icon2 setSize:halfSize];
            [icon3 setSize:halfSize];
            [icon4 setSize:halfSize];
            
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(half,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(0,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon3 drawAtPoint:NSMakePoint(half,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 5:
            [icon1 setSize:halfSize];
            [icon2 setSize:halfSize];
            [icon3 setSize:halfSize];
            [icon4 setSize:halfSize];
            [icon5 setSize:halfSize];
            
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(half,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(0,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon5 drawAtPoint:NSMakePoint(half,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon3 drawAtPoint:NSMakePoint(half/2,half/2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 6: default:
            [icon1 setSize:halfSize]; [icon2 setSize:halfSize];
            [icon3 setSize:halfSize]; [icon4 setSize:halfSize];
            [icon5 setSize:halfSize]; [icon6 setSize:halfSize];
            
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(half,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon3 drawAtPoint:NSMakePoint(half,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(0,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon5 drawAtPoint:NSMakePoint(half/2,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon6 drawAtPoint:NSMakePoint(half/2,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
    }    
    
    [newIcon unlockFocus];
    
    [NSApp setApplicationIconImage:newIcon];
    [iconArray removeAllObjects];
    @synchronized(core.deviceArray) {
        for(Device* device in core.deviceArray) {
            if(device.icon) {
                NSImage* icon = device.icon;
                [icon setSize:NSMakeSize(32.0,32.0)];
            }
        }
    }
}


//Add the menu to the status bar
- (void) addStatusBarmenu {
    if(! [statusItem statusBar]) {
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [statusItem setMenu:_statusBarMenu];
        [statusItem setTitle:@"⏏"];
        [statusItem setHighlightMode:YES];   
    } else {
        NSLog(@"StatusBar already present");
    }
}

//Remove the menu for the status bar
- (void) removeStatusBarMenu {
    NSStatusBar* statusBar = [NSStatusBar systemStatusBar];
    if( statusItem && [statusItem statusBar]) {
        [statusBar removeStatusItem:statusItem];
        statusItem=nil;
    } else {
        NSLog(@"No statusbar menu");
    }
}

//Watch for app location preference change
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {

    //When dock position is modified in the preferences
    if([keyPath isEqualToString:kAppInDock] || [keyPath isEqualToString:kAppInStatusBar]) {
        [self updateAppLocation];
    } else {
        NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    }
}


- (void) updateAppLocation{
    if ([dw isVisible]) {
        //closing the window if changing the dock position while it's open.
        [dw orderOut:nil];
    }
    
    appLocation newAppLocation = [Preferences appLocation];
    
    if((previousAppLocation == dock || previousAppLocation == bothPositions )
       && newAppLocation == statusbar) {
        //Only the status bar is visible therefore adding pref/about/quit items
        
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToUIElementApplication); //remove from dock
        [self addStatusBarmenu];
        [self addQuitAboutItems];
    } else if (previousAppLocation == dock && newAppLocation == bothPositions) {
        [self addStatusBarmenu]; //add to status bar
    } else if (previousAppLocation == statusbar && newAppLocation == dock) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication); //app visible in the dock
        [self removeQuitAboutItems];  //remove the pref/about/items from the menu
        [self removeStatusBarMenu];
        [self updateDockIcon];
    } else if (previousAppLocation == statusbar && newAppLocation == bothPositions) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        [self removeQuitAboutItems];  //remove quit & about item
        [self updateDockIcon];
    } else if (previousAppLocation == bothPositions && newAppLocation == dock) {
        [self removeStatusBarMenu];
    }
    previousAppLocation=newAppLocation;
}



#pragma mark Menu methods


//Displays the DrivesWindow next to the dock if it's not open else it closes the window
- (void) popUpTheDockMenu {
    CGPoint iconPos;  CGSize iconSize;
    if(![AccessibilityUtilities dockIconIsAt:&iconPos withSize:&iconSize]) {
        //if AX API is not enabled
        return;
    }
    
    //On wich side is the dock ?
    //Computing also the window position
    dockposition dockPosition; // RETINA COMPATIBLE ???
    NSPoint pos;
    if(iconPos.x < 20) {
        dockPosition = left;
        pos.x = iconPos.x*2.2+iconSize.width;
        pos.y = [[NSScreen mainScreen] frame].size.height-(iconPos.y+iconSize.height/2);
    } else if ([[NSScreen mainScreen] frame].size.width -  (iconPos.x+iconSize.width) < 20) {
        dockPosition = right;
        float rest = [[NSScreen mainScreen] frame].size.width - (iconPos.x + iconSize.width);
        pos.x = iconPos.x-rest ;
        pos.y = [[NSScreen mainScreen] frame].size.height-(iconPos.y+iconSize.height/2);
    } else {
        dockPosition = bottom;
        pos.x = iconPos.x + iconSize.width/2;
        pos.y = [[NSScreen mainScreen] frame].size.height-iconPos.y;
    }

    if(! [dw isVisible]) {
        dw = [[DrivesWindow alloc] initWithView:[viewController view] attachedToPoint:pos];
        
        //To set the arrow position of the drive window
        if(dockPosition == left) {
            [dw setLeft];
        } else if (dockPosition == right) {
            [dw setRight];
        } else if (dockPosition == bottom) {
            [dw setBottom];
        }
        
        
        for(int i=0;i<[[viewController.arrayController arrangedObjects] count]; i++) {
            DriveViewBoxController* dvb = (DriveViewBoxController*) [viewController.collectionView itemAtIndex:i];
            dvb.target = self;
        }
        
        [NSApp activateIgnoringOtherApps:YES];
        [dw makeKeyAndOrderFront:nil];
    } else {
        [dw orderOut:nil];
    }
}

- (void) addDeviceToMenu:(Device*) device {
    [viewController updateWindow];
    
    NSMenuItem* item = [[NSMenuItem alloc] init];
    [item setTitle:device.name];
    [item setImage:device.icon];
    
    //For direct clicking on the item
    [item setAction:@selector(openDevice:)];
    [item setRepresentedObject:device];
    [item setTarget:self];
    
    if(device.ejectAvailable) { // You can't unmount root.
        NSMenu *ejectMenu = [[NSMenu alloc] init];
        NSMenuItem *ejectItem;
        ejectItem = [ejectMenu addItemWithTitle:NSLocalizedString(@"Unmount", @"") action:nil keyEquivalent:@""];
        [ejectItem setTarget:self];
        [ejectItem setAction:@selector(unmountDevice:)];
        [item setSubmenu: ejectMenu];
        [ejectItem setImage: [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kEjectMediaIcon)]];
        [ejectItem setRepresentedObject:device];
    }
    
    int i; //index of separator to insert before separator
    for(i=0; i< _contextualDockMenu.numberOfItems;i++) {
        NSMenuItem* item = [_contextualDockMenu itemAtIndex:i];
        if([item isSeparatorItem]){
            break;
        }
    }
    NSMenuItem* contextualMenuItem = [item copy];
    [_contextualDockMenu insertItem:contextualMenuItem atIndex:i];

    
    
    for(i=0; i< _statusBarMenu.numberOfItems;i++) {
        NSMenuItem* item = [_statusBarMenu itemAtIndex:i];
        if([item isSeparatorItem]){
            break;
        }
    }
    NSMenuItem* statusBarMenuItem = [item copy];
    [_statusBarMenu insertItem:statusBarMenuItem atIndex:i];
    
    //Register for Device modifations :
    if([item conformsToProtocol:@protocol(DeviceDelegate)])
        [device addDelegate:item];
    if([contextualMenuItem conformsToProtocol:@protocol(DeviceDelegate)])
        [device addDelegate:contextualMenuItem];
    if([statusBarMenuItem conformsToProtocol:@protocol(DeviceDelegate)])
        [device addDelegate:statusBarMenuItem];
    
    [self updateDockIcon];
}

- (void) removeDeviceFromMenu:(Device *) device {
    [viewController updateWindow];
    
    for (NSMenuItem* item in _contextualDockMenu.itemArray) {
        if (item.representedObject == device) {
            [_contextualDockMenu removeItem:item];
            break;
        }
    }
    for (NSMenuItem* item in _statusBarMenu.itemArray) {
        if (item.representedObject == device) {
            [_statusBarMenu removeItem:item];
            break;
        }
    }
    [self updateDockIcon];
}

- (void) removeQuitAboutItems {
    //Remove the items of the StatusBar Menu when the DockIcon is present
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // separator
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // Pref
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // Update
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // About
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // separator
    [_statusBarMenu removeItemAtIndex:[[_statusBarMenu itemArray] count]-1]; // quit
}

// Adding Preference, Update, About & Quit items to the Status Bar menu
// Used when only the status bar menu is visible
- (void) addQuitAboutItems {
    
    [_statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"Preferences",@"") action:@selector(showPreferences:) keyEquivalent:@""];
    [item setTarget:self];
    
    item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"CheckForUpdate", @"") action:@selector(checkUpdates) keyEquivalent:@""];
    [item setTarget:self];
    
    item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"About", @"") action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [item setTarget:NSApp];
    
    [_statusBarMenu addItem:[NSMenuItem separatorItem]];
    item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(terminate:) keyEquivalent:@"q"];
    [item setTarget:NSApp];
}




#pragma mark Menu Commands
//Unmount the drive
- (IBAction) unmountDevice:(id) sender {
    Device* device = [sender representedObject];
    [core performSelectorOnMainThread:@selector(unmountDevice:) withObject:device waitUntilDone:NO];
}

//Open the drive in the finder
- (IBAction) openDevice:(id) sender {
    [core openDevice:[sender representedObject]];
    
}

//Open the preference window.
- (IBAction)showPreferences:(id)sender {
    if(!prefCon) {
        prefCon = [[PreferencesController alloc] init];
    }
    [prefCon showPreferences];
}

//Opens the disk utility app
- (IBAction) openDiskUtility:(id) sender {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    [ws launchApplication:@"Disk Utility"];
    
//    AXUIElementRef _systemWideElement;
//    AXUIElementRef _focusedApp;
//    CFTypeRef _focusedWindow;
//    _systemWideElement = AXUIElementCreateSystemWide();
//    AXUIElementCopyAttributeValue(_systemWideElement,
//                                  (CFStringRef)kAXFocusedApplicationAttribute,(CFTypeRef*)&_focusedApp);
//    AXUIElementCopyAttributeValue((AXUIElementRef)_focusedApp,
//                                  (CFStringRef)NSAccessibilityFocusedWindowAttribute,(CFTypeRef*)&_focusedWindow);
}

//Checking for updates using the Sparkle framework
- (IBAction) checkUpdates {
    [[[SUUpdater alloc] init] checkForUpdates:nil];
}

@end


//@implementation NSMenuItem (represented)
//-(void) deviceWasUpdated {
//    NSLog(@"device was updated");
//    Device* device = (Device*) self.representedObject;
//    [self setTitle:device.name];
//}
//@end
