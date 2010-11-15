//
//  YLExifController.m
//  Nally
//
//  Created by Jjgod Jiang on 1/5/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "YLExifController.h"

@implementation YLExifController

@synthesize exifData;
@synthesize isoSpeed;
@synthesize exposureTime;
@synthesize modelName;

- (void) showExifPanel
{
    NSArray *isoArray = [exifData objectForKey: (NSString *) kCGImagePropertyExifISOSpeedRatings];
    NSNumber *isoNumber = nil;
    if (isoArray && [isoArray count])
        isoNumber = [isoArray objectAtIndex: 0];
    [self setIsoSpeed: [isoNumber stringValue]];
    
    NSNumber *eTime = [exifData objectForKey: (NSString *) kCGImagePropertyExifExposureTime];
    // readable exposure time
    NSString *eTimeStr = nil;
    if (eTime) {
        double eTimeVal = [eTime doubleValue];
        // zero exposure time...
        if (eTimeVal < 1 && eTimeVal != 0) {
            eTimeStr = [NSString stringWithFormat:@"1/%g", 1/eTimeVal];
        } else
            eTimeStr = [eTime stringValue];
    }
    [self setExposureTime: eTimeStr];

    [exifPanel center];
    [exifPanel makeKeyAndOrderFront: nil];
}

@end
