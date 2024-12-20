// SBASIC Win32 interface
// Author: Dominique Ezvan

#define _WIN32_WINNT 0x0500
#include <windows.h>
#include "win32.h"
#include "sb32.h"
#include "display.h"

#define HIDE_MOUSE       0

#define DEFAULT_WIDTH    (8 * TEXT_COLS + 16 + 17)
#define DEFAULT_HEIGHT   (15 * TEXT_LINES + 54 + 17)
#define PATH_NOT_FOUND   0
#define PATH_DIRECTORY   1
#define PATH_FILE        2
#define PATH_ERROR       3
#define DIR_ATTRIBUTES   (FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_HIDDEN | FILE_ATTRIBUTE_SYSTEM)
#define FILE_ATTRIBUTES  (FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_HIDDEN | FILE_ATTRIBUTE_SYSTEM | FILE_ATTRIBUTE_ARCHIVE)

// Windows variables
static HINSTANCE Instance;
static HWND MainWnd;
static HWND ReadMeWnd;
static HWND HelpWnd;
HWND DisplayWnd;
static LONG MaxWidth;      // total width of main window
static LONG MaxHeight;     // total height of main window
ULONG TextCols;            // width of main window in chars
ULONG TextLines;           // height of main window in chars
static ULONG XChar;        // character width
static ULONG YChar;        // character height
static ULONG ScrollBarX;   // vertical bar width
static ULONG ScrollBarY;   // horizontal bar height
static ULONG XClient;      // number of horizontal characters in main window
static ULONG YClient;      // number of character lines in main window
static ULONG XOffset;      // additional pixels on the left of the main window
static ULONG YOffset;      // additional pixels on the top of the main window
static ULONG XMin;         // left character position of the text window
static ULONG XMax;         // right character position of the text window
static ULONG YMin;         // top character position of the text window
static ULONG YMax;         // bottom character position of the text window
static ULONG XScrollMax;   // number of characters outside of the main window 
static ULONG YScrollMax;   // number of lines outside of the main window
static ULONG XScroll;      // number of characters masked on the left of the main window
static ULONG YScroll;      // number of liness masked on the top of the main window
static ULONG TOffset;      // Line offset of the text screen in the buffer
static ULONG XCursor;      // text cursor column
static ULONG YCursor;      // text cursor line
static ULONG XPos;         // text cursor column
static ULONG YPos;         // text cursor line
static ULONG HCursor;      // text cursor height
static ULONG BCursor;      // text cursor bottom position
static ULONG MouseX;       // last mouse X position in graphic window
static ULONG MouseY;	   // last mouse Y position in graphic window
static ULONG MouseButtons; // last mouse buttons state
ULONG WScreen;             // max graphical window width
ULONG HScreen;             // max graphical window height
static ULONG GraphicZoom;  // default graphic zoom (xN) 
static ULONG DisplayZoom;  // displayed graphic zoom (N%)
static ULONG XBorder;      // graphic window border witdh
static ULONG YBorder;      // graphic window border height
static COLORREF TextColor; // text color
static COLORREF BackColor; // background color
static COLORREF SysTextColor; // system text color
static COLORREF SysBackColor; // system background color
static HBRUSH BackBrush;   // background brush 
static HMENU Menu;
static UCHAR ProgName[] = "SBASIC";
static UCHAR DisplayName[] = "DISPLAY";

// Other variables
static HANDLE BasicHandle;
static HANDLE EditPrintHandle;
static HANDLE GraphicHandle;
static HANDLE StartEvent;
static HANDLE NotifyKey;
static HANDLE NotifyMouse;
static HANDLE NotifyDisp;
static HANDLE NotifyConsole;
static HANDLE WaitCursor;
static HANDLE DisplayCreated;
static HANDLE DisplayClosed;
static HANDLE InputRead;
static HANDLE InputWrite;
static HANDLE OutputRead;
static HANDLE OutputWrite;
static HANDLE OutputHandle;
static HANDLE StdInput;
static HANDLE StdOutput;
static HANDLE StdError;
static HANDLE ProcessHandle;
static CRITICAL_SECTION DispCs;
static CRITICAL_SECTION KeyCs;
static CRITICAL_SECTION MouseCs;
static ULONG ArgC;
static ULONG DataLen;
static ULONG CodeLen;
static ULONG SymbLen;
static ULONG ReturnCode;
static ULONG KeyIn;
static ULONG KeyOut;
static ULONG KeyCount;
static ULONG DispIn;
static ULONG DispOut;
static ULONG DispCount;
static ULONG InputOffset;
static ULONG OutputFormat;
static ULONG CursorPtr;
static ULONG ImageCount;
static PUCHAR ArgV[MAX_ARG];
static PVOID DataBase;
static PVOID CodeBase;
static PVOID SymbBase;
PVOID InputBuffer;
static PUCHAR CharMemory;
static PULONG TextColMemory;
static PULONG BackColMemory;
static PUCHAR KeyBuf;
static PUCHAR DispCmd;
static PULONG DispParam1;
static PULONG DispParam2;
static UCHAR Arg[MAX_ARG][MAX_PATH];
static UCHAR BasicFileName[MAX_PATH];
static UCHAR BasFileName[MAX_PATH];
static UCHAR BacFileName[MAX_PATH];
UCHAR PrintFileName[MAX_PATH];
static UCHAR BasDefExt[] = "BAS";
static UCHAR BacDefExt[] = "BAC";
static UCHAR ImageDefExt[] = "BMP";
static UCHAR CmdStr[] = "CMD /A /C ";
static UCHAR NotepadStr[] = "notepad ";
static UCHAR PrintStr[] = "SB$PRINT.TXT";
static BOOLEAN BasicEndFlag;
static BOOLEAN GraphicStopFlag;
static BOOLEAN NotifyKeyFlag;
static BOOLEAN NotifyMouseFlag;
static BOOLEAN NotifyDispFlag;
static BOOLEAN NotifyConsoleFlag;
static BOOLEAN CloseFlag;
static BOOLEAN OutputEndFlag;
static BOOLEAN SizeFlag;
static BOOLEAN FocusOn;
static BOOLEAN CaretOn;
static BOOLEAN HorzScroll;
static BOOLEAN VertScroll;
static BOOLEAN InputPipeFlag;
static BOOLEAN RedirInputFlag;
static BOOLEAN FlushInputFlag;
static BOOLEAN SyncOutputFlag;
static BOOLEAN BreakOn;
static BOOLEAN EscFlag;
static BOOLEAN InvertFlag;
static BOOLEAN ClickFlag;
#if HIDE_MOUSE
static BOOLEAN CursorOffFlag;
static BOOLEAN TrackingFlag;
#endif
BOOLEAN RefreshFlag;
BOOLEAN SaveFlag;
static UCHAR OemFixedFont[] = {0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
							  0x60, 0x27, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x5F,
							  0x20, 0xAD, 0xBD, 0x9C, 0xCF, 0xBE, 0xDD, 0xF5, 0xF9, 0xB8, 0xA6, 0xAE, 0xAA, 0xF0, 0xA9, 0x20,
							  0xF8, 0xF1, 0xFD, 0xFC, 0x27, 0xE6, 0xF4, 0xFA, 0x2C, 0xFB, 0xA7, 0xAF, 0xAC, 0xAB, 0xF3, 0xA8,
							  0xB7, 0xB5, 0xB6, 0xC7, 0x8E, 0x8F, 0x92, 0x80, 0xD4, 0x90, 0xD2, 0xD3, 0xDE, 0xD6, 0xD7, 0xD8,
							  0xD1, 0xA5, 0xE3, 0xE0, 0xE2, 0xE5, 0x99, 0x9E, 0x9D, 0xEB, 0xE9, 0xEA, 0x9A, 0xED, 0xE7, 0xE1,
							  0x85, 0xA0, 0x83, 0xC6, 0x84, 0x86, 0x91, 0x87, 0x8A, 0x82, 0x88, 0x89, 0x8D, 0xA1, 0x8C, 0x8B,
							  0xD0, 0xA4, 0x95, 0xA2, 0x93, 0xE4, 0x94, 0xF6, 0x9B, 0x97, 0xA3, 0x96, 0x81, 0xEC, 0xE8, 0x98};
UCHAR SystemFixedFont[128];

// Keywords
#include "KEYWORD.H"

// Common Routines
VOID GetString(ULONG Id, PUCHAR String, ULONG Size) {
	LoadString(Instance, Id, String, Size);
}

// LocalRoutines
static VOID FillMemULong(PVOID Start, ULONG Count, ULONG Data) {
__asm{
		mov		eax,Data
		mov		ecx,Count
		mov		edi,Start
		rep		stosd
}
}

// Convert OEM string to SYSTEM string
VOID Oem2System(PUCHAR Oem, PUCHAR System, ULONG Size) {
	PUCHAR Ptr1;
	PUCHAR Ptr2;
	ULONG i;
	UCHAR c;

	Ptr1 = Oem;
	Ptr2 = System;
	i = Size - 1;
	while (i-- != 0) {
		c = *Ptr1++;
		if (c == 0)
			break;
		if (c >= 128)
			c = SystemFixedFont[c-128];
		*Ptr2++ = c;
	}
	*Ptr2 = 0;
}

static VOID DisplayError(UINT ErrorMsg) {
	UCHAR buffer[100];

	GetString(ErrorMsg, buffer, sizeof(buffer));
	MessageBox(MainWnd, buffer, ProgName, MB_OK | MB_ICONERROR);
	ReturnCode = ErrorMsg;
}

// Skip space in text
static ULONG SkipSpace(PUCHAR Line) {
	PUCHAR ptr;

	ptr = Line;
	while (*ptr != 0 && *ptr == ' ')
		ptr++;
	return ptr - Line;
}

// Get decimal number from text
static ULONG DecimalParam(PUCHAR Line, PULONG Param) {
	ULONG temp;
	PUCHAR ptr;

	temp = 0;
	ptr = Line;
	while (*ptr >= '0' && *ptr <= '9')
		temp = temp * 10 + (ULONG)(*ptr++ - '0');
	*Param = temp;
	return ptr - Line;
}

// Get string from text
static ULONG StringParam(PUCHAR Line, PUCHAR Param, ULONG MaxLength) {
	ULONG length;
	PUCHAR ptr;
	UCHAR c;

	length = 0;
	ptr = Line;
	while (TRUE) {
		c = *ptr;
		if (c == 0 || c == ' ' || length >= MaxLength - 1)
			break;
		if (c == '"') {
			ptr++;
			while (TRUE) {
				c = *ptr;
				if (c == 0 || c == '"' || length >= MaxLength - 1)
					break;
				if (c >= 128)
					c = OemFixedFont[c-128];
				*Param++ = c;
				ptr++;
				length++;
			}
			if (c == '"')
				ptr++;
		} else {
			if (c >= 128)
				c = OemFixedFont[c-128];
			*Param++ = c;
			ptr++;
			length++;
		}
	}
	*Param = 0;
	return ptr - Line;
}

static VOID ClickMouse(VOID) {
	BOOLEAN notify;

	EnterCriticalSection(&MouseCs);
	notify = NotifyMouseFlag;
	if (notify) { // Simulate mouse click
		ClickFlag = TRUE;
		NotifyMouseFlag = FALSE;
	}
	LeaveCriticalSection(&MouseCs);
	if (notify)
		SetEvent(NotifyMouse);
}
			
static VOID FlushKey(VOID) {

	EnterCriticalSection(&KeyCs);
	KeyIn = 0;
	KeyOut = 0;
	KeyCount = 0;
	LeaveCriticalSection(&KeyCs);
}

static VOID QueueKey(UCHAR C) {
	BOOLEAN notify;

	if (C >= 128)
		C = OemFixedFont[C-128];
	EnterCriticalSection(&KeyCs);
	if (KeyCount < MAX_KEY) {
		KeyBuf[KeyIn] = C;
		KeyIn++;
		if (KeyIn >= MAX_KEY)
			KeyIn = 0;
		KeyCount++;
	}
	notify = NotifyKeyFlag;
	NotifyKeyFlag = FALSE;
	LeaveCriticalSection(&KeyCs);
	if (notify)
		SetEvent(NotifyKey);
	ClickMouse();
}

static VOID QueueString(PUCHAR S) {
	ULONG i;
	UCHAR c;
	BOOLEAN notify;

	i = 0;
	EnterCriticalSection(&KeyCs);
	while (KeyCount < MAX_KEY && S[i] != 0) {
		c = S[i];
		if (c == 0x09)
			c = ' ';
		else if (c >= 128)
			c = OemFixedFont[c-128];
		if (c >= 0x20 || c == 0x0D) {
			KeyBuf[KeyIn] = c;
			KeyIn++;
			if (KeyIn >= MAX_KEY)
				KeyIn = 0;
			KeyCount++;
		}
		i++;
	}
	notify = NotifyKeyFlag;
	NotifyKeyFlag = FALSE;
	LeaveCriticalSection(&KeyCs);
	if (notify)
		SetEvent(NotifyKey);
}

