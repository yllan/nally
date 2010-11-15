//
//  YLBundle.m
//  MacBlueTelnet
//
//  Created by Jjgod Jiang on 8/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import "YLBundle.h"

@implementation YLBundle

@synthesize title;
@synthesize description;

- (id) init
{
    if (self = [super init])
    {
        // since this is a semi-abstract class, these need to be defined in the subclasses:
        title = [NSString stringWithString: @"<name undefined>"];
        description = [NSString stringWithString: @"<description undefined>"];
        pluginsMenu = [[[NSApp mainMenu] itemWithTitle: @"Plugins"] submenu];
    }

    return self;
}

- (NSImage *) icon
{
    NSBundle *currBundle = [NSBundle bundleForClass: [self class]];
    NSString *bundleIconName = [currBundle objectForInfoDictionaryKey: @"CFBundleIconFile"];
    NSImage *iconImage = nil;

    if (bundleIconName != nil)
    {
        NSString *iconPathStr = [currBundle pathForResource: bundleIconName 
                                                     ofType: nil];
        iconImage = [[[NSImage alloc] initWithContentsOfFile: iconPathStr] autorelease];
    }

    return iconImage;
}

- (NSMenu *) pluginMenu
{
    if (! pluginsMenu)
        return nil;

    NSMenu *pluginMenu = [[pluginsMenu itemWithTitle: [self title]] submenu];
    if (! pluginMenu)
    {
        NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle: [self title] 
                                                                action: nil 
                                                         keyEquivalent: @""];
        [pluginMenuItem setToolTip: [self description]];
        [pluginsMenu addItem: pluginMenuItem];
        [pluginMenuItem release];
        
        pluginMenu = [[NSMenu alloc] initWithTitle: title];
        [pluginMenuItem setSubmenu: pluginMenu];
        [pluginMenu release];
    }
    
    return pluginMenu;
}

- (NSString *) localizedStringForKey: (NSString *) key
{
    return [[NSBundle bundleForClass: [self class]] localizedStringForKey: key 
                                                                    value: @"" 
                                                                    table: nil];
}

- (void) addMenuItem: (NSMenuItem *) item
{
    [item setTarget: self];
    [[self pluginMenu] addItem: item];
}

- (NSMenuItem *) addMenuItemWithTitle: (NSString *) menuTitle 
                               action: (SEL) action 
                        keyEquivalent: (NSString *) keyEquiv
{
    return [[self pluginMenu] addItemWithTitle: menuTitle 
                                        action: action 
                                 keyEquivalent: keyEquiv];
}

@end
