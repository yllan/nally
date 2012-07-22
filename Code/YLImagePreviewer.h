//
//  YLImagePreviewer.h
//  Nally
//
//  Created by Jjgod Jiang on 2/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HMBlkAppKit/HMBlkProgressIndicator.h>

@interface YLImagePreviewer : NSObject<NSWindowDelegate> {
    NSURL           *_currentFileUrlDownloading;
    NSString        *_currentFileDownloading;
    NSMutableData   *_receivedData;
    NSURLConnection *_connection;
    HMBlkProgressIndicator *_indicator;
    long long        _totalLength;
    NSPanel         *_window;
}

- (void) showLoadingWindow;
- (void) releaseConnection;
- (NSMutableData *) receivedData;
- (NSString *) filename;

@end
