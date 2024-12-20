VOID InitColors(VOID);
BOOLEAN CreateDisplay(HWND Wnd);
VOID CloseDisplay(VOID);
VOID UpdateDisplay(HWND Wnd, ULONG Width, ULONG Height);
VOID ReleaseDisplay(VOID);
VOID CheckDisplay(VOID);
VOID RefreshDisplay(VOID);
PUCHAR ScreenShoot(PULONG Size);

extern ULONG DisplayWidth;
extern ULONG DisplayHeight;
extern ULONG GraphicWidth;
extern ULONG GraphicHeight;
extern PUCHAR GraphicMemory;
extern BOOLEAN RefreshFkag;