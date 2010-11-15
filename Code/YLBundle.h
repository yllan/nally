//
//  YLBundle.h
//  Nally
//
//  Created by Jjgod Jiang on 8/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLBundle : NSBundle {
    NSString *title;
    NSString *description;
    NSMenu   *pluginsMenu;
}

@property (copy) NSString *title;
@property (copy) NSString *description;
- (NSImage *) icon;

- (NSString *) localizedStringForKey: (NSString *)key;
- (NSMenu *) pluginMenu;
- (void) addMenuItem: (NSMenuItem *)item;
- (NSMenuItem *) addMenuItemWithTitle: (NSString *)title 
                               action: (SEL)action 
                        keyEquivalent: (NSString *)keyEquiv;

@end
