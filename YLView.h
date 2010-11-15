//
//  YLView.h
//  Nally
//
//  Created by Yung-Luen Lan on 2006/6/9.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C" {
#endif
    #import "CommonType.h"
#ifdef __cplusplus
}
#endif

@class YLTerminal;
@class YLConnection;
@class YLMarkedTextView;

@interface YLView : NSTabView <NSTextInput> {	
	CGFloat _fontWidth;
	CGFloat _fontHeight;
	
	NSImage *_backedImage;
	
	NSTimer *_timer;
	int _x;
	int _y;
	
	id _markedText;
	NSRange _selectedRange;
	NSRange _markedRange;
	
	IBOutlet YLMarkedTextView *_textField;
    
    int _selectionLocation;
    int _selectionLength;
}

- (void) configure;

- (IBAction) pasteWrap: (id)sender;
- (IBAction) paste: (id)sender;
- (IBAction) pasteColor: (id)sender;

- (void) displayCellAtRow: (int)r column: (int)c;
- (void) updateBackedImage;
- (void) drawSpecialSymbol: (unichar)ch forRow: (int)r column: (int)c leftAttribute: (attribute)attr1 rightAttribute: (attribute)attr2;
- (void) drawSelection;
- (void) drawBlink;
- (void) refreshHiddenRegion;

- (void) clearSelection;

- (YLTerminal *) frontMostTerminal;
- (YLConnection *) frontMostConnection;
- (BOOL) connected;

- (void) extendBottomFrom: (int)start to: (int)end;
- (void) extendTopFrom: (int)start to: (int)end;

- (void) drawStringForRow: (int)r context: (CGContextRef)myCGContext;
- (void) updateBackgroundForRow: (int)r from: (int)start to: (int)end;

@property int x;
@property int y;

- (NSString *) selectedPlainString;
- (BOOL) hasBlinkCell;

- (void) insertText: (id)aString withDelay: (int)microsecond;
@end