static VOID QueueDisp(UCHAR Cmd, ULONG Param1, ULONG Param2) {
	BOOLEAN post;

	EnterCriticalSection(&DispCs);
	while (DispCount >= MAX_DISP) {
		NotifyDispFlag = TRUE;
		LeaveCriticalSection(&DispCs);
		WaitForSingleObject(NotifyDisp, INFINITE);
		if (BasicEndFlag)
			return;
		EnterCriticalSection(&DispCs);
	}
	DispCmd[DispIn] = Cmd;
	DispParam1[DispIn] = Param1;
	DispParam2[DispIn] = Param2;
	DispIn++;
	if (DispIn >= MAX_DISP)
		DispIn = 0;
	post = DispCount++ == 0;
	LeaveCriticalSection(&DispCs);
	if (post)
		PostMessage(MainWnd, WM_DISP_CMD, 0, 0);
}

static BOOLEAN GetDisp(PUCHAR Cmd, PULONG Param1, PULONG Param2) {
	BOOLEAN notify;

	EnterCriticalSection(&DispCs);
	if (DispCount == 0) {
		notify = NotifyDispFlag;
		NotifyDispFlag = FALSE;
		LeaveCriticalSection(&DispCs);
		if (notify)
			SetEvent(NotifyDisp);
		return FALSE;
	}
	*Cmd = DispCmd[DispOut];
	*Param1 = DispParam1[DispOut];
	*Param2 = DispParam2[DispOut];
	DispOut++;
	if (DispOut >= MAX_DISP)
		DispOut = 0;
	DispCount--;
	LeaveCriticalSection(&DispCs);
	return TRUE;
}

static VOID	ClearTextMemory(VOID) {

	FillMemory(CharMemory, BUFFER_LINES * TextCols, ' ');
	FillMemULong(TextColMemory, BUFFER_LINES * TextCols, TextColor); 
	FillMemULong(BackColMemory, BUFFER_LINES * TextCols, BackColor); 
}

static VOID SizeText(BOOLEAN Repaint) {
	LONG width;
	LONG height;
	RECT rect;
	RECT rect2;

	GetWindowRect(MainWnd, &rect);
	rect2.top = rect.top;
	rect2.left = rect.left;
	rect2.bottom = rect.top + YChar * TextLines;
	rect2.right = rect.left + XChar * TextCols;
	AdjustWindowRect(&rect2, WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX, TRUE);
	MaxWidth = rect2.right - rect2.left + ScrollBarX;
	MaxHeight = rect2.bottom - rect2.top;
	width = GetSystemMetrics(SM_CXSCREEN);
	height = GetSystemMetrics(SM_CYSCREEN);
	if (rect.left + MaxWidth > width) {
		if (MaxWidth < width)
			rect.left = width - MaxWidth;
		else
			rect.left = 0;
	}
	if (rect.top + MaxHeight > height) {
		if (MaxHeight < height)
			rect.top = height - MaxHeight;
		else
			rect.top = 0;
	}
	MoveWindow(MainWnd, rect.left, rect.top, MaxWidth, MaxHeight, Repaint);
}

static VOID PosCursor(HWND Wnd, BOOLEAN Adjust) {
	ULONG x;
	ULONG y;

	if (Adjust) {
		if (YScroll + YClient < TOffset + YCursor + 1) {
			YScroll = TOffset + YCursor + 1 - YClient;
SetVerticalScrollPos:
			SetScrollPos(Wnd, SB_VERT, YScroll, TRUE);
			InvalidateRect(Wnd, NULL, TRUE);
		} else if (YScroll > TOffset + YCursor) {
			YScroll = TOffset + YCursor;
			goto SetVerticalScrollPos;
		}
	}
	if (FocusOn) {
		if (!CaretOn) {
			if (XCursor >= XScroll && TOffset + YCursor >= YScroll) {
				x =  XCursor - XScroll;
				y =  TOffset + YCursor - YScroll;
				if (x < XClient && y < YClient) {
					CreateCaret(Wnd, NULL, XChar, HCursor);
					SetCaretPos(XChar * x, YChar * (y + 1) - BCursor - HCursor + YOffset);
					ShowCaret(Wnd);
					CaretOn = TRUE;
				}
			}
		} else {
			if (XCursor < XScroll || XCursor - XScroll >= XClient || TOffset + YCursor < YScroll || TOffset + YCursor - YScroll >= YClient) {
				CaretOn = FALSE;
				DestroyCaret();
			} else
				SetCaretPos(XChar * (XCursor - XScroll), YChar * (TOffset + YCursor - YScroll + 1) - BCursor - HCursor + YOffset);
		}
	}
}

static ULONG CheckPath(PUCHAR Path) {
	ULONG attrib;
	ULONG errorCode;

	attrib = GetFileAttributes(Path);
	if (attrib == 0xFFFFFFFF) {
		errorCode = GetLastError();
		if (errorCode == ERROR_FILE_NOT_FOUND || errorCode == ERROR_PATH_NOT_FOUND)
			return PATH_NOT_FOUND;
		else
			return PATH_ERROR;
	} else {
		if ((attrib & FILE_ATTRIBUTE_DIRECTORY) == FILE_ATTRIBUTE_DIRECTORY)
			return PATH_DIRECTORY;
		else
			return PATH_FILE;
	}
}

static VOID ProcessKey(UCHAR C) {
	ULONG bytesWritten;
	PUCHAR pc;
	HGLOBAL global;

	if (C == 0x03 && ProcessHandle != NULL) { // Ctrl-C and command running
		TerminateProcess(ProcessHandle, 0);
	} else if (RedirInputFlag) { // Redirection to standard input
		WriteFile(InputWrite, &C, 1, &bytesWritten, NULL);
		FlushInputFlag = TRUE;
	} else if (C == 0x03 && BreakOn) { // Ctrl-C and Break enabled
		FlushKey();
		QueueKey(0x03);
		SetBreak(FALSE);
	} else if (C == 0x08)       // Ctrl-H
		QueueKey(0x7F);
	else if (C == 0x16) {       // Ctrl-V
		if (IsClipboardFormatAvailable(CF_TEXT) && OpenClipboard(MainWnd)) {
			global = GetClipboardData(CF_TEXT);
			if (global != NULL) {
				pc = (PUCHAR)GlobalLock(global);
				if (pc != NULL) {
					QueueString(pc);
					GlobalUnlock(global);
				}
			}
			CloseClipboard();
		}
	} else
		QueueKey(C);
}

static VOID LineFeed(HWND Wnd) {
	ULONG i;
	ULONG j;
	ULONG k;
	ULONG w;
	ULONG h;
	ULONG x;
	ULONG y;
	COLORREF text;
	COLORREF back;
	HDC hdc;
	RECT rect;
	UCHAR buffer[MAX_COLS+1];
	BOOLEAN bottom;

	if (YCursor < YMax) {
		YCursor++;
		return;
	}
	if (XMin != 0 || XMax != TextCols - 1 || YMin != 0 || YMax != TextLines - 1) { // Not full screen text window
		for (i = YMin; i < YMax; i++) {
			x = (TOffset + i) * TextCols + XMin;
			CopyMemory(CharMemory + x, CharMemory + x + TextCols, (XMax - XMin + 1) * sizeof(UCHAR));
			CopyMemory(TextColMemory + x, TextColMemory + x + TextCols, (XMax - XMin + 1) * sizeof(ULONG));
			CopyMemory(BackColMemory + x, BackColMemory + x + TextCols, (XMax - XMin + 1) * sizeof(ULONG));
		}
		FillMemory(CharMemory + (TOffset + YMax) * TextCols + XMin, XMax - XMin + 1, ' ');
		FillMemULong(TextColMemory + (TOffset + YMax) * TextCols + XMin, XMax - XMin + 1, TextColor);
		FillMemULong(BackColMemory + (TOffset + YMax) * TextCols + XMin, XMax - XMin + 1, BackColor);
	} else if (TOffset < BUFFER_LINES - TextLines) { // Advance text window
		TOffset++; // Text screen one line down
	} else { // Scroll up buffer
		CopyMemory(CharMemory, CharMemory + TextCols, (BUFFER_LINES - 1) * TextCols * sizeof(UCHAR));
		CopyMemory(TextColMemory, TextColMemory + TextCols, (BUFFER_LINES - 1) * TextCols * sizeof(ULONG));
		CopyMemory(BackColMemory, BackColMemory + TextCols, (BUFFER_LINES - 1) * TextCols * sizeof(ULONG));
		FillMemory(CharMemory + (BUFFER_LINES-1) * TextCols, TextCols, ' '); 
		FillMemULong(TextColMemory + (BUFFER_LINES-1) * TextCols, TextCols, TextColor);
		FillMemULong(BackColMemory + (BUFFER_LINES-1) * TextCols, TextCols, BackColor);
	}

	// Cip the text window with the display window
	w = XMax - XMin + 1;
	if (XMin >= XScroll)
		x = XMin - XScroll;
	else {
		x = 0;
		if (w + XMin > XScroll)
			w -= XScroll - XMin;
		else
			w = 0;
	}
	if (x + w > XClient + 1) {
		if (x < XClient + 1)
			w = XClient + 1 - x;
		else
			w = 0;
	}
	h = YMax - YMin + 1;
	if (YMin + TOffset >= YScroll)
		y = YMin + TOffset - YScroll;
	else {
		y = 0;
		if (h + YMin + TOffset > YScroll)
			h -= YScroll - YMin - TOffset;
		else
			h = 0;
	}
	bottom = TRUE;
	if (y + h >= YClient) {
		if (y < YClient) {
			h = YClient - y;
			bottom = FALSE;
		} else
			h = 0;
	}

	// Scroll up the display window by one text line
	if (w != 0) { // Scoll up screen window
		if (CaretOn)
			HideCaret(Wnd);
		hdc = GetDC(Wnd);
		SelectObject(hdc, GetStockObject(OEM_FIXED_FONT));
		if (h > 1) // Scroll up display window
			BitBlt(hdc, x * XChar, y * YChar + YOffset, w * XChar, (h - 1) * YChar, hdc, x * XChar, (y + 1) * YChar + YOffset, SRCCOPY);
		if (h != 0) {
			if (bottom) { // Clear bottom line of the display window
				rect.left = x * XChar;
				rect.top = (y + h - 1) * YChar + YOffset;
				rect.right = (x + w) * XChar;
				rect.bottom = (y + h) * YChar + YOffset;
				FillRect(hdc, &rect, BackBrush);
			} else { // Draw bottom line of the display window
				i = y + YScroll + h - 1;
				j = x + XScroll;
				while (j < x + XScroll + w) {
					if (i < TextLines && j < TextCols) {
						buffer[0] = CharMemory[i*TextCols+j];
						text = TextColMemory[i*TextCols+j];
						back = BackColMemory[i*TextCols+j];
					} else {
						buffer[0] = ' ';
						text = TextColor;
						back = BackColor;
					}
					k = 1;
					j++;
					while (j < x + XScroll + w) {
						if (i < TextLines && j < TextCols) {
							if (text != TextColMemory[i*TextCols+j] || back != BackColMemory[i*TextCols+j])
								break;
						} else {
							if (text != TextColor || back != BackColor)
								break;
						}
						if (i < TextLines && j < TextCols)
							buffer[k] = CharMemory[i*TextCols+j];
						else
							buffer[k] = ' ';
						k++;
						j++;
					}
					SetTextColor(hdc, text);
					SetBkColor(hdc, back);
					TextOut(hdc, XChar * (j - XScroll - k), YChar * (i - YScroll) + YOffset, buffer, k);
				}
			}
		}
		ReleaseDC(Wnd, hdc);
		if (CaretOn)
			ShowCaret(Wnd);
	}
}

static VOID DisplayChar(HWND Wnd, UCHAR C) {
	ULONG x;
	ULONG y;
	HDC hdc;

	// Update display memory
	CharMemory[(TOffset+YCursor)*TextCols+XCursor] = C;
	if (!InvertFlag) {
		TextColMemory[(TOffset+YCursor)*TextCols+XCursor] = TextColor;
		BackColMemory[(TOffset+YCursor)*TextCols+XCursor] = BackColor;
	} else {
		TextColMemory[(TOffset+YCursor)*TextCols+XCursor] = BackColor;
		BackColMemory[(TOffset+YCursor)*TextCols+XCursor] = TextColor;
	}

	// Draw character
	if (XCursor >= XScroll && TOffset + YCursor >= YScroll) {
		x = XCursor - XScroll;
		y = TOffset + YCursor - YScroll;
		if (x <= XClient && y < YClient) {
			if (CaretOn)
				HideCaret(Wnd);
			hdc = GetDC(Wnd);
			SelectObject(hdc, GetStockObject(OEM_FIXED_FONT));
			if (!InvertFlag) {
				SetTextColor(hdc, TextColor);
				SetBkColor(hdc, BackColor);
			} else {
				SetTextColor(hdc, BackColor);
				SetBkColor(hdc, TextColor);
			}
			TextOut(hdc, XChar * x, YChar * y + YOffset, &C, 1);
			ReleaseDC(Wnd, hdc);
			if (CaretOn)
				ShowCaret(Wnd);
		}
	}

	// Move cursor
	if (XCursor < XMax)
		XCursor++;
	else {
		XCursor = XMin;
		LineFeed(Wnd);
	}
	PosCursor(Wnd, TRUE);
}

