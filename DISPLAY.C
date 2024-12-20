// Display management (Direct 3D)
// Author: Dominique Ezvan

#define _WIN32_WINNT 0x0500
#include <windows.h>
#include "sb32.h"
#include "d3d9.h"

#define D3DFVF_CUSTOMVERTEX (D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1)
typedef struct {
	FLOAT x,y,z;      // vertex untransformed position 
    FLOAT rhw;        // eye distance
    D3DCOLOR diffuse; // diffuse color
    FLOAT tu, tv;     // texture relative coordinates
} CUSTOMVERTEX, *PCUSTOMVERTEX;

#pragma pack(1)
typedef struct {
	USHORT Signature;  // "BM"
	ULONG BmpSize;     // file size
	ULONG Filler;      // ?
	ULONG ImageOffset; // image start
	ULONG DescLen;     // descriptor size (40)
	ULONG Width;       // image width in pixels
	ULONG Height;      // image height in pixels
	USHORT Planes;     // plane count (1)
	USHORT Deep;       // color bits
	ULONG Compress;    // compression (0)
	ULONG ImageSize;   // image size in bytes
	ULONG HorDef;      // horizontal definition
	ULONG VerDef;      // vertical definition
	ULONG ColorsCount; // number of palette colors (256)
	ULONG MainColors;  // number of main colors
	ULONG RGB[256];    // palette
} BMP_HEADER, *PBMP_HEADER;
#pragma pack()

// External variables
extern HWND DisplayWnd;
extern BOOLEAN RefreshFlag;

// Direct3D variables
HMODULE D3D9Dll;
PDIRECT3D9 (WINAPI *Direct3DCreate9Entry)(UINT SDKVersion);
LPDIRECT3D9 D3DObject;
LPDIRECT3DDEVICE9 DisplayDevice;
LPDIRECT3DSURFACE9 ImageSurface;
LPDIRECT3DTEXTURE9 DisplayTexture;
LPDIRECT3DVERTEXBUFFER9 DisplayVertex;
D3DFORMAT BackBufferFormat;
CUSTOMVERTEX Vertex[4];
static D3DFORMAT FourCc[DISPLAY_FORMATS] = {D3DFMT_X8R8G8B8,
											D3DFMT_R5G6B5,
											D3DFMT_P8};

// Display variables
static ULONG DisplayFormat;
ULONG DisplayWidth;
ULONG DisplayHeight;
ULONG GraphicWidth;
ULONG GraphicHeight;
PUCHAR GraphicMemory;
//static ULONG BackBufferWidth;
//static ULONG BackBufferHeight;
//static RECT DisplayRect;
static CRITICAL_SECTION DisplayCs;
ULONG Color32[256];
static ULONG Color16[256];
static BOOLEAN DisplayFlag = FALSE;
static BOOLEAN ObjectsFlag;
static BOOLEAN ClearFlag;
static BOOLEAN ResetFlag;

static UCHAR DacVgaLow[] = {0x00,0x10,0x04,0x14,0x01,0x11,0x09,0x15,
							0x2A,0x3A,0x2E,0x3E,0x2B,0x3B,0x2F,0x3F};

static UCHAR DacVgaMedium[] = {0x00,0x05,0x08,0x0B,0x0E,0x11,0x14,0x18,
							   0x1C,0x20,0x24,0x28,0x2D,0x32,0x38,0x3F};

