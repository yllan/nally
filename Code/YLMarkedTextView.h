//
//  YLMarkedTextView.h
//  Nally
//
//  Created by Yung-Luen Lan on 9/29/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLMarkedTextView : NSView {
	NSAttributedString *_string;
	NSRange _markedRange;
	NSRange _selectedRange;
	NSFont *_defaultFont;
	CGFloat _lineHeight;
	NSPoint _destination;
}

@property (copy) NSAttributedString *string;
@property NSRange markedRange;
@property NSRange selectedRange;
@property (retain) NSFont *defaultFont;
@property NSPoint destination;

@end