BOOLEAN IsLetter(UCHAR C) {

	return (C >= 'A' && C <= 'Z') || (C >= 'a' && C <= 'z') || C == '%' || C == '$';
}

// Global Routines
BOOLEAN CheckKey(VOID) {
	
	return KeyCount != 0;
}

VOID SetControlC(BOOLEAN On) {

	BreakOn = On;
}

VOID RedirConsoleOn(VOID) {

	RedirInputFlag = InputPipeFlag;
	FlushInputFlag = FALSE;
}

VOID RedirConsoleOff(VOID) {
	ULONG bytesAvail;
	ULONG bytesRead;
	UCHAR c;

	if (RedirInputFlag) {
		RedirInputFlag = FALSE;
		if (FlushInputFlag)
			while (PeekNamedPipe(InputRead, NULL, 0, NULL, &bytesAvail, NULL) && bytesAvail != 0)
				if (!ReadFile(InputRead, &c, 1, &bytesRead, NULL))
					break;
	}
	SyncOutputFlag = TRUE;
}

BOOLEAN GetKey(PUCHAR C) {

	EnterCriticalSection(&KeyCs);
	while (KeyCount == 0) {
		NotifyKeyFlag = TRUE;
		LeaveCriticalSection(&KeyCs);
		WaitForSingleObject(NotifyKey, INFINITE);
		if (BasicEndFlag)
			return FALSE;
		EnterCriticalSection(&KeyCs);
	}
	*C = KeyBuf[KeyOut];
	KeyOut++;
	if (KeyOut >= MAX_KEY)
		KeyOut = 0;
	KeyCount--;
	LeaveCriticalSection(&KeyCs);
	return TRUE;
}

VOID InitVar(VOID) {

	if (BasicEndFlag)
		return;
	QueueDisp(DISP_INIT, 0, 0);
}

VOID PutChar(UCHAR Char) {
	ULONG bytesWritten;
	UCHAR c;

	if (BasicEndFlag)
		return;
	if (SyncOutputFlag) {
		SyncOutputFlag = FALSE;
		if (OutputHandle != NULL) {
			NotifyConsoleFlag = TRUE;
			c = 0x1A;
			WriteFile(OutputWrite, &c, 1, &bytesWritten, NULL);
			WaitForSingleObject(NotifyConsole, INFINITE);
		}
	}
	QueueDisp(DISP_CHAR, Char, 0);
}

BOOLEAN MoveCursor(ULONG X, ULONG Y) {

	QueueDisp(DISP_SET_CURSOR, Y, X);
	return TRUE;
}

ULONG CursorPos(VOID) {

	if (BasicEndFlag)
		return 0;
	QueueDisp(DISP_GET_CURSOR, 0, 0);
	if (WaitForSingleObject(WaitCursor, 1000) == WAIT_TIMEOUT)
		return 0;
	return (YPos << 8) | XPos;
}

ULONG CursorSize(ULONG High, ULONG Low) {

	if (BasicEndFlag)
		return FALSE;
	if (High == 0 || Low >=8 || High > Low)
		return FALSE;
	QueueDisp(DISP_CURSOR_SIZE, YChar * (Low - High) / 6 + 1, YChar * (7 - Low) / 6 + 1);
	return TRUE;
}

VOID ResizeTxt(ULONG Lines, ULONG Chars) {

	QueueDisp(DISP_RESIZE, Chars, Lines);
}

VOID SetTxtWindow(LONG LineUp, LONG ColLeft, LONG LineDown, LONG ColRight) {

	if (BasicEndFlag)
		return;
	if (ColLeft < 0)
		ColLeft = 0;
	if (ColLeft > 255)
		ColLeft = 255;
	if (LineUp < 0)
		LineUp = 0;
	if (LineUp > 255)
		LineUp = 255;
	if (ColRight < 0)
		ColRight = 0;
	if (ColRight > 255)
		ColRight = 255;
	if (LineDown < 0)
		LineDown = 0;
	if (LineDown > 255)
		LineDown = 255;
	QueueDisp(DISP_WINDOW, (LineUp << 8) | ColLeft, (LineDown << 8) | ColRight);
}

VOID SetTxtColor(ULONG Color, ULONG R, ULONG G, ULONG B) {
	COLORREF color;
	
	color = (B << 16) | (G << 8) | R;
	QueueDisp(DISP_COLOR, Color, color);
}

BOOLEAN CheckExit(VOID) {
	UCHAR buffer[100];

	GetString(IDS_NOSAVE, buffer, sizeof(buffer));
	return MessageBox(MainWnd, buffer, ProgName, MB_OKCANCEL) == IDOK;
}

VOID CloseBasicWindow(VOID) {
	UCHAR buffer[100];

	GetString(IDS_CLOSEWINDOW, buffer, sizeof(buffer));
	MessageBox(MainWnd, buffer, ProgName, MB_OK);
}

VOID EnableCmdMenu(VOID) {

	EnableMenuItem(Menu, IDM_RUNF, MF_ENABLED);
	EnableMenuItem(Menu, IDM_LOAD, MF_ENABLED);
	EnableMenuItem(Menu, IDM_BLOAD, MF_ENABLED);
	EnableMenuItem(Menu, IDM_SAVE, MF_ENABLED);
	EnableMenuItem(Menu, IDM_COMPILE, MF_ENABLED);
	EnableMenuItem(Menu, IDM_NEW, MF_ENABLED);
	EnableMenuItem(Menu, IDM_CLEAR, MF_ENABLED);
	EnableMenuItem(Menu, IDM_LIST, MF_ENABLED);
	EnableMenuItem(Menu, IDM_RUN, MF_ENABLED);
	EnableMenuItem(Menu, IDM_BREAK, MF_GRAYED);
	EnableMenuItem(Menu, IDM_CONT, MF_ENABLED);
}

VOID DisableCmdMenu(VOID) {

	EnableMenuItem(Menu, IDM_RUNF, MF_GRAYED);
	EnableMenuItem(Menu, IDM_LOAD, MF_GRAYED);
	EnableMenuItem(Menu, IDM_BLOAD, MF_GRAYED);
	EnableMenuItem(Menu, IDM_SAVE, MF_GRAYED);
	EnableMenuItem(Menu, IDM_COMPILE, MF_GRAYED);
	EnableMenuItem(Menu, IDM_NEW, MF_GRAYED);
	EnableMenuItem(Menu, IDM_CLEAR, MF_GRAYED);
	EnableMenuItem(Menu, IDM_LIST, MF_GRAYED);
	EnableMenuItem(Menu, IDM_RUN, MF_GRAYED);
	EnableMenuItem(Menu, IDM_BREAK, MF_ENABLED);
	EnableMenuItem(Menu, IDM_CONT, MF_GRAYED);
}

BOOL W32_ReadFile(HANDLE Handle, PVOID Buffer, ULONG ByteCount, PULONG ByteRead) {

	return ReadFile(Handle, Buffer, ByteCount, ByteRead, NULL);
}

BOOL W32_WriteFile(HANDLE Handle, PVOID Buffer, ULONG ByteCount, PULONG ByteWritten) {

	return WriteFile(Handle, Buffer, ByteCount, ByteWritten, NULL);
}

BOOL W32_DeleteFile(PUCHAR FileName) {
	UCHAR Path[128];

	Oem2System(FileName, Path, sizeof(Path));
	return DeleteFile(Path);
}

BOOL W32_MoveFile(PUCHAR CurrentName, PUCHAR NewName) {
	UCHAR Path1[128];
	UCHAR Path2[128];

	Oem2System(CurrentName, Path1, sizeof(Path1));
	Oem2System(NewName, Path2, sizeof(Path2));
	return MoveFile(Path1, Path2);
}

BOOL W32_LockFile(HANDLE Handle, ULONG OffsetLow, ULONG OffsetHigh, ULONG CountLow, ULONG CountHigh) {

	return LockFile(Handle, OffsetLow, OffsetHigh, CountLow, CountHigh);
}

BOOL W32_UnlockFile(HANDLE Handle, ULONG OffsetLow, ULONG OffsetHigh, ULONG CountLow, ULONG CountHigh) {

	return UnlockFile(Handle, OffsetLow, OffsetHigh, CountLow, CountHigh);
}

HANDLE W32_CreateFile(PUCHAR FileName, ULONG Access, ULONG Share, ULONG Disposition, ULONG Attributes, BOOLEAN Troncate) {
	HANDLE handle;
	UCHAR Path[128];

	Oem2System(FileName, Path, sizeof(Path));
	handle = CreateFile(Path, Access, Share, NULL, Disposition, Attributes, NULL);
	if (handle != INVALID_HANDLE_VALUE && Troncate)
		SetEndOfFile(handle);
	return handle;
}

BOOL W32_CloseHandle(HANDLE Handle) {

	return CloseHandle(Handle);
}

BOOL W32_GetFileSize(HANDLE Handle, PULONG Size) {

	*Size = GetFileSize(Handle, NULL);
	return *Size != INVALID_FILE_SIZE;
}

BOOL W32_SetFilePointer(HANDLE Handle, LONG OffsetLow, LONG OffsetHigh, ULONG Method) {

	return SetFilePointer(Handle, OffsetLow, &OffsetHigh, Method) != INVALID_SET_FILE_POINTER;
}

HMODULE W32_LoadLibrary(PUCHAR LibName) {
	UCHAR Path[128];

	Oem2System(LibName, Path, sizeof(Path));
	return LoadLibrary(Path);
}

BOOL W32_FreeLibrary(HMODULE Module) {

	return FreeLibrary(Module);
}

FARPROC W32_GetProcAddress(HMODULE Module, PUCHAR ProcName) {
	UCHAR Name[128];

	Oem2System(ProcName, Name, sizeof(Name));
	return GetProcAddress(Module, Name);
}

static ULONG WINAPI OutputThread(PVOID Params) {
	ULONG bytesRead;
	UCHAR c;

	while (TRUE) {
		if (!ReadFile(OutputRead, &c, 1, &bytesRead, NULL))
			break;
		if (c == 0x1A) {
			if (NotifyConsoleFlag) {
				NotifyConsoleFlag = FALSE;
				SetEvent(NotifyConsole);
			}
			if (OutputEndFlag)
				break;
		} else if(!BasicEndFlag)
			QueueDisp(DISP_CHAR, c, 0);
	}
	return 0;
}

VOID W32_CreateProcess(PUCHAR CmdLine) {
	ULONG i;
	STARTUPINFO startupInfo;
	PROCESS_INFORMATION processInformation;
	UCHAR c;
	UCHAR buffer[128+sizeof(CmdStr)];

	CopyMemory(buffer, CmdStr, sizeof(CmdStr) - 1);
	i = 0;
	do {
		c = CmdLine[i];
		if (c < 128)
			buffer[i+sizeof(CmdStr)-1] = c;
		else
			buffer[i+sizeof(CmdStr)-1] = SystemFixedFont[c-128];
		i++;
	} while (i < 128 && c != 0);
	ProcessHandle = NULL;
	ZeroMemory(&startupInfo, sizeof(STARTUPINFO));
	startupInfo.cb = sizeof(STARTUPINFO);
	startupInfo.dwFlags = STARTF_USESTDHANDLES;
	startupInfo.hStdInput = InputRead;
	startupInfo.hStdOutput = OutputWrite;
	startupInfo.hStdError = OutputWrite;
	RedirConsoleOn();
	if (CreateProcess(NULL,
					  buffer,
					  NULL,
					  NULL,
					  TRUE,
					  CREATE_DEFAULT_ERROR_MODE | NORMAL_PRIORITY_CLASS | CREATE_NO_WINDOW,
					  NULL,
					  NULL,
					  &startupInfo,
					  &processInformation)) {
		ProcessHandle = processInformation.hProcess;
		CloseHandle(processInformation.hThread);
		WaitForSingleObject(processInformation.hProcess, INFINITE);
		CloseHandle(processInformation.hProcess);
		ProcessHandle = NULL;
	}
	RedirConsoleOff();
}

BOOL W32_SetCurrentDirectory(PUCHAR DirName) {
	UCHAR Path[128];

	Oem2System(DirName, Path, sizeof(Path));
	return SetCurrentDirectory(Path);
}

ULONG W32_GetDate(VOID) {
	FILETIME fileTimeUtc;
	FILETIME fileTimeLocal;
	SYSTEMTIME SystemTime;

	GetSystemTimeAsFileTime(&fileTimeUtc);
	FileTimeToLocalFileTime(&fileTimeUtc, &fileTimeLocal);
	FileTimeToSystemTime(&fileTimeLocal, &SystemTime);
	return (SystemTime.wYear << 16) | (SystemTime.wMonth << 8) | SystemTime.wDay;
}

ULONG W32_GetTime(VOID) {
	FILETIME fileTimeUtc;
	FILETIME fileTimeLocal;
	SYSTEMTIME SystemTime;

	GetSystemTimeAsFileTime(&fileTimeUtc);
	FileTimeToLocalFileTime(&fileTimeUtc, &fileTimeLocal);
	FileTimeToSystemTime(&fileTimeLocal, &SystemTime);
	return (SystemTime.wHour << 24) | (SystemTime.wMinute << 16) | (SystemTime.wSecond << 8) | (SystemTime.wMilliseconds / 10);
}

