//
//  YLEmoticon.h
//  Nally
//
//  Created by Lan Yung-Luen on 12/4/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLEmoticon : NSObject {
    NSString *_name;
    NSString *_content;
}

+ (YLEmoticon *) emoticonWithDictionary: (NSDictionary *)dict;
- (NSDictionary *) dictionaryOfEmoticon;

@property (copy) NSString *name;
@property (copy) NSString *content;

@end
