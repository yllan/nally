//
//  YLTerminal.h
//  Nally
//
//  Created by Yung-Luen Lan on 2006/9/10.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <deque>
#import "CommonType.h"
#import "YLView.h"
#import "YLConnection.h"
#import "YLPluginLoader.h"

// single character control command
#define ASC_NUL     0x00 // NULL
#define ASC_SOH     0x01 // START OF HEADING
#define ASC_STX     0x02 // START OF TEXT
#define ASC_ETX     0x03 // END OF TEXT
#define ASC_EQT     0x04 // END OF TRANSMISSION
#define ASC_ENQ     0x05 // ^E, ENQUIRE
#define ASC_ACK     0x06 // ACKNOWLEDGE
#define ASC_BEL     0x07 // ^G, BELL (BEEP)
#define ASC_BS      0x08 // ^H, BACKSPACE
#define ASC_HT      0x09 // ^I, HORIZONTAL TABULATION
#define ASC_LF      0x0A // ^J, LINE FEED
#define ASC_VT      0x0B // ^K, Virtical Tabulation
#define ASC_FF      0x0C // ^L, Form Feed
#define ASC_CR      0x0D // ^M, Carriage Return
#define ASC_LS1     0x0E // Shift Out
#define ASC_LS0     0x0F // ^O, Shift In
#define ASC_DLE     0x10 // Data Link Escape, normally MODEM
#define ASC_DC1     0x11 // Device Control One, XON
#define ASC_DC2     0x12 // Device Control Two
#define ASC_DC3     0x13 // Device Control Three, XOFF
#define ASC_DC4     0x14 // Device Control Four
#define ASC_NAK     0x15 // Negative Acknowledge
#define ASC_SYN     0x16 // Synchronous Idle
#define ASC_ETB     0x17 // End of Transmission Block
#define ASC_CAN     0x18 // Cancel
#define ASC_EM      0x19 // End of Medium
#define ASC_SUB     0x1A // Substitute
#define ASC_ESC     0x1B // Escape
#define ASC_FS      0x1C // File Separator
#define ASC_GS      0x1D // Group Separator
#define ASC_RS      0x1E // Record Separator
#define ASC_US      0x1F // Unit Separator
#define ASC_DEL     0x7F // Delete, Ignored on input; not stored in buffer.

// Escape Sequence
#define ESC_HASH    0x23 // #, Several DEC modes..
#define ESC_sG0     0x28 // (, Font Set G0
#define ESC_sG1     0x29 // ), Font Set G1
#define ESC_APPK    0x3D // =, Appl. keypad
#define ESC_NUMK    0x3E // >, Numeric keypad
#define ESC_DECSC   0x37 // 7,
#define ESC_DECRC   0x38 // 8,
#define ESC_BPH     0x42 // B,
#define ESC_NBH     0x43 // C,
#define ESC_IND     0x44 // D, Index
#define ESC_NEL     0x45 // E, Next Line
#define ESC_SSA     0x46 // F,
#define ESC_ESA     0x47 // G,
#define ESC_HTS     0x48 // H, Tab Set
#define ESC_HTJ     0x49 // I,
#define ESC_VTS     0x4A // J,
#define ESC_PLD     0x4B // K,
#define ESC_PLU     0x4C // L,
#define ESC_RI      0x4D // M, Reverse Index
#define ESC_SS2     0x4E // N, Single Shift Select of G2 Character Set
#define ESC_SS3     0x4F // O, Single Shift Select of G3 Character Set
#define ESC_DCS     0x50 // P, Device Control String
#define ESC_PU1     0x51 // Q,
#define ESC_PU2     0x52 // R,
#define ESC_STS     0x53 // S,
#define ESC_CCH     0x54 // T,
#define ESC_MW      0x55 // U,
#define ESC_SPA     0x56 // V, Start of Guarded Area
#define ESC_EPA     0x57 // W, End of Guarded Area
#define ESC_SOS     0x58 // X, Start of String
//#define ESC_      0x59 // Y,
#define ESC_SCI     0x5A // Z, Return Terminal ID
#define ESC_CSI     0x5B // [, Control Sequence Introducer
#define ESC_ST      0x5C // \, String Terminator
#define ESC_OSC     0x5D // ], Operating System Command
#define ESC_PM      0x5E // ^, Privacy Message
#define ESC_APC     0x5F // _, Application Program Command
#define ESC_RIS     0x63 // c, RIS reset

