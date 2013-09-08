//
//  DrivesViewController.h
//  EasyDrive
//
//  Created by Matthieu Riegler on 20/01/13.
//
//

#import <Cocoa/Cocoa.h>
#import "Device.h"
#import "DriveViewBox.h"

@interface DrivesViewController : NSViewController
{
    IBOutlet NSCollectionView *collectionView;
    IBOutlet NSArrayController *arrayController;    
}
@property (retain) NSMutableArray *drives;
@property (readonly) NSCollectionView *collectionView;
@property (readonly) NSArrayController *arrayController;
@property id target; 


- (void) updateWindow;
@end


