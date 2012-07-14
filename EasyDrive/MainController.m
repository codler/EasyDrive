//
//  MainController.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 09/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"
#import "AXAlertController.h"

@implementation MainController

@synthesize doNotOpenMenu=_doNotOpenMenu; 
@synthesize contextualDockMenu=_contextualDockMenu;

-(id) init {
    self = [super init]; 
    if (self) {
        NSLog(@"init mainController");
        //Prefs
        userDefaults = [NSUserDefaults standardUserDefaults];
        [Preferences checkPreferencesIntegrity];
        [userDefaults addObserver:self forKeyPath:kAppLocation options:NSKeyValueObservingOptionNew context:NULL];        
        
        fileManager = [[NSFileManager alloc]init];
        iconArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        
        //Dock Menu
        _dockMenu = [[NSMenu alloc] init];
        [_dockMenu setDelegate: self];
        
        
        //Contextual Dock menu
        _contextualDockMenu = [[NSMenu alloc] init];
        [_contextualDockMenu addItem:[NSMenuItem separatorItem]];
        NSMenuItem* item = [_contextualDockMenu addItemWithTitle:NSLocalizedString(@"Preferences",@"") action:@selector(showPreferences:) keyEquivalent:@""];
        item.target=self;
        
        NSString *appName = [[NSFileManager defaultManager] displayNameAtPath:@"/Applications/Utilities/Disk Utility.app"] ;
        appName = [appName substringWithRange:NSMakeRange(0, [appName length]-4)]; //Remove .app extention
        item = [_contextualDockMenu addItemWithTitle:appName action:@selector(openDiskUtility) keyEquivalent:@""];
        item.target=self;
        
        
        //StatusBar menu 
        _statusBarMenu   = [[NSMenu alloc] init];
        [_statusBarMenu addItem:[NSMenuItem separatorItem]];
        item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"Preferences",@"") action:@selector(showPreferences:) keyEquivalent:@""];
        [item setTarget:self];       
        
        
        
        core = [[Core alloc] init];
        [core setDelegate:self];
        [core performSelectorOnMainThread:@selector(loadMountedDevices) withObject:nil waitUntilDone:NO];
        
        [self readDockPosition];
        [self watchConfigFile:[@"~/Library/Preferences/com.apple.dock.plist" stringByExpandingTildeInPath]];
        
        
        currentAppLocation = [Preferences appLocation];
        [self updateAppLocation];
        NSLog(@"end init mainController");
    }
    return self;
}

- (void) dealloc {
    [userDefaults removeObserver:self forKeyPath:@"appLocation"];
}

- (void) readDockPosition {
    NSString *plistPath = [@"~/Library/Preferences/com.apple.dock.plist" stringByExpandingTildeInPath];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *dockLocation = [plistData objectForKey:@"orientation"];
    if( [dockLocation isEqualToString:@"left"]){
        dockPosition=left;
    } else if( [dockLocation isEqualToString:@"bottom"]){
        dockPosition=bottom;
    } else if( [dockLocation isEqualToString:@"right"]){
        dockPosition=right;
    }
}

- (void) watchConfigFile:(NSString*) path{
    int fildes = open([path cStringUsingEncoding:NSASCIIStringEncoding], O_RDONLY);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block typeof(self) blockSelf = self;
	__block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes, 
															  DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
															  queue);
	dispatch_source_set_event_handler(source, ^
                                      {
                                          unsigned long flags = dispatch_source_get_data(source);
                                          if(flags & DISPATCH_VNODE_DELETE)
                                          {
                                              dispatch_source_cancel(source);                                              
                                              [self readDockPosition];
                                              [blockSelf watchConfigFile:path];
                                          }
                                          // Reload config file
                                      });
	dispatch_source_set_cancel_handler(source, ^(void) 
                                       {
                                           close(fildes);
                                       });
	dispatch_resume(source);
}

