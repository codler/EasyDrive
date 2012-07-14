//
//  AXAlertController.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 13/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AXAlertController : NSWindowController <NSWindowDelegate> {
    
    IBOutlet NSButton* continueButton;
    IBOutlet NSButton* quitButton;
    IBOutlet NSButton* openAXButton; 
    IBOutlet NSImageView *icon;
}


- (IBAction) openUniversalAccess:(id)sender;
- (IBAction) continue:(id)sender;
- (IBAction) quit:(id)sender;

- (void) showAlert;
@end
