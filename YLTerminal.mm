//
//  YLTerminal.m
//  Nally
//
//  Created by Yung-Luen Lan on 2006/9/10.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import "YLTerminal.h"
#import "YLLGlobalConfig.h"
#import "encoding.h"

#define CURSOR_MOVETO(x, y) \
do {\
    _cursorX = (x); _cursorY = (y); \
    if (_cursorX < 0) _cursorX = 0; \
    if (_cursorX >= _column) _cursorX = _column - 1;\
    if (_cursorY < 0) _cursorY = 0; \
    if (_cursorY >= _row) _cursorY = _row - 1;\
} while(0);

//BOOL isC0Control(unsigned char c) { return (c <= 0x1F); }
//BOOL isSPACE(unsigned char c) { return (c == 0x20 || c == 0xA0); }
//BOOL isIntermediate(unsigned char c) { return (c >= 0x20 && c <= 0x2F); }
BOOL isParameter(unsigned char c) { return (c >= 0x30 && c <= 0x3F); }
//BOOL isUppercase(unsigned char c) { return (c >= 0x40 && c <= 0x5F); }
//BOOL isLowercase(unsigned char c) { return (c >= 0x60 && c <= 0x7E); }
//BOOL isDelete(unsigned char c) { return (c == 0x7F); }
//BOOL isC1Control(unsigned char c) { return(c >= 0x80 && c <= 0x9F); }
//BOOL isG1Displayable(unsigned char c) { return(c >= 0xA1 && c <= 0xFE); }
//BOOL isSpecial(unsigned char c) { return(c == 0xA0 || c == 0xFF); }
//BOOL isAlphabetic(unsigned char c) { return(c >= 0x40 && c <= 0x7E); }

//ASCII_CODE asciiCodeFamily(unsigned char c) {
//  if (isC0Control(c)) return C0;
//  if (isIntermediate(c)) return INTERMEDIATE;
//  if (isAlphabetic(c)) return ALPHABETIC;
//  if (isDelete(c)) return DELETE;
//  if (isC1Control(c)) return C1;
//  if (isG1Displayable(c)) return G1;
//  if (isSpecial(c)) return SPECIAL;
//  return ERROR;
//}


static unsigned short gEmptyAttr;

@implementation YLTerminal

- (YLTerminal *) init
{
    if ([super init]) {
        _savedCursorX = _savedCursorY = -1;
        _row = [[YLLGlobalConfig sharedInstance] row];
        _column = [[YLLGlobalConfig sharedInstance] column];
        _scrollBeginRow = 0; _scrollEndRow = _row - 1;
        _modeScreenReverse = NO;
		_modeOriginRelative = NO;
        _modeWraptext = YES;
		_modeLNM = YES;
        _modeIRM = NO;
        _emustd = VT102;
        _gotWrapped = NO;
        _grid = (cell **) malloc(sizeof(cell *) * _row);
        int i;
        for (i = 0; i < _row; i++)
            // NOTE: in case _cursorX will exceed _column size (at
            // the border of the screen), we allocate one more unit
            // for this array
            _grid[i] = (cell *) malloc(sizeof(cell) * (_column + 1));
        _dirty = (char *) malloc(sizeof(char) * (_row * _column));
        [self clearAll];
    }
    return self;
}

- (void) dealloc
{
    [_connection release];
    [_pluginLoader release];
    delete _csBuf;
    delete _csArg;
    int i;
    for (i = 0; i < _row; i++)
        free(_grid[i]);
    free(_grid);
    [super dealloc];
}

# pragma mark -
# pragma mark Input Interface
- (void) feedData: (NSData *)data connection: (id)connection
{
    [self feedBytes: (const unsigned char *)[data bytes] length: [data length] connection: connection];
    [_pluginLoader feedData: data];
}

#define SET_GRID_BYTE(c) \
if (_cursorX <= _column - 1) { \
    if (_modeIRM) { \
        for (x = _column - 1; x > _cursorX; x--) { \
            _grid[_cursorY][x] = _grid[_cursorY][x-1]; \
            [self setDirty: YES atRow: _cursorY column: x]; \
        } \
    } \
    _grid[_cursorY][_cursorX].byte = c; \
    _grid[_cursorY][_cursorX].attr.f.fgColor = _fgColor; \
    _grid[_cursorY][_cursorX].attr.f.bgColor = _bgColor; \
    _grid[_cursorY][_cursorX].attr.f.bold = _bold; \
    _grid[_cursorY][_cursorX].attr.f.underline = _underline; \
    _grid[_cursorY][_cursorX].attr.f.blink = _blink; \
    _grid[_cursorY][_cursorX].attr.f.reverse = _reverse; \
    _grid[_cursorY][_cursorX].attr.f.url = NO; \
    [self setDirty: YES atRow: _cursorY column: _cursorX]; \
    _cursorX++; \
} else if (_cursorX == _column && _modeWraptext == YES) { \
    _cursorX = 0; \
    _gotWrapped = YES; \
    if (_cursorY == _scrollEndRow) { \
    	[_delegate updateBackedImage]; \
	    [_delegate extendBottomFrom: _scrollBeginRow to: _scrollEndRow]; \
	    cell *emptyLine = _grid[_scrollBeginRow]; \
	    [self clearRow: _scrollBeginRow]; \
	    for (x = _scrollBeginRow; x < _scrollEndRow; x++) \
		    _grid[x] = _grid[x + 1]; \
	    _grid[_scrollEndRow] = emptyLine; \
	    [self setAllDirty]; \
    } else { \
	    _cursorY++; \
	    if (_cursorY >= _row) _cursorY = _row - 1; \
    } \
    _grid[_cursorY][_cursorX].byte = c; \
    _grid[_cursorY][_cursorX].attr.f.fgColor = _fgColor; \
    _grid[_cursorY][_cursorX].attr.f.bgColor = _bgColor; \
    _grid[_cursorY][_cursorX].attr.f.bold = _bold; \
    _grid[_cursorY][_cursorX].attr.f.underline = _underline; \
    _grid[_cursorY][_cursorX].attr.f.blink = _blink; \
    _grid[_cursorY][_cursorX].attr.f.reverse = _reverse; \
    _grid[_cursorY][_cursorX].attr.f.url = NO; \
    [self setDirty: YES atRow: _cursorY column: _cursorX]; \
    _cursorX++; \
}

