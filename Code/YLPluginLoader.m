//
//  YLPluginLoader.m
//  Nally
//
//  Created by Jjgod Jiang on 8/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import "YLPluginLoader.h"

@implementation YLPluginLoader

NSString * const kPrefixBundleIDStr = @"org.yllan.Nally.Plugin";

- (id) init
{
    if ([super init])
    {
        bundleInstanceList = [[NSMutableArray alloc] init];
        [NSThread detachNewThreadSelector: @selector(startSearch:)
                                 toTarget: self
                               withObject: nil];
    }

    return self;
}

- (void) startSearch: (id)idObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *currPath;
    NSEnumerator *pathEnum;

    // our built bundles are found inside the app's "PlugIns" folder -
    NSMutableArray *bundleSearchPaths = [NSMutableArray array];
    [bundleSearchPaths addObject: [[NSBundle mainBundle] builtInPlugInsPath]];

    // Search other locations for bundles
    // (i.e. $(HOME)/Library/Application Support/BundleLoader)
    NSArray *librarySearchPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, 
                                                                      NSUserDomainMask, YES);
    pathEnum = [librarySearchPaths objectEnumerator];
    while (currPath = [pathEnum nextObject])
        [bundleSearchPaths addObject: [NSString stringWithFormat: @"%@/%@/PlugIns",
                                       currPath,
                                       [[NSProcessInfo processInfo] processName]]];

    pathEnum = [bundleSearchPaths objectEnumerator];
    while (currPath = [pathEnum nextObject])
    {
        NSDirectoryEnumerator *bundleEnum = [[NSFileManager defaultManager] enumeratorAtPath: currPath];
        NSString *currBundlePath;

        if (bundleEnum)
            while (currBundlePath = [bundleEnum nextObject])
                if ([[currBundlePath pathExtension] isEqualToString: @"bundle"])
                {
                    Class bundleInstance = [self loadBundleAtPath: 
                                            [currPath stringByAppendingPathComponent: currBundlePath]];

                    if (bundleInstance)
                        [bundleInstanceList addObject: bundleInstance];
                }
    }

    [pool release];
}

- (Class) loadBundleAtPath: (NSString *)path
{
    NSBundle *currBundle = [NSBundle bundleWithPath: path];
    NSRange searchRange = NSMakeRange(0, [kPrefixBundleIDStr length]);

    if (! currBundle)
        return nil;

    // Check the bundle ID to see if it starts with our know prefix string 
    // (kPrefixBundleIDStr). We want to only load the bundles we care about.
    if ([[currBundle bundleIdentifier] compare: kPrefixBundleIDStr 
                                       options: NSLiteralSearch 
                                         range: searchRange] == NSOrderedSame)
    {
        // load and startup our bundle
        //
        // note: principleClass method actually loads the bundle for us,
        // or we can call [currBundle load] directly.
        Class currPrincipalClass = [currBundle principalClass];
        if (currPrincipalClass)
        {
            id currInstance = [[currPrincipalClass alloc] init];
            if (currInstance)
                return [currInstance autorelease];
        }
    }
    
    return nil;
}

- (void) feedData: (NSData *)data
{
}

@end
