//
//  YLApplicationKitAddition.h
//  Nally
//
//  Created by Yung-Luen Lan on 12/5/10.
//  Copyright 2010 yllan.org. All rights reserved.
//
#import <AppKit/AppKit.h>

@interface NSMutableArray (QueueLikeOperation)
- (id) popFirstObject;
- (id) popLastObject;
- (void) addObjectToFront: (id)object;
- (void) insertObjects: (NSArray *)objects atIndex: (NSUInteger)index;
- (void) addObjectsToFront: (NSArray *)objects;
@end