- (void) feedBytes: (const unsigned char *)bytes length: (int)len connection: (id)connection
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    int i, x, y;
    unsigned char c;

//    NSLog(@"length: %d", len);
    for (i = 0; i < len; i++) {
        c = bytes[i];
//      if (c == 0x00) continue;
        
        switch (_state)
        {
        case TP_NORMAL:
            if (NO) { // code alignment
            } else if (c == ASC_NUL) { // do nothing
            } else if (c == ASC_ETX) { // FLOW CONTROL? do nothing
            } else if (c == ASC_EQT) { // FLOW CONTROL? do nothing
            } else if (c == ASC_ENQ) { // FLOW CONTROL? do nothing
                unsigned char cmd[1];
                unsigned int cmdLength = 1;
                cmd[1] = ASC_NUL;
                [[self connection] sendBytes:cmd length:cmdLength];
            } else if (c == ASC_ACK) { // FLOW CONTROL? do nothing
            } else if (c == ASC_BEL) { // BEEP
                [[NSSound soundNamed: @"Whit.aiff"] play];
                [self setHasMessage: YES];
            } else if (c == ASC_BS ) { // ^H, backspace
                if (_cursorX > 0) {
				    if (_cursorX == _column && _modeWraptext)
                        _cursorX--; // vt console bug/feature
                    _cursorX--;
                } else if (_cursorX == 0 && _gotWrapped ) { // reverse-wrap
                    _cursorX = _column - 1;
                    if (_cursorY == _scrollBeginRow) {
                       [_delegate updateBackedImage];
                       [_delegate extendTopFrom: _scrollBeginRow to: _scrollEndRow];
                       cell *emptyLine = _grid[_scrollEndRow];
                       [self clearRow: _scrollEndRow];
                    
                       for (x = _scrollEndRow; x > _scrollBeginRow; x--) 
                          _grid[x] = _grid[x - 1];
                       _grid[_scrollBeginRow] = emptyLine;
                       [self setAllDirty];
                    } else {
                       _cursorY--;
                       if (_cursorY < 0) _cursorY = 0;
                    }
                    _gotWrapped = NO;
                    //NSLog(@"%d %d",_cursorX,_cursorY);
                }
            } else if (c == ASC_HT ) { // Horizontal TABulation
                // Normally the tabulation stops for every 8 chars
				_cursorX=(int(_cursorX/8) + 1) * 8;
            } else if (c == ASC_LF ||
                       c == ASC_VT ||
                       c == ASC_FF ) { // Linefeed or Vertical tab or Form feed
				if (_modeLNM == NO) _cursorX = 0;
                if (_cursorY == _scrollEndRow) {
                    cell *emptyLine = _grid[_scrollBeginRow];
                    [self clearRow: _scrollBeginRow];
                    
                    for (x = _scrollBeginRow; x < _scrollEndRow; x++) 
                        _grid[x] = _grid[x + 1];
                    _grid[_scrollEndRow] = emptyLine;
                    [self setAllDirty]; // not necessary be all-dirty
                } else {
                    _cursorY++;
                    if (_cursorY >= _row) _cursorY = _row - 1;
                }
            } else if (c == ASC_CR ) { // Go to the begin of this line
                _cursorX = 0;
            } else if (c == ASC_LS1) { // do nothing for now
                //LS1 (Locked Shift-One in Unicode) Selects G1 characteri
                //set designated by a select character set sequence.
                //However we drop it for now
            } else if (c == ASC_LS0) { // (^O)
                //LS0 (Locked Shift-Zero in Unicode) Selects G0 character
                //set designated by a select character set sequence.
                //However we drop it for now
            } else if (c == ASC_DLE) { // Normally for MODEM
            } else if (c == ASC_DC1) { // XON
            } else if (c == ASC_DC2) { // 
            } else if (c == ASC_DC3) { // XOFF
            } else if (c == ASC_DC4) { 
            } else if (c == ASC_NAK) { 
            } else if (c == ASC_SYN) {
            } else if (c == ASC_ETB) {
            } else if (c == ASC_CAN || c == ASC_SUB) {
                //If received during an escape or control sequence, 
                //cancels the sequence and displays substitution character ().
                //SUB is processed as CAN
                //This is not implemented here
            } else if (c == ASC_EM ) { // ^Y
            } else if (c == ASC_ESC) { // ^[
                _state = TP_ESCAPE;
            } else if (c == ASC_FS ) { // ^\ 
            } else if (c == ASC_GS ) { // ^]
            } else if (c == ASC_RS ) { // ^^
            } else if (c == ASC_US ) { // ^_
// 0x20 ~ 0x7E ascii readible bytes... (btw Big5 second byte 0x40 ~ 0x7E)
            } else if (c == ASC_DEL) { // Ignored on input; not stored
//          } else if (c == 0x80){
/*
// Following characters are used by Big5 or Big5-HKSCS
// Big5 first byte: 0x81 ~ 0xfe
// Big5 second byte: 0x40 ~ 0x7e + 0xa1 ~ 0xfe
// HKSCS first byte: 0x81 ~ 0xa0
            } else if (c >= 0x81 && c <= 0x99) {
            } else if (c == 0x9A) { // SCI (Single Character Introducer)
            } else if (c == 0x9B) { // CSI (Control Sequence Introducer)
                // Single-character CSI is China-Sea incompatible.
                //_csBuf->clear();
                //_csArg->clear();
                //_csTemp = 0;
                //_state = TP_CONTROL;
            } else if (c == 0x9C) {
            } else if (c == 0x9D) {
            } else if (c == 0x9E) {
            } else if (c == 0x9F) {
*/
            } else
                SET_GRID_BYTE(c);

            break;

        case TP_ESCAPE:
			if (NO) {
			} else if (c == ASC_ESC) { // ESCESC according to zterm this happens
                _state = TP_ESCAPE;
            } else if (c == ESC_CSI) { // 0x5B, CSI
                _csBuf->clear();
                _csArg->clear();
                _csTemp = 0;
                _state = TP_CONTROL;
            } else if (c == ESC_RI ) { // scroll down (cursor up)
                if (_cursorY == _scrollBeginRow) {
                    [_delegate updateBackedImage];
                    [_delegate extendTopFrom: _scrollBeginRow to: _scrollEndRow];
                    cell *emptyLine = _grid[_scrollEndRow];
                    [self clearRow: _scrollEndRow];
                    
                    for (x = _scrollEndRow; x > _scrollBeginRow; x--) 
                        _grid[x] = _grid[x - 1];
                    _grid[_scrollBeginRow] = emptyLine;
                    [self setAllDirty];
                } else {
                    _cursorY--;
                    if (_cursorY < 0) _cursorY = 0;
                }
                _state = TP_NORMAL;
            } else if (c == ESC_IND) { // Index, scroll up/cursor down
                if (_cursorY == _scrollEndRow) {
                    [_delegate updateBackedImage];
                    [_delegate extendBottomFrom: _scrollBeginRow to: _scrollEndRow];
                    cell *emptyLine = _grid[_scrollBeginRow];
                    [self clearRow: _scrollBeginRow];
                    
                    for (x = _scrollBeginRow; x < _scrollEndRow; x++) 
                        _grid[x] = _grid[x + 1];
                    _grid[_scrollEndRow] = emptyLine;
                    [self setAllDirty];
                } else {
                    _cursorY++;
                    if (_cursorY >= _row) _cursorY = _row - 1;
                }
                _state = TP_NORMAL;
            } else if (c == ESC_DECSC) { // Save cursor
                _savedCursorX = _cursorX;
                _savedCursorY = _cursorY;
                _state = TP_NORMAL;
            } else if (c == ESC_DECRC) { // Restore cursor
                _cursorX = _savedCursorX;
                _cursorY = _savedCursorY;
                _state = TP_NORMAL;
            } else if (c == ESC_HASH) { // 0x23
                if (i < len-1 && bytes[i+1] == '8'){ // DECALN (fill with E)
                    i++;
					for (y = 0; y <= _row-1; y++) {
					    for (x = 0; x <= _column-1; x++) {
							_grid[y][x].byte = 'E';
							_grid[y][x].attr.v = gEmptyAttr;
							_dirty[y * _column + x] = YES;
						}
					}
//              } else if (i < len-1 && bytes[i+1] == '3'){ //DECDHL
//              } else if (i < len-1 && bytes[i+1] == '4'){ //DECDHL
//              } else if (i < len-1 && bytes[i+1] == '5'){ //DECSWL
//              } else if (i < len-1 && bytes[i+1] == '6'){ //DECDWL
                } else
                    NSLog(@"Unhandled <ESC># case");
                _state = TP_NORMAL;
            } else if (c == ESC_sG0) { // 0x28 Font Set G0
                _state = TP_SCS;
            } else if (c == ESC_sG1) { // 0x29 Font Set G1
                _state = TP_SCS;
            } else if (c == ESC_APPK) { // 0x3D Application keypad mode (vt52)
//              NSLog(@"unprocessed request of application keypad mode");
                _state = TP_NORMAL;
            } else if (c == ESC_NUMK) { // 0x3E Numeric keypad mode (vt52)
//              NSLog(@"unprocessed request of numeric keypad mode");
                _state = TP_NORMAL;
            } else if (c == ESC_NEL) { // 0x45 NEL Next Line (CR+Index)
                _cursorX = 0;
                if (_cursorY == _scrollEndRow) {
                    [_delegate updateBackedImage];
                    [_delegate extendBottomFrom: _scrollBeginRow to: _scrollEndRow];
                    cell *emptyLine = _grid[_scrollBeginRow];
                    [self clearRow: _scrollBeginRow];
                    
                    for (x = _scrollBeginRow; x < _scrollEndRow; x++) 
                        _grid[x] = _grid[x + 1];
                    _grid[_scrollEndRow] = emptyLine;
                    [self setAllDirty];
                } else {
                    _cursorY++;
                    if (_cursorY >= _row) _cursorY = _row - 1;
                }
                _state = TP_NORMAL;
//          } else if (c == ESC_HTS) { // 0x48 Set a tab at the current column
//              Please implement
//              _state = TP_NORMAL;
            } else if (c == ESC_RIS) { // 0x63 RIS reset
                [self clearAll];
                _cursorX = 0, _cursorY = 0;
                _state = TP_NORMAL;
            } else {
                NSLog(@"unprocessed esc: %c(0x%X)", c, c);
                _state = TP_NORMAL;
            }

            break;

        case TP_SCS:
/*
			if (NO) {
            } else if (c == '0') { //Special characters and line drawing set
                _state = TP_NORMAL;
            } else if (c == '1') { //Alternate character ROM
                _state = TP_NORMAL;
            } else if (c == '2') { //Alt character ROM - special characters
                _state = TP_NORMAL;
            } else if (c == 'A') { //United Kingdom (UK)
                _state = TP_NORMAL;
            } else if (c == 'B') { //United States (US)
                _state = TP_NORMAL;
            } else {
                _state = TP_NORMAL;
            }
 */
            _state = TP_NORMAL;
            break;

        case TP_CONTROL:
            if (isParameter(c)) {
                _csBuf->push_back(c);
                if (c >= '0' && c <= '9') {
                    _csTemp = _csTemp * 10 + (c - '0');
				} else if (c == '?') {
					_csArg->push_back(-1);
					_csTemp = 0;
					_csBuf->clear();
                } else if (!_csBuf->empty()) {
                    _csArg->push_back(_csTemp);
                    _csTemp = 0;
                    _csBuf->clear();
                }
            } else if (c == ASC_BS) { // Backspace eats previous parameter.
				if (!_csBuf->empty()) {
					_csArg->pop_front();
				}
			} else if (c == ASC_VT) { // Virtical Tabulation
				if (_modeLNM == NO) _cursorX = 0;
                if (_cursorY == _scrollEndRow) {
                    cell *emptyLine = _grid[_scrollBeginRow];
                    [self clearRow: _scrollBeginRow];
                    
                    for (x = _scrollBeginRow; x < _scrollEndRow; x++) 
                        _grid[x] = _grid[x + 1];
                    _grid[_scrollEndRow] = emptyLine;
                    [self setAllDirty]; // We might not need to set everything dirty.
                } else {
                    _cursorY++;
                    if (_cursorY >= _row) _cursorY = _row - 1;
                }
            } else if (c == ASC_CR) { // CR (Carriage Return)
                _cursorX = 0;
            } else {
                if (!_csBuf->empty()) {
                    _csArg->push_back(_csTemp);
                    _csTemp = 0;
                    _csBuf->clear();
                }

                if (NO) {                   // code alignment
                } else if (c == CSI_ICH) {
                    int p;
                    if (_csArg->size() > 0) {
                        p = _csArg->front();
						if (p < 1) p = 1;
                    } else {
                        p = 1;
                    }
                    for (x = _column - 1; x > _cursorX + p - 1; x--) {
                        _grid[_cursorY][x] = _grid[_cursorY][x-p];
                        [self setDirty: YES atRow: _cursorY column: x];
                    }
                    [self clearRow: _cursorY fromStart: _cursorX toEnd: _cursorX+p-1];
                } else if (c == CSI_CUU) {
                    if (_csArg->size() > 0) {
                        int p = _csArg->front();
						if (p < 1) p = 1;
						_cursorY -= p;
                    } else
                        _cursorY--;
					if (_modeOriginRelative && _cursorY < _scrollBeginRow) {
						_cursorY = _scrollBeginRow;
					} else if (_cursorY < 0) {
						_cursorY = 0;
					}
                } else if (c == CSI_CUD) {
                    if (_csArg->size() > 0) {
                        int p = _csArg->front();
						if (p < 1) p = 1;
                        _cursorY += p;
                    } else
                        _cursorY++;
					if (_modeOriginRelative && _cursorY > _scrollEndRow) {
						_cursorY = _scrollEndRow;
					} else if (_cursorY >= _row) {
						_cursorY = _row - 1;
					}
                } else if (c == CSI_CUF) {
                    if (_csArg->size() > 0) {
                        int p = _csArg->front();
						if (p < 1) p = 1;
                        _cursorX += p;
                    } else
                        _cursorX++;
                    if (_cursorX >= _column) _cursorX = _column - 1;
                } else if (c == CSI_CUB) {
                    if (_csArg->size() > 0) {
                        int p = _csArg->front();
						if (p < 1) p = 1;
                        _cursorX -= p;
                    } else
                        _cursorX--;
                    if (_cursorX < 0) _cursorX = 0;
                } else if (c == CSI_CNL) {
                    _cursorX=0;
                    if (_csArg->size() > 0)
                        _cursorY += _csArg->front();
                    else
                        _cursorY++;
                    if (_cursorY >= _row) _cursorY = _row - 1;
                } else if (c == CSI_CPL) {
                    _cursorX=0;
                    if (_csArg->size() > 0)
                        _cursorY -= _csArg->front();
                    else
                        _cursorY--;
                    if (_cursorY < 0) _cursorY = 0;
                } else if (c == CSI_CHA) { // move to Pn position of current line
                    if (_csArg->size() > 0) {
                       int p = (*_csArg)[0];
                       if (p < 1) p = 1;
                       CURSOR_MOVETO(p - 1, _cursorY);
                    } else {
                       CURSOR_MOVETO(0, _cursorY);
                    }
                } else if (c == CSI_HVP || c == CSI_CUP) { // Cursor Position
                    /*  ^[H			: go to row 1, column 1
                        ^[3H		: go to row 3, column 1
                        ^[3;4H		: go to row 3, column 4 */
                    if (_csArg->size() == 0) {
                        _cursorX = 0, _cursorY = 0;
                    } else if (_csArg->size() == 1) {
                        int p = _csArg->front();
                        if (p < 1) p = 1;
						if (_modeOriginRelative && _scrollBeginRow > 0) {
							p += _scrollBeginRow;
							if (p > _scrollEndRow) p = _scrollEndRow + 1;
						}
                        CURSOR_MOVETO(0, p - 1);
                    } else if (_csArg->size() > 1) {
                        int p = _csArg->front(); _csArg->pop_front();
                        int q = _csArg->front();
                        if (p < 1) p = 1;
                        if (q < 1) q = 1;
						if (_modeOriginRelative && _scrollBeginRow > 0) {
							p += _scrollBeginRow;
							if (p > _scrollEndRow) p = _scrollEndRow + 1;
						}
                        CURSOR_MOVETO(q - 1, p - 1);
                    }
                } else if (c == CSI_ED ) { // Erase Page (cursor does not move)
                    /*  ^[J, ^[0J	: clear from cursor position to end
                        ^[1J		: clear from start to cursor position
                        ^[2J		: clear all */
                    int j;
                    if (_csArg->size() == 0 || _csArg->front() == 0) {
                        // mjhsieh is not comfortable with putting _csArg lookup with
                        // _csArg->size()==0
                        [self clearRow: _cursorY fromStart: _cursorX toEnd: _column - 1];
                        for (j = _cursorY + 1; j < _row; j++)
                            [self clearRow: j];
                    } else if (_csArg->size() > 0 && _csArg->front() == 1) {
                        [self clearRow: _cursorY fromStart: 0 toEnd: _cursorX];
                        for (j = 0; j < _cursorY; j++)
                            [self clearRow: j];
                    } else if (_csArg->size() > 0 && _csArg->front() == 2) {
                        [self clearAll];
                    }
                } else if (c == CSI_EL ) { // Erase Line (cursor does not move)
                    /*  ^[K, ^[0K	: clear from cursor position to end of line
                        ^[1K		: clear from start of line to cursor position
                        ^[2K		: clear whole line */
                    if (_csArg->size() == 0 || _csArg->front() == 0) {
                        [self clearRow: _cursorY fromStart: _cursorX toEnd: _column - 1];
                    } else if (_csArg->size() > 0 && _csArg->front() == 1) {
                        [self clearRow: _cursorY fromStart: 0 toEnd: _cursorX];
                    } else if (_csArg->size() > 0 && _csArg->front() == 2) {
                        [self clearRow: _cursorY];
                    }
                } else if (c == CSI_IL ) { // Insert Line
                    int lineNumber = 0;
                    if (_csArg->size() == 0) 
                        lineNumber = 1;
                    else if (_csArg->size() > 0)
                        lineNumber = _csArg->front();
                    if (lineNumber < 1) lineNumber = 1; //mjhsieh is paranoid

                    int j;
                    for (j = 0; j < lineNumber; j++) {
                        [self clearRow: _scrollEndRow];
                        cell *emptyRow = [self cellsOfRow: _scrollEndRow];
                        int r;
                        for (r = _scrollEndRow; r > _cursorY; r--)
                            _grid[r] = _grid[r - 1];
                        _grid[_cursorY] = emptyRow;
                    }
                    for (j = _cursorY; j <= _scrollEndRow; j++)
                        [self setDirtyForRow: j];
                } else if (c == CSI_DL ) { // Delete Line
                    int lineNumber = 0;
                    if (_csArg->size() == 0) 
                        lineNumber = 1;
                    else if (_csArg->size() > 0)
                        lineNumber = _csArg->front();
                    if (lineNumber < 1) lineNumber = 1; //mjhsieh is paranoid
                    
                    int j;
                    for (j = 0; j < lineNumber; j++) {
                        [self clearRow: _cursorY];
                        cell *emptyRow = [self cellsOfRow: _cursorY];
                        int r;
                        for (r = _cursorY; r < _scrollEndRow; r++)
                            _grid[r] = _grid[r + 1];
                        _grid[_scrollEndRow] = emptyRow;
                    }
                    for (j = _cursorY; j <= _scrollEndRow; j++)
                        [self setDirtyForRow: j];
                } else if (c == CSI_DCH) { // Delete characters at the current cursor position.
                    int p = 1;
                    if (_csArg->size() == 1) {
                        p = _csArg->front();
                    }
                    if (p < 1) p = 1;
                    int j;
                    for (j = _cursorX; j <= _column - 1; j++){
                        if ( j <= _column - 1 - p ) {
                            _grid[_cursorY][j] = _grid[_cursorY][j+p];
                        } else {
                            _grid[_cursorY][j].byte = '\0';
                            _grid[_cursorY][j].attr.v = gEmptyAttr;
                            _grid[_cursorY][j].attr.f.bgColor = _bgColor;
                        }
						_dirty[_cursorY * _column + j] = YES;
                    }
				} else if (c == CSI_HPA) { // goto to absolute character position
					int p = 0;
                    if (_csArg->size() > 0) {
                        p = _csArg->front()-1;
						if (p < 0) p = 0;
                    }
					CURSOR_MOVETO(p,_cursorY);
				} else if (c == CSI_HPR) { // goto to the next position of the line
					int p = 1;
                    if (_csArg->size() > 0) {
                        p = _csArg->front();
						if (p < 1) p = 1;
                    }
					CURSOR_MOVETO(_cursorX+p,_cursorY);					
//				} else if (c == CSI_REP) { // REPEAT, not going to implement for now.
                } else if (c == CSI_DA ) { // Computer requests terminal identify itself.
					unsigned char cmd[10]; // 10 should be enough for now
					unsigned int cmdLength = 0;
                    if (_emustd == VT100) { // VT100, respond ESC[?1;0c
					   cmd[cmdLength++] = 0x1B; cmd[cmdLength++] = 0x5B;
					   cmd[cmdLength++] = 0x3F; cmd[cmdLength++] = '1';
                       cmd[cmdLength++] = 0x3B; cmd[cmdLength++] = '0';
					   cmd[cmdLength++] = 'c';
                    } else if (_emustd == VT102) { // VT102, respond ESC[?6c
					   cmd[cmdLength++] = 0x1B; cmd[cmdLength++] = 0x5B;
					   cmd[cmdLength++] = 0x3F; cmd[cmdLength++] = '6';
					   cmd[cmdLength++] = 'c';
                    }
                    if (_csArg->empty()) {
						[[self connection] sendBytes:cmd length:cmdLength];
					} else if (_csArg->size() == 1 && (*_csArg)[0] == 0){
                        [[self connection] sendBytes:cmd length:cmdLength];
                    }
                } else if (c == CSI_VPA) { // move to Pn line, col remaind the same
					int p = 0;
                    if (_csArg->size() > 0) {
						p = _csArg->front()-1;
						if (p < 0) p = 0;
                    }
					CURSOR_MOVETO(_cursorX,p);
                } else if (c == CSI_VPR) { // move to Pn Line in forward direction
					int p = 1;
                    if (_csArg->size() > 0) {
						p = _csArg->front();
						if (p < 1) p = 1;
                    }
					CURSOR_MOVETO(_cursorX,_cursorY+p);
                } else if (c == CSI_TBC) { // Clear a tab at the current column
                    int p = 1;
                    if (_csArg->size() == 1){
                        p = _csArg->front();
                    }
                    if (p == 3) {
                        NSLog(@"Ignoring request to clear all horizontal tab stops.");
                    } else
                        NSLog(@"Ignoring request to clear one horizontal tab stop.");
                } else if (c == CSI_SM ) {  // set mode
					int doClear = 0;
                    while (!_csArg->empty()) {
                        int p = _csArg->front();
						if (p == -1) {
							_csArg->pop_front();
							if (_csArg->size() == 1) {
								p = _csArg->front();
								if (p == 3) { // Set number of columns to 132
									NSLog(@"132-column mode is not supported.");
									doClear = 1;
									_modeOriginRelative = NO;
									_scrollBeginRow = 0;
									_scrollEndRow = _row - 1;
                                } else if (p == 5 && _modeScreenReverse == NO) { //Set reverse video on screen
                                    _modeScreenReverse = YES;
                                    _reverse = !_reverse;
                                    [self reverseAll];
								} else if (p == 6) { // Set origin to relative
									_modeOriginRelative = YES;
                                } else if (p == 7) { // Set auto-wrap mode
                                    _modeWraptext = YES;
//								} else if (p == 1) { // Set cursor key to application
//								} else if (p == 4) { // Set smooth scrolling
//								} else if (p == 8) { // Set auto-repeat mode
//								} else if (p == 9) { // Set interlacing mode
								}
							}
                        } else if (p == 20) { // Set new line mode
                            _modeLNM = NO;
                        } else if (p == 4) {
                            // selects insert mode and turns INSERT on. New
                            // display characters move old display characters
                            // to the right. Characters moved past the right
							// margin are lost.
                            _modeIRM = YES;
//                      } else if (p == 1) { //When set, the cursor keys send an ESC O prefix, rather than ESC [
//                      } else if (p == 2) { //NSLog(@"ignore setting Keyboard Action Mode (AM)");
//						} else if (p == 6) { //_modeErasure = YES;
//                      } else if (p == 12) { //NSLog(@"ignore re/setting Send/receive (SRM)");
						}
                        _csArg->pop_front();
                    }
					if (doClear == 1) {
						if (_modeOriginRelative) {
							
						} else {
						    [self clearAll];
					        _cursorX = 0;
							_cursorY = 0;
						}
					}
                } else if (c == CSI_HPB) { // move to Pn Location in backward direction, same raw
					int p = 1;
                    if (_csArg->size() > 0) {
						p = _csArg->front();
						if (p < 1) p = 1;
                    }
					CURSOR_MOVETO(_cursorX-p,_cursorY);										
                } else if (c == CSI_VPB) { // move to Pn Line in backward direction
					int p = 1;
                    if (_csArg->size() > 0) {
						p = _csArg->front();
						if (p < 1) p = 1;
                    }
					CURSOR_MOVETO(_cursorX,_cursorY-p);
                } else if (c == CSI_RM ) { // reset mode
					int doClear = 0;
                    while (!_csArg->empty()) {
                        int p = _csArg->front();
						if (p == -1) {
							_csArg->pop_front();
							if (_csArg->size() == 1) {
								p = _csArg->front();
								if (p == 3) { // Set number of columns to 80
									//NSLog(@"132-column mode (re)setting are not supported.");
									doClear = 1;
									_modeOriginRelative = NO;
									_scrollBeginRow = 0;
									_scrollEndRow = _row - 1;
                                } else if (p == 5 && _modeScreenReverse) { // Set non-reverse video on screen
                                    _modeScreenReverse = NO;
                                    _reverse = !_reverse;
                                    [self reverseAll];
								} else if (p == 6) { // Set origin to absolute
									_modeOriginRelative = NO;
						        } else if (p == 7) { // Reset auto-wrap mode (disable)
                                    _modeWraptext = NO;
//							    } else if (p == 1) { // Set cursor key to cursor
//								} else if (p == 4) { // Set jump scrolling
//								} else if (p == 8) { // Reset auto-repeat mode
//								} else if (p == 9) { // Reset interlacing mode
								}
							}
						} else if (p == 20) { // set line feed mode
							_modeLNM == YES;
                        } else if (p == 4) {
                            // selects replace mode and turns INSERT off. New
                            // display characters replace old display characters
                            // at cursor position. The old character is erased.
                            _modeIRM = NO;
//						} else if (p == 6) { //_modeErasure = NO;
						}
                        _csArg->pop_front();
                    }
					if (doClear == 1) {
						[self clearAll];
					    _cursorX = 0, _cursorY = 0;
					}
                } else if (c == CSI_SGR) { // Character Attributes
                    if (_csArg->empty()) { // clear
                        _fgColor = 7;
                        _bgColor = 9;
                        _bold = NO;
                        _underline = NO;
                        _blink = NO;
                        _reverse = NO ^ _modeScreenReverse;
                    } else {
                        while (!_csArg->empty()) {
                            int p = _csArg->front();
                            _csArg->pop_front();
                            if (p  == 0) {
                                _fgColor = 7;
                                _bgColor = 9;
                                _bold = NO;
                                _underline = NO;
                                _blink = NO;
                                _reverse = NO ^ _modeScreenReverse;
                            } else if (30 <= p && p <= 39) {
                                _fgColor = p - 30;
                            } else if (40 <= p && p <= 49) {
                                _bgColor = p - 40;
                            } else if (p == 1) {
                                _bold = YES;
                            } else if (p == 4) {
                                _underline = YES;
                            } else if (p == 5) {
                                _blink = YES;
                            } else if (p == 7) {
                                _reverse = YES ^ _modeScreenReverse;
                            }
                        }
                    }
				} else if (c == CSI_DSR) {
					if (_csArg->size() != 1) {
						//do nothing
                        //NSLog(@"%s %s",(*_csArg)[0],(*_csArg)[1]);
					} else if ((*_csArg)[0] == 5) {
						unsigned char cmd[4];
						unsigned int cmdLength = 0;
						// Report Device OK	<ESC>[0n
						cmd[cmdLength++] = 0x1B;
						cmd[cmdLength++] = 0x5B;
						cmd[cmdLength++] = 0x30;
						cmd[cmdLength++] = CSI_DSR;
						[[self connection] sendBytes:cmd length:cmdLength];
					} else if ((*_csArg)[0] == 6) {
						unsigned char cmd[8];
						unsigned int cmdLength = 0;
                        unsigned int mynum;
						// Report Device OK	<ESC>[y;xR
						cmd[cmdLength++] = 0x1B;
						cmd[cmdLength++] = 0x5B;
                        if ((_cursorY + 1)/10 >= 1) {
						   mynum = int((_cursorY + 1)/10);
                           cmd[cmdLength++] = 0x30+mynum;
                        }
                        mynum = (_cursorY + 1) % 10;
                        cmd[cmdLength++] = 0x30+mynum;
						cmd[cmdLength++] = 0x3B;
                        if ((_cursorX + 1)/10 >= 1) {
						   mynum = int((_cursorX + 1)/10);
                           cmd[cmdLength++] = 0x30+mynum;
                        }
                        mynum = (_cursorX + 1) % 10;
                        cmd[cmdLength++] = 0x30+mynum;
						cmd[cmdLength++] = CSI_CPR;
						[[self connection] sendBytes:cmd length:cmdLength];
					}
                } else if (c == CSI_DECSTBM) { // Assigning Scrolling Region
                    if (_csArg->size() == 0) {
                        _scrollBeginRow = 0;
                        _scrollEndRow = _row - 1;
                    } else if (_csArg->size() == 2) {
                        int s = (*_csArg)[0];
                        int e = (*_csArg)[1];
                        if (s > e) s = (*_csArg)[1], e = (*_csArg)[0];
                        _scrollBeginRow = s - 1;
                        _scrollEndRow = e - 1;
						//NSLog(@"Assigning Scrolling Region between line %d and line %d",s,e);
                    }
					_cursorX = 0;
					_cursorY = _scrollBeginRow;
                } else if (c == CSI_SCP) {
                    _savedCursorX = _cursorX;
                    _savedCursorY = _cursorY;
                } else if (c == CSI_RCP) {
                    if (_savedCursorX >= 0 && _savedCursorY >= 0) {
                        _cursorX = _savedCursorX;
                        _cursorY = _savedCursorY;
                    }
                } else {
                    NSLog(@"unsupported control sequence: 0x%X", c);
                }
                _csArg->clear();
                _state = TP_NORMAL;
            }

            break;
        }
    }

    for (i = 0; i < _row; i++) {
        [self updateDoubleByteStateForRow: i];
        [self updateURLStateForRow: i];
    }
    [_delegate performSelector: @selector(tick)
                    withObject: nil
                    afterDelay: 0.07];
    
    [pool release];
}

