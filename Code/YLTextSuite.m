//
//  YLTextTransformer.m
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import "YLTextSuite.h"
#import "YLLine.h"
#import "YLRun.h"
#import "YLApplicationKitAddition.h"

#define SPACE 0x0020
#define TAB 0x0009
#define LF 0x000a
#define CR 0x000d


static BOOL isGluingCharacter(unichar c)
{
    if (c >= 'A' && c <= 'Z') return YES;
    if (c >= 'a' && c <= 'z') return YES;
    if (c >= '0' && c <= '9') return YES;
	NSString *punctuation = @"'\".,;:*&^#@~`=";
    int i;
	for (i = 0; i < [punctuation length]; i++)
		if (c == [punctuation characterAtIndex: i]) return YES;
    return NO;
}

@implementation YLTextSuite

- (NSString *) wrapText: (NSString *)text withLength: (int)length encoding: (YLEncoding)encoding
{
	YLRun *spaceRun = [YLRun runWithString: @" " type: YLRunTypeSpace encoding: encoding];
	YLRun *tabRun = [YLRun runWithString: @"\t" type: YLRunTypeTab encoding: encoding];
	YLRun *lineRun = [YLRun runWithString: @"\n" type: YLRunTypeNewLine encoding: encoding];
	
	YLRun *bufferRun = [[YLRun alloc] initWithString: @"" type: YLRunTypeString encoding: encoding];
	
	NSMutableArray *runs = [NSMutableArray new];

#define COMMIT_BUFFER_RUN() if ([bufferRun.string length] > 0) {\
	[runs addObject: bufferRun];\
	[bufferRun release];\
	bufferRun = [[YLRun alloc] initWithString: @"" type: YLRunTypeString encoding: encoding];\
}
	
	/* Create runs from the text */
	int i;
	for (i = 0; i < [text length]; i++) {
		unichar c = [text characterAtIndex: i];
		if (c == SPACE) {
			COMMIT_BUFFER_RUN();
			[runs addObject: spaceRun];
			continue;
		}
		if (c == TAB) {
			COMMIT_BUFFER_RUN();
			[runs addObject: tabRun];
			continue;
		}
		if (c == CR || c == LF) {
			COMMIT_BUFFER_RUN();
			[runs addObject: lineRun];
			continue;
		}
		NSString *s = [NSString stringWithCharacters: &c length: 1];

		if (!isGluingCharacter(c)) {
			COMMIT_BUFFER_RUN();
			[runs addObject: [YLRun runWithString: s type: YLRunTypeString encoding: encoding]];
		} else {
			[bufferRun appendString: s];
		}
	}
	COMMIT_BUFFER_RUN();
	[bufferRun release];

	NSMutableArray *result = [NSMutableArray array];
	YLLine *line = [[YLLine alloc] initWithWidth: length];
	
	/* Layout the run */
	while ([runs count] > 0) {
		YLRun *run = [runs popFirstObject];
		
		if (run.type == YLRunTypeNewLine) {
			[result addObject: [line description]];
			[line release];
			line = [[YLLine alloc] initWithWidth: length];
			continue;
		}
		
		if ([line hasRoomForRun: run]) {
			[line addRun: run];
			continue;
		}
		
		// if the line is empty, split the run
		if ([line.runs count] == 0) {
			NSArray *splittedRuns = [run forceSplitToMaxLength: length];
			if ([splittedRuns count] > 1)
				[runs addObjectsToFront: splittedRuns];
			else
				[line addRun: run];
			continue;
		}
		
		// create a new line
		[runs addObjectToFront: run];
		if ([run shouldBeAvoidAtBeginOfLine] || [[line lastStringRun] shouldBeAvoidAtEndOfLine])	{
			NSArray *poppedRuns = [line popRunsToWrapLine];
			if ([poppedRuns count] > 0) {
				[runs addObjectsToFront: poppedRuns];
			} else if (line.length < line.width) { // can't pop. force split
				run = [runs popFirstObject];
				[runs addObjectsToFront: [run forceSplitToMaxLength: line.width - line.length]];
				continue;
			}
		}
		
		[result addObject: [line description]];
		[line release];
		line = [[YLLine alloc] initWithWidth: length];
	}
	if ([line.runs count] > 0)
		[result addObject: [line description]];
	[line release];
	[runs release];
	return [result componentsJoinedByString: @"\n"];
}

- (NSString *) paddingText: (NSString *)text withLeftPadding: (int)leftPadding
{
	int i;
	NSMutableString *paddingString = [NSMutableString new];
	for (i = 0; i < leftPadding; i++)
		[paddingString appendString: @" "];
	
	NSMutableString *result = [NSMutableString string];

	for (i = 0; i < [text length]; i++) {
		unichar c = [text characterAtIndex: i];
		if (c == LF) {
			[result appendString: [NSString stringWithCharacters: &c length: 1]]; 
			[result appendString: paddingString];
		} else if (i == 0) {
			[result appendString: paddingString];
			[result appendString: [NSString stringWithCharacters: &c length: 1]];
		} else {
			[result appendString: [NSString stringWithCharacters: &c length: 1]];
		}
	}
	
	[paddingString release];
	return result;
}
@end
