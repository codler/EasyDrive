//
//  AccessibilityUtilities.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccessibilityUtilities.h"

@implementation AccessibilityUtilities

+ (NSArray *)subelementsFromElement:(AXUIElementRef)element forAttribute:(NSString *)attribute{
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


+ (AXUIElementRef)appDockIconByName:(NSString *)appName{
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

+ (BOOL) dockIconIsAt:(CGPoint*) iconPos withSize: (CGSize*) iconSize  {
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


