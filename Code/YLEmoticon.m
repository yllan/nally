//
//  YLEmoticon.m
//  Nally
//
//  Created by Lan Yung-Luen on 12/4/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "YLEmoticon.h"


@implementation YLEmoticon

+ (YLEmoticon *) emoticonWithDictionary: (NSDictionary *)dict
{
    YLEmoticon *e = [[YLEmoticon alloc] init];
//    [e setName: [d valueForKey: @"name"]];
    [e setContent: [dict valueForKey: @"content"]];
    return [e autorelease];    
}

+ (NSSet *) keyPathsForValuesAffectingDescription
{
	return [NSSet setWithObjects: @"content", nil];
}

- (NSDictionary *) dictionaryOfEmoticon
{
    return [NSDictionary dictionaryWithObjectsAndKeys: [self content], @"content", nil];
}
     
+ (YLEmoticon *) emoticonWithName: (NSString *)n content: (NSString *)c
{
    YLEmoticon *e = [YLEmoticon new];
//    [e setName: n];
    [e setContent: c];
    return [e autorelease];
}

- (YLEmoticon *) init
{
    if ([super init]) {
        [self setContent: @":)"];
    }
    return self;
}

- (void) dealloc
{
    [_content release];
    [_name release];
    [super dealloc];
}

@synthesize name = _name;
@synthesize content = _content;

- (NSString *) description
{
    return [NSString stringWithFormat: @"%@", [[[self content] componentsSeparatedByString: @"\n"] componentsJoinedByString: @""]];
}

@end