ULONG W32_GetLastError(VOID) {

	return GetLastError();
}

VOID W32_PlaySound(PUCHAR FileName, BOOLEAN Wait) {
	ULONG flags;
	UCHAR Path[128];

	Oem2System(FileName, Path, sizeof(Path));
	if (Wait)
		flags = SND_FILENAME | SND_SYNC;
	else
		flags = SND_FILENAME | SND_ASYNC;
	PlaySound(Path, NULL, flags);
}

VOID FocusGraphic(VOID) {

	if (DisplayWnd != NULL)
		SetForegroundWindow(DisplayWnd);
}

VOID FocusText(VOID) {

	SetForegroundWindow(MainWnd);
}

PUCHAR OpenGraphicWindow(ULONG Width, ULONG Height) {

	GraphicWidth = Width;
	GraphicHeight = Height;
	CloseFlag = FALSE;
	PostMessage(MainWnd, WM_CREATE_DISPLAY, 0, 0);
	WaitForSingleObject(DisplayCreated, INFINITE); // Wait for end of window initialization
	InitColors();
	return GraphicMemory;
}

VOID CloseGraphicWindow(VOID) {

	CloseFlag = TRUE;
	PostMessage(MainWnd, WM_CLOSE_DISPLAY, 0, 0);
	WaitForSingleObject(DisplayClosed, INFINITE); // Wait for end of window destruction
}

VOID ShowMouse(VOID) {

#if HIDE_MOUSE
	PostMessage(DisplayWnd, WM_SHOW_MOUSE, 0, 0);
#endif
}
			
VOID HideMouse(VOID) {

#if HIDE_MOUSE
	PostMessage(DisplayWnd, WM_HIDE_MOUSE, 0, 0);
#endif
}

ULONG GetMouse(PULONG X, PULONG Y, BOOLEAN Wait, PBOOLEAN EndFlag) {
	ULONG buttons;

	EnterCriticalSection(&MouseCs);
	if (Wait)
		while (!ClickFlag) {
			NotifyMouseFlag = TRUE;
			LeaveCriticalSection(&MouseCs);
			WaitForSingleObject(NotifyMouse, INFINITE);
			if (BasicEndFlag) {
				*EndFlag = TRUE;
				return 0;
			}
			EnterCriticalSection(&MouseCs);
		}
	*X = MouseX;
	*Y = MouseY;
	buttons = MouseButtons;
	ClickFlag = FALSE;
	LeaveCriticalSection(&MouseCs);
	*EndFlag = BasicEndFlag;
	return buttons;
}

// Basic thread
static ULONG WINAPI BasicThread(PVOID Params) {

	WaitForSingleObject(StartEvent, INFINITE); // Wait for end of window initialization
	if (StartBasic(ArgC, ArgV, DataBase, DataLen << 20, CodeBase, CodeLen << 20, SymbBase, SymbLen << 20)) {
		BasicEndFlag = TRUE;
		PostMessage(MainWnd, WM_USER_DONE, 0, 0); // If return by itself (not following an abort request)
	}
	return 0;
}

// Graphic thread
static ULONG WINAPI GraphicThread(PVOID Params) {

	SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);

	while (TRUE) {
		Sleep(20); // max 50 rafraichissemnent par seconde
		if (GraphicStopFlag)
			goto GraphicStop;
		if (RefreshFlag) {
			RefreshFlag = FALSE;
			RefreshDisplay();
		}
	}
GraphicStop:
	return 0;
}

// Print thread
static ULONG WINAPI PrintThread(PVOID Params) {
	ULONG i;
	STARTUPINFO startupInfo;
	PROCESS_INFORMATION processInformation;
	UCHAR buffer[MAX_PATH+sizeof(NotepadStr)];

	if (CheckPath(PrintFileName) != PATH_FILE) {
			DisplayError(IDS_NOPRINT);
	} else {
		CopyMemory(buffer, NotepadStr, sizeof(NotepadStr) - 1);
		i = 0;
		while (PrintFileName[i] != 0 && i < MAX_PATH) {
			buffer[i+sizeof(NotepadStr)-1] = PrintFileName[i];
			i++;
		}
		buffer[i+sizeof(NotepadStr)-1] = 0;
		ZeroMemory(&startupInfo, sizeof(STARTUPINFO));
		startupInfo.cb = sizeof(STARTUPINFO);
		startupInfo.dwFlags = 0;
		if (CreateProcess(NULL,
					  buffer,
					  NULL,
					  NULL,
					  FALSE,
					  CREATE_DEFAULT_ERROR_MODE | NORMAL_PRIORITY_CLASS,
					  NULL,
					  NULL,
					  &startupInfo,
					  &processInformation)) {
			CloseHandle(processInformation.hThread);
			WaitForSingleObject(processInformation.hProcess, INFINITE);
			CloseHandle(processInformation.hProcess);
		} else
			DisplayError(IDS_PRINTERR);
	}
	PostMessage(MainWnd, WM_EDIT_DONE, 0 , 0);
	return 0;
}

