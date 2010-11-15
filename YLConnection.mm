//
//  YLConnection.mm
//  Nally
//
//  Created by Lan Yung-Luen on 12/7/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "YLConnection.h"


@implementation YLConnection

+ (YLConnection *) connectionWithAddress: (NSString *)addr
{
    Class c; 
    if ([addr hasPrefix: @"ssh://"])
        c = NSClassFromString(@"YLSSH");
    else
        c = NSClassFromString(@"YLTelnet");
//    NSLog(@"CONNECTION wih addr: %@ %@", addr, c);
    return (YLConnection *)[[c new] autorelease];
}

- (void) dealloc
{
    [_lastTouchDate release];
    [_icon release];
    [_connectionName release];
    [_connectionAddress release];
    [_terminal release];
    [super dealloc];
}

- (YLTerminal *) terminal
{
	return _terminal;
}

- (void) setTerminal: (YLTerminal *) term
{
	if (term != _terminal) {
		[_terminal release];
		_terminal = [term retain];
        [_terminal setConnection: self];
	}
}

- (BOOL) connected
{
    return _connected;
}

- (void) setConnected: (BOOL)value
{
    _connected = value;
    if (_connected) 
        [self setIcon: [NSImage imageNamed: @"connect.pdf"]];
    else {
        [[self terminal] setHasMessage: NO];
        [self setIcon: [NSImage imageNamed: @"offline.pdf"]];
    }
}

@synthesize connectionName = _connectionName;
@synthesize connectionAddress = _connectionAddress;
@synthesize icon = _icon;
@synthesize isProcessing = _processing;
@synthesize site = _site;

- (NSDate *) lastTouchDate
{
    return _lastTouchDate;
}

#pragma mark -
#pragma mark Dummy Behavior
- (void) close
{
}
- (void) reconnect
{
}
- (BOOL) connectToSite: (YLSite *)site
{
    [self setSite: site];
    return [self connectToAddress: [site address]];
}

- (BOOL) connectToAddress: (NSString *)addr
{
    return YES;
}
- (BOOL) connectToAddress: (NSString *)addr port: (unsigned int)port
{
    return YES;
}

- (void) receiveBytes: (unsigned char *)bytes length: (NSUInteger)length
{
}
- (void) sendBytes: (unsigned char *)msg length: (NSInteger)length
{
}
- (void) sendData: (NSData *)msg
{
}

@end