static UCHAR DacVgaHigh[] = {0x00,0x00,0x3F,0x10,0x00,0x3F,
							 0x1F,0x00,0x3F,0x2F,0x00,0x3F,
							 0x3F,0x00,0x3F,0x3F,0x00,0x2F,
							 0x3F,0x00,0x1F,0x3F,0x00,0x10,
							 0x1F,0x1F,0x3F,0x27,0x1F,0x3F,
							 0x2F,0x1F,0x3F,0x37,0x1F,0x3F,
							 0x3F,0x1F,0x3F,0x3F,0x1F,0x37,
							 0x3F,0x1F,0x2F,0x3F,0x1F,0x27,
							 0x2D,0x2D,0x3F,0x31,0x2D,0x3F,
							 0x36,0x2D,0x3F,0x3A,0x2D,0x3F,
							 0x3F,0x2D,0x3F,0x3F,0x2D,0x3A,
							 0x3F,0x2D,0x36,0x3F,0x2D,0x31,
							 0x00,0x00,0x1C,0x07,0x00,0x1C,
							 0x0E,0x00,0x1C,0x15,0x00,0x1C,
							 0x1C,0x00,0x1C,0x1C,0x00,0x15,
							 0x1C,0x00,0x0E,0x1C,0x00,0x07,
							 0x0E,0x0E,0x1C,0x11,0x0E,0x1C,
							 0x15,0x0E,0x1C,0x18,0x0E,0x1C,
							 0x1C,0x0E,0x1C,0x1C,0x0E,0x18,
							 0x1C,0x0E,0x15,0x1C,0x0E,0x11,
							 0x14,0x14,0x1C,0x16,0x14,0x1C,
							 0x18,0x14,0x1C,0x1A,0x14,0x1C,
							 0x1C,0x14,0x1C,0x1C,0x14,0x1A,
							 0x1C,0x14,0x18,0x1C,0x14,0x16,
							 0x00,0x00,0x10,0x04,0x00,0x10,
							 0x08,0x00,0x10,0x0C,0x00,0x10,
							 0x10,0x00,0x10,0x10,0x00,0x0C,
							 0x10,0x00,0x08,0x10,0x00,0x04,
							 0x08,0x08,0x10,0x0A,0x08,0x10,
							 0x0C,0x08,0x10,0x0E,0x08,0x10,
							 0x10,0x08,0x10,0x10,0x08,0x0E,
							 0x10,0x08,0x0C,0x10,0x08,0x0A,
							 0x0B,0x0B,0x10,0x0C,0x0B,0x10,
							 0x0D,0x0B,0x10,0x0F,0x0B,0x10,
							 0x10,0x0B,0x10,0x10,0x0B,0x0F,
							 0x10,0x0B,0x0D,0x10,0x0B,0x0C};
	
// Display initialization
static ULONG RGB2Color32(ULONG R, ULONG G, ULONG B) {
	
	R = (R << 2) | (R >> 4);
	G = (G << 2) | (G >> 4);
	B = (B << 2) | (B >> 4);
	return (R << 16) | (G << 8) | B;
}

static ULONG RGB2Color16(ULONG R, ULONG G, ULONG B) {

	return ((R & 0x3E) << 10) | (G << 5) | (B >> 1);
}

static ULONG ExpandDacData(UCHAR Byte) {
	ULONG color;

	color = 0;
	if ((Byte & 0x02) !=0)
		color += 21; 
	if ((Byte & 0x01) !=0)
		color += 42;
	return color;
}

VOID InitColors(VOID) {
	ULONG i;
	ULONG j;
	ULONG red;
	ULONG green;
	ULONG blue;
	PUCHAR ptr;
	UCHAR byte;

	ptr = DacVgaLow;
	for (i = 0; i < 16; i++) {
		byte = *ptr++;
		red = ExpandDacData(byte);
		green = ExpandDacData(byte >> 2);
		blue = ExpandDacData(byte >> 4);
		Color32[i] = RGB2Color32(red, green, blue);
		Color16[i] = RGB2Color16(red, green, blue);
	}
	ptr = DacVgaMedium;
	for (i = 16; i < 32; i++) {
		red = (ULONG)(*ptr++);
		Color32[i] = RGB2Color32(red, red, red);
		Color16[i] = RGB2Color16(red, red, red);
	}
	ptr = DacVgaHigh;
	for (i = 32; i < 248; i += 3 * 8)
		for (j = 0; j < 8; j++) {
			red = (ULONG)(*ptr++);
			green = (ULONG)(*ptr++);
			blue = (ULONG)(*ptr++);
			Color32[i+j] = RGB2Color32(red, green, blue);
			Color16[i+j] = RGB2Color16(red, green, blue);
			Color32[i+j+8] = RGB2Color32(blue, red, green);
			Color16[i+j+8] = RGB2Color16(blue, red, green);
			Color32[i+j+2*8] = RGB2Color32(green, blue, red);
			Color16[i+j+2*8] = RGB2Color16(green, blue, red);
		}
	for (i = 248; i < 256; i++) {
		Color32[i] = 0;
		Color16[i] = 0;
	}
}

