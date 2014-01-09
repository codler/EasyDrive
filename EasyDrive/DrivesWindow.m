//
//  DrivesWindow.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 18/01/13.
//
// This is mostely a stripped down version of Matt Gemmell's MAAttachedWindow
//
// Licence :
//
// License Agreement for Source Code provided by Matt Gemmell

/*
This software is supplied to you by Matt Gemmell in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

  In consideration of your agreement to abide by the following terms, and subject to these terms, Matt Gemmell grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Matt Gemmell as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Matt Gemmell may be used to endorse or promote products derived from the software without specific prior written permission from Matt Gemmell. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Matt Gemmell herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Matt Gemmell on an "AS IS" basis. MATT GEMMELL MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL MATT GEMMELL BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF MATT GEMMELL HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "DrivesWindow.h"

@interface DrivesWindow (DWPrivateMethods)
- (void)_updateGeometry;
- (float)_arrowInset;
- (void)_appendArrowToPath:(NSBezierPath *)path;
@end


typedef void * CGSConnection;
extern OSStatus CGSNewConnection(const void **attributes, CGSConnection * id);

float borderWidth=2.f;
float viewMargin=6.f;
float arrowBaseWidth=30.f;
float arrowHeight=15.f;
float cornerRadius=6.f;
BOOL drawsRoundCornerBesideArrow=YES;


@implementation DrivesWindow

- (DrivesWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point

{
    // Insist on having a valid view.
    if (!view) {
        NSLog(@"No view");
        //return nil;
    }
    
    // Create dummy initial contentRect for window.
    NSRect contentRect = NSZeroRect;
    contentRect.size = [view frame].size;
    
    if ((self = [super initWithContentRect:contentRect
                                 styleMask:  NSBorderlessWindowMask
                                   backing:NSBackingStoreBuffered
                                     defer:NO])) {
        
        _side  = DWPositionRight;
        _view = view;
        _point = point;
        
        //Window bounds its inner view
        contentRect.size.width = view.bounds.size.width;
        contentRect.size.height = view.bounds.size.height;
        contentRect.origin = point;
 
        [self setFrame:contentRect display:YES];
        
        _DWBackgroundColor = [NSColor colorWithCalibratedHue:0.0f saturation:0.0f brightness:0.0f alpha:0.7f];
        
        borderColor = [NSColor colorWithCalibratedHue:1.0f saturation:0.0f brightness:0.7f alpha:0.6f];
        
        [self setMovableByWindowBackground:NO];
        [self setExcludedFromWindowsMenu:YES];
        [self setAlphaValue:1];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self useOptimizedDrawing:YES];
        
        [self setLevel:NSPopUpMenuWindowLevel]; //Above the dock
        
        [[self contentView] addSubview:_view];
        
        [self _updateGeometry];
        [self _updateBackground];

        [self enableBlurForWindow:self];
    }
    
    [self setDelegate:self];
    
    return self;
}


//override because otherwise NSTexturedBackgroundWindowMask can't become key
- (BOOL) canBecomeKeyWindow {
    return YES;
}

- (void)windowDidResignKey:(NSNotification *)notification{
    //Always closing the window when losing focus
    //[self close];
    [self orderOut:nil];
}

- (void) setRight{
    _side = DWPositionLeft;
    [self _updateGeometry];
    [self _updateBackground];
}

- (void) setLeft {
    _side = DWPositionRight;
    [self _updateGeometry];
    [self _updateBackground];
}

- (void) setBottom {
    _side = DWPositionTop;
    [self _updateGeometry];
    [self _updateBackground];
}

- (void)_updateGeometry
{
    NSRect contentRect = NSZeroRect;
    contentRect.size = [_view frame].size;
    
    // Account for viewMargin.
    _viewFrame = NSMakeRect(viewMargin,
                            viewMargin,
                            [_view frame].size.width, [_view frame].size.height);
    
    contentRect = NSInsetRect(contentRect,
                              -viewMargin,
                              -viewMargin);
    
  
    float scaledArrowHeight = arrowHeight;
    switch (_side) {
        case DWPositionLeft:
            contentRect.size.width += scaledArrowHeight;
            break;
        case DWPositionRight:
            _viewFrame.origin.x += scaledArrowHeight;
            contentRect.size.width += scaledArrowHeight;
            break;
        case DWPositionTop:
            _viewFrame.origin.y += scaledArrowHeight;
            contentRect.size.height += scaledArrowHeight;
            break;
    }
    
    // Position frame origin appropriately for _side, accounting for arrow-inset.
    contentRect.origin =  _point;
    //float arrowInset = [self _arrowInset];
    float halfWidth = contentRect.size.width / 2.0;
    float halfHeight = contentRect.size.height / 2.0;
    
    switch (_side) {
        case DWPositionTop:
            contentRect.origin.x -= halfWidth;
            break;
        case DWPositionLeft:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= halfHeight;
            break;
        case DWPositionRight:
            contentRect.origin.y -= halfHeight;
            break;
    }
    
    // Reconfigure window and view frames appropriately.
    [self setFrame:contentRect display:NO];
    [_view setFrame:_viewFrame];
}

-(void)enableBlurForWindow:(NSWindow *)window
{
    //!! Uses Private API.
    
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_8) {
        // 10.8 and below :  http://blog.steventroughtonsmith.com/2008/03/using-core-image-filters-onunder.html
        
        //Definition for non documented methods
        typedef long CGSWindow;
        typedef void *CGSWindowFilterRef;
        
        extern CGError CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, CGSWindowFilterRef *outFilter);
        extern CGError CGSSetCIFilterValuesFromDictionary(CGSConnection cid, CGSWindowFilterRef filter, CFDictionaryRef filterValues);
        extern OSStatus CGSAddWindowFilter( CGSConnection cid, CGSWindow wid, void * fid, int value );

        CGSConnection thisConnection;
        CGSWindowFilterRef compositingFilter;
        int compositingType = 1; // Under the window
        
        /* Make a new connection to CoreGraphics */
        CGSNewConnection(NULL, &thisConnection);
        
        /* Create a CoreImage filter and set it up */
        CGSNewCIFilterByName(thisConnection, (CFStringRef)@"CIGaussianBlur", &compositingFilter);
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
        CGSSetCIFilterValuesFromDictionary(thisConnection, compositingFilter, (__bridge CFDictionaryRef)options);
        
        /* Now apply the filter to the window */
        CGSAddWindowFilter(thisConnection, [window windowNumber], compositingFilter, compositingType);
        
    } else {
        //Since Mavericks : http://stackoverflow.com/questions/19575642/how-to-use-cifilter-on-nswindow-in-osx-10-9-mavericks
        
        typedef void * CGSConnection;
        extern OSStatus CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger   windowNumber, int radius);
        extern CGSConnection CGSDefaultConnectionForThread();
        
        [window setOpaque:NO];
        
        CGSConnection connection = CGSDefaultConnectionForThread();
        CGSSetWindowBackgroundBlurRadius(connection, [window windowNumber], 5.0);
    }
 }

