//
//  DrivesViewController.m
//  EasyDrive
//
//  Created by Matthieu Riegler on 20/01/13.
//
//

#import "DrivesViewController.h"


@implementation DrivesViewController

@synthesize collectionView;
@synthesize arrayController;


- (void)awakeFromNib {
    float height=0, maxwidth=0;
    
    for(int i=0;i<[self.drives count]; i++) {
        height += [[[collectionView itemAtIndex:i] view] bounds].size.height;
        if([[[collectionView itemAtIndex:i] view] frame].size.width > maxwidth) {
            maxwidth = [[[collectionView itemAtIndex:i] view] frame].size.width;
        }
    }
    
    [[self view] setAlphaValue:1.0f];
    [[self view] setFrame:NSMakeRect([self view].frame.origin.x,[self view].frame.origin.y,maxwidth, height)];
    [[self view] setNeedsDisplay:YES];
    
    [collectionView setSelectionIndexes:nil];
    [self updateWindow];
}


- (BOOL)acceptsFirstResponder {
    return YES;
}


- (void) updateWindow {    
    //on recupère le modèle sous jacent
    //On calcule la largeur max des items
    //On ajuste leur largeur et celle de la fenetre en conséquence
    
    [arrayController setContent:self.drives];

    NSSize s = [collectionView maxItemSize];

    float height=0, maxwidth=0;
    for(int i=0;i<[[arrayController arrangedObjects] count]; i++) {
        DriveViewBox* dvb = (DriveViewBox*)[[collectionView itemAtIndex:i] view];
        NSSize prefSize = [dvb preferredSize];
        
        height += prefSize.height;        
        
        if(prefSize.width > maxwidth) {
            maxwidth = prefSize.width;
        }
    }

    [[self view] setNeedsDisplay:YES];
    [[self view] setAlphaValue:1.0f];
    [[self view] setFrame:NSMakeRect([self view].frame.origin.x,[self view].frame.origin.y,maxwidth, height)];
    
    s.width = maxwidth;
    
    //NSSize size = NSMakeSize(maxwidth, 0);
    [collectionView setMinItemSize:s];
    [collectionView setMaxItemSize:s];
 
}

@end