VOID SetGrColor(ULONG Color, ULONG R, ULONG G, ULONG B) {
	
	if (Color < 256) {
		Color32[Color] = (R << 16) | (G << 8) | B;
		Color16[Color] = ((R & 0xF8) << 8) | ((G & 0xFC) << 3) | (B >> 3);
		RefreshFlag = TRUE;
	}
}

static BOOLEAN CreateD3DObjects(VOID) {

	// Create off screen surface
	if (IDirect3DDevice9_CreateOffscreenPlainSurface(DisplayDevice, GraphicWidth, GraphicHeight, FourCc[DisplayFormat], D3DPOOL_SYSTEMMEM, &ImageSurface, NULL) != D3D_OK) {
		return FALSE;
	}
	ClearFlag = TRUE;

	// Create scene
    if (IDirect3DDevice9_CreateTexture(DisplayDevice, DisplayWidth + 1, DisplayHeight + 1, 1, D3DUSAGE_RENDERTARGET, BackBufferFormat, D3DPOOL_DEFAULT, &DisplayTexture, NULL) != D3D_OK) {
CreateReleaseSurface:
		IDirect3DSurface9_Release(ImageSurface);
		ImageSurface = NULL;
		return FALSE;
	}
	if (IDirect3DDevice9_CreateVertexBuffer(DisplayDevice, sizeof(CUSTOMVERTEX)*4, D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY, D3DFVF_CUSTOMVERTEX, D3DPOOL_DEFAULT, &DisplayVertex, NULL) != D3D_OK) {
		IDirect3DTexture9_Release(DisplayTexture);
		DisplayTexture = NULL;
		goto CreateReleaseSurface;
	}
	Vertex[0].x = 0.0f;       // left
	Vertex[0].y = 0.0f;       // top
	Vertex[0].z = 0.0f;
	Vertex[0].diffuse = D3DCOLOR_ARGB(128, 128, 128, 128);
	Vertex[0].rhw = 1.0f;
	Vertex[0].tu = 0.0f;
	Vertex[0].tv = 0.0f;
	Vertex[1].x = (float)(DisplayWidth); // right
	Vertex[1].y = 0.0f;                    // top
	Vertex[1].z = 0.0f;
	Vertex[1].diffuse = D3DCOLOR_ARGB(128, 128, 128, 128);
	Vertex[1].rhw = 1.0f;
	Vertex[1].tu = 1.0f;
	Vertex[1].tv = 0.0f;
	Vertex[2].x = (float)(DisplayWidth);  // right
	Vertex[2].y = (float)(DisplayHeight); // bottom
	Vertex[2].z = 0.0f;
	Vertex[2].diffuse = D3DCOLOR_ARGB(128, 128, 128, 128);
	Vertex[2].rhw = 1.0f;
	Vertex[2].tu = 1.0f;
	Vertex[2].tv = 1.0f;
	Vertex[3].x = 0.0f;                     // left
	Vertex[3].y = (float)(DisplayHeight); // bottom
	Vertex[3].z = 0.0f;
	Vertex[3].diffuse = D3DCOLOR_ARGB(128, 128, 128, 128);
	Vertex[3].rhw = 1.0f;
	Vertex[3].tu = 0.0f;
	Vertex[3].tv = 1.0f;

	// Texture coordinates outside the range [0.0, 1.0] are set 
	// to the texture color at 0.0 or 1.0, respectively.
	IDirect3DDevice9_SetSamplerState(DisplayDevice, 0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
	IDirect3DDevice9_SetSamplerState(DisplayDevice, 0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);

	// Set linear filtering quality
	IDirect3DDevice9_SetSamplerState(DisplayDevice, 0, D3DSAMP_MINFILTER, D3DTEXF_NONE);
	IDirect3DDevice9_SetSamplerState(DisplayDevice, 0, D3DSAMP_MAGFILTER, D3DTEXF_NONE);

	// Set maximum ambient light
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_AMBIENT, D3DCOLOR_XRGB(255,255,255));

	// Turn off culling
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_CULLMODE, D3DCULL_NONE);

	// Turn off the zbuffer
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_ZENABLE, D3DZB_FALSE);

	// Turn off lights
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_LIGHTING, FALSE);

	// Disable dithering
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_DITHERENABLE, FALSE);

	// Disable stencil
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_STENCILENABLE, FALSE);

	// Manage blending
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_ALPHABLENDENABLE, FALSE);
	IDirect3DDevice9_SetRenderState(DisplayDevice, D3DRS_ALPHATESTENABLE, FALSE);

	// Set texture states
	IDirect3DDevice9_SetTextureStageState(DisplayDevice, 0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
	IDirect3DDevice9_SetTextureStageState(DisplayDevice, 0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	IDirect3DDevice9_SetTextureStageState(DisplayDevice, 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

	// Turn off alpha operation
	IDirect3DDevice9_SetTextureStageState(DisplayDevice, 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
	return TRUE;
}

static VOID ReleaseD3DObjects(VOID) {
	if (DisplayVertex != NULL) {
		IDirect3DVertexBuffer9_Release(DisplayVertex);
		DisplayVertex = NULL;
	}
	if (DisplayTexture != NULL) {
		IDirect3DTexture9_Release(DisplayTexture);
		DisplayTexture = NULL;
	}
	if (ImageSurface != NULL) {
		IDirect3DSurface9_Release(ImageSurface);
		ImageSurface = NULL;
	}
}

static BOOLEAN GetDisplayFormat(HWND Wnd, D3DPRESENT_PARAMETERS *D3DPp) {
    D3DDISPLAYMODE d3dDm;

	// Get display mode
	if (IDirect3D9_GetAdapterDisplayMode(D3DObject, D3DADAPTER_DEFAULT, &d3dDm) != D3D_OK)
		return FALSE;
	BackBufferFormat = d3dDm.Format;
//	BackBufferWidth = d3dDm.Width;
//	BackBufferHeight = d3dDm.Height;

	// Search suported surface format
	for (DisplayFormat = 0; DisplayFormat < DISPLAY_FORMATS; DisplayFormat++)
		if (IDirect3D9_CheckDeviceFormat(D3DObject, D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, BackBufferFormat, 0, D3DRTYPE_SURFACE, FourCc[DisplayFormat]) == D3D_OK &&
			IDirect3D9_CheckDeviceFormatConversion(D3DObject, D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, FourCc[DisplayFormat], BackBufferFormat) == D3D_OK)
			break;
	if (DisplayFormat >= DISPLAY_FORMATS)
		return FALSE;

	// Set display parameters
	ZeroMemory(D3DPp, sizeof(D3DPRESENT_PARAMETERS));
	D3DPp->Flags = D3DPRESENTFLAG_VIDEO;
	D3DPp->Windowed = TRUE;
	D3DPp->hDeviceWindow = Wnd;
	D3DPp->BackBufferWidth = GraphicWidth;
	D3DPp->BackBufferHeight = GraphicHeight;
	D3DPp->SwapEffect = D3DSWAPEFFECT_COPY;
	D3DPp->MultiSampleType = D3DMULTISAMPLE_NONE;
	D3DPp->PresentationInterval = D3DPRESENT_INTERVAL_DEFAULT;
	D3DPp->BackBufferFormat = d3dDm.Format;
	D3DPp->BackBufferCount = 1;
	D3DPp->EnableAutoDepthStencil = FALSE;
//	DisplayRect.left = 0;
//	DisplayRect.right = GraphicWidth;
//	DisplayRect.top = 0;
//	DisplayRect.bottom = GraphicHeight;
	return TRUE;
}

BOOLEAN CreateDisplay(HWND Wnd) {
	ULONG errorMsg;
	D3DPRESENT_PARAMETERS d3dPp;
	UCHAR buffer[100];

	// Load D3D DLL
	D3D9Dll = LoadLibrary("D3D9.DLL");
	if (D3D9Dll == NULL) {
		errorMsg = IDS_D3DDLL;
DisplayErrorMsg:
		GetString(errorMsg, buffer, sizeof(buffer));
		MessageBox(Wnd, buffer, "Direct 3D", MB_OK | MB_ICONWARNING);
		return FALSE; // abort window creation
	}

	// Get D3D Create Entry Point
	Direct3DCreate9Entry = (VOID*)GetProcAddress(D3D9Dll, "Direct3DCreate9");
	if (Direct3DCreate9Entry == NULL) {
		errorMsg = IDS_D3DPROC;
DisplayFreeLibrary:
		FreeLibrary(D3D9Dll);
		D3D9Dll = NULL;
		goto DisplayErrorMsg;
	}

	// Create a D3D object
	D3DObject = Direct3DCreate9Entry(D3D_SDK_VERSION);
	if (D3DObject == NULL) {
		errorMsg = IDS_D3DOBJECT;
		goto DisplayFreeLibrary;
	}

	// Get display format
	if (!GetDisplayFormat(Wnd, &d3dPp)) {
		errorMsg = IDS_D3DFORMAT;
DisplayReleaseObject:
		IDirect3D9_Release(D3DObject);
		D3DObject = NULL;
		goto DisplayFreeLibrary;
	}

	// Create the D3D device
	if (IDirect3D9_CreateDevice(D3DObject, D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Wnd, D3DCREATE_SOFTWARE_VERTEXPROCESSING, &d3dPp, &DisplayDevice) != D3D_OK) {
		errorMsg = IDS_D3DDEVICE;
		goto DisplayReleaseObject;
	}
	InitializeCriticalSection(&DisplayCs);
	ObjectsFlag = FALSE;
	ResetFlag = FALSE;
	DisplayFlag = TRUE;
	return TRUE;
}

VOID CloseDisplay(VOID) {

	// Release surfaces and DirectDraw objects
	if (DisplayFlag) {
		EnterCriticalSection(&DisplayCs);
		if (ObjectsFlag) {
			ReleaseD3DObjects();
			ObjectsFlag = FALSE;
		}
		IDirect3DDevice9_Release(DisplayDevice);
		DisplayDevice = NULL;
		IDirect3D9_Release(D3DObject);
		D3DObject = NULL;
		FreeLibrary(D3D9Dll);
		D3D9Dll = NULL;
		DisplayFlag = FALSE;
		LeaveCriticalSection(&DisplayCs);
	}
}

VOID UpdateDisplay(HWND Wnd, ULONG Width, ULONG Height) {
	UCHAR buffer[100];

	EnterCriticalSection(&DisplayCs);
	DisplayWidth = Width;
	DisplayHeight = Height;

	// Release D3D objects if exist
	if (ObjectsFlag) {
		ReleaseD3DObjects();
		ObjectsFlag = FALSE;
	}
 
	// Recreate D3D objects with new display size
	ObjectsFlag = CreateD3DObjects();
	LeaveCriticalSection(&DisplayCs);
	if (!ObjectsFlag) {
		GetString(IDS_D3DOBJECTS, buffer, sizeof(buffer));
		MessageBox(Wnd, buffer, "Direct 3D", MB_OK | MB_ICONWARNING);
	}
}

VOID ReleaseDisplay(VOID) {

	// Release D3D objects if exist
	EnterCriticalSection(&DisplayCs);
	if (ObjectsFlag) {
		ReleaseD3DObjects();
		ObjectsFlag = FALSE;
	}
	LeaveCriticalSection(&DisplayCs);
}

VOID CheckDisplay(VOID) {
	D3DPRESENT_PARAMETERS d3dPp;

	EnterCriticalSection(&DisplayCs);
	if (ResetFlag || IDirect3DDevice9_TestCooperativeLevel(DisplayDevice) == D3DERR_DEVICENOTRESET) {
		ResetFlag = FALSE;

		// Reset device
		if (ObjectsFlag) {
			ReleaseD3DObjects();
			ObjectsFlag = FALSE;
		}
		if (GetDisplayFormat(DisplayWnd, &d3dPp) && IDirect3DDevice9_Reset(DisplayDevice, &d3dPp) == D3D_OK)
			CreateD3DObjects();
	}
	LeaveCriticalSection(&DisplayCs);
}

VOID RefreshDisplay(VOID) {
	ULONG lineFill;
	ULONG count;
	LPDIRECT3DSURFACE9 displaySurface;
//	RECT imageRect;
	POINT displayPoint;
    PVOID vertex;
	D3DLOCKED_RECT d3dRect;

	EnterCriticalSection(&DisplayCs);
	if (!DisplayFlag || ResetFlag || ImageSurface == NULL || DisplayTexture == NULL || DisplayVertex == NULL ||
		IDirect3DSurface9_LockRect(ImageSurface, &d3dRect, NULL, 0) != D3D_OK) {
		LeaveCriticalSection(&DisplayCs);
		return;
	}

	// Generate back buffer from graphic memory
	switch (DisplayFormat) {
	case 0: // D3DFMT_X8R8G8B8
		lineFill = d3dRect.Pitch - GraphicWidth * 4;
__asm{
		mov		eax,GraphicHeight
		mov		esi,GraphicMemory
		mov		edi,d3dRect.pBits
		mov		count,eax
b32_line:
		mov		ecx,GraphicWidth
b32_pixel:
		movzx	ebx,byte ptr [esi]
		mov		eax,Color32[ebx*4]
		stosd
		inc		esi
		loop	b32_pixel
		dec		count				;next line
		jz		short b32_done
		add		edi,lineFill
		jmp		b32_line
b32_done:
}
		break;
	case 1: // D3DFMT_R5G6B5
		lineFill = d3dRect.Pitch - GraphicWidth * 2;
__asm{
		mov		eax,GraphicHeight
		mov		esi,GraphicMemory
		mov		edi,d3dRect.pBits
		mov		count,eax
b16_line:
		mov		ecx,GraphicWidth
b16_pixel:
		movzx	ebx,byte ptr [esi]
		mov		eax,Color16[ebx*2]
		stosw
		inc		esi
		loop	b16_pixel
		dec		count				;next line
		jz		short b16_done
		add		edi,lineFill
		jmp		b16_line
b16_done:
}
	case 2: // D3DFMT_P8
		lineFill = d3dRect.Pitch - GraphicWidth;
__asm{
		mov		eax,GraphicHeight
		mov		esi,GraphicMemory
		mov		edi,d3dRect.pBits
		mov		count,eax
b8_line:
		mov		ecx,GraphicWidth
		shr		ecx,2				;dword count
		rep		stosd
		dec		count				;next line
		jz		short b8_done
		add		edi,lineFill
		jmp		b8_line
b8_done:
}
	}

	IDirect3DSurface9_UnlockRect(ImageSurface);

	// Check if device is still availlable
	if (IDirect3DDevice9_TestCooperativeLevel(DisplayDevice) == D3DERR_DEVICENOTRESET) {
		ResetFlag = TRUE;
		LeaveCriticalSection(&DisplayCs);
		InvalidateRect(DisplayWnd, NULL, FALSE);
		return;
	}

	// Clear the backbuffer and the zbuffer
	if (ClearFlag) {
		if (IDirect3DDevice9_Clear(DisplayDevice, 0, NULL, D3DCLEAR_TARGET, D3DCOLOR_XRGB(0, 0, 0), 1.0f, 0) != D3D_OK)
			goto RefreshDisplayLeaveCS;
		ClearFlag = FALSE;
	}

	// Retrieve texture top level surface
	if (IDirect3DTexture9_GetSurfaceLevel(DisplayTexture, 0, &displaySurface) != D3D_OK)
		goto RefreshDisplayLeaveCS;

	// Copy picture surface into texture surface with image streching and color conversion
//	imageRect.top = 0;
//	imageRect.left = 0;
//	imageRect.right = GraphicWidth;
//	imageRect.bottom = GraphicHeight;
	displayPoint.x = 0;
	displayPoint.y = 0;
	if (IDirect3DDevice9_UpdateSurface(DisplayDevice, ImageSurface, NULL, displaySurface, &displayPoint) != D3D_OK) {
		IDirect3DSurface9_Release(displaySurface);
		goto RefreshDisplayLeaveCS;
	}
	IDirect3DSurface9_Release(displaySurface);

	// Set the vertex buffer
	if (IDirect3DVertexBuffer9_Lock(DisplayVertex, 0, 0, &vertex, D3DLOCK_DISCARD) != D3D_OK)
		goto RefreshDisplayLeaveCS;
	CopyMemory(vertex, Vertex, sizeof(CUSTOMVERTEX)*4);
	IDirect3DVertexBuffer9_Unlock(DisplayVertex);
			
	// Begin the scene
	if (IDirect3DDevice9_BeginScene(DisplayDevice) != D3D_OK)
		goto RefreshDisplayLeaveCS;

	// Setup the texture
	if (IDirect3DDevice9_SetTexture(DisplayDevice, 0, (LPDIRECT3DBASETEXTURE9)DisplayTexture) != D3D_OK) {
RefreshDisplayEndScene:
		IDirect3DDevice9_EndScene(DisplayDevice);
		goto RefreshDisplayLeaveCS;
	}

	// Render the vertex buffer contents
	if (IDirect3DDevice9_SetStreamSource(DisplayDevice, 0, DisplayVertex, 0, sizeof(CUSTOMVERTEX)) != D3D_OK)
		goto RefreshDisplayEndScene;

	// Use FVF instead of vertex shader
	if (IDirect3DDevice9_SetVertexShader(DisplayDevice, NULL) != D3D_OK)
		goto RefreshDisplayEndScene;
	if (IDirect3DDevice9_SetFVF(DisplayDevice, D3DFVF_CUSTOMVERTEX) != D3D_OK)
		goto RefreshDisplayEndScene;

	// Draw rectangle
	if (IDirect3DDevice9_DrawPrimitive(DisplayDevice, D3DPT_TRIANGLEFAN, 0, 2) != D3D_OK)
		goto RefreshDisplayEndScene;

	// End the scene
	IDirect3DDevice9_EndScene(DisplayDevice);

	// Present the back buffer to the display
	IDirect3DDevice9_Present(DisplayDevice, NULL, NULL, NULL, NULL);

	// Remove back brush
	//if (GetClassLong(DisplayWnd, GCL_HBRBACKGROUND) != 0) {
	//	SetClassLong(DisplayWnd, GCL_HBRBACKGROUND, 0);
	//$$$deadlock$$$	SetWindowPos(DisplayWnd, 0, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED); // bug trick
	//}

RefreshDisplayLeaveCS:
	LeaveCriticalSection(&DisplayCs);
}

PUCHAR ScreenShoot(PULONG Size) {
	ULONG lineSize;
	ULONG imageSize;
	ULONG imageOffset;
	ULONG i;
	PBMP_HEADER bmpHeader;
	PUCHAR bmp;
	PUCHAR ptr;

	if (GraphicMemory == NULL)
		return NULL;
	lineSize = ((GraphicWidth + 3) / 4) * 4; // line byte size must be a multiple of 4
	imageSize = lineSize * GraphicHeight;
	imageOffset = ((sizeof(BMP_HEADER) + 3) / 4) * 4; // align to 32 bits
	bmp = VirtualAlloc(NULL, imageOffset + imageSize, MEM_COMMIT, PAGE_READWRITE);
	if (bmp == NULL)
		return NULL;
	ZeroMemory(bmp, imageOffset + imageSize);
	bmpHeader = (PBMP_HEADER)bmp;
	bmpHeader->Signature = 'MB';
	bmpHeader->BmpSize = imageOffset + imageSize;
	bmpHeader->ImageOffset = imageOffset;
	bmpHeader->DescLen = 40;
	bmpHeader->Width = GraphicWidth;
	bmpHeader->Height = GraphicHeight;
	bmpHeader->Planes = 1;
	bmpHeader->Deep = 8;
	bmpHeader->ImageSize = imageSize;
	bmpHeader->ColorsCount = 256;
	CopyMemory(bmpHeader->RGB, Color32, 256 * sizeof(ULONG));
	ptr = bmp + imageOffset;
	for (i = 0; i < GraphicHeight; i ++) {
		CopyMemory(ptr, GraphicMemory + (GraphicHeight - i - 1) * GraphicWidth, GraphicWidth);
		ptr += lineSize;
	}
	*Size = imageOffset + imageSize;
	return bmp;
}