- (void)_updateBackground
{
    // Call NSWindow's implementation of -setBackgroundColor: because we override
    // it in this class to let us set the entire background image of the window
    // as an NSColor patternImage.
    NSDisableScreenUpdates();
    [super setBackgroundColor:[self _backgroundColorPatternImage]];
    if ([self isVisible]) {
        [self display];
        [self invalidateShadow];
    }
    NSEnableScreenUpdates();
}

- (NSColor *)_backgroundColorPatternImage
{
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    NSRect bgRect = NSZeroRect;
    bgRect.size = [bg size];
    
    [bg lockFocus];
    NSBezierPath *bgPath = [self _backgroundPath];
    [NSGraphicsContext saveGraphicsState];
    //[bgPath addClip];
    
    // Draw background.
    [_DWBackgroundColor set];
    [bgPath fill];
    
    // Draw border if appropriate.
    if (borderWidth > 0) {
        // Double the borderWidth since we're drawing inside the path.
        [bgPath setLineWidth:(borderWidth * 1.0) ];
        [borderColor set];
        [bgPath stroke];
    }
    
    [NSGraphicsContext restoreGraphicsState];
    [bg unlockFocus];
    
    return [NSColor colorWithPatternImage:bg];
}


- (NSBezierPath *)_backgroundPath
{
    /*
     Construct path for window background, taking account of:
     1. hasArrow
     2. _side
     3. drawsRoundCornerBesideArrow
     4. arrowBaseWidth
     5. arrowHeight
     6. cornerRadius
     */
    
    /****/
    float scaleFactor = 1.f;
    /***/
    
    float scaledRadius = cornerRadius * scaleFactor;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    NSRect contentArea = NSInsetRect(_viewFrame,
                                     -viewMargin * scaleFactor,
                                     -viewMargin * scaleFactor);
    float minX = ceilf(NSMinX(contentArea) * scaleFactor + 0.5f);
	float midX = NSMidX(contentArea) * scaleFactor;
	float maxX = floorf(NSMaxX(contentArea) * scaleFactor - 0.5f);
	float minY = ceilf(NSMinY(contentArea) * scaleFactor + 0.5f);
	float midY = NSMidY(contentArea) * scaleFactor;
	float maxY = floorf(NSMaxY(contentArea) * scaleFactor - 0.5f);
	
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    
    // Begin at top-left. This will be either after the rounded corner, or
    // at the top-left point if cornerRadius is zero and/or we're drawing
    // the arrow at the top-left or left-top without a rounded corner.
    NSPoint currPt = NSMakePoint(minX, maxY);
    if (scaledRadius > 0 && drawsRoundCornerBesideArrow) {
        currPt.x += scaledRadius;
    }
    
    NSPoint endOfLine = NSMakePoint(maxX, maxY);
    BOOL shouldDrawNextCorner = NO;
    if (scaledRadius > 0 && drawsRoundCornerBesideArrow ) {
        endOfLine.x -= scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    [path moveToPoint:currPt];
    
    // Line to end of this side.
    [path lineToPoint:endOfLine];
    
    // Rounded corner on top-right.
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY)
                                       toPoint:NSMakePoint(maxX, maxY - scaledRadius)
                                        radius:scaledRadius];
    }
    
    
    // Draw the right side, beginning at the top-right.
    endOfLine = NSMakePoint(maxX, minY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 && drawsRoundCornerBesideArrow){
        endOfLine.y += scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    // If arrow should be drawn at right-top point, draw it.
    if (_side == DWPositionLeft) {
        // Line to relevant point before arrow.
        [path lineToPoint:NSMakePoint(maxX, midY + halfArrowWidth)];
        // Draw arrow.
        [self _appendArrowToPath:path];
    }
    
    // Line to end of this side.
    [path lineToPoint:endOfLine];
    
    // Rounded corner on bottom-right.
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
                                       toPoint:NSMakePoint(maxX - scaledRadius, minY)
                                        radius:scaledRadius];
    }
    
    
    // Draw the bottom side, beginning at the bottom-right.
    endOfLine = NSMakePoint(minX, minY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 && drawsRoundCornerBesideArrow ) {
        endOfLine.x += scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    // If arrow should be drawn at bottom-right point, draw it.
    if (_side == DWPositionTop) {
        // Line to relevant point before arrow.
        [path lineToPoint:NSMakePoint(midX + halfArrowWidth, minY)];
        // Draw arrow.
        [self _appendArrowToPath:path];
    }
    
    // Line to end of this side.
    [path lineToPoint:endOfLine];
    
    // Rounded corner on bottom-left.
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY)
                                       toPoint:NSMakePoint(minX, minY + scaledRadius)
                                        radius:scaledRadius];
    }
    
    
    // Draw the left side, beginning at the bottom-left.
    endOfLine = NSMakePoint(minX, maxY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 && drawsRoundCornerBesideArrow) {
        endOfLine.y -= scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    // If arrow should be drawn at left-bottom point, draw it.
   if (_side == DWPositionRight) {
        // Line to relevant point before arrow.
        [path lineToPoint:NSMakePoint(minX, midY - halfArrowWidth)];
        // Draw arrow.
        [self _appendArrowToPath:path];
    }
    
    // Line to end of this side.
    [path lineToPoint:endOfLine];
    
    // Rounded corner on top-left.
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
                                       toPoint:NSMakePoint(minX + scaledRadius, maxY)
                                        radius:scaledRadius];
    }
    
    [path closePath];
    return path;
}


- (void)_appendArrowToPath:(NSBezierPath *)path
{
    
    float scaleFactor = 1.f;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    float scaledArrowHeight = arrowHeight * scaleFactor;
    NSPoint currPt = [path currentPoint];
    NSPoint tipPt = currPt;
    NSPoint endPt = currPt;
    
    // Note: we always build the arrow path in a clockwise direction.
    switch (_side) {
        case DWPositionLeft:
            // Arrow points towards right. We're starting from the top.
            tipPt.x += scaledArrowHeight;
            tipPt.y -= halfArrowWidth;
            endPt.y -= scaledArrowWidth;
            break;
        case DWPositionRight:
            // Arrow points towards left. We're starting from the bottom.
            tipPt.x -= scaledArrowHeight;
            tipPt.y += halfArrowWidth;
            endPt.y += scaledArrowWidth;
            break;
        case DWPositionTop:
            // Arrow points towards bottom. We're starting from the right.
            tipPt.y -= scaledArrowHeight;
            tipPt.x -= halfArrowWidth;
            endPt.x -= scaledArrowWidth;
            break;
        default:
            break; // won't happen, but this satisfies gcc with -Wall
    }
    
    [path lineToPoint:tipPt];
    [path lineToPoint:endPt];
}


@end
