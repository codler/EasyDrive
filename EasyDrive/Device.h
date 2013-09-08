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
    NSString* name;
    NSString* previousName;
    BOOL ejectAvailable;
    NSMutableArray* delegateArray;
}

@property (readonly) NSString* path;
@property (readonly) NSImage* icon;
@property (readonly) NSString* name;
@property (readonly) BOOL ejectAvailable;


-(id) initWithPath:(NSString*) s;  
-(void) setNewPath: (NSString*) newPath;
-(void) addDelegate:(id) delegate;
@end


@protocol DeviceDelegate <NSObject>
@required
-(void) deviceWasUpdated;
@end
