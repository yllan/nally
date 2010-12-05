//
//  TestTextSuite.m
//  Nally
//
//  Created by Yung-Luen Lan on 12/5/10.
//  Copyright 2010 HTC. All rights reserved.
//

#import "TextSuiteTests.h"
#import "YLTextSuite.h"
#import "encoding.h"
#import "YLApplicationKitAddition.h"

@implementation TextSuiteTests
- (void) setUp
{
    init_table();
}

- (void) tearDown
{
    
}

- (void) testWrapLine
{
	YLTextSuite *t = [YLTextSuite new];
	
	STAssertEqualObjects([t wrapText: @"aaaaa" withLength: 5 encoding: YLBig5Encoding], @"aaaaa", @"No Wrap");
	STAssertEqualObjects([t wrapText: @"aaaaaa" withLength: 5 encoding: YLBig5Encoding], @"aaaaa\na", @"Force Wrap");
	STAssertEqualObjects([t wrapText: @"aaa aaa" withLength: 5 encoding: YLBig5Encoding], @"aaa \naaa", @"Simple Wrap");
	STAssertEqualObjects([t wrapText: @"中文字" withLength: 5 encoding: YLBig5Encoding], @"中文\n字", @"Chinese Wrap");
	STAssertEqualObjects([t wrapText: @"中文字" withLength: 4 encoding: YLBig5Encoding], @"中文\n字", @"Chinese Wrap");
	STAssertEqualObjects([t wrapText: @"中a文字" withLength: 3 encoding: YLBig5Encoding], @"中a\n文\n字", @"Chinese Wrap");
	STAssertEqualObjects([t wrapText: @"aa aa ,aa" withLength: 6 encoding: YLBig5Encoding], @"aa \naa ,aa", @"Prohibit Head");
	STAssertEqualObjects([t wrapText: @"aa ,aa" withLength: 5 encoding: YLBig5Encoding], @"aa ,a\na", @"Prohibit Head Pull All Line");
	
	STAssertEqualObjects([t wrapText: @"aaa(aa" withLength: 5 encoding: YLBig5Encoding], @"aaa\n(aa", @"Prohibit Tail");
	STAssertEqualObjects([t wrapText: @"aaa)aa" withLength: 5 encoding: YLBig5Encoding], @"aaa)\naa", @"Prohibit Head");
	
	STAssertEqualObjects([t wrapText: @"你好不好。" withLength: 8 encoding: YLBig5Encoding], @"你好不\n好。", @"Prohibit Head");
	STAssertEqualObjects([t wrapText: @"中文" withLength: 1 encoding: YLBig5Encoding], @"中\n文", @"Force Add");
	
	[t release];
}
@end