- (void) updateDockIcon {
    NSLog(@"updateDockIcon");
    [iconArray removeAllObjects];
    @synchronized(core.deviceArray) {
        if([core.deviceArray count] < 1) { //In case of no device are mounted. 
            return;
        }
        for(Device* device in core.deviceArray) {
            NSImage* icon = device.icon;
            [icon setSize:NSMakeSize(256.0,256.0)];
            [iconArray addObject:icon];
        }
    }
    
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
    if([iconArray count] > 4) {
        icon6 =[iconArray objectAtIndex:5];
    }
    
    
    NSImage *newImage = [[NSImage alloc]
                         initWithSize:NSMakeSize(icon1.size.width, icon1.size.height)];
    
    NSSize halfSize = NSMakeSize(icon1.size.width/2, icon1.size.height/2);
    CGFloat half = icon1.size.width/2;
    [newImage lockFocus];
    
    switch([iconArray count]) {
        case 1:
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        case 2: 
            [icon1 setSize:NSMakeSize(2*newImage.size.width/3, 2*newImage.size.height/3)];
            [icon2 setSize:NSMakeSize(2*newImage.size.width/3, 2*newImage.size.height/3)];
            
            [icon1 drawAtPoint:NSMakePoint(0,newImage.size.height/3) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(newImage.size.width/3,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
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
        case 6:
            [icon1 setSize:halfSize]; [icon2 setSize:halfSize];
            [icon3 setSize:halfSize]; [icon4 setSize:halfSize];
            [icon5 setSize:halfSize]; [icon6 setSize:halfSize];
            
            [icon1 drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon2 drawAtPoint:NSMakePoint(half,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon3 drawAtPoint:NSMakePoint(half,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(0,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(half/2,0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [icon4 drawAtPoint:NSMakePoint(half/2,half) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
    }    
    
    [newImage unlockFocus];
    
    [NSApp setApplicationIconImage:newImage];
    [iconArray removeAllObjects];
    @synchronized(core.deviceArray) {
        for(Device* device in core.deviceArray) {
            NSImage* icon = device.icon;
            [icon setSize:NSMakeSize(32.0,32.0)];
        }
    }
}

- (void) updateAppLocation{
    appLocation newAppLocation = [Preferences appLocation];
    
    if(previousAppLocation == dock && newAppLocation == statusbar) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
        [self addStatusBarmenu];        
        [self addQuitAboutItems];
    } else if (previousAppLocation == dock && newAppLocation == both) {
        [self addStatusBarmenu];
        
        
    } else if (previousAppLocation == statusbar && newAppLocation == dock) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        [self removeQuitAboutItems];
        [self removeStatusBarMenu];
    } else if (previousAppLocation == statusbar && newAppLocation == both) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        //remove quit & about item
        [self removeQuitAboutItems];
    } else if (previousAppLocation == both && newAppLocation == dock) {
        [self removeStatusBarMenu];        
    } else if (previousAppLocation == both && newAppLocation == statusbar) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
        [self addStatusBarmenu];
        [self addQuitAboutItems];
    }
    previousAppLocation=newAppLocation;
}

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

- (void) removeStatusBarMenu {
    NSStatusBar* statusBar = [NSStatusBar systemStatusBar];
    if( statusItem && [statusItem statusBar]) {
        [statusBar removeStatusItem:statusItem];
        statusItem=nil;
    } else {
        NSLog(@"No statusbar menu");
    }
}


//For observing modification oser UserDefaults
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    if([keyPath isEqualToString:kAppLocation]) {
        [self updateAppLocation];
    } else {
        NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    }
}

#pragma mark Menu methods 

//Delegate methods used to know if clicking on dock icon
- (void) menuWillOpen:(NSMenu *)menu {
    menuIsOpen=true;
    monitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUp 
                                                     handler:^(NSEvent *event){
                                                         [self handleGlobalClickAtPoint:[event locationInWindow]];
                                                     }];
}

- (void) menuDidClose:(NSMenu *)menu {
    menuIsOpen=false;
    [NSEvent removeMonitor:monitor];
    monitor=nil;
}

- (void) handleGlobalClickAtPoint:(NSPoint) point {
    if(menuIsOpen) {
        CGPoint iconPos;
        CGSize iconSize;
        [self dockIconIsAt:&iconPos withSize:&iconSize];
        
        iconPos.y = [[NSScreen mainScreen] frame].size.height-iconPos.y;
        
        CGRect rect = CGRectMake(iconPos.x, iconPos.y, iconSize.width, -iconSize.height);
        
        if(CGRectContainsPoint(rect, point)) {
            [_dockMenu performSelectorOnMainThread:@selector(cancelTracking) withObject:nil waitUntilDone:false];
            _doNotOpenMenu=true;
        }
    }
}

//Menu handling

- (void) popUpTheDockMenu { 
    NSLog(@"popup");
    CGPoint iconPos; 
    CGSize iconSize;
    if(![self dockIconIsAt:&iconPos withSize:&iconSize]) {
        //if API no enabled 
        return;
    }
    NSPoint pos;
    if(dockPosition == left) {
        pos.x = iconPos.x+iconSize.width*1.2;
        pos.y = [[NSScreen mainScreen] frame].size.height - (iconPos.y+iconSize.height/2) + _dockMenu.size.height/2;    
    } else if (dockPosition == right) {
        pos.x = iconPos.x-_dockMenu.size.width;        
        pos.y = [[NSScreen mainScreen] frame].size.height - (iconPos.y+iconSize.height/2) + _dockMenu.size.height/2;    
    } else {
        pos.x = iconPos.x+iconSize.width/2-_dockMenu.size.width/2;
        pos.y = ([[NSScreen mainScreen] frame].size.height - iconPos.y)+_dockMenu.size.height-2;
    }
    //Popup the menu 
    [_dockMenu popUpMenuPositioningItem:nil atLocation:pos inView:nil];
}

- (void) addDeviceToMenu:(Device*) device {
    NSMenuItem *subItem1, *subItem2;
    NSMenuItem* item;
    item = [[NSMenuItem alloc] init];
    NSString* path = device.path;
    [item setTitle:[fileManager displayNameAtPath:path]];
    [item setImage:device.icon];
    
    NSMenu *submenu = [[NSMenu alloc] init];
    
    subItem1 = [submenu addItemWithTitle:NSLocalizedString(@"Open", @"") action:@selector(openDriveWithPath:) keyEquivalent:@""];
    [subItem1 setTarget:self];
    [subItem1 setImage:[NSImage imageNamed:NSImageNameFolder]];
    [subItem1 setRepresentedObject:path];
    
    subItem2 = [submenu addItemWithTitle:NSLocalizedString(@"Unmount", @"") action:nil keyEquivalent:@""];
    if(! [path isEqualToString:@"/"]) { // You can't unmount root. 
        [subItem2 setTarget:self];
        [subItem2 setAction:@selector(unmountDeviceWithPath:)];
    }
    [subItem2 setImage: [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kEjectMediaIcon)]];        
    [subItem2 setRepresentedObject:path];
    
    //For direct clicking on the item 
    [item setAction:@selector(openDriveWithPath:)];
    [item setRepresentedObject:path];
    [item setTarget:self];   
    
    [item setSubmenu: submenu]; 
    
    [_dockMenu addItem:item];
    
    int i;
    for(i=0; i< _contextualDockMenu.numberOfItems;i++) {
        NSMenuItem* item = [_contextualDockMenu itemAtIndex:i];
        if([item isSeparatorItem]){
            break;
        }
    }
    [_contextualDockMenu insertItem:[item copy] atIndex:i];
    
    for(i=0; i< _statusBarMenu.numberOfItems;i++) {
        NSMenuItem* item = [_statusBarMenu itemAtIndex:i];
        if([item isSeparatorItem]){
            break;
        }
    }
    [_statusBarMenu insertItem:[item copy] atIndex:i];
    
    [self updateDockIcon];
}

- (void) removeDeviceFromMenu:(Device *)device {
    NSString* title = [fileManager displayNameAtPath:device.path];
    
    NSMenuItem* item = [_dockMenu itemWithTitle:title];
    [_dockMenu removeItem:item];
    item = [_contextualDockMenu itemWithTitle:title];
    [_contextualDockMenu removeItem:item];
    item = [_statusBarMenu itemWithTitle:title];
    [_statusBarMenu removeItem:item];
    
    [self updateDockIcon];
}

- (void) removeQuitAboutItems {
    NSLog(@"remove");
    [_statusBarMenu removeItem:[_statusBarMenu itemWithTitle:NSLocalizedString(@"About", @"")]];
    [_statusBarMenu removeItem:[_statusBarMenu itemWithTitle:NSLocalizedString(@"Quit", @"")]];
}

- (void) addQuitAboutItems {
    NSMenuItem* item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"About", @"") action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [item setTarget:NSApp];
    
    item = [_statusBarMenu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(terminate:) keyEquivalent:@""];
    [item setTarget:NSApp];
}



