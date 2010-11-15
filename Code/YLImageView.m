//
//  YLImageView.m
//  Nally
//
//  Created by Jjgod Jiang on 3/27/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import "YLImageView.h"
#import "YLController.h"

enum {
    kFloatRectWidth  = 100,
    kFloatRectHeight = 60,
};

@implementation YLImageView

@synthesize tiffData;

- (id) initWithFrame: (NSRect)frame previewer: (YLImagePreviewer *)thePreviewer
{
    if ([super initWithFrame: frame])
    {
        tipsState = kShowTipsGray;
        tipsRect = NSMakeRect((frame.size.width - kFloatRectWidth) / 2, 10, kFloatRectWidth, kFloatRectHeight);
        
        previewer = thePreviewer;
        [self addTrackingRect: frame
                        owner: self 
                     userData: nil
                 assumeInside: NO];
        
        indicator = [[YLFloatingView alloc] initWithFrame: tipsRect];
        [indicator setWantsLayer: YES];
        [indicator setAlphaValue: 0.0];
        [self addSubview: indicator];
    }
    
    return self;
}

- (void) dealloc
{
    [indicator release];
    [super dealloc];
}

- (void) keyDown: (NSEvent *)event
{
    if ([[event characters] isEqual: @"i"])
    {
        NSBitmapImageRep *rep = [[[self image] representations] objectAtIndex: 0];
        NSDictionary *exif = [rep valueForProperty: NSImageEXIFData];

        // NSLog(@"exif = %@", exif);
        
        YLController *controller = [NSApp delegate];
        YLExifController *exifController = [controller exifController];
        
        NSString *makeName = [tiffData objectForKey:(NSString *) kCGImagePropertyTIFFMake];
        NSString *modelName = [tiffData objectForKey: (NSString *) kCGImagePropertyTIFFModel];
        // NSLog(@"tiff = %@, modelName = %@", tiff, modelName);

        [exifController setExifData: exif];
        [exifController setModelName: [NSString stringWithFormat: @"%@ %@", makeName, modelName]];
        [exifController showExifPanel];
    }
}

- (void) mouseMoved: (NSEvent *)event
{
    [[indicator animator] setAlphaValue: 0.8];
    [[self window] setAcceptsMouseMovedEvents: NO];
}

- (void) mouseEntered: (NSEvent *)event
{
    [[indicator animator] setAlphaValue: 0.8];
}

- (void) mouseExited: (NSEvent *)event
{
    [[indicator animator] setAlphaValue: 0.0];
}

- (void) setPreviewer: (YLImagePreviewer *)thePreviewer
{
    previewer = thePreviewer;
}

- (YLImagePreviewer *) previewer
{
    return previewer;
}

@end