# pragma mark -
# pragma mark Start / Stop

- (void) startConnection
{
    [self clearAll];
    [_delegate updateBackedImage];
    [_delegate setNeedsDisplay: YES];
}

- (void) closeConnection
{
    [_delegate setNeedsDisplay: YES];
}

# pragma mark -
# pragma mark Clear

- (void) clearAll
{
    _cursorX = _cursorY = 0;
    attribute t;
    t.f.fgColor = [YLLGlobalConfig sharedInstance]->_fgColorIndex;
    t.f.bgColor = [YLLGlobalConfig sharedInstance]->_bgColorIndex;
    t.f.bold = 0;
    t.f.underline = 0;
    t.f.blink = 0;
    t.f.reverse = 0;
    t.f.url = 0;
    t.f.nothing = 0;
    gEmptyAttr = t.v;
    int i;
    for (i = 0; i < _row; i++) 
        [self clearRow: i];
    
    if (_csBuf)
        _csBuf->clear();
    else
        _csBuf = new std::deque<unsigned char>();
    if (_csArg)
        _csArg->clear();
    else
        _csArg = new std::deque<int>();
    _fgColor = [YLLGlobalConfig sharedInstance]->_fgColorIndex;
    _bgColor = [YLLGlobalConfig sharedInstance]->_bgColorIndex;
    _csTemp = 0;
    _state = TP_NORMAL;
    _bold = NO;
    _underline = NO;
    _blink = NO;
    _reverse = NO ^ _modeScreenReverse;
}

