//
//  AccessibilityUtilities.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXAlertController.h"

@interface AccessibilityUtilities : NSObject {
    
}

+ (BOOL) isAxApiEnabled;

+ (BOOL) dockIconIsAt:(CGPoint*) point withSize: (CGSize*) size;
+ (NSArray *)subelementsFromElement:(AXUIElementRef)element forAttribute:(NSString *)attribute;
+ (AXUIElementRef)appDockIconByName:(NSString *)appName;



@end
