//
//  YLConnection.h
//  Nally
//
//  Created by Lan Yung-Luen on 12/7/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YLTerminal.h"

@class YLSite;

@protocol YLConnectionProtocol 
- (void) close;
- (void) reconnect;

- (BOOL) connectToSite: (YLSite *)s;
- (BOOL) connectToAddress: (NSString *)addr;
- (BOOL) connectToAddress: (NSString *)addr port: (unsigned int)port;

- (void) receiveBytes: (unsigned char *)bytes length: (NSUInteger)length;
- (void) sendBytes: (unsigned char *)msg length: (NSInteger)length;
- (void) sendData: (NSData *)msg;

@property (retain) YLTerminal *terminal;
@property BOOL connected;
@property (copy) NSString *connectionName;
@property (copy) NSString *connectionAddress;
@property (retain) NSImage *icon;
@property BOOL isProcessing;
@property (retain) YLSite *site;
- (NSDate *) lastTouchDate;
@end

@interface YLConnection : NSObject <YLConnectionProtocol> {
    NSString *_connectionName;
    NSString *_connectionAddress;
    NSImage *_icon;
    BOOL _processing;
    BOOL _connected;

    NSDate *_lastTouchDate;
    
    YLTerminal *_terminal;
    YLSite *_site;
}

+ (YLConnection *) connectionWithAddress: (NSString *)addr;
@end