// Windows procedures
static BOOL CALLBACK DisplayProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {
	HANDLE hFile;
	ULONG button;
	ULONG width;
	ULONG height;
	ULONG x;
	ULONG y;
	ULONG result;
	PRECT rect;
	PUCHAR ptr;
	CREATESTRUCT *createStruct;
	OPENFILENAME openFileName;
#if HIDE_MOUSE
	TRACKMOUSEEVENT trackMouseEvent;
#endif
	UCHAR format[64];
	UCHAR filter[100];
	UCHAR fileName[MAX_PATH];
	UCHAR directory[MAX_PATH];
	UCHAR buffer[100];
	BOOLEAN notify;

	switch (Msg) {
    case WM_CREATE:
		createStruct = (CREATESTRUCT *)LParam;
		if (!CreateDisplay(Wnd))
			return -1; // abort window creation
		GraphicStopFlag = FALSE;
		GraphicHandle = CreateThread(NULL, 0, GraphicThread, NULL, 0, NULL);
		if (GraphicThread == NULL) {
			CloseDisplay();
			return -1; // abort window creation
		}
		SetClassLong(Wnd, GCL_HBRBACKGROUND, (LONG)CreateSolidBrush(COLOR_KEY)); // Set color key
		InvalidateRect(Wnd, NULL, TRUE);
		DisplayZoom = 0;
		GraphicMemory = NULL;
#if HIDE_MOUSE
		CursorOffFlag = TRUE;
		TrackingFlag = FALSE;
#endif
		MouseButtons = 0;
		ClickFlag = FALSE;
		RegisterHotKey(Wnd, 12345, MOD_CONTROL, 'P');
		break;
	case WM_SIZING:
		result = 0;
		rect = (PRECT)LParam;
		width = rect->right - rect->left - XBorder;
		height = rect->bottom - rect->top - YBorder;
		x = height * GraphicWidth / GraphicHeight;
		y = width * GraphicHeight / GraphicWidth;
		if (x < GraphicWidth || y < GraphicHeight) {
			switch (LOWORD(WParam)) {
			case WMSZ_BOTTOM:
			case WMSZ_BOTTOMRIGHT:
			case WMSZ_RIGHT:
				rect->right = rect->left + GraphicWidth + XBorder;
				rect->bottom = rect->top + GraphicHeight + YBorder;
				break;
			case WMSZ_TOPRIGHT:
				rect->right = rect->left + GraphicWidth + XBorder;
				rect->top = rect->bottom - GraphicHeight - YBorder;
				break;
			case WMSZ_TOP:
			case WMSZ_TOPLEFT:
			case WMSZ_LEFT:
				rect->left = rect->right - GraphicWidth - XBorder;
				rect->top = rect->bottom - GraphicHeight - YBorder;
				break;
			case WMSZ_BOTTOMLEFT:
				rect->left = rect->right - GraphicWidth - XBorder;
				rect->bottom = rect->top + GraphicHeight + YBorder;
				break;
			}
			result = 1;
		} else
			switch (LOWORD(WParam)) {
			case WMSZ_BOTTOM:
			case WMSZ_BOTTOMRIGHT:
				if (width != x) {
					rect->right += x - width;
					result = 1;
				}
				break;
			case WMSZ_TOP:
			case WMSZ_TOPLEFT:
				if (width != x) {
					rect->left -= x - width;
					result = 1;
				}
				break;
			case WMSZ_RIGHT:
			case WMSZ_TOPRIGHT:
				if (height != y) {
					rect->bottom += y - height;
					result = 1;
				}
				break;
			case WMSZ_LEFT:
			case WMSZ_BOTTOMLEFT:
				if (height != y) {
					rect->top -= y - height;
					result = 1;
				}
				break;
			}
		return result;
	case WM_SIZE:
		if (WParam == SIZE_MINIMIZED) {
			ReleaseDisplay();
			return 0;
		}
		if (WParam == SIZE_RESTORED || WParam == SIZE_MAXIMIZED) {
			width = LOWORD(LParam);
			height = HIWORD(LParam);
			UpdateDisplay(Wnd, width, height);
			result = width * 100 / GraphicWidth;
			if (result != DisplayZoom) {
				GetString(IDS_ZOOMF, format, sizeof(buffer));
				wsprintf(buffer, format, result);
				SetWindowText(Wnd, buffer);
				DisplayZoom = result;
			}
			return 0;
		}
	case WM_PAINT:
		CheckDisplay();
		RefreshFlag = TRUE;
		break;
 	case WM_KEYDOWN:
		switch(WParam) {
		case VK_ESCAPE:
			SetForegroundWindow(MainWnd);
			break;
		case VK_HOME:
			QueueKey(0x0C);
			break;
		case VK_UP:
			QueueKey(0x0B);
			break;
		case VK_LEFT:
			QueueKey(0x08);
			break;
		case VK_RIGHT:
			QueueKey(0x1D);
			break;
		case VK_DOWN:
			QueueKey(0x0A);
			break;
		case VK_END:
			QueueKey(0x12);
			break;
		case VK_INSERT:
			QueueKey(0x02);
			break;
		case VK_DELETE:
			QueueKey(0x05);
		}
		return 0;
	case WM_CHAR:
		ProcessKey((UCHAR)WParam);
		return 0;
	case WM_MOUSEMOVE:
#if HIDE_MOUSE
		if (!TrackingFlag) {
			trackMouseEvent.cbSize = sizeof (trackMouseEvent);
			trackMouseEvent.dwFlags = TME_LEAVE;
			trackMouseEvent.hwndTrack = Wnd;
			TrackingFlag = TrackMouseEvent(&trackMouseEvent);
			if (TrackingFlag && CursorOffFlag)
				ShowCursor(FALSE);
		}
#endif
		if (DisplayWidth != 0 && DisplayHeight != 0) {
			EnterCriticalSection(&MouseCs);
			MouseX = (LOWORD(LParam) * GraphicWidth) / DisplayWidth;
			MouseY = GraphicHeight - 1 - (HIWORD(LParam) * GraphicHeight) / DisplayHeight;
			LeaveCriticalSection(&MouseCs);
		}
		break;
#if HIDE_MOUSE
	case WM_MOUSELEAVE:
		if (TrackingFlag) {
			if (CursorOffFlag)
				ShowCursor(TRUE);
			TrackingFlag = FALSE;
		}
		break;
	case WM_SHOW_MOUSE:
		if (CursorOffFlag) {
			if (TrackingFlag)
				ShowCursor(TRUE);
			CursorOffFlag = FALSE;
		}
		return 0;
	case WM_HIDE_MOUSE:
		if (!CursorOffFlag) {
			if (TrackingFlag)
				ShowCursor(FALSE);
			CursorOffFlag = TRUE;
		}
		return 0;
#endif
	case WM_LBUTTONDOWN:
		button = 1;
ButtonDown:
		if (DisplayWidth != 0 && DisplayHeight != 0) {
			EnterCriticalSection(&MouseCs);
			MouseX = (LOWORD(LParam) * GraphicWidth) / DisplayWidth;
			MouseY = GraphicHeight - (HIWORD(LParam) * GraphicHeight) / DisplayHeight;
			if ((MouseButtons & button) == 0) { // Mouse click detected
				MouseButtons |= button;
				ClickFlag = TRUE;
				notify = NotifyMouseFlag;
				NotifyMouseFlag = FALSE;
			} else
				notify = FALSE;
			LeaveCriticalSection(&MouseCs);
			if (notify)
				SetEvent(NotifyMouse);
		}
		break;
	case WM_MBUTTONDOWN:
		button = 4;
		goto ButtonDown;
	case WM_RBUTTONDOWN:
		button = 2;
		goto ButtonDown;
	case WM_LBUTTONUP:
		button = ~1;
ButtonUp:
		EnterCriticalSection(&MouseCs);
		MouseButtons &= button;
		if (MouseButtons == 0) // No more mouse click
			ClickFlag = FALSE;
		LeaveCriticalSection(&MouseCs);
		break;
	case WM_MBUTTONUP:
		button = ~4;
		goto ButtonUp;
	case WM_RBUTTONUP:
		button = ~2;
		goto ButtonUp;
	case WM_HOTKEY:
		ptr = ScreenShoot(&x);
		if (ptr != NULL) {
			GetString(IDS_WRITE_AS, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			GetString(IDS_FILTER_BMP, filter, sizeof(filter));
			GetString(IDS_PICTUREF, format, sizeof(buffer));
			wsprintf(fileName, format, ++ImageCount);
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = fileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_OVERWRITEPROMPT;
			openFileName.lpstrDefExt = ImageDefExt;
			result = GetCurrentDirectory(sizeof(directory), directory);
			if (GetSaveFileName(&openFileName)) {
				hFile = CreateFile(fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
				if (hFile == INVALID_HANDLE_VALUE)
					DisplayError(IDS_UCREATEIMAGE);
				else {
					if (!WriteFile(hFile, ptr, x, &y, NULL) || y != x) {
						DisplayError(IDS_UWRITEIMAGE);
					}
					CloseHandle(hFile);
				}
			}
			if (result != 0 && result < sizeof(directory))
				SetCurrentDirectory(directory);
			VirtualFree(ptr, 0, MEM_RELEASE);
		}
		break;
	case WM_DESTROY:
#if HIDE_MOUSE
		if (TrackingFlag) {
			if (CursorOffFlag)
				ShowCursor(TRUE);
			TrackingFlag = FALSE;
		}
#endif
		UnregisterHotKey(Wnd, 12345);
		GraphicStopFlag = TRUE;
		WaitForSingleObject(GraphicHandle, INFINITE);
		CloseHandle(GraphicHandle);
		GraphicHandle = NULL;
		CloseDisplay();
		ClickMouse();
		DisplayWnd = NULL;
		if (CloseFlag) {
			CloseFlag = FALSE;
			SetEvent(DisplayClosed); // End of display closing
		} else
			DestroyGraphic(); // Inform graphic module
		if (GraphicMemory != NULL) {
			VirtualFree(GraphicMemory, 0, MEM_RELEASE);
			GraphicMemory = NULL;
		}
		break;
	}
	return DefWindowProc(Wnd, Msg, WParam, LParam);
}

static BOOL CALLBACK ReadMeProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {
	ULONG len;
	HRSRC resource;
	PUCHAR string;
	UCHAR buffer[HELP_LEN+1];

    switch(Msg) {
    case WM_INITDIALOG:
		SendMessage(Wnd, WM_SETICON, ICON_SMALL, (LONG)LoadIcon(Instance, ProgName));
		resource = FindResource(Instance, "README", "TEXT");
		string = (PUCHAR)LockResource(LoadResource(Instance, resource));
		len = SizeofResource(Instance, resource);
		if (len > HELP_LEN)
			len = HELP_LEN;
		CopyMemory(buffer, string, len);
		buffer[len] = 0; // terminate string with null
		ReadMeWnd = GetDlgItem(Wnd, IDC_README);
		SendMessage(ReadMeWnd, WM_SETTEXT, 0, (LONG)string);
		return TRUE;
	case WM_COMMAND:
		switch(HIWORD(WParam)){
		case EN_SETFOCUS:
			SendMessage(ReadMeWnd, EM_SETSEL, -1, 0);
			return FALSE;
		}
		if (HIWORD(WParam) != 0)
			 break;
		switch(LOWORD(WParam)){
		case IDC_RETURN:
		case IDCANCEL:
			EndDialog(Wnd, 0);
		}
	}
	return FALSE;
}

static BOOL CALLBACK AboutProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {

    switch(Msg) {
    case WM_INITDIALOG:
		return TRUE;
	case WM_COMMAND:
		if (HIWORD(WParam) != 0)
			 break;
		switch(LOWORD(WParam)){
		case IDOK:
		case IDCANCEL:
			EndDialog(Wnd, 0);
		}
	}
	return FALSE;
}

static BOOL CALLBACK HelpProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {

    switch(Msg) {
    case WM_INITDIALOG:
		SendMessage(Wnd, WM_SETICON, ICON_SMALL, (LONG)LoadIcon(Instance, ProgName));
		return TRUE;
	case WM_COMMAND:
		switch(HIWORD(WParam)){
		case EN_SETFOCUS:
			SendMessage(HelpWnd, EM_SETSEL, -1, 0);
			return FALSE;
		}
		if (HIWORD(WParam) != 0)
			 break;
		switch(LOWORD(WParam)){
		case IDC_CLOSE:
		case IDCANCEL:
			EndDialog(Wnd, 0);
		}
	}
	return FALSE;
}

VOID DisplayHelp(HWND Wnd, ULONG Index) {
	ULONG len;
	HRSRC resource;
	PUCHAR string;
	UCHAR buffer[HELP_LEN+1];

	if (HelpWnd == NULL) {
		HelpWnd = CreateDialog(Instance, "HELP", Wnd, HelpProc);
		if (HelpWnd == NULL)
			return;
	}
	resource = FindResource(Instance, MAKEINTRESOURCE(Index), "TEXT");
	string = (PUCHAR)LockResource(LoadResource(Instance, resource));
	len = SizeofResource(Instance, resource);
	if (len > HELP_LEN)
		len = HELP_LEN;
	CopyMemory(buffer, string, len);
	buffer[len] = 0; // terminate string with null
	SendMessage(GetDlgItem(HelpWnd, IDC_HELPSB), WM_SETTEXT, 0, (LONG)buffer);
    ShowWindow(HelpWnd, SW_SHOWNORMAL);
}

// Main message procedure
LRESULT CALLBACK MainProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {
	ULONG oldPos;
	ULONG width;
	ULONG height;
	ULONG i;
	ULONG j;
	ULONG k;
	ULONG w;
	ULONG h;
	ULONG x;
	ULONG y;
	ULONG z;
	PUCHAR charMemory;
	PULONG textColMemory;
	PULONG backColMemory;
	COLORREF text;
	COLORREF back;
	HBRUSH brush;
	PRECT prect;
	HDC hdc;
	TEXTMETRIC textMetric;
	PAINTSTRUCT paintStruct;
	RECT rect;
	OPENFILENAME openFileName;
	SECURITY_ATTRIBUTES pipeAttributes;
	SHORT delta;
	UCHAR c;
	UCHAR filter[100];
	UCHAR buffer[MAX_COLS+1];
	LRESULT result;
	BOOLEAN horz;
	BOOLEAN move;

	switch (Msg) {
	case WM_CREATE:
		hdc = GetDC(Wnd);
		SelectObject(hdc, GetStockObject(OEM_FIXED_FONT));
		GetTextMetrics(hdc, &textMetric);
		XChar = textMetric.tmAveCharWidth;
		YChar = textMetric.tmHeight + textMetric.tmExternalLeading;
		ReleaseDC(Wnd, hdc);
		SysTextColor = GetSysColor(COLOR_WINDOWTEXT);
		SysBackColor = GetSysColor(COLOR_WINDOW);
		width = GetSystemMetrics(SM_CXSCREEN);
		height = GetSystemMetrics(SM_CYSCREEN);
		rect.left = 0;
		rect.top = 0;
		rect.right = width;
		rect.bottom = height;
		AdjustWindowRect(&rect, WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX, FALSE);
		WScreen = (width << 1) - (rect.right - rect.left);
		HScreen = (height << 1) - (rect.bottom - rect.top);
		SizeFlag = FALSE;
		FocusOn = FALSE;
		CaretOn = FALSE;
		HorzScroll = FALSE;
		VertScroll = FALSE;
		EscFlag = FALSE;
		InvertFlag = FALSE;
		XCursor = 0;
		YCursor = 0;
		HCursor = 1;
		BCursor = 1;
		XScroll = 0;
		YScroll = 0;
		TOffset = 0;
		XMin = 0;
		YMin = 0;
		XMax = TextCols - 1;
		YMax = TextLines - 1;
		TextColor = SysTextColor;
		BackColor = SysBackColor;
		ClearTextMemory();
		BackBrush = CreateSolidBrush(BackColor);
		if (BackBrush == NULL) {
CreateError:
			return -1;
		}
		StartEvent = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (StartEvent == NULL) {
DeleteBrushError:
			DeleteObject(BackBrush);
			goto CreateError;
		}
		NotifyKey = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (NotifyKey == NULL) {
CloseStartError:
			CloseHandle(StartEvent);
			goto DeleteBrushError;
		}
		NotifyMouse = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (NotifyMouse == NULL) {
CloseNotifyKeyError:
			CloseHandle(NotifyKey);
			goto CloseStartError;
		}
		NotifyDisp = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (NotifyDisp == NULL) {
CloseNotifyMouseError:
			CloseHandle(NotifyMouse);
			goto CloseNotifyKeyError;
		}
		NotifyConsole = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (NotifyConsole == NULL) {
CloseNotifyDispError:
			CloseHandle(NotifyDisp);
			goto CloseNotifyMouseError;
		}
		WaitCursor = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (WaitCursor == NULL) {
CloseNotifyConsoleError:
			CloseHandle(NotifyConsole);
			goto CloseNotifyDispError;
		}
		DisplayCreated = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (DisplayCreated == NULL) {
CloseWaitError:
			CloseHandle(WaitCursor);
			goto CloseNotifyConsoleError;
		}
		DisplayClosed = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
		if (DisplayClosed == NULL) {
CloseCreatedError:
			CloseHandle(DisplayCreated);
			goto CloseWaitError;
		}
		InitializeCriticalSection(&DispCs);
		InitializeCriticalSection(&KeyCs);
		InitializeCriticalSection(&MouseCs);
		NotifyDispFlag = FALSE;
		NotifyKeyFlag = FALSE;
		NotifyMouseFlag = FALSE;
		RedirInputFlag = FALSE;
		SyncOutputFlag = FALSE;
		FlushKey();
		StdInput = GetStdHandle(STD_INPUT_HANDLE);
		StdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
		StdError = GetStdHandle(STD_ERROR_HANDLE);
		pipeAttributes.nLength = sizeof(SECURITY_ATTRIBUTES);
		pipeAttributes.bInheritHandle = TRUE;
		pipeAttributes.lpSecurityDescriptor = NULL;
		if (CreatePipe(&InputRead, &InputWrite, &pipeAttributes, 0)) {
			SetHandleInformation(InputWrite, HANDLE_FLAG_INHERIT, 0);
			InputPipeFlag = TRUE;
			if (SetStdHandle(STD_INPUT_HANDLE, InputRead)) {
				if (CreatePipe(&OutputRead, &OutputWrite, &pipeAttributes, 0)) {
					SetHandleInformation(OutputRead, HANDLE_FLAG_INHERIT, 0);

					OutputEndFlag = FALSE;
					OutputHandle = CreateThread(NULL, 0, OutputThread, NULL, 0, NULL);
					if (OutputHandle != NULL) {
						NotifyConsoleFlag = FALSE;
						if (SetStdHandle(STD_OUTPUT_HANDLE, OutputWrite)) {
							if (!SetStdHandle(STD_ERROR_HANDLE, OutputWrite)) {
								SetStdHandle(STD_OUTPUT_HANDLE, StdOutput);
								goto EndOutputThread;
							}
						} else {
EndOutputThread:
							OutputEndFlag = TRUE;
							c = 0x1A;
							WriteFile(OutputWrite, &c, 1, &i, NULL);
							WaitForSingleObject(OutputHandle, INFINITE);
							goto CloseOutputPipe;
						}
					} else {
CloseOutputPipe:
						CloseHandle(OutputRead);
						CloseHandle(OutputWrite);
						goto RestoreStdInput;
					}
				} else {
RestoreStdInput:
					SetStdHandle(STD_INPUT_HANDLE, StdInput);
					goto CloseInputPipe;
				}
			} else {
CloseInputPipe:
				CloseHandle(InputRead);
				CloseHandle(InputWrite);
				goto NoPipe;
			}
		} else {
NoPipe:
			InputPipeFlag = FALSE;
			OutputHandle = NULL;
		}
		BreakOn = TRUE;
		BasicEndFlag = FALSE;
		BasicHandle = CreateThread(NULL, 0, BasicThread, NULL, 0, NULL);
		if (BasicHandle == NULL) {
			DeleteCriticalSection(&DispCs);
			DeleteCriticalSection(&KeyCs);
			DeleteCriticalSection(&MouseCs);
			CloseHandle(DisplayClosed);
			goto CloseCreatedError;
		}
		ShowScrollBar(Wnd, SB_HORZ, FALSE);
		ShowScrollBar(Wnd, SB_VERT, FALSE);
		return 0;
	case WM_SIZING:
		prect = (PRECT)LParam;
		result = 0;
		if (prect->right - prect->left > MaxWidth) {
			if (LOWORD(WParam) == WMSZ_TOPLEFT || LOWORD(WParam) == WMSZ_LEFT || LOWORD(WParam) == WMSZ_BOTTOMLEFT)
				prect->left = prect->right - MaxWidth;
			else if (LOWORD(WParam) == WMSZ_TOPRIGHT || LOWORD(WParam) == WMSZ_RIGHT || LOWORD(WParam) == WMSZ_BOTTOMRIGHT)
				prect->right = prect->left + MaxWidth;
			result = 1;
		}
		if (prect->bottom - prect->top > MaxHeight) {
			if (LOWORD(WParam) == WMSZ_TOPLEFT || LOWORD(WParam) == WMSZ_TOP || LOWORD(WParam) == WMSZ_TOPRIGHT)
				prect->top = prect->bottom - MaxHeight;
			else if (LOWORD(WParam) == WMSZ_BOTTOMLEFT || LOWORD(WParam) == WMSZ_BOTTOM || LOWORD(WParam) == WMSZ_BOTTOMRIGHT)
				prect->bottom = prect->top + MaxHeight;
			result = 1;
		}
		return result;
	case WM_SIZE:
		if (WParam != SIZE_RESTORED)
			break;
		width = LOWORD(LParam);
		XClient = width / XChar;
		XOffset = width - XClient * XChar;
		height = HIWORD(LParam);
		h = YClient;
		YClient = height / YChar;
		YOffset = height - YClient * YChar;
		if (YScroll != 0) {
			if (YClient > h) {
				if (YScroll > YClient - h)
					YScroll -= YClient - h;
				else
					YScroll = 0;
			} else if (YClient < h)
				YScroll += h - YClient;
		}
		if (SizeFlag)
			break;
		SizeFlag = TRUE;
		if (HorzScroll)
			height += ScrollBarY;
		if (VertScroll)
			width += ScrollBarX;
		horz = FALSE;
		width -= ScrollBarX; // Horizontal scroll bar always displayed
		if (width < TextCols * XChar) {
			horz = TRUE;
			height -= ScrollBarY;
		}
		if (horz) {
			XScrollMax = TextCols - width / XChar;
			if (!HorzScroll) {
				ShowScrollBar(Wnd, SB_HORZ, TRUE);
				HorzScroll = TRUE;
			} else if (XScroll > XScrollMax)
				XScroll = XScrollMax;
			SetScrollRange(Wnd, SB_HORZ, 0, XScrollMax, FALSE);
			SetScrollPos(Wnd, SB_HORZ, XScroll, TRUE);
		} else if (HorzScroll) {
			ShowScrollBar(Wnd, SB_HORZ, FALSE);
			XScroll = 0;
			HorzScroll = FALSE;
		}
		YScrollMax = BUFFER_LINES - height / YChar;
		if (!VertScroll) {
			ShowScrollBar(Wnd, SB_VERT, TRUE);
			VertScroll = TRUE;
		}
		SetScrollRange(Wnd, SB_VERT, 0, YScrollMax, FALSE);
		SetScrollPos(Wnd, SB_VERT, YScroll, TRUE);
		PosCursor(Wnd, FALSE);
		SizeFlag = FALSE;
		return 0;
	case WM_HSCROLL:
		oldPos = XScroll;
		switch (LOWORD(WParam)) {
		case SB_TOP:
			XScroll = 0;
			break;
		case SB_BOTTOM:
			XScroll = XScrollMax;
			break;
		case SB_LINEUP:
			if (XScroll != 0)
				XScroll--;
			break;
		case SB_LINEDOWN:
			if (XScroll < XScrollMax)
				XScroll++;
			break;
		case SB_PAGEUP:
			if (XScroll > XClient)
				XScroll -= XClient;
			else
				XScroll = 0;
			break;
		case SB_PAGEDOWN:
			if (XScroll + XClient < XScrollMax)
				XScroll += XClient;
			else
				XScroll = XScrollMax;
			break;
		case SB_THUMBTRACK:
			XScroll = HIWORD(WParam);
		}
		if (XScroll != oldPos) {
			SetScrollPos(Wnd, SB_HORZ, XScroll, TRUE);
			PosCursor(Wnd, FALSE);
			InvalidateRect(Wnd, NULL, TRUE);
		}
		return 0;
	case WM_VSCROLL:
		oldPos = YScroll;
		switch (LOWORD(WParam)) {
		case SB_TOP:
			YScroll = 0;
			break;
		case SB_BOTTOM:
			YScroll = YScrollMax;
			break;
		case SB_LINEUP:
			if (YScroll != 0)
				YScroll--;
			break;
		case SB_LINEDOWN:
			if (YScroll < YScrollMax)
				YScroll++;
			break;
		case SB_PAGEUP:
PageUp:
			if (YScroll > YClient)
				YScroll -= YClient;
			else
				YScroll = 0;
			break;
		case SB_PAGEDOWN:
PageDown:
			if (YScroll + YClient < YScrollMax)
				YScroll += YClient;
			else
				YScroll = YScrollMax;
			break;
		case SB_THUMBTRACK:
			YScroll = HIWORD(WParam);
		}
		if (YScroll != oldPos) {
			SetScrollPos(Wnd, SB_VERT, YScroll, TRUE);
			PosCursor(Wnd, FALSE);
			InvalidateRect(Wnd, NULL, TRUE);
		}
		return 0;
	case WM_MOUSEWHEEL:
		oldPos = YScroll;
		delta = HIWORD(WParam);
		if (delta > 0) {
			if (YScroll != 0)
				YScroll--;
		} else {
			if (YScroll < YScrollMax)
				YScroll++;
		}
		if (YScroll != oldPos) {
			SetScrollPos(Wnd, SB_VERT, YScroll, TRUE);
			PosCursor(Wnd, FALSE);
			InvalidateRect(Wnd, NULL, TRUE);
		}
		return 0;
	case WM_PAINT:
		hdc = BeginPaint(Wnd, &paintStruct);
		SelectObject(hdc, GetStockObject(OEM_FIXED_FONT));
		if (YOffset != 0) {
			// Clear top space line of the display window
			rect.left = 0;
			rect.top = 0;
			rect.right = XClient * XChar + XOffset;
			rect.bottom = YOffset;
			FillRect(hdc, &rect, BackBrush);
		}
		for (i = YScroll; i < YScroll + YClient; i++) {
			j = XScroll;
			while (j <= XScroll + XClient) {
				if (i < BUFFER_LINES && j < TextCols) {
					buffer[0] = CharMemory[i*TextCols+j];
					text = TextColMemory[i*TextCols+j];
					back = BackColMemory[i*TextCols+j];
				} else {
					buffer[0] = ' ';
					text = TextColor;
					back = BackColor;
				}
				k = 1;
				j++;
				while (j <= XScroll + XClient && k < TextCols + 1) {
					if (i < BUFFER_LINES && j < TextCols) {
						if (text != TextColMemory[i*TextCols+j] || back != BackColMemory[i*TextCols+j])
							break;
					} else {
						if (text != TextColor || back != BackColor)
							break;
					}
					if (i < BUFFER_LINES && j < TextCols)
						buffer[k] = CharMemory[i*TextCols+j];
					else
						buffer[k] = ' ';
					k++;
					j++;
				}
				SetTextColor(hdc, text);
				SetBkColor(hdc, back);
				TextOut(hdc, XChar * (j - XScroll - k), YChar * (i - YScroll) + YOffset, buffer, k);
			}
		}
		EndPaint(Wnd, &paintStruct);
		return 0;
	case WM_SETFOCUS:
		FocusOn = TRUE;
		if (!CaretOn && XCursor >= XScroll && TOffset + YCursor >= YScroll) {
			x =  XCursor - XScroll;
			y =  TOffset + YCursor - YScroll;
			if (x < XClient && y < YClient) {
				CreateCaret(Wnd, NULL, XChar, HCursor);
				SetCaretPos(XChar * x, YChar * (y + 1) - BCursor - HCursor + YOffset);
				ShowCaret(Wnd);
				CaretOn = TRUE;
			}
		}
		break;
	case WM_KILLFOCUS:
		if (CaretOn) {
			CaretOn = FALSE;
			DestroyCaret();
		}
		FocusOn = FALSE;
		break;
	case WM_KEYDOWN:
		switch(WParam) {
		case VK_HOME:
			QueueKey(0x0C);
			break;
		case VK_UP:
			QueueKey(0x0B);
			break;
		case VK_LEFT:
			QueueKey(0x08);
			break;
		case VK_RIGHT:
			QueueKey(0x1D);
			break;
		case VK_DOWN:
			QueueKey(0x0A);
			break;
		case VK_END:
			QueueKey(0x12);
			break;
		case VK_INSERT:
			QueueKey(0x02);
			break;
		case VK_DELETE:
			QueueKey(0x05);
			break;
		case VK_PRIOR:
			oldPos = YScroll;
			goto PageUp;
		case VK_NEXT:
			oldPos = YScroll;
			goto PageDown;
		}
		return 0;
	case WM_CHAR:
		ProcessKey((UCHAR)WParam);
		return 0;
	case WM_LBUTTONDOWN:
		x = LOWORD(LParam) / XChar + XScroll;
		y = HIWORD(LParam) / YChar + YScroll;
		if (IsLetter(CharMemory[y*TextCols+x])) {
			i = x;
			while (i > 0 && x - i < KEY_LEN - 1 && IsLetter(CharMemory[y*TextCols+i-1]))
				i--;
			j = 0;
			while (i <= x) {
				c = CharMemory[y*TextCols+i];
				if (c >= 'a' && c <= 'z')
					c &= 0xDF;
				buffer[j] = c;
				i++;
				j++;
			}
			k = j;
			while (j - k < KEY_LEN - 1 && i < TextCols && IsLetter(CharMemory[y*TextCols+i])) {
				c = CharMemory[y*TextCols+i];
				if (c >= 'a' && c <= 'z')
					c &= 0xDF;
				buffer[j] = c;
				i++;
				j++;
			}
			x = 0;
			while (x < k) {
				c = buffer[x];
				y = 0;
				while (y < KEY_COUNT) {
					if (c == KeyWord[y][0]) {
						z = 1;
						while (z < j - x && buffer[x+z] == KeyWord[y][z])
							z++;
						if (KeyWord[y][z] == 0 && x + z >= k) { // keyword found
							z = KeyIndex[y];
							if (z != 0)
								DisplayHelp(Wnd, z);
							goto KeyWordEnd;
						}
					}
					y++;
				}
				x++;
			}
KeyWordEnd:;
		}
		break;
	case WM_DISP_CMD:
		while (!BasicEndFlag && GetDisp(&c, &w, &h))
			switch(c) {
			case DISP_INIT:
				InvertFlag = FALSE;
				XMin = 0;
				YMin = 0;
				XMax = TextCols - 1;
				YMax = TextLines - 1;
				TextColor = SysTextColor;
				if (BackColor != SysBackColor) {
					brush = CreateSolidBrush(SysBackColor);
					if (brush != NULL) {
						DeleteObject(BackBrush);
						BackBrush = brush;
						SetClassLong(MainWnd, GCL_HBRBACKGROUND, (LONG)BackBrush);
						BackColor = SysBackColor;
					}
				}
				EscFlag = FALSE;
				break;
			case DISP_WINDOW:
				i = w & 0x00FF;
				j = (w & 0xFF00) >> 8;
				x = h & 0x00FF;
				y = (h & 0xFF00) >> 8;
				if (x > TextCols - 1)
					x = TextCols - 1;
				if (y > TextLines - 1)
					y = TextLines - 1;
				if (i <= x && j <= y) {
					XMin = i;
					YMin = j;
					XMax = x;
					YMax = y;
					move = FALSE;
					if (XCursor < XMin) {
						XCursor = XMin;
						move = TRUE;
					}
					if (XCursor > XMax) {
						XCursor = XMax;
						move = TRUE;
					}
					if (YCursor < YMin) {
						YCursor = YMin;
						move = TRUE;
					}
					if (YCursor > YMax) {
						YCursor = YMax;
						move = TRUE;
					}
					if (move)
						PosCursor(MainWnd, FALSE);
				}
				break;
			case DISP_COLOR:
				switch (w) {
				case 0:
					if (BackColor == (COLORREF)h)
						break;
					brush = CreateSolidBrush((COLORREF)h);
					if (brush == NULL)
						break;
					DeleteObject(BackBrush);
					BackBrush = brush;
					SetClassLong(MainWnd, GCL_HBRBACKGROUND, (LONG)BackBrush);
					BackColor = (COLORREF)h;
					break;
				case 1:
					TextColor = (COLORREF)h;
					break;
				}
				break;
			case DISP_CHAR:
				c = (UCHAR)w;
				if (EscFlag) {
					EscFlag = FALSE;
					switch (c) {
					case ']':
					case 'H':
					case 'Z': // Inverse On
						InvertFlag = TRUE;
						break;
					case '\\':
					case 'I':
					case 'Y':
					case 'u': // Inverse Off
						InvertFlag = FALSE;
						break;
					case 'p':
						if (YCursor < YMin || YCursor > YMax)
							break;
						// Clear display memory Line
						for (j = XMin; j <= XMax; j++) {
							CharMemory[(TOffset+YCursor)*TextCols+j] = ' ';
							TextColMemory[(TOffset+YCursor)*TextCols+j] = TextColor;
							BackColMemory[(TOffset+YCursor)*TextCols+j] = BackColor;
						}
						// Cip the text line with the display window
						w = XMax - XMin + 1;
						if (XMin >= XScroll)
							x = XMin - XScroll;
						else {
							x = 0;
							if (w + XMin > XScroll)
								w -= XScroll - XMin;
							else
								w = 0;
						}
						if (x + w > XClient + 1) {
							if (x < XClient + 1)
								w = XClient + 1 - x;
							else
								w = 0;
						}
						if (TOffset + YCursor >= YScroll) {
							y = TOffset + YCursor - YScroll;
							h = 1;
						} else {
							y = 0;
							h = 0;
						}
						if (y >= YClient)
							h = 0;
						if (w != 0 && h != 0) {
							// Clear screen line
							if (CaretOn)
								HideCaret(Wnd);
							hdc = GetDC(Wnd);
							rect.left = x * XChar;
							rect.top = y * YChar + YOffset;
							rect.right = (x + w) * XChar;
							rect.bottom = (y + 1) * YChar + YOffset;
							FillRect(hdc, &rect, BackBrush);
							ReleaseDC(Wnd, hdc);
							if (CaretOn)
								ShowCaret(Wnd);
						}
						break;
					case 'q': {
ClearScreen:
						// Clear display memory
						if (XMin != 0 || XMax != TextCols - 1 || YMin != 0 || YMax != TextLines - 1) { // Not full screen text window
							for (i = YMin; i <= YMax; i++)
								for (j = XMin; j <= XMax; j++) {
									CharMemory[(TOffset+i)*TextCols+j] = ' ';
									TextColMemory[(TOffset+i)*TextCols+j] = TextColor;
									BackColMemory[(TOffset+i)*TextCols+j] = BackColor;
								}
						} else {
							ClearTextMemory();
							TOffset = 0;
							YScroll = 0;
							SetScrollPos(Wnd, SB_VERT, YScroll, TRUE);
						}
						// Clip the text window with the display window
						w = XMax - XMin + 1;
						if (XMin >= XScroll)
							x = XMin - XScroll;
						else {
							x = 0;
							if (w + XMin > XScroll)
								w -= XScroll - XMin;
							else
								w = 0;
						}
						if (x + w > XClient + 1) {
							if (x < XClient + 1)
								w = XClient + 1 - x;
							else
								w = 0;
						}
						h = YMax - YMin + 1;
						if (TOffset + YMin >= YScroll)
							y = TOffset + YMin - YScroll;
						else {
							y = 0;
							if (h + TOffset + YMin > YScroll)
								h -= YScroll - TOffset - YMin;
							else
								h = 0;
						}
						if (y + h >= YClient) {
							if (y < YClient)
								h = YClient - y;
							else
								h = 0;
						}
						if (w != 0 && h != 0) {
							// Clear display window
							if (CaretOn)
								HideCaret(Wnd);
							hdc = GetDC(Wnd);
							rect.left = x * XChar;
							rect.top = y * YChar + YOffset;
							rect.right = (x + w) * XChar;
							rect.bottom = (y + h) * YChar + YOffset;
							FillRect(hdc, &rect, BackBrush);
							ReleaseDC(Wnd, hdc);
							if (CaretOn)
								ShowCaret(Wnd);
						}
						break;
					}
					case '0':
						text = SysBackColor;
SetTextColor:
						if (!InvertFlag)
							TextColor = text;
						else
							BackColor = text;
						break;
					case '1':
						text = RGB(192, 0, 0);
						goto SetTextColor;
					case '2':
						text = RGB(0, 192, 0);
						goto SetTextColor;
					case '3':
						text = RGB(192, 128, 0);
						goto SetTextColor;
					case '4':
						text = RGB(0, 0, 192);
						goto SetTextColor;
					case '5':
						text = RGB(192, 0, 192);
						goto SetTextColor;
					case '6':
						text = RGB(0, 192, 192);
						goto SetTextColor;
					case '7':
						text = RGB(192, 192, 192);
						goto SetTextColor;
					case '8':
						text = SysTextColor;
						goto SetTextColor;
					}
					break;
				}
				if (c >= 0x20) {
					DisplayChar(Wnd, c);
					break;
				}
				switch (c) {
				case 0x07: // Bell
					Beep(1760,500);
					break;
				case 0x08: // BackSpace
					if (XCursor > XMin)
						XCursor--;
					else if (YCursor > YMin) {
						YCursor--;
						XCursor = XMax;
					}
					PosCursor(Wnd, TRUE);
					break;
				case 0x09: // Tab
					do
						DisplayChar(Wnd, ' ');
					while ((XCursor - XMin) % 8 != 0);
					break;
				case 0x0A: // LF
					LineFeed(Wnd);
					PosCursor(Wnd, TRUE);
					break;
				case 0x0B: // Up
					if (YCursor > YMin) {
						YCursor--;
						PosCursor(Wnd, TRUE);
					}
					break;
				case 0x0C: // Home
					XCursor = XMin;
					YCursor = YMin;
					PosCursor(Wnd, TRUE);
					goto ClearScreen;
				case 0x0D: // CR
					XCursor = XMin;
					PosCursor(Wnd, TRUE);
					break;
				case 0x1B: // Escape
					EscFlag = TRUE;
					break;
				case 0x1D: // Right
					if (XCursor < XMax) {
						XCursor++;
						PosCursor(Wnd, TRUE);
					}
					break;
				}
				break;
			case DISP_CURSOR_SIZE:
				HCursor = w;
				BCursor = h;
				if (CaretOn) {
					DestroyCaret();
					CreateCaret(Wnd, NULL, XChar, HCursor);
					if (XCursor >= XScroll && TOffset + YCursor >= YScroll) {
						x =  XCursor - XScroll;
						y =  TOffset + YCursor - YScroll;
						if (x < XClient && y < YClient) {
							SetCaretPos(XChar * x, YChar * (y + 1) - BCursor - HCursor + YOffset);
							ShowCaret(Wnd);
						}
					}
				}
				break;
			case DISP_SET_CURSOR:
				y = w + YMin;
				x = h + XMin;
				if (x <= XMax && y <= YMax) {
					XCursor = x;
					YCursor = y;
					PosCursor(Wnd, TRUE);
				}
				break;
			case DISP_GET_CURSOR:
				if (XCursor > XMin) {
					XPos = XCursor - XMin;
					if (XPos > XMax - XMin)
						XPos = XMax - XMin;
				} else
					XPos = 0;
				if (YCursor > YMin) {
					YPos = YCursor - YMin;
					if (YPos > YMax - YMin)
						YPos = YMax - YMin;
				} else
					YPos = 0;
				SetEvent(WaitCursor);
				break;
			case DISP_RESIZE:
				charMemory = VirtualAlloc(NULL, BUFFER_LINES * w * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
				textColMemory = VirtualAlloc(NULL, BUFFER_LINES * w * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
				backColMemory = VirtualAlloc(NULL, BUFFER_LINES * w * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
				if (charMemory != NULL && textColMemory != NULL && backColMemory != NULL) {
					SizeFlag = TRUE;
					if (HorzScroll) {
						ShowScrollBar(Wnd, SB_HORZ, FALSE);
						HorzScroll = FALSE;
					}
					if (VertScroll) {
						ShowScrollBar(Wnd, SB_VERT, FALSE);
						VertScroll = FALSE;
					}
					VirtualFree(CharMemory, 0, MEM_RELEASE);
					CharMemory = charMemory;
					VirtualFree(TextColMemory, 0, MEM_RELEASE);
					TextColMemory = textColMemory;
					VirtualFree(BackColMemory, 0, MEM_RELEASE);
					BackColMemory = backColMemory;
					TextCols = w;
					TextLines = h;
					EscFlag = FALSE;
					InvertFlag = FALSE;
					XCursor = 0;
					YCursor = 0;
					HCursor = 1;
					BCursor = 1;
					XScroll = 0;
					YScroll = 0;
					TOffset = 0;
					XMin = 0;
					YMin = 0;
					XMax = TextCols - 1;
					YMax = TextLines - 1;
					TextColor = SysTextColor;
					if (BackColor != SysBackColor) {
						brush = CreateSolidBrush(SysBackColor);
						if (brush != NULL) {
							DeleteObject(BackBrush);
							BackBrush = brush;
							SetClassLong(MainWnd, GCL_HBRBACKGROUND, (LONG)BackBrush);
							BackColor = SysBackColor;
						}
					}
					ClearTextMemory();
					SizeFlag = FALSE;
					SizeText(TRUE);
					FocusText();
				} else {
					if (charMemory != NULL)
						VirtualFree(charMemory, 0, MEM_RELEASE);
					if (textColMemory != NULL)
						VirtualFree(textColMemory, 0, MEM_RELEASE);
					if (backColMemory != NULL)
						VirtualFree(backColMemory, 0, MEM_RELEASE);
				}
				break;
			}
		return 0;
	case WM_COMMAND:
		switch(LOWORD(WParam)) {
		case IDM_ZOOM1:
			GraphicZoom = 1;
ApplyZoom:
			width = GetSystemMetrics(SM_CXSCREEN);
			height = GetSystemMetrics(SM_CYSCREEN);
			if (DisplayWnd != NULL && GraphicZoom * GraphicWidth + XBorder <= width && GraphicZoom * GraphicHeight + YBorder <= height) {
				GetWindowRect(DisplayWnd, &rect);
				if (rect.left < 0) {
					rect.right -= rect.left;
					rect.left = 0;
				}
				if ((ULONG)rect.left > width - GraphicZoom * GraphicWidth - XBorder)
					rect.left = width - GraphicZoom * GraphicWidth - XBorder;
				if (rect.top < 0) {
					rect.bottom -= rect.top;
					rect.top = 0;
				}
				if ((ULONG)rect.top > GraphicZoom * GraphicHeight + YBorder)
					rect.top = height - GraphicZoom * GraphicHeight - YBorder;
				MoveWindow(DisplayWnd, rect.left, rect.top, GraphicZoom * GraphicWidth + XBorder, GraphicZoom * GraphicHeight + YBorder, FALSE);
				InvalidateRect(NULL, NULL, TRUE);
			} else
				GraphicZoom = 0;
			break;
		case IDM_ZOOM2:
			GraphicZoom = 2;
			goto ApplyZoom;
		case IDM_ZOOM3:
			GraphicZoom = 3;
			goto ApplyZoom;
		case IDM_ZOOM4:
			GraphicZoom = 4;
			goto ApplyZoom;
		case IDM_ZOOM5:
			GraphicZoom = 5;
			goto ApplyZoom;
		case IDM_ZOOM6:
			GraphicZoom = 6;
			goto ApplyZoom;
		case IDM_RUNF:
			LoadString(Instance, IDS_BLOAD_FILE, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			LoadString(Instance, IDS_FILTER_BACBAS, filter, sizeof(filter));
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = BasicFileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_FILEMUSTEXIST;
			openFileName.lpstrDefExt = BacDefExt;
			if (GetOpenFileName(&openFileName)) {
				QueueString("RUN \"");
				QueueString(BasicFileName);
				QueueString("\"\r");
			}
			break;
		case IDM_LOAD:
			LoadString(Instance, IDS_LOAD_FILE, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			LoadString(Instance, IDS_FILTER_BAS, filter, sizeof(filter));
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = BasFileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_FILEMUSTEXIST;
			openFileName.lpstrDefExt = BasDefExt;
			if (GetOpenFileName(&openFileName)) {
				QueueString("LOAD \"");
				QueueString(BasFileName);
				QueueString("\"\r");
			}
			break;
		case IDM_BLOAD:
			LoadString(Instance, IDS_BLOAD_FILE, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			LoadString(Instance, IDS_FILTER_BAC, filter, sizeof(filter));
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = BacFileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_FILEMUSTEXIST;
			openFileName.lpstrDefExt = BacDefExt;
			if (GetOpenFileName(&openFileName)) {
				QueueString("BLOAD \"");
				QueueString(BacFileName);
				QueueString("\"\r");
			}
			break;
		case IDM_SAVE:
			LoadString(Instance, IDS_SAVE_FILE, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			LoadString(Instance, IDS_FILTER_BAS, filter, sizeof(filter));
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = BasFileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_OVERWRITEPROMPT;
			openFileName.lpstrDefExt = BasDefExt;
			if (GetSaveFileName(&openFileName)) {
				QueueString("SAVE \"");
				QueueString(BasFileName);
				QueueString("\"\r");
			}
			break;
		case IDM_COMPILE:
			LoadString(Instance, IDS_COMPILE_FILE, buffer, sizeof(buffer));
			ZeroMemory(filter, sizeof(filter));
			LoadString(Instance, IDS_FILTER_BAC, filter, sizeof(filter));
			openFileName.lStructSize = sizeof(openFileName);
			openFileName.hwndOwner = Wnd;
			openFileName.lpstrFilter = filter;
			openFileName.lpstrCustomFilter = NULL;
			openFileName.nMaxCustFilter = 0;
			openFileName.nFilterIndex = 1;
			openFileName.lpstrFile = BacFileName;
			openFileName.nMaxFile = MAX_PATH;
			openFileName.lpstrFileTitle = NULL;
			openFileName.nMaxFileTitle = 0;
			openFileName.lpstrInitialDir = NULL;
			openFileName.lpstrTitle = buffer;
			openFileName.Flags = OFN_OVERWRITEPROMPT;
			openFileName.lpstrDefExt = BacDefExt;
			if (GetSaveFileName(&openFileName)) {
				QueueString("COMPILE \"");
				QueueString(BacFileName);
				QueueString("\"\r");
			}
			break;
		case IDM_NEW:
			QueueString("NEW\r");
			break;
		case IDM_CLEAR:
			QueueString("CLEAR\r");
			break;
		case IDM_LIST:
			QueueString("LIST\r");
			break;
		case IDM_RUN:
			QueueString("RUN\r");
			break;
		case IDM_BREAK:
			FlushKey();
			QueueKey(0x03); // Ctrl-C
			SetBreak(FALSE);
			break;
		case IDM_CONT:
			QueueString("CONT\r");
			break;
		case IDM_PRINT:
			EnableMenuItem(Menu, IDM_PRINT, MF_GRAYED);
			EnableMenuItem(Menu, IDM_CLEARPRINT, MF_GRAYED);
			EditPrintHandle = CreateThread(NULL, 0, PrintThread, NULL, 0, NULL);
			if (EditPrintHandle == NULL) {
				EnableMenuItem(Menu, IDM_PRINT, MF_ENABLED);
				EnableMenuItem(Menu, IDM_CLEARPRINT, MF_ENABLED);
			}
			break;
		case IDM_CLEARPRINT:
			if (CheckPath(PrintFileName) == PATH_FILE) {
				GetString(IDS_DELPRINT, buffer, sizeof(buffer));
				if (MessageBox(MainWnd, buffer, ProgName, MB_OKCANCEL) == IDOK && !DeleteFile(PrintFileName))
					DisplayError(IDS_PRINTCLEARERR);
			}
			break;
		case IDM_README:
			DialogBox(Instance, "README", Wnd, ReadMeProc);
			break;
		case IDM_ABOUT:
			DialogBox(Instance, "ABOUT", Wnd, AboutProc);
			break;
		case IDM_QUIT:
EndProgram:
			if (SaveFlag && !CheckExit())
				break;
			BasicEndFlag = TRUE;
			SetBreak(TRUE);
			SetEvent(StartEvent);
			SetEvent(NotifyKey);
			SetEvent(NotifyMouse);
			SetEvent(NotifyDisp);
			SetEvent(NotifyConsole);
			SetEvent(WaitCursor);
			SetEvent(DisplayCreated);
			SetEvent(DisplayClosed);
			WaitForSingleObject(BasicHandle, INFINITE);
CloseBasic:
			CloseHandle(BasicHandle);
			DeleteObject(BackBrush);
			PostQuitMessage(0);
			break;
		}
		return 0;
	case WM_CLOSE:
		goto EndProgram;
	case WM_USER_DONE:
		goto CloseBasic;
	case WM_EDIT_DONE:
		if (EditPrintHandle != NULL) {
			WaitForSingleObject(EditPrintHandle, INFINITE);
			CloseHandle(EditPrintHandle);
			EditPrintHandle = NULL;
		}
		EnableMenuItem(Menu, IDM_PRINT, MF_ENABLED);
		EnableMenuItem(Menu, IDM_CLEARPRINT, MF_ENABLED);
		return 0;
	case WM_CREATE_DISPLAY:
		width = GetSystemMetrics(SM_CXSCREEN);
		height = GetSystemMetrics(SM_CYSCREEN);
		i = width * 95 / GraphicWidth / 100;
		j = height * 95 / GraphicHeight / 100;
		if (j < i)
			i = j;
		if (i == 0)
			i = 1;
		if (GraphicZoom != 0) {
			if (GraphicZoom > i)
				GraphicZoom = i;
			else
				i = GraphicZoom;
		}
		XBorder = GraphicWidth * i;
		YBorder = GraphicHeight * i;
		if (XBorder < width)
			rect.left = (width - XBorder) / 2;
		else
			rect.left = 0;
		rect.right = rect.left + XBorder - 1;
		if (YBorder < height)
			rect.top = (height - YBorder) / 2;
		else
			rect.top = 0;
		rect.bottom = rect.top + YBorder - 1;
		AdjustWindowRect(&rect, WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX, FALSE);
		if (rect.right < 0) {
			rect.left -= rect.right;
			rect.right = 0;
		}
		if (rect.top < 0) {
			rect.bottom -= rect.top;
			rect.top = 0;
		}
		width = rect.right - rect.left + 1;
		height = rect.bottom - rect.top + 1;
		XBorder = width - XBorder;
		YBorder = height - YBorder;
		DisplayWnd = CreateWindow(DisplayName, // Must be called by the Main thread !
								  ProgName,
								  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_VISIBLE,
								  rect.left,
								  rect.top,
								  width,
								  height,
								  NULL,
								  NULL,
								  Instance,
								  NULL);
		if (DisplayWnd != NULL) {
			GraphicMemory = VirtualAlloc(NULL, GraphicWidth * GraphicHeight * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
			if (GraphicMemory == NULL)
				DestroyWindow(DisplayWnd);
		}
		SetEvent(DisplayCreated); // End of display creation
		return 0;
	case WM_CLOSE_DISPLAY:
		if (DisplayWnd != NULL)
			DestroyWindow(DisplayWnd);
		else if (CloseFlag) {
			CloseFlag = FALSE;
			SetEvent(DisplayClosed); // End of display closing
		}
		return 0;
	}
    return DefWindowProc(Wnd, Msg, WParam, LParam);
}

// Main program
int WINAPI WinMain(HINSTANCE HInstance, HINSTANCE HPrevInstance, PSTR ProgCmdLine, int CmdShow) {
	ULONG i;
	MSG msg;
	WNDCLASSEX winClass;
	UCHAR c;

	// Initialization
	SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOOPENFILEERRORBOX);
	Instance = HInstance;
	MainWnd = NULL;
	HelpWnd = NULL;
	OutputFormat = 0;
	ReturnCode = 0;
	GraphicZoom = 0;
	ImageCount = 0;
	ScrollBarX = GetSystemMetrics(SM_CXVSCROLL);
	ScrollBarY = GetSystemMetrics(SM_CYHSCROLL);
	BasicFileName[0] = 0;
	BasFileName[0] = 0;
	BacFileName[0] = 0;
	TextCols = TEXT_COLS;
	TextLines = TEXT_LINES;
	DispIn = 0;
	DispOut = 0;
	DispCount = 0;
	DataLen = DATA_LEN;
	CodeLen = CODE_LEN;
	SymbLen = SYMB_LEN;
	ArgC = 0;

	i = 0;
	while (ProgCmdLine[i] != 0) {
		if (ProgCmdLine[i] == ' ')
			i++;
		else if (ArgC == 0 && ProgCmdLine[i] == '/') {
			i++;
			switch (ProgCmdLine[i] & 0xDF) {
			case 'D':
				i++;
				i += SkipSpace(&ProgCmdLine[i]);
				i += DecimalParam(&ProgCmdLine[i], &DataLen);
				if (DataLen == 0 || DataLen > 1024)
					goto SyntaxError;
				break;
			case 'C':
				i++;
				i += SkipSpace(&ProgCmdLine[i]);
				i += DecimalParam(&ProgCmdLine[i], &CodeLen);
				if (CodeLen == 0 || CodeLen > 1024)
					goto SyntaxError;
				break;
			case 'S':
				i++;
				i += SkipSpace(&ProgCmdLine[i]);
				i += DecimalParam(&ProgCmdLine[i], &SymbLen);
				if (SymbLen == 0 || SymbLen > 1024)
					goto SyntaxError;
				break;
			default:
SyntaxError:
				DisplayError(IDS_SYNTAXERR);
				goto MainReturn;
			}
		} else if (ArgC < MAX_ARG) {
			i += StringParam(&ProgCmdLine[i], Arg[ArgC], MAX_WORK);
			ArgV[ArgC] = Arg[ArgC];
			ArgC++;
		} else
			goto SyntaxError;
	}

	// Oem font to System font
	for (i = 0; i < 128; i++) {
		ULONG j;
		UCHAR c;

		c = (UCHAR)(i + 128);
		j = 0;
		while (j < 128 && OemFixedFont[j] != c)
			j++;
		if (j < 128)
			SystemFixedFont[i] = (UCHAR)(j + 128);
		else
			SystemFixedFont[i] = '?';
	}

	// Allocate memory
	DataBase = VirtualAlloc(NULL, DataLen << 20, MEM_COMMIT, PAGE_READWRITE);
	CodeBase = VirtualAlloc(NULL, CodeLen << 20, MEM_COMMIT, PAGE_READWRITE);
	SymbBase = VirtualAlloc(NULL, SymbLen << 20, MEM_COMMIT, PAGE_READWRITE);
	InputBuffer = VirtualAlloc(NULL, INPUT_LINES * MAX_INPUT * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
	CharMemory = VirtualAlloc(NULL, BUFFER_LINES * TextCols * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
	TextColMemory = VirtualAlloc(NULL, BUFFER_LINES * TextCols * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
	BackColMemory = VirtualAlloc(NULL, BUFFER_LINES * TextCols * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
	KeyBuf = VirtualAlloc(NULL, MAX_KEY * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
	DispCmd = VirtualAlloc(NULL, MAX_DISP * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
	DispParam1 = VirtualAlloc(NULL, MAX_DISP * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
	DispParam2 = VirtualAlloc(NULL, MAX_DISP * sizeof(ULONG), MEM_COMMIT, PAGE_READWRITE);
	if (DataBase == NULL || CodeBase == NULL || SymbBase == NULL || InputBuffer == NULL || CharMemory == NULL || TextColMemory == NULL || BackColMemory == NULL ||
		KeyBuf == NULL || DispCmd == NULL || DispParam1 == NULL || DispParam2 == NULL) {
		DisplayError(IDS_UALLOCBUF);
		goto MainReturn;
	}

	// Prepare temporary filename (in temp directory)
	i = GetTempPath(sizeof(PrintFileName) - sizeof(PrintStr) - 1, PrintFileName);
	if (i != 0 && i < sizeof(PrintFileName) - sizeof(PrintStr) - 1) {
		if (PrintFileName[i-1] != '\\') {
			PrintFileName[i] = '\\';
			i++;
		}
	} else
		i = 0;
	CopyMemory(&PrintFileName[i], PrintStr, sizeof(PrintStr));

	// Register graphic window class
    winClass.cbSize = sizeof(winClass) ;
    winClass.style = CS_HREDRAW | CS_VREDRAW;
    winClass.lpfnWndProc = DisplayProc;
    winClass.cbClsExtra = 0;
    winClass.cbWndExtra = sizeof(LONG);
    winClass.hInstance = HInstance;
	winClass.hIcon = LoadIcon(Instance, ProgName);
    winClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    winClass.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    winClass.lpszMenuName = NULL;
    winClass.lpszClassName = DisplayName;
    winClass.hIconSm = NULL;
    RegisterClassEx(&winClass);

	// Create main window
    winClass.cbSize = sizeof(winClass) ;
    winClass.style = CS_HREDRAW | CS_VREDRAW;
    winClass.lpfnWndProc = MainProc;
    winClass.cbClsExtra = 0;
    winClass.cbWndExtra = sizeof(LONG);
    winClass.hInstance = Instance;
    winClass.hIcon = LoadIcon(Instance, ProgName);
    winClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    winClass.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    winClass.lpszMenuName = ProgName;
    winClass.lpszClassName = ProgName ;
    winClass.hIconSm = LoadIcon(Instance, ProgName);
    RegisterClassEx (&winClass);
    MainWnd = CreateWindow(ProgName,
						   ProgName,
						   WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX, // | WS_VSCROLL | WS_HSCROLL,
						   CW_USEDEFAULT, CW_USEDEFAULT,
						   DEFAULT_WIDTH, DEFAULT_HEIGHT,
						   NULL,
						   NULL,
						   Instance,
						   NULL);
	if (MainWnd == NULL) {
		DisplayError(IDS_UCREATEWIN);
		goto MainReturn;
	}
	Menu = GetMenu(MainWnd);
	SizeText(FALSE);
	ShowWindow(MainWnd, CmdShow);
	UpdateWindow(MainWnd);
	SetEvent(StartEvent); // Allow BASIC thread to run

	// Message loop
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	// Cleanup
	if (InputPipeFlag) {
		SetStdHandle(STD_INPUT_HANDLE, StdInput);
		CloseHandle(InputRead);
		CloseHandle(InputWrite);
	}
	if (OutputHandle != NULL) {
		SetStdHandle(STD_OUTPUT_HANDLE, StdOutput);
		SetStdHandle(STD_ERROR_HANDLE, StdError);
		OutputEndFlag = TRUE;
		c = 0x1A;
		WriteFile(OutputWrite, &c, 1, &i, NULL);
		WaitForSingleObject(OutputHandle, INFINITE);
		CloseHandle(OutputRead);
		CloseHandle(OutputWrite);
	}
	DeleteCriticalSection(&DispCs);
	DeleteCriticalSection(&KeyCs);
	DeleteCriticalSection(&MouseCs);
	CloseHandle(DisplayClosed);
	CloseHandle(DisplayCreated);
	CloseHandle(WaitCursor);
	CloseHandle(NotifyDisp);
	CloseHandle(NotifyMouse);
	CloseHandle(NotifyKey);
	CloseHandle(NotifyConsole);
	CloseHandle(StartEvent);

	// Purge printer buffer
	DeleteFile(PrintFileName);
MainReturn:
	return ReturnCode;
}