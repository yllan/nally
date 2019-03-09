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
        if (c >= '!' && c <= '~')
            [result appendString: [NSString stringWithCharacters: &c length: 1]];
    }
    return result;
}

- (NSString *) _extractLongURLFromString: (NSString *)s 
{
    // If the line is potentially a URL that is too long (contains "\\\r"),
    // try to fix it by removing "\\\r"
    return [[s componentsSeparatedByString: @"\\\r"] componentsJoinedByString: @""];
}
@end

@interface NSString (UJStringUrlCategory)
- (BOOL) UJ_isUrlLike;
- (NSString *) UJ_protocolPrefixAppendedUrlString;
@end

@implementation NSString (UJStringUrlCategory)
- (BOOL) UJ_isUrlLike
{
    NSArray *comps = [self componentsSeparatedByString:@"."];
    int count = 0;
    for (NSString *comp in comps)
    {
        if ([comp length])
            count++;
        else
            return NO;
        
        if (count > 1)
            return YES;
    }
    return NO;
}

- (NSString *) UJ_protocolPrefixAppendedUrlString
{
    NSArray *protocols = [NSArray arrayWithObjects:@"http://", @"https://", @"ftp://", @"telnet://",
                          @"bbs://", @"ssh://", @"mailto:", nil];
    for (NSString *p in protocols)
    {
        if ([self hasPrefix:p])
            return self;
    }
    return [@"http://" stringByAppendingString:self];
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
    } else if ((gSharedInstance = [[super init] retain])) {
        // ...
    }
    return gSharedInstance;
}

- (NSArray *) availableMenuItemForSelectionString: (NSString *)selectedString
{
    NSMutableArray *items = [NSMutableArray array];
    __block NSMenuItem *item;
    NSString *shortURL = [self _extractShortURLFromString: selectedString];
    NSString *longURL = [self _extractLongURLFromString: selectedString];
    
    if ([longURL UJ_isUrlLike])
    {
        // Split the selected text into blocks seperated by one of the characters in seps
        NSCharacterSet *seps = [NSCharacterSet characterSetWithCharactersInString:@" \r\n"];
        NSArray *blocks = [longURL componentsSeparatedByCharactersInSet:seps];

        // Use out only lines that really are URLs
        NSMutableArray *urls = [NSMutableArray array];
        for (NSString *block in blocks)
        {
            if ([block UJ_isUrlLike])
                [urls addObject:[block UJ_protocolPrefixAppendedUrlString]];
        }

        // Create menu items
        // If there is only one line, then use the text as title
        // Otherwise use the localized string of "Open mutiple URLs"
        
        if ([urls count] > 0)
        {
            NSString *title = @"";
            if ([urls count] > 1)
                title = NSLocalizedString(@"Open mutiple URLs", @"Open mutiple URLs");
            else if ([urls count] == 1)
                title = [urls objectAtIndex: 0];

            if (_urlsToOpen)
                [_urlsToOpen release];
            _urlsToOpen = [urls copy];
            item = [[[NSMenuItem alloc] initWithTitle: title
                                               action: @selector(openURL:)
                                        keyEquivalent: @""] autorelease];
            [item setTarget: self];
            [items addObject: item];
        }
    }

    BOOL (^isAllDigit)(NSString *) = ^(NSString *s) {
        NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange r = [s rangeOfCharacterFromSet: nonNumbers];
        return (BOOL)(r.location == NSNotFound);
    };
    // I know this should be done with regex, but it's available in 10.7+ only.
    
    void (^addShortenedURLMenuItem)(NSString *title, NSString *actualURLString) = ^(NSString *title, NSString *actualURLString) {
        [_urlsToOpen release];
        _urlsToOpen = [@[actualURLString] copy];
        
        item = [[[NSMenuItem alloc] initWithTitle: title action: @selector(openURL:) keyEquivalent: @""] autorelease];
        [item setTarget: self];
        [items addObject: item];
    };
    
    if ([shortURL hasPrefix: @"sm"] && [shortURL length] <= 10 && isAllDigit([shortURL substringFromIndex: 2])) {
        addShortenedURLMenuItem([@"NicoNico/" stringByAppendingString: shortURL],
                                [@"http://www.nicovideo.jp/watch/" stringByAppendingString: shortURL]);
    } else if ([shortURL hasPrefix: @"id="] && [shortURL length] <= 12 && isAllDigit([shortURL substringFromIndex: 3])) {
        addShortenedURLMenuItem([@"pixiv_illust/" stringByAppendingString: shortURL],
                                [@"http://www.pixiv.net/member_illust.php?mode=medium&illust_" stringByAppendingString: shortURL]);
    } else if ([shortURL hasPrefix: @"mid="] && [shortURL length] <= 12 && isAllDigit([shortURL substringFromIndex: 4])) {
        addShortenedURLMenuItem([@"pixiv_member/" stringByAppendingString: [shortURL substringFromIndex: 4]],
                                [@"http://www.pixiv.net/member.php?id=" stringByAppendingString: [shortURL substringFromIndex: 4]]);
    } else if ([shortURL hasSuffix:@".jpg"] || [shortURL hasSuffix:@".jpeg"]) {
        addShortenedURLMenuItem(@"Image search by GOOGLE", [@"https://www.google.com/searchbyimage?&image_url=" stringByAppendingString: shortURL]);
    } else if ([shortURL length] == 4) {
        addShortenedURLMenuItem([@"ppt.cc/" stringByAppendingString: shortURL],
                                [@"http://ppt.cc/" stringByAppendingString: shortURL]);
    } else if ([shortURL length] == 5) {
        addShortenedURLMenuItem([@"0rz.tw/" stringByAppendingString: shortURL],
                                [@"http://0rz.tw/" stringByAppendingString: shortURL]);
    } else if ([shortURL length] == 6 || [shortURL length] == 7) {
        addShortenedURLMenuItem([@"tinyurl.com/" stringByAppendingString: shortURL],
                                [@"http://tinyurl.com/" stringByAppendingString: shortURL]);
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
    NSMutableArray *urls = [NSMutableArray array];
    for (NSString *u in _urlsToOpen)
    {
        u = [u UJ_protocolPrefixAppendedUrlString];
        [urls addObject:[NSURL URLWithString:[u stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }

    [[NSWorkspace sharedWorkspace] openURLs:urls
                    withAppBundleIdentifier:nil
                                    options:NSWorkspaceLaunchDefault
             additionalEventParamDescriptor:nil
                          launchIdentifiers:nil];
    [_urlsToOpen release];
    _urlsToOpen = nil;
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
