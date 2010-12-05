//
//  YLRun.h
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonType.h"

typedef enum {
    YLRunTypeString = 0,
    YLRunTypeSpace,
	YLRunTypeTab,
    YLRunTypeNewLine
} YLRunType;

@interface YLRun : NSObject {
	NSString *_string;
	YLRunType _type;
	YLEncoding _encoding;
}

+ (id) runWithString: (NSString *)string type: (YLRunType)type encoding: (YLEncoding)encoding;
- (id) initWithString: (NSString *)string type: (YLRunType)type encoding: (YLEncoding)encoding;

@property (nonatomic, assign) YLEncoding encoding;
@property (nonatomic, assign) YLRunType type;
@property (nonatomic, copy) NSString *string;
@property (readonly) NSUInteger length;

- (void) appendString: (NSString *)string;
- (NSArray *) forceSplitToMaxLength: (int)maxLength;

- (BOOL) shouldBeAvoidAtBeginOfLine;
- (BOOL) shouldBeAvoidAtEndOfLine;
@end


