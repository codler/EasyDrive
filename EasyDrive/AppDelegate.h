//
//  AppDelegate.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MainController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{  
    IBOutlet MainController* mainController;
}

- (void)deduplicateRunningInstances;

@end