// Control sequences
#define CSI_ICH     0x40 // INSERT CHARACTER, requires DCSM implementation
#define CSI_CUU     0x41 // A, CURSOR UP
#define CSI_CUD     0x42 // B, CURSOR DOWN
#define CSI_CUF     0x43 // C, CURSOR FORWARD
#define CSI_CUB     0x44 // D, CURSOR BACKWARD
#define CSI_CNL     0x45 // E, CURSOR NEXT LINE
#define CSI_CPL     0x46 // F, CURSOR PRECEDING LINE
#define CSI_CHA     0x47 // G, CURSOR CHARACTER ABSOLUTE
#define CSI_CUP     0x48 // H, CURSOR POSITION
#define CSI_CHT     0x49 // I, CURSOR FORWARD TABULATION
#define CSI_ED      0x4A // J, ERASE IN PAGE
#define CSI_EL      0x4B // K, ERASE IN LINE
#define CSI_IL      0x4C // L, INSERT LINE
#define CSI_DL      0x4D // M, DELETE LINE
#define CSI_EF      0x4E // N, Erase in Field, not implemented
#define CSI_EA      0x4F // O, Erase in Area, not implemented
#define CSI_DCH     0x50 // P, DELETE CHARACTER 
#define CSI_SSE     0x51 // Q, ?
#define CSI_CPR     0x52 // R, ACTIVE POSITION REPORT, this is for responding
#define CSI_SU      0x53 // S, ?
#define CSI_SD      0x54 // T, ?
#define CSI_NP      0x55 // U, ?
#define CSI_PP      0x56 // V, ?
#define CSI_CTC     0x57 // W, CURSOR TABULATION CONTROL, not implemented
#define CSI_ECH     0x58 // X, ERASE CHARACTER
#define CSI_CVT     0x59 // Y, CURSOR LINE TABULATION, not implemented
#define CSI_CBT     0x5A // Z, CURSOR BACKWARD TABULATION, not implemented
#define CSI_SRS     0x5B // [, ?
#define CSI_PTX     0x5C // \, ?
#define CSI_SDS     0x5D // ], ?
#define CSISIMD     0x5E // ^, ?
#define CSI_HPA     0x60 // _, CHARACTER POSITION ABSOLUTE
#define CSI_HPR     0x61 // a, CHARACTER POSITION FORWARD
#define CSI_REP     0x62 // b, REPEAT, not implemented
#define CSI_DA      0x63 // c, DEVICE ATTRIBUTES
#define CSI_VPA     0x64 // d, LINE POSITION ABSOLUTE
#define CSI_VPR     0x65 // e, LINE POSITION FORWARD
#define CSI_HVP     0x66 // f, CHARACTER AND LINE POSITION
#define CSI_TBC     0x67 // g, TABULATION CLEAR, not implemented, ignored
#define CSI_SM      0x68 // h, Set Mode, not implemented, ignored
#define CSI_MC      0x69 // i, MEDIA COPY, not implemented, ignored
#define CSI_HPB     0x6A // j, CHARACTER POSITION BACKWARD
#define CSI_VPB     0x6B // k, LINE POSITION BACKWARD
#define CSI_RM      0x6C // l, Reset Mode. not implemented, ignored
#define CSI_SGR     0x6D // m, SELECT GRAPHIC RENDITION
#define CSI_DSR     0x6E // n, DEVICE STATUS REPORT
#define CSI_DAQ     0x6F // o, DEFINE AREA QUALIFICATION, not implemented
#define CSI_DFNKY   0x70 // p, shouldn't be implemented
//0x71 // q,
#define CSI_DECSTBM 0x72 // r, Set Top and Bottom Margins
#define CSI_SCP     0x73 // s, Saves the cursor position.
#define CSI_RCP     0x75 // u, Restores the cursor position.

@interface YLTerminal : NSObject {	
@public
	unsigned int _row;
	unsigned int _column;
	int _cursorX;
	int _cursorY;
	unsigned int _offset;
	
	int _savedCursorX;
	int _savedCursorY;

	int _fgColor;
	int _bgColor;
	BOOL _bold;
	BOOL _underline;
	BOOL _blink;
	BOOL _reverse;
	
	cell **_grid;
	char *_dirty;
	
	enum { TP_NORMAL, TP_ESCAPE, TP_CONTROL, TP_SCS } _state;
    enum { VT100, VT102 } _emustd;
    
// YLEncoding _encoding;
    
	std::deque<unsigned char> *_csBuf;
	std::deque<int> *_csArg;
	unsigned int _csTemp;
	YLView *_delegate;
    
    int _scrollBeginRow;
    int _scrollEndRow;
    
    BOOL _hasMessage;
    BOOL _gotWrapped;
	
    BOOL _modeScreenReverse;  // reverse (true), not reverse (false, default)
	BOOL _modeOriginRelative; // relative origin (true), absolute origin (false, default)
    BOOL _modeWraptext;       // autowrap (true, default), wrap disabled (false)
    BOOL _modeLNM;            // line feed (true, default), new line (false)
    BOOL _modeIRM;            // insert (true), replace (false, default)

    YLConnection *_connection;
    YLPluginLoader *_pluginLoader;
}

/* Input Interface */
- (void) feedData: (NSData *)data connection: (id)connection;
- (void) feedBytes: (const unsigned char *)bytes length: (int)len connection: (id)connection;

/* Start / Stop */
- (void) startConnection;
- (void) closeConnection;

/* Clear */
- (void) clearRow: (int)r;
- (void) clearRow: (int)r fromStart: (int)s toEnd: (int)e;
- (void) clearAll;

/* Dirty */
- (BOOL) isDirtyAtRow: (int)r column:(int)c;
- (void) setAllDirty;
- (void) setDirty: (BOOL)d atRow: (int)r column: (int)c;
- (void) setDirtyForRow: (int)r;

/* Access Data */
- (attribute) attrAtRow: (int)r column: (int)c;
- (NSString *) stringFromIndex: (int)begin length: (int)length;
- (cell *) cellsOfRow: (int)r;

/* Update State */
- (void) reverseAll;
- (void) updateURLStateForRow: (int)r;
- (void) updateDoubleByteStateForRow: (int)r;
- (NSString *) urlStringAtRow: (int)r column: (int)c;

/* Accessor */
@property (assign) id delegate;
@property int cursorRow;
@property int cursorColumn;
@property YLEncoding encoding;
@property BOOL hasMessage;
@property (retain) YLConnection *connection;
@property (retain) YLPluginLoader *pluginLoader;

@end
