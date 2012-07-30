//
//  YLSite.m
//  Nally
//
//  Created by Lan Yung-Luen on 11/20/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "YLSite.h"

@implementation YLSite

- (id) init
{
    self = [super init];
    if (self) {
        [self setName: @"Site Name"];
        [self setAddress: @"(your.site.org)"];
        [self setEncoding: YLBig5Encoding];
    }
    return self;
}

+ (YLSite *) site
{
    return [[YLSite new] autorelease];
}


+ (YLSite *) siteWithDictionary: (NSDictionary *)dict
{
    YLSite *s = [[[YLSite alloc] init] autorelease];
    [s setName: [dict valueForKey: @"name"] ?: @""];
    [s setAddress: [dict valueForKey: @"address"] ?: @""];
    [s setEncoding: (YLEncoding)[[dict valueForKey: @"encoding"] unsignedShortValue]];
    [s setAnsiColorKey: (YLANSIColorKey)[[dict valueForKey: @"ansicolorkey"] unsignedShortValue]];
    [s setDetectDoubleByte: [[dict valueForKey: @"detectdoublebyte"] boolValue]];
    return s;
}

- (NSDictionary *) dictionaryOfSite
{
    return [NSDictionary dictionaryWithObjectsAndKeys: [self name] ?: @"", @"name", [self address], @"address",
            [NSNumber numberWithUnsignedShort: [self encoding]], @"encoding", 
            [NSNumber numberWithUnsignedShort: [self ansiColorKey]], @"ansicolorkey", 
            [NSNumber numberWithBool: [self detectDoubleByte]], @"detectdoublebyte", nil];
}

@synthesize name = _name;
@synthesize address = _address;
@synthesize encoding = _encoding;
@synthesize ansiColorKey = _ansiColorKey;
@synthesize detectDoubleByte = _detectDoubleByte;

- (NSString *) description {
    return [NSString stringWithFormat: @"%@:%@", [self name], [self address]];
}

- (id) copyWithZone: (NSZone *)zone
{
    YLSite *s = [[YLSite allocWithZone: zone] init];
    [s setName: [self name]];
    [s setAddress: [self address]];
    [s setEncoding: [self encoding]];
    [s setAnsiColorKey: [self ansiColorKey]];
    [s setDetectDoubleByte: [self detectDoubleByte]];
    return s;
}

@end