//
//  YLImageView.h
//  Nally
//
//  Created by Jjgod Jiang on 3/27/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YLImagePreviewer.h"
#import "YLFloatingView.h"

enum showTips { kShowTipsNone, kShowTipsWhite, kShowTipsGray };

@interface YLImageView : NSImageView {
    NSRect tipsRect;
    enum showTips tipsState;
    
    YLImagePreviewer *previewer;
    YLFloatingView *indicator;
    
    NSDictionary *tiffData;
}

@property (retain) NSDictionary *tiffData;

- (id) initWithFrame: (NSRect)frame previewer: (YLImagePreviewer *)thePreviewer;
- (void) setPreviewer: (YLImagePreviewer *)thePreviewer;
- (YLImagePreviewer *)previewer;

@end