- (void) clearRow: (int)r
{
    [self clearRow: r fromStart: 0 toEnd: _column - 1];
}

- (void) clearRow: (int)r fromStart: (int)s toEnd: (int)e
{
    int i;
    for (i = s; i <= e; i++) {
        _grid[r][i].byte = '\0';
        _grid[r][i].attr.v = gEmptyAttr;
        _grid[r][i].attr.f.bgColor = _bgColor;
        _grid[r][i].attr.f.reverse = _reverse;
        _dirty[r * _column + i] = YES;
    }
}

- (void) reverseAll
{
    int j;
    for (j = 0; j < _row; j++) {
        int i;
        for (i = 0; i <= _column - 1; i++) {
            int tmpColorIndex = _grid[j][i].attr.f.bgColor;
            _grid[j][i].attr.f.bgColor = _grid[j][i].attr.f.fgColor;
            _grid[j][i].attr.f.fgColor = tmpColorIndex;
            _dirty[j*_column + i] = YES;
        }
    }
}

# pragma mark -
# pragma mark Dirty

- (void) setAllDirty
{
    int i, end = _column * _row;
    for (i = 0; i < end; i++)
        _dirty[i] = YES;
}

- (void) setDirtyForRow: (int)r
{
    int i, end = _column * _row;
    for (i = r * _column; i < end; i++)
        _dirty[i] = YES;
}

