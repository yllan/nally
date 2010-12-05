//
//  YLRun.m
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import "YLRun.h"
#import "encoding.h"

@implementation YLRun

@synthesize encoding = _encoding;
@synthesize type = _type;
@synthesize string = _string;

+ (id) runWithString: (NSString *)string type: (YLRunType)type encoding: (YLEncoding)encoding
{
	return [[[YLRun alloc] initWithString: string type: type encoding: encoding] autorelease];
}

- (id) initWithString: (NSString *)string type: (YLRunType)type encoding: (YLEncoding)encoding
{
	if ((self = [super init])) {
		self.string = string;
		self.type = type;
		self.encoding = encoding;
	}
	return self;
}

- (NSUInteger) length
{
	if (_type == YLRunTypeSpace) return 1;
	if (_type == YLRunTypeTab) return 1; // not correct!

	NSUInteger length = 0;
	int i;
	for (i = 0; i < [_string length]; i++) {
		unichar c = [_string characterAtIndex: i];
		if (c > 0x0020 && c < 0x0080) length++;
		if (c >= 0x0080 && (_encoding == YLBig5Encoding ? U2B[c] : U2G[c]) != 0x0000) length += 2;
	}
	return length;
}

- (void) appendString: (NSString *)string
{
    NSAssert(self.type == YLRunTypeString, @"You can only append run to a string.");
	self.string = [_string stringByAppendingString: string];
}

- (NSArray *) forceSplitToMaxLength: (int)maxLength
{
	NSAssert(self.type == YLRunTypeString, @"You can only split a string.");
	NSUInteger length = 0;
	NSMutableString *firstString = [NSMutableString string];
	NSMutableString *secondString = [NSMutableString string];

	int i;
	for (i = 0; i < [_string length]; i++) {
		unichar c = [_string characterAtIndex: i];
		NSString *s = [NSString stringWithCharacters: &c length: 1];
		if (c > 0x0020 && c < 0x0080) length++;
		if (c >= 0x0080 && (_encoding == YLBig5Encoding ? U2B[c] : U2G[c]) != 0x0000) length += 2;

		[((length <= maxLength) ? firstString : secondString) appendString: s];
	}
	
	if ([firstString length] == 0 || [secondString length] == 0) 
		return [NSArray arrayWithObject: self];
	
	return [NSArray arrayWithObjects: [YLRun runWithString: firstString type: YLRunTypeString encoding: _encoding], [YLRun runWithString: secondString type: YLRunTypeString encoding: _encoding], nil];
}

- (BOOL) shouldBeAvoidAtBeginOfLine
{
    if (_type == YLRunTypeSpace || _type == YLRunTypeTab) return YES;
    if (_type != YLRunTypeString) return NO;
	
    NSArray *forbiddenTokens = [NSArray arrayWithObjects: @"，", @"。", @"、", @"：", @"；", @"？", @"！", @"」", @"』", @"》", @"〉", @"】", @"〕", @"）", @",", @".", @":", @";", @"!", @")", @"]", @"}", @"-", @"–", nil];
    for (NSString *forbiddenToken in forbiddenTokens)
        if ([_string hasPrefix: forbiddenToken]) 
            return YES;
    return NO;
}

- (BOOL) shouldBeAvoidAtEndOfLine
{
    NSArray *forbiddenTokens = [NSArray arrayWithObjects: @"「", @"『", @"《", @"〈", @"【", @"〔", @"（", @"(", @"[", @"{", @"'", @"\"", nil];
    for (NSString *forbiddenToken in forbiddenTokens)
        if ([_string hasSuffix: forbiddenToken]) 
            return YES;
    return NO;
}


- (void) dealloc
{
	[_string release], _string = nil;
	[super dealloc];
}

@end