//MenuItem commands 
- (void) unmountDeviceWithPath:(id) sender {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    
    bool ret;
    ret =[ws unmountAndEjectDeviceAtPath:[sender representedObject]];
    if(!ret) {
        [[NSSound soundNamed:@"Funk"] play];
    }
}

- (void) openDriveWithPath:(id) sender {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    [ws openFile:[sender representedObject] withApplication:@"Finder"];
}

- (IBAction)showPreferences:(id)sender {
    if(!prefCon) {
        prefCon = [[PreferencesController alloc] init];
    }
    [prefCon showPreferences];
}

- (void) openDiskUtility {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    [ws launchApplication:@"Disk Utility"];
}



#pragma mark AX Methods 
- (NSArray *)subelementsFromElement:(AXUIElementRef)element forAttribute:(NSString *)attribute{
    CFArrayRef subElementsCFArray = nil;
    CFIndex count = 0;
    AXError result;
    
    result = AXUIElementGetAttributeValueCount(element, (__bridge CFStringRef)attribute, &count);
    if (result != kAXErrorSuccess) return nil;
    result = AXUIElementCopyAttributeValues(element, (__bridge CFStringRef)attribute, 0, count, (CFArrayRef *) &subElementsCFArray);
    if (result != kAXErrorSuccess) return nil;
    NSArray *subElements = (__bridge NSArray *)subElementsCFArray;
    return subElements;
}