- (BOOL) isDirtyAtRow: (int)r column: (int)c
{
    return _dirty[(r) * _column + (c)];
}

- (void) setDirty: (BOOL)d atRow: (int)r column: (int)c
{
    _dirty[(r) * _column + (c)] = d;
}

# pragma mark -
# pragma mark Access Data

- (attribute) attrAtRow: (int)r column: (int)c
{
    return _grid[r][c].attr;
}

- (NSString *) stringFromIndex: (int)begin length: (int)length
{
    int i, j;
    unichar textBuf[_row * (_column + 1) + 1];
    unichar firstByte = 0;
    int bufLength = 0;
    int spacebuf = 0;
    for (i = begin; i < begin + length; i++) {
        int x = i % _column;
        int y = i / _column;
        if (x == 0 && i != begin && i - 1 < begin + length) { // newline
            [self updateDoubleByteStateForRow: y];
            unichar cr = 0x000D;
            textBuf[bufLength++] = cr;
            spacebuf = 0;
        }
        int db = _grid[y][x].attr.f.doubleByte;
        if (db == 0) {
            if (_grid[y][x].byte == '\0' || _grid[y][x].byte == ' ')
                spacebuf++;
            else {
                for (j = 0; j < spacebuf; j++)
                    textBuf[bufLength++] = ' ';
                textBuf[bufLength++] = _grid[y][x].byte;
                spacebuf = 0;
            }
        } else if (db == 1) {
            firstByte = _grid[y][x].byte;
        } else if (db == 2 && firstByte) {
            int index = (firstByte << 8) + _grid[y][x].byte - 0x8000;
            YLEncoding encoding = [[[self connection] site] encoding];

            for (j = 0; j < spacebuf; j++)
                textBuf[bufLength++] = ' ';
            textBuf[bufLength++] = (encoding == YLBig5Encoding) ? B2U[index] : G2U[index];
            spacebuf = 0;
        }
    }
    if (bufLength == 0) return nil;
    return [[[NSString alloc] initWithCharacters: textBuf length: bufLength] autorelease];
}

