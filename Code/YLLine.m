//
//  YLLine.m
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import "YLLine.h"
#import "YLApplicationKitAddition.h"

#define TAB_SIZE 4

@implementation YLLine

@synthesize width = _width;
@synthesize runs = _runs;

+ (id) lineWithWidth: (NSUInteger)width
{
	return [[[YLLine alloc] initWithWidth: width] autorelease];
}

- (id) initWithWidth: (NSUInteger)width
{
	if ((self = [super init])) {
		_runs = [NSMutableArray new];
		self.width = width;
	}
	return self;
}

- (NSUInteger) length
{
	NSUInteger length = 0;
	for (YLRun *run in _runs) {
		if (length >= _width && run.type == YLRunTypeSpace) continue;
		
		if (run.type == YLRunTypeTab) {
			length += (TAB_SIZE - (length % TAB_SIZE));
			if (length >= _width) 
				length = _width;
			continue;
		}
		length += [run length];
	}
	return length;
}

- (BOOL) hasRoomForRun: (YLRun *)run
{
    if (run.type == YLRunTypeSpace) return YES;
    if (run.type == YLRunTypeTab) return YES;
    if (run.type == YLRunTypeNewLine) return NO;
	
	return run.length + self.length <= self.width;
}

- (void) addRun: (YLRun *)run
{
	[_runs addObject: run];
}

- (YLRun *) lastStringRun
{
	for (YLRun *run in [_runs reverseObjectEnumerator])
		if (run.type == YLRunTypeString) return run;
	return nil;
}

- (NSArray *) popRunsToWrapLine 
{
    NSMutableArray *originRuns = [[NSMutableArray alloc] initWithArray: _runs];
    NSMutableArray *poppedRuns = [NSMutableArray array];
    while ([_runs count] > 0) {
        YLRun *run = [_runs popLastObject];
        [poppedRuns addObjectToFront: run];

        if ([_runs count] > 0 && ![[_runs lastObject] shouldBeAvoidAtEndOfLine] && ![run shouldBeAvoidAtBeginOfLine]) {
            [originRuns release];
            return poppedRuns;
        }
    }
    
    _runs = originRuns;
    return nil;
}

- (NSString *) description
{
	NSMutableString *result = [NSMutableString string];
	
	NSUInteger length = 0;
	for (YLRun *run in _runs) {
		if (length >= _width && run.type == YLRunTypeSpace) continue;
		
		if (run.type == YLRunTypeTab) {
			int numberOfSpaces = (TAB_SIZE - (length % TAB_SIZE));
			while (numberOfSpaces > 0) {
				if (length >= _width) break;
				[result appendString: @" "];
				numberOfSpaces--;
				length++;
			}
			continue;
		}

		[result appendString: run.string];
		length += [run length];
	}
	return result;
}

- (void) dealloc
{
	[_runs release], _runs = nil;
	[super dealloc];
}
@end


