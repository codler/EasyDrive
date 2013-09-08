//
//  Core.m
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Core.h"


@implementation Core

@synthesize deviceArray;


#pragma mark init methods

-(id) init {
    self = [super init];
    if (self) {
        NSLog(@"init core");
        delegate=nil;
        
        notifCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
        [notifCenter addObserver:self
                        selector:@selector(discMounted:)
                            name:NSWorkspaceDidMountNotification
                          object:[NSWorkspace sharedWorkspace]];
        [notifCenter addObserver:self
                        selector:@selector(willUnmount:)
                            name:NSWorkspaceWillUnmountNotification
                          object:[NSWorkspace sharedWorkspace]];
        [notifCenter addObserver:self
                        selector:@selector(didUnmount:)
                            name:NSWorkspaceDidUnmountNotification
                          object:[NSWorkspace sharedWorkspace]];
        deviceArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        eject= false;
        
        NSLog(@"init core ended");
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loadMountedDevices {
    fileManager = [[NSFileManager alloc]init];
    //NSArray* array = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:@"file://localhost/Volumes"] includingPropertiesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes error:nil];
    
    NSArray* array = [fileManager mountedVolumeURLsIncludingResourceValuesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes];
    @synchronized (deviceArray) {
        for(NSURL* string in array) {
            [self performSelectorOnMainThread:@selector(postponeDeviceInitWithPath:) withObject:string waitUntilDone:NO];
        }
    }
    [[FSEventsListener instance] addListener:self forPath:@"/Volumes/"];
}

- (void) postponeDeviceInitWithPath:(NSURL*) path {
    BOOL isDirectory;
    [fileManager fileExistsAtPath:[path relativePath] isDirectory:&isDirectory];
    if(isDirectory) {
        NSString *urlString = [path relativePath];
        Device* device = [[Device alloc] initWithPath:urlString];
        [self addDevice:device];
        [delegate addDeviceToMenu:device];
    }
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}


//////////////////////////////////
#pragma mark Core Methods

- (void) unmountDevice: (Device*) device {
    if(!eject) {
        NSLog(@"Unmounting in core");
        
        CFAllocatorRef allocator = kCFAllocatorDefault;
        DASessionRef session = DASessionCreate(kCFAllocatorDefault);
        DASessionScheduleWithRunLoop(session, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );

        NSURL *url = [NSURL URLWithString:[device.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        DADiskRef disk = DADiskCreateFromVolumePath(allocator,
                                                    session,
                                                    (__bridge CFURLRef) url );
        if (disk) {
            DASessionScheduleWithRunLoop(session, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            
            DADiskUnmount(disk,
                          kDADiskMountOptionDefault,
                          unmountCallback,
                          NULL);
            CFRelease(disk);
        }
        if (session) {CFRelease(session);}
    } else {
        NSLog(@"Ejecting in core");
        NSWorkspace* ws = [NSWorkspace sharedWorkspace];
        NSError* error;
        bool ret;
        ret =[ws unmountAndEjectDeviceAtURL:[NSURL fileURLWithPath:device.path] error:&error];
        if (error)
            NSLog(@"%@",[error localizedDescription]);
        if(!ret) {
            [NSApp activateIgnoringOtherApps:YES];
            [[NSSound soundNamed:@"Funk"] play];
            [[NSAlert alertWithMessageText:NSLocalizedString(@"CannotEjectMessageText",@"") defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"« %@ » %@", device.name, NSLocalizedString(@"CannotEjectInformativeText", @"")] runModal];
        }
    }
}

void unmountCallback(DADiskRef disk, DADissenterRef dissenter, void *context) {
    if(dissenter)
    {
        DAReturn status = DADissenterGetStatus(dissenter);
        if(unix_err(status))
        {
            int code = err_get_code(status);
            printf("%d", code);
        }
    }
}


- (void) openDevice:(Device*) device {
    NSLog(@"Core opens %@", device.path);
    NSURL *fileURL = [NSURL fileURLWithPath: device.path];
    [[NSWorkspace sharedWorkspace] openURL:fileURL];
}



//////////////////////////////////

#pragma mark callback Methods
- (void)discMounted:(NSNotification *)notification{
    
    NSString* devicePath = [[notification userInfo] objectForKey:@"NSDevicePath"];
    if([devicePath hasPrefix:@"/private"]) {
        NSLog(@"Private device at %@", devicePath);
        return;
    } else {
        NSLog(@"Mount : %@",devicePath);
    }
    Device* device = [[Device alloc] initWithPath:devicePath];
    [self addDevice:device];
    
    [delegate addDeviceToMenu:device];
    
    Notifications* notif = [Notifications getInstance];
    [notif sendPluggedInNotification:device.name];
}


- (void) openDevice {
    
}


- (void)willUnmount:(NSNotification *)notification{
    //NSLog(@"Will Unmount : %@",[[notification userInfo] objectForKey:@"NSDevicePath"]);
}


- (void)didUnmount:(NSNotification *)notification{
    NSString* devicePath = [[notification userInfo] objectForKey:@"NSDevicePath"];
    if([devicePath hasPrefix:@"/private"]) {
        NSLog(@"Unmount Private device at %@", devicePath);
        return;
    } else {
        NSLog(@"Unmount : %@",[[notification userInfo] objectForKey:@"NSDevicePath"]);
    }
    
    Device* device = [self removeDeviceWithPath:devicePath];
    if(! device) {
        return;
    }
    
    [delegate removeDeviceFromMenu:device];
    
    
    Notifications* notif = [Notifications getInstance];
    [notif sendPluggedOutNotification:device.name];
}

# pragma mark misc methods

- (void) addDevice:(Device*) device {
#ifdef DEBUG
    for(Device* dev in deviceArray) {
        if([dev.path isEqualToString:device.path]) {
            [[NSAlert alertWithMessageText:@"Device deja present" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
            return;
        }
    }
#endif
    
    @synchronized(deviceArray) {
        [deviceArray addObject:device];
    }
}

- (void) removeDevice:(Device*) device {
    [self removeDeviceWithPath:device.path];
}

- (Device*) removeDeviceWithPath:(NSString*) path {
    Device* device;
    @synchronized(deviceArray){
        for(device in deviceArray) {
            if([device.path isEqualToString:path]) {
                [deviceArray removeObject:device];
                return device;
            }
        }
    }
    return nil;
}

-(Device*) updateDeviceWithOldPath:(NSString*) oldPath  toNewPath:(NSString*) newPath {
    for (Device *device in deviceArray) {
        if ([device.path isEqualToString:oldPath]) {
            [device setNewPath:newPath];
            return device;
        }
    }
    return nil;
}


# pragma mark FSEventListenerDelegate methods

-(void)fileWasRenamed:(NSString *)oldFile to:(NSString *)newFile {
    NSLog(@"%@ moved to %@", oldFile, newFile);
}
-(void)fileWasAdded:(NSString *)file {
    NSLog(@"added %@", file);
}
-(void)fileWasRemoved:(NSString *)file{
    NSLog(@"removed %@", file);
}

-(void)directoryWasAdded:(NSString *)directory{
    //also called when mounting in /Volumes/
    //NSLog(@"dir added %@", directory);
}
-(void)directoryWasRemoved:(NSString *)directory{
    //also called when unmounting in /Volumes/
    //NSLog(@"dir removed %@", directory);
    
}
-(void)directoryWasRenamed:(NSString *)oldDirectory to:(NSString *)newDirectory {
    NSLog(@"Dir %@ moved to dir %@", oldDirectory, newDirectory);
    [self updateDeviceWithOldPath:oldDirectory toNewPath:newDirectory];
}

@end