- (cell *) cellsOfRow: (int)r
{
    return _grid[r];
}

# pragma mark -
# pragma mark Update State

- (void) updateDoubleByteStateForRow: (int)r
{
    cell *currRow = _grid[r];
    int i, db = 0;
    for (i = 0; i < _column; i++) {
        if (db == 0 || db == 2) {
            if (currRow[i].byte > 0x7F) db = 1;
            else db = 0;
        } else { // db == 1
            db = 2;
        }
        currRow[i].attr.f.doubleByte = db;
    }
}

- (void) updateURLStateForRow: (int)r
{
    cell *currRow = _grid[r];
    /* TODO: use DFA to reduce the computation  */
    const char *protocols[] = {"http://", "https://", "ftp://", "telnet://", "bbs://", "ssh://", "mailto:"};
    int protocolNum = 7;
    
    BOOL urlState = NO;
    
    if (r > 0) 
        urlState = _grid[r - 1][_column - 1].attr.f.url;
    
    int i;
    for (i = 0; i < _column; i++) {
        if (urlState) {
            unsigned char c = currRow[i].byte;
            if (0x21 > c || c > 0x7E || c == ')')
                urlState = NO;
        } else {
            int p;
            for (p = 0; p < protocolNum; p++) {
                int s, len = strlen(protocols[p]);
                BOOL match = YES;
                for (s = 0; s < len; s++) 
                    if (currRow[i + s].byte != protocols[p][s] || currRow[i + s].attr.f.doubleByte) {
                        match = NO;
                        break;
                    }
                
                if (match) {
                    urlState = YES;
                    break;
                }
            }
        }            
        
        if (currRow[i].attr.f.url != urlState) {
            currRow[i].attr.f.url = urlState;
            [self setDirty: YES atRow: r column: i];
            //            [_delegate displayCellAtRow: r column: i];
            /* TODO: Do not regenerate the region. Draw the url line instead. */
        }
    }
}

