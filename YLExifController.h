//
//  YLExifController.h
//  Nally
//
//  Created by Jjgod Jiang on 1/5/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YLExifController : NSObject {
    IBOutlet NSTextField *exposure;
    IBOutlet NSTextField *fNumber;
    IBOutlet NSTextField *iso;
    IBOutlet NSTextField *model;
    IBOutlet NSTextField *date;
    IBOutlet NSPanel     *exifPanel;
    
    NSDictionary *exifData;
    NSString *isoSpeed;
    NSString *exposureTime;
    NSString *modelName;
}

@property (retain) NSDictionary *exifData;
@property (assign) NSString *isoSpeed;
@property (assign) NSString *exposureTime;
@property (assign) NSString *modelName;

- (void) showExifPanel;

@end
