//
//  AXAlertController.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 13/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AXAlertController.h"

@implementation AXAlertController

- (id)init{
    self = [super initWithWindowNibName:@"AXAlert"];
    if (self) {
        [self.window setDelegate:self];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [icon setImage:[[NSBundle mainBundle] imageForResource:@"External.icns"]];
    NSLog(@"%@",icon);
}

- (void) windowWillClose:(NSNotification *)notification {
    [NSApp stopModal];
    if(! AXAPIEnabled()) {
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0];
    }
}

- (void) showAlert {
    NSLog(@"show alert");
    [NSApp runModalForWindow:self.window];
}



- (IBAction) openUniversalAccess:(id)sender{
    NSLog(@"open AX");
    if(!AXAPIEnabled()){
        [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
    }
    AXUIElementRef _systemWideElement;
    AXUIElementRef _focusedApp;
    CFTypeRef _focusedWindow;
    _systemWideElement = AXUIElementCreateSystemWide();
    AXUIElementCopyAttributeValue(_systemWideElement,
                                  (CFStringRef)kAXFocusedApplicationAttribute,(CFTypeRef*)&_focusedApp);
    AXUIElementCopyAttributeValue((AXUIElementRef)_focusedApp,
                                  (CFStringRef)NSAccessibilityFocusedWindowAttribute,(CFTypeRef*)&_focusedWindow);
}

- (IBAction) continue :(id)sender {
    NSLog(@"continue");
    [self close];
}

- (IBAction) quit:(id)sender {
    NSLog(@"quit");
    [NSApp stopModal];
    [NSApp terminate: nil];
}

- (IBAction) showHelp:(id)sender {
    if([popover isShown]){
        [popover close];
    } else {
        [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}

@end