- (NSString *) urlStringAtRow: (int)r column: (int)c
{
    if (!_grid[r][c].attr.f.url) return nil;

    while (_grid[r][c].attr.f.url) {
        c--;
        if (c < 0) {
            c = _column - 1;
            r--;
        }
        if (r < 0) 
            break;
    }
    
    c++;
    if (c >= _column) {
        c = 0;
        r++;
    }
    
    NSMutableString *urlString = [NSMutableString string];
    while (_grid[r][c].attr.f.url) {
        [urlString appendFormat: @"%c", _grid[r][c].byte];
        c++;
        if (c >= _column) {
            c = 0;
            r++;
        }
        if (r >= _row) 
            break;
    }
    return urlString;
}

# pragma mark -
# pragma mark Accessor

@synthesize delegate = _delegate;
@synthesize cursorRow = _cursorY;
@synthesize cursorColumn = _cursorX;

- (YLEncoding) encoding
{
    return [[[self connection] site] encoding];
}

- (void) setEncoding: (YLEncoding)encoding
{
    [[[self connection] site] setEncoding: encoding];
}

- (BOOL) hasMessage
{
    return _hasMessage;
}

- (void) setHasMessage: (BOOL)value
{
    if (_hasMessage != value) {
        _hasMessage = value;
        YLLGlobalConfig *config = [YLLGlobalConfig sharedInstance];
        if (_hasMessage) {
            [NSApp requestUserAttention: ([config repeatBounce] ? NSCriticalRequest : NSInformationalRequest)];
            if (_connection != [[_delegate selectedTabViewItem] identifier] || ![NSApp isActive]) { /* Not selected tab */
                [_connection setIcon: [NSImage imageNamed: @"message.pdf"]];
                [config setMessageCount: [config messageCount] + 1];
            } else {
                _hasMessage = NO;
            }
        } else {
            [config setMessageCount: [config messageCount] - 1];
            if ([_connection connected])
                [_connection setIcon: [NSImage imageNamed: @"connect.pdf"]];
            else
                [_connection setIcon: [NSImage imageNamed: @"offline.pdf"]];
        }        
    }
}

@synthesize connection = _connection;
@synthesize pluginLoader = _pluginLoader;

@end
