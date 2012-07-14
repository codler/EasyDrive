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

-(id) initWithPath:(NSString*) s {
    self = [super init];
    if(self) {
        path = [[NSString alloc] initWithString:s];
        NSWorkspace* ws = [NSWorkspace sharedWorkspace];
        icon = [ws iconForFile:path];
    }
    return self;
}

@end
