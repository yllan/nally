//
//  YLTextTransformer.h
//  Nally
//
//  Created by Yung-Luen Lan on 12/4/10.
//  Copyright 2010 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@interface YLTextSuite : NSObject {

}

- (NSString *) wrapText: (NSString *)text withLength: (int)length encoding: (YLEncoding)encoding;
- (NSString *) paddingText: (NSString *)text withLeftPadding: (int)leftPadding;
@end
