//
//  YLContextualMenuManager.m
//  Nally
//
//  Created by Yung-Luen Lan on 11/28/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "YLContextualMenuManager.h"

static YLContextualMenuManager *gSharedInstance;

@interface YLContextualMenuManager (Private)
- (NSString *) _extractShortURLFromString: (NSString *)s;
- (NSString *) _extractLongURLFromString: (NSString *)s;
@end

@implementation YLContextualMenuManager (Private)
- (NSString *) _extractShortURLFromString: (NSString *)s 
{
    NSMutableString *result = [NSMutableString string];
    int i;
    for (i = 0; i < [s length]; i++) {
        unichar c = [s characterAtIndex: i];
        if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z'))
            [result appendString: [NSString stringWithCharacters: &c length: 1]];
    }
    return result;
}

- (NSString *) _extractLongURLFromString: (NSString *)s 
{
    return [[s componentsSeparatedByString: @"\n"] componentsJoinedByString: @""];
}
@end


@implementation YLContextualMenuManager

+ (YLContextualMenuManager *) sharedInstance 
{
    return gSharedInstance ?: [[[YLContextualMenuManager alloc] init] autorelease];
}

- (id) init 
{
    if (gSharedInstance) {
        [self release];
    } else if (gSharedInstance = [[super init] retain]) {
        // ...
    }
    return gSharedInstance;
}

- (NSArray *) availableMenuItemForSelectionString: (NSString *)selectedString
{
    NSMutableArray *items = [NSMutableArray array];
    NSMenuItem *item;
    NSString *shortURL = [self _extractShortURLFromString: selectedString];
    NSString *longURL = [self _extractLongURLFromString: selectedString];
    
    if ([[longURL componentsSeparatedByString: @"."] count] > 1) {
        if (![longURL hasPrefix: @"http://"]) longURL = [@"http://" stringByAppendingString: longURL];
        item = [[[NSMenuItem alloc] initWithTitle: longURL action: @selector(openURL:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [items addObject: item];
    }
    
    if ([shortURL length] > 0 && [shortURL length] < 8) {
        item = [[[NSMenuItem alloc] initWithTitle: [@"0rz.tw/" stringByAppendingString: shortURL] action: @selector(openURL:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [items addObject: item];
    
        item = [[[NSMenuItem alloc] initWithTitle: [@"tinyurl.com/" stringByAppendingString: shortURL] action: @selector(openURL:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [items addObject: item];
    }
    
    if ([selectedString length] > 0) {
        item = [[[NSMenuItem alloc] initWithTitle: @"Google" action: @selector(google:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [item setRepresentedObject: selectedString];
        [items addObject: item];
        
        item = [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Lookup in Dictionary", @"Menu") action: @selector(lookupDictionary:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [item setRepresentedObject: selectedString];
        [items addObject: item];

        item = [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Copy", @"Menu") action: @selector(copy:) keyEquivalent: @""] autorelease];
        [item setTarget: [[NSApp keyWindow] firstResponder]];
        [item setRepresentedObject: selectedString];
        [items addObject: item];
    }
    return items;
}

#pragma mark -
#pragma mark Action

- (IBAction) openURL: (id)sender
{
    NSString *u = [sender title];
    if (![u hasPrefix: @"http://"])
        u = [@"http://" stringByAppendingString: u];
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: u]];
}

- (IBAction) google: (id)sender
{
    NSString *u = [sender representedObject];
    u = [@"http://www.google.com/search?q=" stringByAppendingString: [u stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: u]];
}

- (IBAction) lookupDictionary: (id)sender
{
    NSString *u = [sender representedObject];
    NSPasteboard *spb = [NSPasteboard pasteboardWithUniqueName];
    [spb declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: self];
    [spb setString: u forType: NSStringPboardType];
    NSPerformService(@"Look Up in Dictionary", spb);
    
}

@end
