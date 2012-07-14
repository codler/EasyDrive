//
//  Device.h
//  DrivesOnDock
//
//  Created by Matthieu Riegler on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Device : NSObject
{
    @public
    NSString* path;
    NSImage* icon;
}

@property (readonly) NSString* path;
@property (readonly) NSImage* icon;

-(id) initWithPath:(NSString*) s;
@end
