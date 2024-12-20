// SBASIC Console interface
// Author: Dominique Ezvan

#define _WIN32_WINNT 0x0500
#include <windows.h>
#include "console.h"
#include "sb32.h"
#include "display.h"

#define HIDE_MOUSE       0

#define PATH_NOT_FOUND   0
#define PATH_DIRECTORY   1
#define PATH_FILE        2
#define PATH_ERROR       3
#define DIR_ATTRIBUTES   (FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_HIDDEN | FILE_ATTRIBUTE_SYSTEM)
#define FILE_ATTRIBUTES  (FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_HIDDEN | FILE_ATTRIBUTE_SYSTEM | FILE_ATTRIBUTE_ARCHIVE)

#define BACK_COLOR       0
#define TEXT_COLOR       FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED

// Windows variables
static HINSTANCE Instance;
static HWND MainWnd;
HWND DisplayWnd;
static HWND PrintWnd;
static HMENU PrintMenu;
ULONG TextCols;            // width of display in chars
ULONG TextLines;           // height of display in chars
ULONG BuffLines;           // height of display buffer in chars
static ULONG XMin;         // left character position of the text window
static ULONG XMax;         // right character position of the text window
static ULONG YMin;         // top character position of the text window
static ULONG YMax;         // bottom character position of the text window
static ULONG TOffset;      // Line offset of the text screen in the buffer
static ULONG XCursor;      // text cursor column
static ULONG YCursor;      // text cursor line
static ULONG MouseX;       // last mouse X position in graphic window
static ULONG MouseY;	   // last mouse Y position in graphic window
static ULONG MouseButtons; // last mouse buttons state
ULONG WScreen;             // max graphical window width
ULONG HScreen;             // max graphical window height
static ULONG GraphicZoom;  // default graphic zoom (xN) 
static ULONG DisplayZoom;  // displayed graphic zoom (N%)
static ULONG XBorder;      // graphic window border witdh
static ULONG YBorder;      // graphic window border height
static ULONG TextColor;    // text color
static ULONG BackColor;    // background color
static UCHAR ProgName[] = "SBASIC";
static UCHAR DisplayName[] = "DISPLAY";
static UCHAR PrintName[] = "PRINT";

// Other variables
static HANDLE StdInput;
static HANDLE StdOutput;
static HANDLE DisplayHandle;
static HANDLE PrintHandle;
static HANDLE EditPrintHandle;
static HANDLE GraphicHandle;
static HANDLE NotifyEdit;
static HANDLE NotifyMouse;
static HANDLE DisplayStarted;
static HANDLE ProcessHandle;
static INPUT_RECORD KeyRecord;
static CRITICAL_SECTION MouseCs;
static ULONG DataLen;
static ULONG CodeLen;
static ULONG SymbLen;
static ULONG RecordCount;
static ULONG RecordIndex;
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
static INPUT_RECORD InputRecord[32];
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
static UCHAR SyntaxErrMsg[] = {"->Erreur de syntaxe (utilisez l'option /H)\r\n"};
static UCHAR AllocErrMsg[] = {"->Impossible d'allouer un tampon\r\n"};
static BOOLEAN GraphicStopFlag;
static BOOLEAN NotifyMouseFlag;
static BOOLEAN CloseFlag;
static BOOLEAN EditFlag;
static BOOLEAN BreakOn;
static BOOLEAN NotifyEditFlag;
static BOOLEAN EscFlag;
static BOOLEAN InvertFlag;
static BOOLEAN ClickFlag;
#if HIDE_MOUSE
static BOOLEAN CursorOffFlag;
static BOOLEAN TrackingFlag;
#endif
BOOLEAN RefreshFlag;
BOOLEAN SaveFlag;
static UCHAR OemFixedFont[] = {0x3F, 0x3F, 0x3F, 0x9F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3C, 0x3F, 0x3F, 0x3F, 0x3F,
							  0x3F, 0x60, 0x27, 0x22, 0x22, 0xF7, 0xF0, 0xC4, 0x7E, 0x3F, 0x3F, 0x3E, 0x3F, 0x3F, 0x3F, 0x98,
							  0x20, 0xAD, 0xBD, 0x9C, 0xCF, 0xBE, 0xDD, 0xF5, 0xF9, 0xB8, 0xA6, 0xAE, 0xAA, 0xF0, 0xA9, 0x20,
							  0xF8, 0xF1, 0xFD, 0xFC, 0x27, 0xE6, 0xF4, 0xFA, 0x2C, 0xFB, 0xA7, 0xAF, 0xAC, 0xAB, 0xF3, 0xA8,
							  0xB7, 0xB5, 0xB6, 0xC7, 0x8E, 0x8F, 0x92, 0x80, 0xD4, 0x90, 0xD2, 0xD3, 0xDE, 0xD6, 0xD7, 0xD8,
							  0xD1, 0xA5, 0xE3, 0xE0, 0xE2, 0xE5, 0x99, 0x9E, 0x9D, 0xEB, 0xE9, 0xEA, 0x9A, 0xED, 0xE8, 0xE1,
							  0x85, 0xA0, 0x83, 0xC6, 0x84, 0x86, 0x91, 0x87, 0x8A, 0x82, 0x88, 0x89, 0x8D, 0xA1, 0x8C, 0x8B,
							  0xD0, 0xA4, 0x95, 0xA2, 0x93, 0xE4, 0x94, 0xF6, 0x9B, 0x97, 0xA3, 0x96, 0x81, 0xEC, 0xE7, 0x98};
