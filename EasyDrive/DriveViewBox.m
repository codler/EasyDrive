//
//  DriveViewBox.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 29/01/13.
//
//

#import "DriveViewBox.h"

@implementation DriveViewBox

- (void)awakeFromNib{
    [ejectIcon setImage:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kEjectMediaIcon)]];
    if(! ejectIcon.isEnabled) {
        [ejectIcon setAlphaValue:0.2f];
    }
}

- (NSSize) preferredSize {
    //Computes the width (Icon + label + eject)
    NSSize label = [[name stringValue] sizeWithAttributes:[NSDictionary dictionaryWithObject:[name font] forKey:NSFontAttributeName]];
    CGFloat labelWidth = label.width;
    CGFloat iconWidth = name.frame.origin.x;
    CGFloat ejectWidth = ejectBox.bounds.size.width;
    CGFloat complementarySpace = 20.f;
    return NSMakeSize(iconWidth+labelWidth+complementarySpace+ejectWidth , 40);
}

- (void) viewWillMoveToSuperview:newSuperview{
    //removing old tracking areas because of size change
    [self removeTrackingArea:driveTrackingArea];
    [self removeTrackingArea:ejectTrackingArea];
    
    //Same tracking options for both TrackingAreas
    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingMouseMoved;
    
    NSRect driveRect =  NSMakeRect(0,0,ejectBox.frame.origin.x, self.preferredSize.height);
    driveTrackingArea = [[NSTrackingArea alloc] initWithRect:driveRect
                                                     options: trackingOptions
                                                       owner:self userInfo:nil];
    ejectTrackingArea= [[NSTrackingArea alloc] initWithRect:ejectBox.frame
                                                    options: trackingOptions
                                                      owner:self userInfo:nil];
    [self addTrackingArea:driveTrackingArea];
    [self addTrackingArea:ejectTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if([theEvent trackingArea] == driveTrackingArea) {
        //Entering the drive area
        overLabel = true;

    } else if([theEvent trackingArea] == ejectTrackingArea) {
        //Entering the eject area
        overEject = true;
    } else {
        NSLog(@"ERROR ENTERING TRACKING AREA");
    }
    [self setNeedsDisplayInRect:self.bounds];
    [self needsDisplay];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if([theEvent trackingArea] == driveTrackingArea) {
       //Leaving the drive area
        overLabel = false;
    } else if([theEvent trackingArea] == ejectTrackingArea) {
        //Leaving the eject area
        overEject = false;
    } else {
        NSLog(@"ERROR EXITING TRACKING AREA");
    }
    [self setNeedsDisplayInRect:self.bounds];
    [self needsDisplay];
}

-(void)mouseDown:(NSEvent *)theEvent {
    //blank override to disable superclass behaviour
}

- (void)mouseUp:(NSEvent *)theEvent{
    //Finding which box is below the cursor
    NSArray* subviews = [[self superview] subviews];
    for (DriveViewBox* subview in subviews) {
        NSPoint globalLocation = [NSEvent mouseLocation];
        NSPoint windowLocation = [[subview window] convertScreenToBase: globalLocation ];
        NSPoint viewLocation = [subview convertPoint: windowLocation fromView: nil ];
        if( NSPointInRect( viewLocation,[subview bounds])) {
            [subview clickOnBox];
        }
    }
    
}

-(void) clickOnBox {
    if(overEject && !ejectIcon.isEnabled){
        return; //when clicking on disabled eject
    }
    
    [self performSelector:@selector(blinkItemOnce:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0];
    [self performSelector:@selector(blinkItemOnce:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.05];
    if(overLabel) {
        [[self window] performSelector:@selector(orderOut:) withObject:nil afterDelay:0.15];
        [self performSelector:@selector(openDevice) withObject:nil afterDelay:0.2];
    } else if(overEject && ejectIcon.isEnabled) {
        [[self window] performSelector:@selector(orderOut:) withObject:nil afterDelay:0.15];
        [self performSelector:@selector(unmountDevice) withObject:nil afterDelay:0.2];
    } 
}

-(void) drawRect: (NSRect)dirtyRect{
    //drawing the gradient background on the current Item
    if(overLabel) {
        [NSGraphicsContext saveGraphicsState];
        
        CGFloat yOffset = NSMaxY([self convertRect:self.bounds toView:nil]);
        CGFloat xOffset = NSMinX([self convertRect:self.bounds toView:nil]);
        [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
        
        [[NSColor selectedMenuItemColor] setFill];
        
        dirtyRect.size.width = ejectBox.frame.origin.x;
        
        NSRectFill(dirtyRect);
        [NSGraphicsContext restoreGraphicsState];
    } else if (overEject && ejectIcon.isEnabled) {
        [NSGraphicsContext saveGraphicsState];
        
        CGFloat yOffset = NSMaxY([self convertRect:self.bounds toView:nil]);
        CGFloat xOffset = NSMinX([self convertRect:self.bounds toView:nil]);
        [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
        
        [[NSColor selectedMenuItemColor] setFill];
        
        NSRectFill(ejectBox.frame);
        [NSGraphicsContext restoreGraphicsState];
    } 
}

-(void) blinkItemOnce:(NSNumber*) b {
    overLabel = [b boolValue];
    [self setNeedsDisplayInRect:self.bounds];
    [self setNeedsDisplay:YES];
}

-(void) setTarget: (id)t {
    target = t;
}

-(void) openDevice {
    overEject =false;
    overLabel = false;
    [self setNeedsDisplayInRect:self.bounds];
    [self setNeedsDisplay:YES];
    [NSApp sendAction:@selector(openDevice:) to:target from:self];
}

-(void) unmountDevice {
    overEject =false;
    overLabel = false;
    [self setNeedsDisplayInRect:self.bounds];
    [self setNeedsDisplay:YES];
    [NSApp sendAction:@selector(unmountDevice:) to:target from:self];
}

@end

////////////

@implementation DriveViewBoxController

@synthesize target;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void) awakeFromNib {
    DriveViewBox* dvb = (DriveViewBox*) [self view];
    [dvb setTarget:self];
}

- (void) openDevice:(id) sender {
    [NSApp sendAction:@selector(openDevice:) to:target from:self];
}

- (void) unmountDevice:(id) sender {
    [NSApp sendAction:@selector(unmountDevice:) to:target from:self];
    NSLog(@"Unmount from DriveViewController");
}


@end