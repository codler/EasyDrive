//
//  DriveViewBox.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 29/01/13.
//
//

#import <Cocoa/Cocoa.h>
#import "Device.h"
@protocol DriveViewBoxDelegate
- (void)openDevice:(Device*) device;
- (void)unmountDevice:(Device*) device;
@end

@interface DriveViewBox : NSBox {
    BOOL overLabel;
    BOOL overEject;
    
    IBOutlet NSTextField* name;
    IBOutlet NSImageView* icon;
    IBOutlet NSCollectionViewItem *item;
    
    @public
    IBOutlet NSView* ejectBox;
    IBOutlet NSImageView* ejectIcon;
    
    id target;
    
    NSTrackingArea* driveTrackingArea;
    NSTrackingArea* ejectTrackingArea;
}

- (void)setTarget: (id)t;
- (NSSize)preferredSize;

@end


@interface DriveViewBoxController : NSCollectionViewItem {
    //id<DriveViewBoxDelegate> delegate;
}
//- (void)setDelegate:(id<DriveViewBoxDelegate>)_delegate;

@property id target;
@end
