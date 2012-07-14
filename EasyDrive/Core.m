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
        NSLog(@"init core ended");
    }
    return self;
}

-(void) loadMountedDevices {
    fileManager = [[NSFileManager alloc]init];
    NSArray* array = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:@"file://localhost/Volumes"] includingPropertiesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes error:nil];    
    
    //[fileManager mountedVolumeURLsIncludingResourceValuesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes];
    @synchronized (deviceArray) {
        for(NSURL* string in array) {
            [self performSelectorOnMainThread:@selector(postponeDeviceInitWithPath:) withObject:string waitUntilDone:NO];
        }
    }
}

- (void) postponeDeviceInitWithPath:(NSURL*) path {
    BOOL isDirectory;
    [fileManager fileExistsAtPath:[path relativePath] isDirectory:&isDirectory];
    if(isDirectory) {
        NSString *urlString = [path relativePath];
        Device* device = [self addDeviceWithPath:urlString];
        [delegate addDeviceToMenu:device];
    }
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)discMounted:(NSNotification *)notification
{
    NSLog(@"Mount : %@",[[notification userInfo] objectForKey:@"NSDevicePath"]);
    Device* device = [self addDeviceWithPath:[[notification userInfo] objectForKey:@"NSDevicePath"]];
    
    [delegate addDeviceToMenu:device];
}

- (void)willUnmount:(NSNotification *)notification
{
    //NSLog(@"Will Unmount : %@",[[notification userInfo] objectForKey:@"NSDevicePath"]);
}

- (void)didUnmount:(NSNotification *)notification
{
    NSLog(@"Unmount : %@",[[notification userInfo] objectForKey:@"NSDevicePath"]);
    NSString* path = [[notification userInfo] objectForKey:@"NSDevicePath"];
    Device* device = [self removeDeviceWithPath:path];
    
    [delegate removeDeviceFromMenu:device];
    
    if([path isEqualToString:pathToUnmount]) {
        [[NSSound soundNamed:@"Submarine"] play];
    } 
    
}


-(Device*) addDeviceWithPath:(NSString*) path {
    NSLog(@"%@",path);
    Device* device = [[Device alloc] initWithPath:path];
    @synchronized(deviceArray) {
        [deviceArray addObject:device];
    }
    
    return device;
}

-(Device*) removeDeviceWithPath:(NSString*) path {
    Device* device;
    @synchronized(deviceArray){
        for(int i=0; i< [deviceArray count];i++) {
            device = [deviceArray objectAtIndex:i];
            NSString* string = device.path;
            if([string isEqualToString:path]) {
                [deviceArray removeObjectAtIndex:i];
                break;
            }
        }
    }
    return device;
}



@end