UCHAR SystemFixedFont[128];

static BOOL WINAPI CtrlHandler(DWORD ctrlType) {
	ULONG byteCount;

	if (ctrlType == CTRL_C_EVENT) {
		if (NotifyEditFlag)
			SetEvent(NotifyEdit);
		else if (BreakOn) {
			SetBreak();
			if (!EditFlag) {
				KeyRecord.Event.KeyEvent.uChar.AsciiChar = 0x03; // CtrlC
				KeyRecord.Event.KeyEvent.bKeyDown = TRUE;
				WriteConsoleInput(StdInput, &KeyRecord, 1, &byteCount);
				KeyRecord.Event.KeyEvent.bKeyDown = FALSE;
				WriteConsoleInput(StdInput, &KeyRecord, 1, &byteCount);
			}
		}
		return TRUE;
	}
	return FALSE;
}

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

// Display error box
static VOID DisplayError(UINT ErrorMsg) {
	UCHAR buffer[100];

	GetString(ErrorMsg, buffer, sizeof(buffer));
	MessageBox(MainWnd, buffer, ProgName, MB_OK | MB_ICONERROR);
}

// Get decimal number from string
static BOOLEAN DecimalParam(PCHAR Char, PULONG Param) {
	ULONG temp;

	temp = 0;
	while (*Char >= '0' && *Char <= '9')
		temp = temp * 10 + (ULONG)(*Char++ - '0');
	*Param = temp;
	return *Char == 0;
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

static ULONG RGB2Color(ULONG Red, ULONG Green, ULONG Blue) {
	ULONG color;
	
	if (Red <= 128 && Green <= 128 && Blue <= 128) {
		color = 0;
		if (Red >= 64)
			color |= FOREGROUND_RED;
		if (Green >= 64)
			color |= FOREGROUND_GREEN;
		if (Blue >= 64)
			color |= FOREGROUND_BLUE;
	} else {
		color = FOREGROUND_INTENSITY;
		if (Red >= 128)
			color |= FOREGROUND_RED;
		if (Green >= 128)
			color |= FOREGROUND_GREEN;
		if (Blue >= 128)
			color |= FOREGROUND_BLUE;
	}
	return color;
}

// Console display routines
static VOID OutputChar(UCHAR Char) {
	ULONG bytesWritten;

	WriteFile(StdOutput, &Char, 1, &bytesWritten, NULL);
}

static VOID SetConsoleAttribs(VOID) {

	if (!InvertFlag)
		SetConsoleTextAttribute(StdOutput, (WORD)(BackColor * 16 + TextColor));
	else
		SetConsoleTextAttribute(StdOutput, (WORD)(TextColor * 16 + BackColor));
}

static VOID SetConsoleCursor(VOID) {
	COORD coord;

	coord.X = (SHORT)XCursor;
	coord.Y = (SHORT)(YCursor + TOffset);
	SetConsoleCursorPosition(StdOutput, coord);
}

static VOID GetConsoleCursor(VOID) {
	CONSOLE_SCREEN_BUFFER_INFOEX consoleScreenBufferInfo;
	BOOLEAN move;

	consoleScreenBufferInfo.cbSize = sizeof(consoleScreenBufferInfo);
	GetConsoleScreenBufferInfoEx(StdOutput, &consoleScreenBufferInfo);
	XCursor = consoleScreenBufferInfo.dwCursorPosition.X;
	YCursor = consoleScreenBufferInfo.dwCursorPosition.Y;
	if (YCursor < TOffset)
		YCursor = 0;
	else
		YCursor -= TOffset;
	if (XMin == 0 && XMax == TextCols - 1 && YMin == 0 && YMax == TextLines - 1) {
		if (YCursor >= TextLines) {
			TOffset = consoleScreenBufferInfo.dwCursorPosition.Y - TextLines + 1;
			YCursor = TextLines - 1;
		}
	} else {
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
			SetConsoleCursor();
	}
}

static VOID ScrollTextWindow(VOID) {
	ULONG len;
	ULONG writtenChars;
	SMALL_RECT smallRect;
	CHAR_INFO charInfo;
	COORD coord;

	if (YMin != YMax) {
		smallRect.Left = (SHORT)XMin;
		smallRect.Right = (SHORT)XMax;
		smallRect.Top = (SHORT)(YMin + TOffset + 1);
		smallRect.Bottom = (SHORT)(YMax + TOffset);
		coord.X = (SHORT)XMin;
		coord.Y = (SHORT)(YMin + TOffset);
		charInfo.Char.AsciiChar = ' ';
		charInfo.Attributes = (WORD)(BackColor * 16 + TextColor);
		ScrollConsoleScreenBuffer(StdOutput, &smallRect, NULL, coord, &charInfo); 
	} else {
		len = XMax - XMin + 1;
		coord.X = (SHORT)XMin;
		coord.Y = (SHORT)(YMax + TOffset);
		FillConsoleOutputCharacter(StdOutput, ' ', len, coord, &writtenChars);
		FillConsoleOutputAttribute(StdOutput, (WORD)(BackColor * 16 + TextColor), len, coord, &writtenChars);
	}
}

static VOID DisplayChar(UCHAR Char) {

	if (XMin == 0 && XMax == TextCols - 1 && YMin == 0 && YMax == TextLines - 1) {
		OutputChar(Char);
		XCursor++;
		if (XCursor >= TextCols) {
			XCursor = 0;
			YCursor++;
			if (YCursor >= TextLines) {
				YCursor = TextLines - 1;
				if (TOffset < BuffLines - TextLines)
					TOffset++;
			}
		}
	} else {
		GetConsoleCursor();
		OutputChar(Char);
		if (XCursor == XMax) {
			if (YCursor != YMax) {
				XCursor = XMin;
				YCursor++;
			} else {
				ScrollTextWindow();
				XCursor = XMin;
			}
			SetConsoleCursor();
		}
	}
}

static ULONG WINAPI DisplayThread(PVOID Params) {
	ULONG width;
	ULONG height;
	ULONG i;
	ULONG j;
	RECT rect;
	MSG msg;

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
	DisplayWnd = CreateWindow(DisplayName,
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
	if (DisplayWnd == NULL) {
DisplayError:
		SetEvent(DisplayStarted); // End of graphic window creation
		goto DisplayEnd;
	}
	GraphicMemory = VirtualAlloc(NULL, GraphicWidth * GraphicHeight * sizeof(UCHAR), MEM_COMMIT, PAGE_READWRITE);
	if (GraphicMemory == NULL) {
		DestroyWindow(DisplayWnd);
		goto DisplayError;
	}
	ShowWindow(DisplayWnd, SW_NORMAL);
	UpdateWindow(DisplayWnd);
	SetEvent(DisplayStarted); // End of graphic window creation

	// Message loop
	while (GetMessage(&msg, DisplayWnd, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
DisplayEnd:
	return 0;
}

static ULONG WINAPI PrintThread(PVOID Params) {
	MSG msg;

	PrintWnd = CreateDialog(Instance, PrintName, MainWnd, NULL);
	if (PrintWnd == NULL)
		goto PrintEnd;
	PrintMenu = GetMenu(PrintWnd);
	ShowWindow(PrintWnd, SW_SHOWNOACTIVATE);
	UpdateWindow(PrintWnd);

	// Message loop
	while (GetMessage(&msg, DisplayWnd, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	PrintWnd = NULL;
PrintEnd:
	PrintHandle = NULL;
	return 0;
}

// Global Routines
VOID SetControlC(BOOLEAN On) {

	BreakOn = On;
}

VOID RedirConsoleOn(VOID) {

}

VOID RedirConsoleOff(VOID) {

}

BOOLEAN CheckKey(VOID) {
	ULONG count;
	UCHAR c;
	
	do {
		while (RecordIndex < RecordCount) {
			if (InputRecord[RecordIndex].EventType == KEY_EVENT) {
				c = InputRecord[RecordIndex].Event.KeyEvent.uChar.AsciiChar;
				if (InputRecord[RecordIndex].Event.KeyEvent.bKeyDown && (c >= 0x20 || c == 0x03 || c == 0x0D)) {
					return TRUE;
				}
			}
			RecordIndex++;
		}
		GetNumberOfConsoleInputEvents(StdInput, &count);
		if (count == 0)
			break;
		ReadConsoleInput(StdInput, InputRecord, 32, &RecordCount);
		RecordIndex = 0;
	} while (RecordCount != 0);
	return FALSE;
}

VOID GetKey(PUCHAR C) {
	BOOLEAN keyFound;
	UCHAR c;

	keyFound = FALSE;
	while (!keyFound) {
		if (RecordIndex >= RecordCount) {
			ReadConsoleInput(StdInput, InputRecord, 32, &RecordCount);
			RecordIndex = 0;
		}
		if (RecordCount == 0)
			continue;
		if (InputRecord[RecordIndex].EventType == KEY_EVENT) {
			c = InputRecord[RecordIndex].Event.KeyEvent.uChar.AsciiChar;
			if (InputRecord[RecordIndex].Event.KeyEvent.bKeyDown && (c >= 0x20 || c == 0x03 || c == 0x0D)) {
				*C = c;
				keyFound = TRUE;
			}
		}
		RecordIndex++;
	}
}

VOID EditLine(PUCHAR StartBuffer, PUCHAR EndBuffer, BOOLEAN ReEdit, PULONG ByteCount) {
	ULONG count;
	PUCHAR ptr;

	EditFlag = TRUE;
	if (ReEdit) {
		ptr = StartBuffer;
		while (*ptr != 0x04 && ptr < EndBuffer) {
			KeyRecord.Event.KeyEvent.uChar.AsciiChar = *ptr;
			KeyRecord.Event.KeyEvent.bKeyDown = TRUE;
			WriteConsoleInput(StdInput, &KeyRecord, 1, ByteCount);
			KeyRecord.Event.KeyEvent.bKeyDown = FALSE;
			WriteConsoleInput(StdInput, &KeyRecord, 1, ByteCount);
			ptr++;
		}
	}
	if (XMin == 0 && XMax == TextCols - 1 && YMin == 0 && YMax == TextLines - 1) {
		NotifyEditFlag = TRUE;
		ReadConsole(StdInput, StartBuffer, EndBuffer - StartBuffer, ByteCount, NULL);
		if (*ByteCount == 0)
			WaitForSingleObject(NotifyEdit, 1000);
		NotifyEditFlag = FALSE;
		GetConsoleCursor();
	} else {
		GetConsoleCursor();
		count = EndBuffer - StartBuffer;
		if (count > XMax - XCursor + 1)
			count = XMax - XCursor + 1;
		NotifyEditFlag = TRUE;
		ReadConsole(StdInput, StartBuffer, count, ByteCount, NULL);
		if (*ByteCount == 0)
			WaitForSingleObject(NotifyEdit, 1000);
		NotifyEditFlag = FALSE;
		XCursor = XMin;
		if (YCursor < YMax) {
			YCursor++;
		} else
			ScrollTextWindow();
		SetConsoleCursor();
	}
	RecordCount = 0;
	RecordIndex = 0;
	EditFlag = FALSE;
}

// Display routines
VOID InitVar(VOID) {

	XMin = 0;
	YMin = 0;
	XMax = TextCols - 1;
	YMax = TextLines - 1;
	BackColor = BACK_COLOR;
	TextColor = TEXT_COLOR;
	InvertFlag = FALSE;
	SetConsoleAttribs();
	EscFlag = FALSE;
}

VOID PutChar(UCHAR Char) {
	ULONG writtenChars;
	ULONG len;
	ULONG color;
	ULONG i;
	COORD coord;

	if (EscFlag) {
		EscFlag = FALSE;
		switch (Char) {
		case ']':
		case 'H':
		case 'Z': // Inverse On
			InvertFlag = TRUE;
			SetConsoleAttribs();
			break;
		case '\\':
		case 'I':
		case 'Y':
		case 'u': // Inverse Off
			InvertFlag = FALSE;
			SetConsoleAttribs();
			break;
		case 'p':
			GetConsoleCursor();
			if (YCursor < YMin || YCursor > YMax)
				break;
			// Clear display memory Line
			len = XMax - XMin + 1;
			coord.X = (SHORT)XMin;
			coord.Y = (SHORT)(YCursor + TOffset);
			FillConsoleOutputCharacter(StdOutput, ' ', len, coord, &writtenChars);
			FillConsoleOutputAttribute(StdOutput, (WORD)(BackColor * 16 + TextColor), len, coord, &writtenChars);
			break;
		case 'q': {
ClearScreen:
			// Clear display memory
			len = XMax - XMin + 1;
			coord.X = (SHORT)XMin;
			for (i = YMin; i <= YMax; i++) {
				coord.Y = (SHORT)(TOffset + i);
				FillConsoleOutputCharacter(StdOutput, ' ', len, coord, &writtenChars);
				FillConsoleOutputAttribute(StdOutput, (WORD)(BackColor * 16 + TextColor), len, coord, &writtenChars);
			}
			break;
		}
		case '0':
			color = BACK_COLOR;
SetTextColor:
			if (!InvertFlag)
				TextColor = color;
			else
				BackColor = color;
			SetConsoleAttribs();
			break;
		case '1':
			color = FOREGROUND_INTENSITY | FOREGROUND_RED;
			goto SetTextColor;
		case '2':
			color = FOREGROUND_INTENSITY | FOREGROUND_GREEN;
			goto SetTextColor;
		case '3':
			color = FOREGROUND_RED | FOREGROUND_GREEN;
			goto SetTextColor;
		case '4':
			color = FOREGROUND_INTENSITY | FOREGROUND_BLUE;
			goto SetTextColor;
		case '5':
			color = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
			goto SetTextColor;
		case '6':
			color = FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
			goto SetTextColor;
		case '7':
			color = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
			goto SetTextColor;
		case '8':
			color = TEXT_COLOR;
			goto SetTextColor;
		}
		return;
	}
	if (Char >= 0x20) {
		DisplayChar(Char);
		return;
	}
	switch (Char) {
	case 0x07: // Bell
		Beep(1760,500);
		break;
	case 0x08: // BackSpace
		GetConsoleCursor();
		if (XCursor > XMin)
			XCursor--;
		else if (YCursor > YMin) {
			YCursor--;
			XCursor = XMax;
		}
		SetConsoleCursor();
		break;
	case 0x0A: // LF
		if (XMin == 0 && XMax == TextCols - 1 && YMin == 0 && YMax == TextLines - 1) {
			OutputChar(Char);
			YCursor++;
			if (YCursor >= TextLines) {
				YCursor = TextLines - 1;
				if (TOffset < BuffLines - TextLines)
					TOffset++;
			}
		} else {
			GetConsoleCursor();
			if (YCursor < YMax) {
				YCursor++;
				SetConsoleCursor();
			} else
				ScrollTextWindow();
		}
		break;
	case 0x0D: // CR
		if (XMin == 0 && XMax == TextCols - 1 && YMin == 0 && YMax == TextLines - 1) {
			OutputChar(Char);
			XCursor = 0;
		} else {
			GetConsoleCursor();
			if (XCursor != XMin) {
				XCursor = XMin;
				SetConsoleCursor();
			}
		}
		break;
	case 0x0B: // Up
		GetConsoleCursor();
		if (YCursor > YMin) {
			YCursor--;
			SetConsoleCursor();
		}
		break;
	case 0x0C: // Home
		if (XCursor != XMin || YCursor != YMin) {
			XCursor = XMin;
			YCursor = YMin;
			SetConsoleCursor();
		}
		goto ClearScreen;
	case 0x1B: // Escape
		EscFlag = TRUE;
		break;
	case 0x1D: // Right
		GetConsoleCursor();
		if (XCursor < XMax) {
			XCursor++;
			SetConsoleCursor();
		}
		break;
	}
}

BOOLEAN MoveCursor(ULONG X, ULONG Y) {
	ULONG x;
	ULONG y;

	x = X + XMin;
	y = Y + YMin;
	if (x > XMax || y > YMax)
		return FALSE;
	if (XCursor != x || YCursor != y) {
		XCursor = x;
		YCursor = y;
		SetConsoleCursor();
	}
	return TRUE;
}

ULONG CursorPos(VOID) {
	ULONG x;
	ULONG y;

	GetConsoleCursor();
	if (XCursor > XMin) {
		x = XCursor - XMin;
		if (x > XMax - XMin)
			x = XMax - XMin;
	} else
		x = 0;
	if (YCursor > YMin) {
		y = YCursor - YMin;
		if (y > YMax - YMin)
			y = YMax - YMin;
	} else
		y = 0;
	return (y << 8) | x;
}

VOID ResizeTxt(ULONG Lines, ULONG Chars) {
	ULONG len;
	ULONG writtenChars;
	SMALL_RECT smallRect;
	COORD coord;

	coord = GetLargestConsoleWindowSize(StdOutput);
	if (Chars < (ULONG)coord.X)
		TextCols = Chars;
	else
		TextCols = coord.X;
	if (Lines < (ULONG)coord.Y)
		TextLines = Lines;
	else
		Lines = coord.Y;
	if (BuffLines < Lines * 10)
		BuffLines = Lines * 10;
	TOffset = 0;
	XCursor = 0;
	YCursor = 0;
	XMin = 0;
	YMin = 0;
	XMax = TextCols - 1;
	YMax = TextLines - 1;
	BackColor = BACK_COLOR;
	TextColor = TEXT_COLOR;
	smallRect.Left = 0;
	smallRect.Right = TEXT_COLS - 1;
	smallRect.Top = 0;
	smallRect.Bottom = TEXT_LINES - 1;
	SetConsoleWindowInfo(StdOutput, TRUE, &smallRect); // Set window to minimum
	coord.X = (SHORT)TextCols;
	coord.Y = (SHORT)BuffLines;
	SetConsoleScreenBufferSize(StdOutput, coord); // Set buffer size
	len = TextCols * BuffLines;
	coord.X = 0;
	coord.Y = 0;
	FillConsoleOutputCharacter(StdOutput, ' ', len, coord, &writtenChars);
	FillConsoleOutputAttribute(StdOutput, (WORD)(BackColor * 16 + TextColor), len, coord, &writtenChars);
	smallRect.Left = 0;
	smallRect.Right = (SHORT)(TextCols - 1);
	smallRect.Top = 0;
	smallRect.Bottom = (SHORT)(TextLines - 1);
	SetConsoleWindowInfo(StdOutput, TRUE, &smallRect); // Set window to text
	SetConsoleCursor();
	InvertFlag = FALSE;
	SetConsoleAttribs();
	EscFlag = FALSE;
}

VOID SetTxtWindow(LONG LineUp, LONG ColLeft, LONG LineDown, LONG ColRight) {
	BOOLEAN move;

	if (ColLeft < 0)
		ColLeft = 0;
	if ((ULONG)ColLeft >= TextCols)
		ColLeft = TextCols - 1;
	if (LineUp < 0)
		LineUp = 0;
	if ((ULONG)LineUp >= TextLines)
		LineUp = TextLines - 1;
	if (ColRight < 0)
		ColRight = 0;
	if ((ULONG)ColRight >= TextCols)
		ColRight = TextCols - 1;
	if (LineDown < 0)
		LineDown = 0;
	if ((ULONG)LineDown >= TextLines)
		LineDown = TextLines - 1;
	if (ColLeft <= ColRight && LineUp <= LineDown) {
		XMin = ColLeft;
		YMin = LineUp;
		XMax = ColRight;
		YMax = LineDown;
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
			SetConsoleCursor();
	}
}

VOID SetTxtColor(ULONG Color, ULONG R, ULONG G, ULONG B) {
	
	switch (Color) {
	case 0:
		BackColor = RGB2Color(R, G, B);
		break;
	case 1:
		TextColor = RGB2Color(R, G, B);
		break;
	default:
		return;
	}
	SetConsoleAttribs();
}

VOID OpenPrintMenu(VOID) {

	if (PrintHandle == NULL)
		PrintHandle = CreateThread(NULL, 0, PrintThread, NULL, 0, NULL);
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
		ProcessHandle = processInformation.hProcess;
		CloseHandle(processInformation.hThread);
		WaitForSingleObject(processInformation.hProcess, INFINITE);
		CloseHandle(processInformation.hProcess);
		ProcessHandle = NULL;
	}
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
	GraphicMemory = NULL;
	CloseFlag = FALSE;
	DisplayHandle = CreateThread(NULL, 0, DisplayThread, NULL, 0, NULL);
	if (DisplayHandle != NULL) {
		WaitForSingleObject(DisplayStarted, INFINITE); // Wait for end of graphic window initialization
		if (DisplayWnd != NULL)
			InitColors();
		else {
			WaitForSingleObject(DisplayHandle, INFINITE);
			CloseHandle(DisplayHandle);
		}
	}
	return GraphicMemory;
}

VOID CloseGraphicWindow(VOID) {

	if (DisplayWnd != NULL) {
		CloseFlag = TRUE;
		PostMessage(DisplayWnd, WM_DESTROY, 0, 0);
	}
	WaitForSingleObject(DisplayHandle, INFINITE);
	CloseHandle(DisplayHandle);
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
			EnterCriticalSection(&MouseCs);
		}
	*X = MouseX;
	*Y = MouseY;
	buttons = MouseButtons;
	ClickFlag = FALSE;
	LeaveCriticalSection(&MouseCs);
	*EndFlag = FALSE;
	return buttons;
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

// Edit print thread
static ULONG WINAPI EditPrintThread(PVOID Params) {
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
	PostMessage(PrintWnd, WM_EDIT_DONE, 0 , 0);
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
	UCHAR c;
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
		}
		return 0;
	case WM_CHAR:
		c = (UCHAR)WParam;
		if (c == 0x03 && BreakOn) // CtrlC
			SetBreak();
		if (!EditFlag) {
			KeyRecord.Event.KeyEvent.uChar.AsciiChar = c;
			KeyRecord.Event.KeyEvent.bKeyDown = TRUE;
			WriteConsoleInput(StdInput, &KeyRecord, 1, &result);
			KeyRecord.Event.KeyEvent.bKeyDown = FALSE;
			WriteConsoleInput(StdInput, &KeyRecord, 1, &result);
		}
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
		if (CloseFlag)
			CloseFlag = FALSE;
		else
			DestroyGraphic(); // Inform graphic module
		if (GraphicMemory != NULL) {
			VirtualFree(GraphicMemory, 0, MEM_RELEASE);
			GraphicMemory = NULL;
		}
		PostQuitMessage(0);
		break;
	}
	return DefWindowProc(Wnd, Msg, WParam, LParam);
}

// Print message procedure
LRESULT CALLBACK PrintProc(HWND Wnd, UINT Msg, WPARAM WParam, LPARAM LParam) {
	UCHAR buffer[100];

	switch (Msg) {
	case WM_COMMAND:
		if (HIWORD(WParam) != 0)
			break;
		switch(LOWORD(WParam)) {
		case IDM_PRINT:
			EnableMenuItem(PrintMenu, IDM_PRINT, MF_GRAYED);
			EnableMenuItem(PrintMenu, IDM_CLEARPRINT, MF_GRAYED);
			EditPrintHandle = CreateThread(NULL, 0, EditPrintThread, NULL, 0, NULL);
			if (EditPrintHandle == NULL) {
				EnableMenuItem(PrintMenu, IDM_PRINT, MF_ENABLED);
				EnableMenuItem(PrintMenu, IDM_CLEARPRINT, MF_ENABLED);
			}
			break;
		case IDM_CLEARPRINT:
			if (CheckPath(PrintFileName) == PATH_FILE) {
				GetString(IDS_DELPRINT, buffer, sizeof(buffer));
				if (MessageBox(PrintWnd, buffer, ProgName, MB_OKCANCEL) == IDOK && !DeleteFile(PrintFileName))
					DisplayError(IDS_PRINTCLEARERR);
			} // Fall in IDM_QUIT
		case IDM_QUIT:
EndPrint:
			PostQuitMessage(0);
			break;
		}
		return 0;
	case WM_CLOSE:
		goto EndPrint;
	case WM_EDIT_DONE:
		if (EditPrintHandle != NULL) {
			WaitForSingleObject(EditPrintHandle, INFINITE);
			CloseHandle(EditPrintHandle);
			EditPrintHandle = NULL;
		}
		EnableMenuItem(PrintMenu, IDM_PRINT, MF_ENABLED);
		EnableMenuItem(PrintMenu, IDM_CLEARPRINT, MF_ENABLED);
		return 0;
	}
    return DefDlgProc(Wnd, Msg, WParam, LParam);
}

// Main program
int main(int argc, char *argv[]) {
	ULONG firstParam;
	ULONG width;
	ULONG height;
	ULONG i;
	ULONG j;
	ULONG returnCode;
	PUCHAR string;
	PUCHAR buffer;
	HRSRC resource;
	RECT rect;
	WNDCLASSEX winClass;
	CONSOLE_SCREEN_BUFFER_INFOEX consoleScreenBufferInfo;
	WORD callingAttributes;
	UCHAR c;

	// Initialization
	SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOOPENFILEERRORBOX);
	Instance = GetModuleHandle(NULL);
	MainWnd = GetConsoleWindow();
	StdInput = GetStdHandle(STD_INPUT_HANDLE);
	StdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
	OutputFormat = 0;
	returnCode = 0;
	GraphicZoom = 0;
	ImageCount = 0;
	BasicFileName[0] = 0;
	BasFileName[0] = 0;
	BacFileName[0] = 0;
	DispIn = 0;
	DispOut = 0;
	DispCount = 0;
	DataLen = DATA_LEN;
	CodeLen = CODE_LEN;
	SymbLen = SYMB_LEN;

	i = 1;
	while (i < (ULONG)argc) {
		if (argv[i][0] == '/') {
			switch(argv[i][1] & 0xDF) {
			case 'H':
				resource = FindResource(Instance, "HELP", "TEXT");
				string = (PUCHAR)LockResource(LoadResource(Instance, resource));
				i = SizeofResource(Instance, resource);
				buffer = VirtualAlloc(NULL, i, MEM_COMMIT, PAGE_READWRITE);
				if (buffer != NULL) {
					for (j = 0; j < i; j++) {
						c = string[j];
						if (c < 128)
							buffer[j] = c;
						else
							buffer[j] = OemFixedFont[c-128];
					}
					WriteFile(StdOutput, buffer, i, &i, NULL);
				}
				goto MainReturn;
			case 'D':
				j = 2;
				if (argv[i][2] == 0) {
					i++;
					if (i >= (ULONG)argc)
						goto SyntaxError;
					j = 0;
				}
				if (!DecimalParam(&argv[i][j], &DataLen) || DataLen == 0 || DataLen > 1024)
					goto SyntaxError;
				break;
			case 'C':
				j = 2;
				if (argv[i][2] == 0) {
					i++;
					if (i >= (ULONG)argc)
						goto SyntaxError;
					j = 0;
				}
				if (!DecimalParam(&argv[i][j], &CodeLen) || CodeLen == 0 || CodeLen > 1024)
					goto SyntaxError;
				break;
			case 'S':
				j = 2;
				if (argv[i][2] == 0) {
					i++;
					if (i >= (ULONG)argc)
						goto SyntaxError;
					j = 0;
				}
				if (!DecimalParam(&argv[i][j], &SymbLen) || SymbLen == 0 || SymbLen > 1024)
					goto SyntaxError;
				break;
			default:
SyntaxError:
				WriteFile(StdOutput, SyntaxErrMsg, sizeof(SyntaxErrMsg), &i, NULL);
				returnCode = 1;
				goto MainReturn;
			}
		} else
			break;
		i++;
	}
	firstParam = i;
	for (i = firstParam; i < (ULONG)argc; i++) {
		j = 0;
		while (TRUE) {
			c = argv[i][j];
			if (c == 0)
				break;
			if (c >= 0x80)
				argv[i][j] = OemFixedFont[c-0x80];
			j++;
		}
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
AllocError:
	if (DataBase == NULL || CodeBase == NULL || SymbBase == NULL) {
		WriteFile(StdOutput, AllocErrMsg, sizeof(AllocErrMsg), &i, NULL);
		returnCode = 2;
		goto MainReturn;
	}
	NotifyEdit = CreateEvent(NULL, FALSE, FALSE, NULL);		// auto-reset
	if (NotifyEdit == NULL)
		goto AllocError;
	NotifyMouse = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
	if (NotifyMouse == NULL) {
CloseEditError:
		CloseHandle(NotifyEdit);
		goto AllocError;
	}
	DisplayStarted = CreateEvent(NULL, FALSE, FALSE, NULL);	// auto-reset
	if (DisplayStarted == NULL) {
		CloseHandle(NotifyMouse);
		goto CloseEditError;
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
    winClass.hInstance = Instance;
	winClass.hIcon = LoadIcon(Instance, ProgName);
    winClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    winClass.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    winClass.lpszMenuName = NULL;
    winClass.lpszClassName = DisplayName;
    winClass.hIconSm = NULL;
    RegisterClassEx(&winClass);

	// Create printer window
    winClass.cbSize = sizeof(winClass) ;
    winClass.style = CS_HREDRAW | CS_VREDRAW;
    winClass.lpfnWndProc = PrintProc;
    winClass.cbClsExtra = 0;
    winClass.cbWndExtra = DLGWINDOWEXTRA;
    winClass.hInstance = Instance;
    winClass.hIcon = LoadIcon(Instance, ProgName);
    winClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    winClass.hbrBackground = (HBRUSH)(COLOR_BTNFACE + 1);
    winClass.lpszMenuName = PrintName;
    winClass.lpszClassName = PrintName ;
    winClass.hIconSm = LoadIcon(Instance, ProgName);
    RegisterClassEx (&winClass);

	// Lance le BASIC
	KeyRecord.EventType = KEY_EVENT;
	KeyRecord.Event.KeyEvent.wRepeatCount = 1;
	KeyRecord.Event.KeyEvent.wVirtualKeyCode = 0;
	KeyRecord.Event.KeyEvent.wVirtualScanCode = 0;
	KeyRecord.Event.KeyEvent.dwControlKeyState = 0;
	consoleScreenBufferInfo.cbSize = sizeof(consoleScreenBufferInfo);
	GetConsoleScreenBufferInfoEx(StdOutput, &consoleScreenBufferInfo);
	callingAttributes = consoleScreenBufferInfo.wAttributes;
	TextCols = consoleScreenBufferInfo.dwSize.X;
	BuffLines = consoleScreenBufferInfo.dwSize.Y;
	TextLines = consoleScreenBufferInfo.srWindow.Bottom - consoleScreenBufferInfo.srWindow.Top + 1;
	XMin = 0;
	YMin = 0;
	XMax = TextCols - 1;
	YMax = TextLines - 1;
	TOffset = 0;
	XCursor = consoleScreenBufferInfo.dwCursorPosition.X;
	YCursor = consoleScreenBufferInfo.dwCursorPosition.Y;
	if (YCursor >= TextLines) {
		TOffset = consoleScreenBufferInfo.dwCursorPosition.Y - TextLines + 1;
		YCursor = TextLines - 1;
	}
	BackColor = BACK_COLOR;
	TextColor = TEXT_COLOR;
	InvertFlag = FALSE;
	if (((callingAttributes & 0xF0) >> 4) != BackColor || (callingAttributes & 0x0F) != TextColor)
	SetConsoleAttribs();
	width = GetSystemMetrics(SM_CXSCREEN);
	height = GetSystemMetrics(SM_CYSCREEN);
	rect.left = 0;
	rect.top = 0;
	rect.right = width;
	rect.bottom = height;
	AdjustWindowRect(&rect, WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX, FALSE);
	WScreen = (width << 1) - (rect.right - rect.left);
	HScreen = (height << 1) - (rect.bottom - rect.top);
	EscFlag = FALSE;
	EditFlag = FALSE;
	NotifyEditFlag = FALSE;
	BreakOn = TRUE;
	SetConsoleCtrlHandler(CtrlHandler, TRUE);
	NotifyMouseFlag = FALSE;
	InitializeCriticalSection(&MouseCs);
	PrintHandle = NULL;
	StartBasic(argc - firstParam, argv + firstParam, DataBase, DataLen << 20, CodeBase, CodeLen << 20, SymbBase, SymbLen << 20);

	// Cleanup
	SetConsoleTextAttribute(StdOutput, callingAttributes);
	CloseHandle(DisplayStarted);
	CloseHandle(NotifyMouse);
	CloseHandle(NotifyEdit);

	// Purge printer buffer
	if (PrintHandle != NULL && PrintWnd != NULL) {
		PostMessage(PrintWnd, WM_CLOSE, 0, 0);
		WaitForSingleObject(DisplayHandle, INFINITE);
		CloseHandle(DisplayHandle);
	}
	DeleteFile(PrintFileName);
MainReturn:
	return returnCode;
}