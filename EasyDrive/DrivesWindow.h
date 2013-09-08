//
//  DrivesWindow.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 18/01/13.
//
//

#import <Cocoa/Cocoa.h>

typedef enum _DWPosition {
    DWPositionLeft          = NSMinXEdge, // 0 Box on the left
    DWPositionRight         = NSMaxXEdge, // 2 Box on the right
    DWPositionTop           = NSMaxYEdge, // 3 Box on the top

} DWPosition;


@interface DrivesWindow : NSWindow <NSWindowDelegate>
{
    NSView* _view;
    NSPoint _point;
    
@private
    NSColor *_DWBackgroundColor;
    DWPosition _side;
    NSRect _viewFrame;
    NSColor *borderColor;

}

- (DrivesWindow *)initWithView:(NSView *)view
               attachedToPoint:(NSPoint)point;
- (void) setRight;
- (void) setLeft;
- (void) setBottom;


@end