- (AXUIElementRef)appDockIconByName:(NSString *)appName{
    AXUIElementRef appElement = NULL;
    
    appElement = AXUIElementCreateApplication([[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dock"] lastObject] processIdentifier]);
    if (appElement != NULL)
    {
        AXUIElementRef firstChild = (__bridge AXUIElementRef)[[self subelementsFromElement:appElement forAttribute:@"AXChildren"] objectAtIndex:0];
        NSArray *children = [self subelementsFromElement:firstChild forAttribute:@"AXChildren"];
        NSEnumerator *e = [children objectEnumerator];
        AXUIElementRef axElement;
        while (axElement = (__bridge AXUIElementRef)[e nextObject])
        {
            CFTypeRef value;
            id titleValue;
            AXError result = AXUIElementCopyAttributeValue(axElement, kAXTitleAttribute, &value);
            if (result == kAXErrorSuccess)
            {
                if (AXValueGetType(value) != kAXValueIllegalType)
                    titleValue = [NSValue valueWithPointer:value];
                else
                    titleValue = (__bridge id)value; // assume toll-free bridging
                if ([titleValue isEqual:appName]) {
                    return axElement;
                }
            }
        }
    }
    
    return nil;
}

- (BOOL) dockIconIsAt:(CGPoint*) iconPos withSize: (CGSize*) iconSize  {
    //Check if AX API enabled 
    if (! AXAPIEnabled()) {
        AXAlertController* ax = [[AXAlertController alloc] init];
        [ax showAlert];  
        
        return false;
    }
    
    //Pos of icon
    NSString *appName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    AXUIElementRef dockIcon = [self appDockIconByName:appName];
    //    CGSize iconSize;
    //    CGPoint iconPos;
    if (dockIcon) {
        CFTypeRef value;
        
        AXError result = AXUIElementCopyAttributeValue(dockIcon, kAXSizeAttribute, &value);
        if (result == kAXErrorSuccess)
        {
            if (AXValueGetValue(value, kAXValueCGSizeType, iconSize)) {
                //NSLog(@"taille: (%f, %f)", iconSize.width,iconSize.height);
            }
        }
        result = AXUIElementCopyAttributeValue(dockIcon, kAXPositionAttribute, &value);
        if (result == kAXErrorSuccess)
        {
            if (AXValueGetValue(value, kAXValueCGPointType, iconPos)) {
                //NSLog(@"position: (%f, %f)", iconPos.x,iconPos.y);
            }
        }
    }
    return true;
}
@end
