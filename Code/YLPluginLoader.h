//
//  YLPluginLoader.h
//  Nally
//
//  Created by Jjgod Jiang on 8/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YLBundle.h"

@interface YLPluginLoader : NSObject {
    NSMutableArray *bundleInstanceList;
}

- (void) startSearch: (id)idObject;
- (Class) loadBundleAtPath: (NSString *)path;
- (void) feedData: (NSData *)data;

@end
