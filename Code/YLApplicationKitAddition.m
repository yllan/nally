//
//  YLApplicationKitAddition.m
//  Nally
//
//  Created by Yung-Luen Lan on 12/5/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import "YLApplicationKitAddition.h"

@implementation NSMutableArray (QueueLikeOperation)
- (id) popFirstObject
{
    if ([self count] == 0) return nil;
    id firstObject = [[[self objectAtIndex: 0] retain] autorelease];
    [self removeObjectAtIndex: 0];
    return firstObject;
}

- (id) popLastObject
{
	if ([self count] == 0) return nil;
	id lastObject = [[[self lastObject] retain] autorelease];
    [self removeLastObject];
    return lastObject;
}

- (void) addObjectToFront: (id)object
{
    if (!object) return;
    [self insertObject: object atIndex: 0];
}

- (void) insertObjects: (NSArray *)objects atIndex: (NSUInteger)index
{
    if (!objects) return;
    for (id obj in [objects reverseObjectEnumerator])
        [self insertObject: obj atIndex: index];
}

- (void) addObjectsToFront: (NSArray *)objects
{
    if (!objects) return;
    [self insertObjects: objects atIndex: 0];
}
@end
