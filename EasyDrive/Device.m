//
//  Device.m
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Device.h"

@implementation Device

@synthesize path;
@synthesize icon;
@synthesize name;
@synthesize ejectAvailable;

-(id) initWithPath:(NSString*) s {
    self = [super init];
    if(self) {
        delegateArray = [[NSMutableArray alloc] init];
        path = [[NSString alloc] initWithString:s];
        NSWorkspace* ws = [NSWorkspace sharedWorkspace];
        icon = [ws iconForFile:path];
        name =  [[NSFileManager defaultManager] displayNameAtPath:path];
    
 
        if([path isEqualToString:@"/"]) {
            ejectAvailable = false;
        } else {
            ejectAvailable = true;
        }
    }
    return self;
}

-(id) valueForUndefinedKey:(NSString*) key {
    if([key isEqualToString:@"name"]) {
        return name;
    } else if ([key isEqualToString:@"icon"]) {
        return icon;
    } else {
        [NSException raise: NSUndefinedKeyException format:nil];
        return nil;
    }
}


-(void) setNewPath: (NSString*) newPath {
    path= newPath;
    previousName=name;
    name =  [[NSFileManager defaultManager] displayNameAtPath:path];
    [self updateDelegates];
}

-(void) addDelegate:(id)delegate{
    [delegateArray addObject:delegate];
}

- (void) updateDelegates {
    for (id delegate in delegateArray) {
        [delegate deviceWasUpdated];
    }
}


@end
