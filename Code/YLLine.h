//
//  YLLine.h
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLRun.h"

@interface YLLine : NSObject {
    NSMutableArray *_runs;
	NSUInteger _width;
}

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, retain) NSArray *runs;
@property (readonly) NSUInteger length;

+ (id) lineWithWidth: (NSUInteger)width;
- (id) initWithWidth: (NSUInteger)width;

- (NSString *) description;

- (BOOL) hasRoomForRun: (YLRun *)run;
- (void) addRun: (YLRun *)run;
- (YLRun *) lastStringRun;
- (NSArray *) popRunsToWrapLine;

@end


