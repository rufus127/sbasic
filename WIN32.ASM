	page	,132
	name	win32

	public	StartBasic
	public	SetBreak
	public	DestroyGraphic
	public	fread,fwrite,fkill,frename
	public	fopen,fclose,fcreate,fsize,fseek
	public	fsystem,fchd
	public	fdate,ftime
	public	flock,funlock
	public	libload,libfree,procaddress
	public	playwav
	public	inivar
	public	endbasic
	public	consolon,consoloff
	public	status,conin,conout
	public	sizecursor,setcursor,getcursor
	public	txtwindow,txtcolor,txtresize
	public	prnon,prnoff,prnout
	public	brkon,brkoff
	public	focusgr,focustxt
	public	opengraphic,closegraphic,grcolor
	public	showmous,hidemous,getmous
	public	edlin,redlin
	public	setsave,clrsave,chkexit,closebasic

	.model	flat,c

	include	sbasic.inc

	.data
;Variables runtime
prn_handle	dd	0		;handle fichier impression
inbuf_count	dd	?		;nombre lignes entree
inbuf_current	dd	?		;index ligne entree courante
prtesc		db	?		;indicateur echappement impression

	.code
	extrn	RedirConsoleOn:near
	extrn	RedirConsoleOff:near
	extrn	CheckKey:near
	extrn	SetControlC:near
	extrn	GetKey:near
	extrn	PutChar:near
	extrn	CursorSize:near
	extrn	MoveCursor:near
	extrn	CursorPos:near
	extrn	SetTxtWindow:near
	extrn	SetTxtColor:near
	extrn	ResizeTxt:near
	extrn	SetGrColor:near
	extrn	CheckExit:near
	extrn	CloseBasicWindow:near
	extrn	EnableCmdMenu:near
	extrn	DisableCmdMenu:near
	extrn	W32_ReadFile:near
	extrn	W32_WriteFile:near
	extrn	W32_DeleteFile:near
	extrn	W32_MoveFile:near
	extrn	W32_CreateFile:near
	extrn	W32_CloseHandle:near
	extrn	W32_GetFileSize:near
	extrn	W32_SetFilePointer:near
	extrn	W32_CreateProcess:near
	extrn	W32_SetCurrentDirectory:near
	extrn	W32_GetDate:near
	extrn	W32_GetTime:near
	extrn	W32_LockFile:near
	extrn	W32_UnlockFile:near
	extrn	W32_LoadLibrary:near
	extrn	W32_FreeLibrary:near
	extrn	W32_GetProcAddress:near
	extrn	W32_GetLastError:near
	extrn	W32_PlaySound:near
	extrn	FocusGraphic:near
	extrn	FocusText:near
	extrn	OpenGraphicWindow:near
	extrn	CloseGraphicWindow:near
	extrn	ShowMouse:near
	extrn	HideMouse:near
	extrn	GetMouse:near
	extrn	strtbasic:near
	extrn	InitVar:near
	extrn	destroygra:near
	extrn	WScreen:dword
	extrn	HScreen:dword
	extrn	SaveFlag:byte
	extrn	PrintFileName:byte
	extrn	SystemFixedFont:byte
	extrn	InputBuffer:dword
	extrn	exitbasic:near
	assume	ds:flat,es:flat

;Tables des erreurs windows
	align	16
last_error_tbl	label	dword
	dd	2,err_no_file		;file not found
	dd	3,err_no_dir		;path not found
	dd	5,err_access_prot	;access denied
	dd	6,err_not_opened	;invalid handle
	dd	7,err_bad_fcb		;arena trashed
	dd	8,err_memory_ovf	;not enough memory
	dd	9,err_bad_fcb		;invalid block
	dd	15,err_disk_num		;invalid drive
	dd	19,err_write_prot	;write protected
	dd	20,err_disk_num		;bad unit
	dd	21,err_not_ready	;not ready
	dd	23,err_read		;CRC
	dd	27,err_no_sector	;sector not found
	dd	32,err_file_used	;sharing violation
	dd	33,err_locked		;lock violation
	dd	38,err_eof		;end of file
	dd	39,err_disk_full	;disk full
	dd	80,err_file_exist	;file exist
	dd	82,err_file_create	;cannot be created
	dd	110,err_file_open	;open failed
	dd	111,err_memory_ovf	;buffer overflow
	dd	112,err_disk_full	;disk full
	dd	123,err_bad_name	;invalid name
	dd	126,err_no_file		;module not found
	dd	161,err_bad_name	;bad path name
	dd	183,err_file_exist	;already exist
	dd	206,err_bad_name	;filename exced range
	dd	223,err_too_big		;file too large
	dd	267,err_no_dir		;invalid directory name
	dd	302,err_fat		;disk too fragmented
	dd	0

;Ligne vide
empty_line	db	0

;Debut execution SBASIC
;BOOLEAN StartBasic(ULONG ArgC, PUCHAR ArgV[], PVOID DataBase, ULONG DataLen, PVOID CodeBase, ULONG CodeLen, PVOID SymbBase, ULONG SymbLen);

	align	16
StartBasic:
	push	ebp
	mov	ebp,esp
	mov	inbuf_count,0		;init tampon lignes entree
	mov	eax,WScreen		;largeur maximale fenetre graphique
	mov	penx,eax		;dans XPEN
	mov	eax,HScreen		;hauteur maximale fenetre graphique
	mov	peny,eax		;dans YPEN
	call	strtbasic		;appel point d'entree BASIC
	pop	ebp
	ret	

;Positionnement indicateur BREAK
	align	16
SetBreak:
	test	byte ptr [esp+4],0FFh	;BREAK force ?
	mov	al,break_mask		;masque BREAK 
	jnz	short setbreak2		;oui
	and	al,breakflg		;AND indicateur BREAK
setbreak1:
	or	intflags,al		;indique interruption BREAK
	ret
setbreak2:
	mov	inttbl+4*break_int,0	;raz vecteur BREAK
	jmp	setbreak1

;Fermeture fenetre graphique
	align	16
DestroyGraphic:
	jmp	destroygra

;WIN32 interface routines
;Lecture fichier
;entree: EBX=handle
;	 ECX=compte octets
;	 EDX->tampon
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
;	 EAX=longueur
	align	16
fread:
	push	ecx
	push	edx
	push	eax			;tampon longueur lue
	push	esp			;pointeur tempon
	push	ecx			;lpNumberOfBytesToRead
	push	edx			;lpBuffer
	push	ebx			;hFile
	call	W32_ReadFile		;appel fonction C
	add	esp,4*4
	test	eax,eax			;(CF=0)
	pop	eax			;longueur lue
	jz	short fread_err		;FALSE, erreur
fread_ret:
	pop	edx
	pop	ecx
	ret
fread_err:
	call	get_win32_error		;code d'erreur
	jmp	fread_ret

;Ecriture fichier
;entree: EBX=handle
;	 ECX=compte octets
;	 EDX->tampon
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
;	 EAX=longueur ecrite
	align	16
fwrite:
	push	ecx
	push	edx
	push	eax			;tampon longueur ecrite
	push	esp			;pointeur tempon
	push	ecx			;lpNumberOfBytesToWrite
	push	edx			;lpBuffer
	push	ebx			;hFile
	call	W32_WriteFile		;appel fonction C
	add	esp,4*4
	test	eax,eax			;(CF=0)
	pop	eax			;longueur ecrite
	jz	short fwrite_err	;FALSE, erreur
fwrite_ret:
	pop	edx
	pop	ecx
	ret
fwrite_err:
	call	get_win32_error		;code d'erreur
	jmp	fwrite_ret

;Supression fichier
;entree: EDX->nom de fichier
;retour: CF et AL=code si erreur
	align	16
fkill:
	push	ecx
	push	edx
	push	edx			;lpFileName
	call	W32_DeleteFile		;appel fonction C
	add	esp,1*4
	test	eax,eax			;(CF=0)
	jz	short fkill_err		;FALSE, erreur
fkill_ret:
	pop	edx
	pop	ecx
	ret
fkill_err:
	call	get_win32_error		;code d'erreur
	jmp	fkill_ret

;Changement chemin fichier
;entree: EDX->chemin existant
;	 EDI->nouveau chemin
;retour: CF et AL=code si erreur
	align	16
frename:
	push	ecx
	push	edx
	push	edi			;lpNewFileName
	push	edx			;lpExistingFileName
	call	W32_MoveFile		;appel fonction C
	add	esp,2*4
	test	eax,eax			;(CF=0)
	jz	short fren_err		;FALSE, erreur
fren_ret:
	pop	edx
	pop	ecx
	ret
fren_err:
	call	get_win32_error		;code d'erreur
	jmp	fren_ret

;Ouverture de fichier
;entree: AL=type ouverture (0=lecture,1=ecriture,2=lecture/ecriture)
;	 EDX->nom de fichier
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
;	 EBX=handle
	align	16
fopen:
	push	ecx
	push	edx
	push	edi
	xor	ebx,ebx			;FALSE
	test	al,al			;ouverture en lecture ?
	push	ebx			;Troncate
	jnz	short fopen_write
	mov	eax,3			;OPEN_EXISTING
	mov	ecx,00000001h		;FILE_SHARE_READ
	mov	edi,80000000h		;GENERIC_READ
	jmp	short fopen_create
fopen_write:
	dec	al			;ouverture en ecriture ?
	jnz	short fopen_read_write
	mov	eax,3			;OPEN_EXISTING
fopen_write_create:
	mov	ecx,00000001h		;FILE_SHARE_READ
	mov	edi,40000000h		;GENERIC_WRITE
	jmp	short fopen_create
fopen_read_write:
	dec	al			;ouvertue en lecture/ecriture
	jnz	fopen_err
	mov	eax,3			;OPEN_EXISTING
fopen_read_write_create:
	mov	ecx,00000003h		;FILE_SHARE_READ|FILE_SHARE_WRITE
	mov	edi,0C0000000h		;GENERIC_READ|GENERIC_WRITE
fopen_create:
	xor	ebx,ebx
	push	ebx			;dwFlagsAndAttributes = 0
	push	eax			;dwCreationDisposition
	push	ecx			;dwShareMode
	push	edi			;dwDesiredAccess
	push	edx			;lpFileName
	call	W32_CreateFile		;appel fonction C
	add	esp,6*4
	cmp	eax,0FFFFFFFFh		;INVALID_HANDLE_VALUE ?
	je	short fopen_err		;erreur
	mov	ebx,eax			;retour handle
	clc
fopen_ret:
	pop	edi
	pop	edx
	pop	ecx
	ret
fopen_err:
	call	get_win32_error		;code d'erreur
	jmp	fopen_ret

;Fermeture fichier
;entree: EBX=handle
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
	align	16
fclose:
	push	ecx
	push	edx
	push	ebx			;hObject
	call	W32_CloseHandle		;appel fonction C
	add	esp,1*4
	test	eax,eax			;(CF=0)
	jz	short fclose_err	;FALSE, erreur
fclose_ret:
	pop	edx
	pop	ecx
	ret
fclose_err:
	call	get_win32_error		;code d'erreur
	jmp	fclose_ret

;Taille fichier
;entree: EBX=handle
;	 ESI->FCB (non utilise)
;retour: CF at AL=code si erreur
;	 EAX=taille fichier
fsize:
	push	ecx
	push	edx
	push	eax			;tampon longueur
	push	esp			;pointeur vers tampon longueur
	push	ebx			;hObject
	call	W32_GetFileSize		;appel fonction C
	add	esp,2*4
	test	eax,eax			;(CF=0)
	pop	eax			;longueur
	jz	short fsize_err		;FALSE, erreur
fsize_ret:
	pop	edx
	pop	ecx
	ret
fsize_err:
	call	get_win32_error		;code d'erreur
	jmp	fsize_ret

;Creation de fichier
;entree: AL=type ouverture (1=ecriture,2=lecture/ecriture)
;	 EDX->nom de fichier
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
;	 EBX=handle
	align	16
fcreate:
	push	ecx
	push	edx
	push	edi
	pushd	1			;Troncate
	cmp	al,1			;ouverture en ecriture ?
	mov	eax,4			;OPEN_ALWAYS
	je	fopen_write_create	;oui
	jmp	fopen_read_write_create	;ouverture en lecture/ecriture

;Deplacement pointeur fichier
;entree: AL=type (0=absolu,2=fin de fichier)
;	 EBX=handle
;	 ECX:EDX=position octet
;retour: CF et AL=code si erreur
	align	16
fseek:
	push	ecx
	push	edx
	movzx	eax,al
	push	eax			;dwMoveMethod
	push	ecx			;lDistanceToMoveHigh
	push	edx			;lDistanceToMove
	push	ebx			;hFile
	call	W32_SetFilePointer	;appel fonction C
	add	esp,4*4
	test	eax,eax			;(CF=0)
	jz	short fseek_err		;FALSE, erreur
fseek_ret:
	pop	edx
	pop	ecx
	ret
fseek_err:
	call	get_win32_error		;code d'erreur
	jmp	fseek_ret

;Execution commande systeme
;entree: edx->ligne de commande
	align	16
fsystem:
	push	ecx
	push	edx
	push	edx			;lpCmdLine
	call	W32_CreateProcess	;appel fonction C
	add	esp,1*4
	pop	edx
	pop	ecx
	ret

;Changement repertoire
;entree: edx->chemin
;retour: CF et AL=code si erreur
	align	16
fchd:
	push	ecx
	push	edx
	push	edx			;lpPathName
	call	W32_SetCurrentDirectory	;appel fonction C
	add	esp,1*4
	test	eax,eax			;(CF=0)
	jz	short fchd_err		;FALSE, erreur
fchd_ret:
	pop	edx
	pop	ecx
	ret
fchd_err:
	call	get_win32_error		;code d'erreur
	jmp	fchd_ret

;Lecture date
;retour: DL=jour (1-31)
;	 DH=mois (1-12)
;	 CX=annee (1980-2099)
	align	16
fdate:
	push	eax
	call	W32_GetDate
	movzx	edx,ax
	shr	eax,16
	mov	ecx,eax
	pop	eax
	ret

;Lecture heure
;retour: DL=centiemes (0-99)
;	 DH=secondes (0-59)
;	 CL=minutes (0-59)
;	 CH=heure (0-23)
	align	16
ftime:
	push	eax
	call	W32_GetTime
	movzx	edx,ax
	shr	eax,16
	mov	ecx,eax
	pop	eax
	ret

;Verouillage enregistrement fichier
;entree: EBX=handle
;	 ECX|EDX=offset
;	 ESI|EDI=longueur
	align	16
flock:
	push	ecx
	push	edx
	push	esi			;dwNumberOfBytesToLockHigh
	push	edi			;dwNumberOfBytesToLockLow
	push	ecx			;dwFileOffsetHigh
	push	edx			;dwFileOffsetLow
	push	ebx			;hFile
	call	W32_LockFile		;appel fonction C
	add	esp,5*4
	pop	edx
	pop	ecx
	ret

;Deverouillage enregistrement fichier
;entree: EBX=handle
;	 ECX|EDX=offset
;	 ESI|EDI=longueur
	align	16
funlock:
	push	ecx
	push	edx
	push	esi			;dwNumberOfBytesToLockHigh
	push	edi			;dwNumberOfBytesToLockLow
	push	ecx			;dwFileOffsetHigh
	push	edx			;dwFileOffsetLow
	push	ebx			;hFile
	call	W32_UnlockFile		;appel fonction C
	add	esp,5*4
	pop	edx
	pop	ecx
	ret

;Chargement librairie
;Entree: EDX->nom de fichier
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
;	 EBX=handle
	align	16
libload:
	push	ecx
	push	edx
	push	edx			;lpLibFileName
	call	W32_LoadLibrary		;appel fonction C
	add	esp,1*4
	and	eax,eax			;NULL ? (CF=0)
	jz	lload_err		;oui, erreur
	mov	ebx,eax
lload_ret:
	pop	edx
	pop	ecx
	ret
lload_err:
	call	get_win32_error		;code d'erreur
	jmp	lload_ret

;Liberation librairie
;entree: EBX=handle
;	 ESI->FCB (non utilise)
;retour: CF et AL=code si erreur
libfree:
	push	ecx
	push	edx
	push	ebx			;hModule
	call	W32_FreeLibrary		;appel fonction C
	add	esp,1*4
	test	eax,eax			;(CF=0)
	jz	short lfree_err		;FALSE, erreur
lfree_ret:
	pop	edx
	pop	ecx
	ret
lfree_err:
	call	get_win32_error		;code d'erreur
	jmp	lfree_ret

;Point d'entree fonction librairie
;entree: EBX=handle
;	 EDX->nom point d'entree
;retour: EBX=adresse point d'entree
;	 CF et AL=code si erreur
procaddress:
	push	ecx
	push	edx
	push	edx			;lpProcName
	push	ebx			;hModule
	call	W32_GetProcAddress	;appel fonction C
	add	esp,2*4
	test	eax,eax			;(CF=0)
	jz	short paddr_err		;FALSE, erreur
	mov	ebx,eax
paddr_ret:
	pop	edx
	pop	ecx
	ret
paddr_err:
	call	get_win32_error		;code d'erreur
	jmp	paddr_ret

;Conversion code d'erreur windows
	align	16
get_win32_error:
	push	ebx
	push	ecx
	push	edx
	push	esi
	call	W32_GetLastError	;appel fonction C
	mov	esi,offset last_error_tbl
gwe_loop:
	mov	ebx,[esi]
	test	ebx,ebx			;fin de table ?
	jz	gwe_not_found		;oui
	cmp	eax,ebx			;code trouve ?
	jz	gwe_found		;oui
	add	esi,4*2
	jmp	gwe_loop
gwe_found:
	mov	eax,[esi+4]		;erreur SBASIC
gwe_ret:
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	stc
	ret
gwe_not_found:
	mov	eax,err_fatal		;erreur irrecuperable
	jmp	gwe_ret

;Joue fichier son
;entree: WORKBUF contient le nom de fichier (extension .WAV par defaut)
;	 EAX=indicateur attente
	align	16
playwav:
	push	ebx
	mov	ebx,offset pathbuf	;nom de fichier
	push	ecx
	push	edx
	cmp	byte ptr [ebx],0	;chaine vide ?
	push	eax			;indicateur attente
	je	short playwav2		;oui
playwav1:
	push	ebx			;nom de fichier
	call	W32_PlaySound		;appel fonction C
	add	esp,2*4
	pop	edx
	pop	ecx
	pop	ebx
	ret
playwav2:
	xor	ebx,ebx			;pointeur nul
	jmp	playwav1

;Reinitialisation variables
	align	16
inivar:
	push	ecx
	push	edx
	call	InitVar			;appel fonction C
	pop	edx
	pop	ecx
	mov	eax,WScreen		;largeur maximale fenetre graphique
	mov	penx,eax		;dans XPEN
	mov	eax,HScreen		;hauteur maximale fenetre graphique
	mov	peny,eax		;dans YPEN
	ret

;Activation redirection console
consolon:
	push	ecx
	push	edx
	call	RedirConsoleOn		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Desactivation redirection console
consoloff:
	push	ecx
	push	edx
	call	RedirConsoleOff		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Test caractere en attente
;Retour: ZF=0 si caractere en attente
	align	16
status:
	push	eax
	push	ecx
	push	edx
	call	CheckKey		;appel fonction C
	test	al,al			;ZF si FALSE
	pop	edx
	pop	ecx
	pop	eax
	ret

;Entree caractere
;Retour: AL=caractere
;	 ZF si sortie BASIC demandee
	align	16
conin:
	push	ecx
	push	edx
	push	eax			;tampon caractere
	push	esp			;pointeur vers tampon caractere
	call	GetKey			;appel fonction C
	add	esp,1*4
	test	al,al			;ZF si FALSE
	pop	eax			;caractere dans AL
	pop	edx
	pop	ecx
	jz	short endbasic		;sortie BASIC demandee
	ret
endbasic:
	xor	al,al			;retour FALSE
	jmp	exitbasic		;sortie BASIC

;Affichage caractere
;Entree: AL=caractere
	align	16
conout:
	push	eax
	push	ecx
	push	edx
	push	eax			;caractere
	call	PutChar			;appel fonction C
	add	esp,1*4
	pop	edx
	pop	ecx
	pop	eax
	ret

;Taille curseur
;Entree: CL=ligne inferieure [1..7]
;	 CH=ligne superieure [1..7]
	align	16
sizecursor:
	push	eax
	push	ecx
	push	edx
	movzx	eax,cl			;ligne inferieure
	push	eax
	movzx	eax,ch			;ligne superieure
	push	eax
	call	CursorSize		;appel fonction C
	add	esp,2*4
	test	al,al
	jz	cursor_size_err
cursor_size_ret:
	pop	edx
	pop	ecx
	pop	eax
	ret
cursor_size_err:
	stc				;erreur
	jmp	cursor_size_ret

;Positionnement curseur
;Entree: EAX=colonne(0-79)
;	 EBX=ligne(0-24)
;Retour: CF si position invalide
	align	16
setcursor:
	push	eax
	push	ecx
	push	edx
	push	ebx			;rangee
	push	eax			;colonne
	call	MoveCursor		;appel fonction C
	add	esp,2*4
	test	al,al
	jz	setcursor_err
setcursor_ret:
	pop	edx
	pop	ecx
	pop	eax
	ret
setcursor_err:
	stc				;erreur
	jmp	setcursor_ret

;Recuperation position curseur
;Retour: AL=colonne(0-79)
;	 AH=ligne(0-24)
	align	16
getcursor:
	push	ecx
	push	edx
	push	eax			;ligne|colonne
	call	CursorPos		;appel fonction C
	mov	dx,ax
	pop	eax
	mov	ax,dx
	pop	edx
	pop	ecx
	ret

;Definition fenetre texte
;Entree: ESI->ligne superieure (0-24)
;	 ESI+2->colonne gauche (1-80)
;	 ESI+4->ligne inferieure (0-24)
;	 ESI+6->colonne droite (1-80)
	align	16
txtwindow:
	push	ecx
	push	edx
	mov	eax,[esi].atxt.cright
	dec	eax
	push	eax			;ColRight
	mov	eax,[esi].atxt.ldown
	push	eax			;LineDown
	mov	eax,[esi].atxt.cleft
	dec	eax
	push	eax			;ColLeft
	mov	eax,[esi].atxt.lup
	push	eax			;LineUp
	call	SetTxtWindow		;appel fonction C
	add	esp,4*4
	pop	edx
	pop	ecx
	ret

;Definition couleur texte
;Entree: ESI->couleur (0-1)
;	 ESI+1->niveau rouge (0-255)
;	 ESI+2->niveau vert (0-255)
;	 ESI+3->niveau bleu (0-255)
	align	16
txtcolor:
	push	ecx
	push	edx
	movzx	eax,byte ptr [esi+3]
	push	eax			;bleu
	movzx	eax,byte ptr [esi+2]
	push	eax			;vert
	movzx	eax,byte ptr [esi+1]
	push	eax			;rouge
	movzx	eax,byte ptr [esi]
	push	eax			;couleur
	call	SetTxtColor		;appel fonction C
	add	esp,4*4
	pop	edx
	pop	ecx
	ret

;Redimensionnement fenetre texte
;Entree: EBX=lignes
;	 ECX=colonnes
	align	16
txtresize:
	mov	widthx,ecx		;maj
	push	ebx
	push	ecx
	push	edx
	push	ecx			;colonnes
	push	ebx			;lignes
	mov	eax,ecx
	sub	eax,maxsymb+5
	mov	ebx,minlnum+1
	xor	edx,edx
	div	ebx
	mov	maxnref,eax		;(text_cols-maxsymb-5)/(minlnum+1)
	mov	eax,ecx
	dec	eax
	mov	ebx,maxlabl+minlnum+1
	xor	edx,edx
	div	ebx
	mov	maxlref,eax		;(text_cols-1)/(maxlabl+minlnum+1)
	call	ResizeTxt		;appel fonction C
	add	esp,2*4
	pop	edx
	pop	ecx
	pop	ebx
	ret

;Positionnement indicateur sauvegarde programme
	align	16
setsave:
	mov	SaveFlag,0FFh		;TRUE
	ret

;Raz indicateur sauvegarde programme
	align	16
clrsave:
	mov	SaveFlag,0		;FALSE
	ret

;Test sortie si sauvegarde programme demandee
;Retour: CF=1 si refusee
	align	16
chkexit:
	test	SaveFlag,0FFh		;sauvegarde programme demandee (CF=0) ?
	jz	short chke_ret
	push	eax
	push	ecx
	push	edx
	call	CheckExit
	test	al,al			;OK (CF=0) ?
	pop	edx
	pop	ecx
	pop	eax
	jz	short chke_false	;non
chke_ret:
	ret
chke_false:
	stc				;indique refuse
	jmp	chke_ret

;OK fermeture fenetre BASIC
closebasic:
	call	CloseBasicWindow
	ret

;Activation redirection affichage sur imprimante
	align	16
prnon:
	cmp	prtflg,0		;redirection active ?
	jne	short pon_ret		;oui, ignore
	push	eax
	push	ecx
	push	edx
	xor	eax,eax			;FALSE
	push	eax			;Troncate
	push	eax			;dwFlagsAndAttributes
	mov	eax,4			;OPEN_ALWAYS
	push	eax			;dwCreationDisposition
	mov	eax,1			;FILE_SHARE_READ
	push	eax			;dwShareMode
	mov	eax,0C0000000h		;GENERIC_READ|GENERIC_WRITE
	push	eax			;dwDesiredAccess
	mov	eax,offset PrintFileName
	push	eax			;lpFileName
	call	W32_CreateFile		;appel fonction C
	add	esp,6*4
	cmp	eax,0FFFFFFFFh		;INVALID_HANDLE_VALUE ?
	je	short pon_pop		;erreur
	mov	prn_handle,eax		;sauve handle
	mov	ecx,2			;FILE_END
	push	ecx			;dwMoveMethod
	xor	ecx,ecx
	push	ecx			;lDistanceToMoveHigh
	push	ecx			;lDistanceToMove
	push	eax			;hFile
	call	W32_SetFilePointer	;appel fonction C
	add	esp,4*4
pon_pop:
	pop	edx
	pop	ecx
	pop	eax
	mov	prtflg,1		;active redirection
	mov	prtesc,0		;raz indicateur echapement
pon_ret:
	ret

;Desactivation redirection affichage sur imprimante
	align	16
prnoff:
	cmp	prtflg,0		;redirection active ?
	je	short poff_ret		;non, ignore
	push	eax
	push	ecx
	push	edx
	mov	eax,prn_handle		;handle fichier impression
	test	eax,eax			;ouvert ?
	jz	short poff_pop		;non, ignore
	push	eax			;hObject
	call	W32_CloseHandle		;appel fonction C
	add	esp,1*4
	mov	prn_handle,0		;indique fichier ferme
poff_pop:
	pop	edx
	pop	ecx
	pop	eax
	mov	prtflg,0
poff_ret:
	ret

;Impression caractere
;entree: AL=caractere a imprimer
	align	16
prnout:
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	ecx,prn_handle		;handle fichier d'impression
	jecxz	short pout_pop		;non ouvert, ignore
	cmp	prtesc,0		;echapement en cours ?
	jne	short pout_esc_off	;oui
	cmp	al,20h			;caractere de controle ?
	jb	short pout_ctrl		;oui
	cmp	al,80h			;code etendu ?
	jb	short pout_write	;non
	movzx	ebx,al
	mov	al,SystemFixedFont[ebx-80h] ;conversion fonte systeme
pout_write:
	push	eax			;tampon caractere a imprimer
	mov	edx,esp			;pointeur tampon caractere
	push	eax			;tampon longueur ecrite
	push	esp			;pointeur tampon longueur
	push	1			;lpNumberOfBytesToWrite
	push	edx			;lpBuffer
	push	ecx			;hFile
	call	W32_WriteFile		;appel fonction C
	add	esp,6*4
pout_pop:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
pout_ctrl:
	cmp	al,cr			;retour ligne ?
	je	pout_write		;oui, garde
	cmp	al,lf			;saut de ligne ?
	je	pout_write		;oui, garde
	cmp	al,escape		;caractere echapement ?
	jne	pout_pop		;non, ignore
	mov	prtesc,1		;indique echapement
	jmp	pout_pop
pout_esc_off:
	mov	prtesc,0		;raz echapement
	jmp	pout_pop

;Activation Control-C
	align	16
brkon:
	push	eax
	push	ecx
	push	edx
	movzx	eax,breakflg		;etat courant BREAK
	push	eax
	call	SetControlC		;appel fonction C
	add	esp,1*4
	pop	edx
	pop	ecx
	pop	eax
	ret

;Desactivation Control-C
	align	16
brkoff:
	push	eax
	push	ecx
	push	edx
	xor	al,al			;FALSE
	push	eax
	call	SetControlC		;appel fonction C
	add	esp,1*4
	pop	edx
	pop	ecx
	pop	eax
	ret

;Interface graphique
;Focus fenetre graphique
	align	16
focusgr:
	push	ecx
	push	edx
	call	FocusGraphic		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Focus fenetre texte
	align	16
focustxt:
	push	ecx
	push	edx
	call	FocusText		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Ouverture fenetre graphique
;entree: EBX=largeur
;	 ECX=hauteur
;retour: EAX=base memoire graphique (0 si erreur)
	align	16
opengraphic:
	push	ecx
	push	edx
	push	ecx			;Width
	push	ebx			;High
	call	OpenGraphicWindow	;appel fonction C
	add	esp,2*4
	pop	edx
	pop	ecx
	ret

;Fermeture fenetre graphique
	align	16
closegraphic:
	push	ecx
	push	edx
	call	CloseGraphicWindow		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Definition couleur graphique
;Entree: ESI->couleur (0-255)
;	 ESI+1->niveau rouge (0-255)
;	 ESI+2->niveau vert (0-255)
;	 ESI+3->niveau bleu (0-255)
	align	16
grcolor:
	push	ecx
	push	edx
	movzx	eax,[esi].acol.b
	push	eax			;bleu
	movzx	eax,[esi].acol.g
	push	eax			;vert
	movzx	eax,[esi].acol.r
	push	eax			;rouge
	movzx	eax,[esi].acol.col
	push	eax			;couleur
	call	SetGrColor		;appel fonction C
	add	esp,4*4
	pop	edx
	pop	ecx
	ret

;Activation souris
	align	16
showmous:
	push	ecx
	push	edx
	call	ShowMouse		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Desactivation souris
	align	16
hidemous:
	push	ecx
	push	edx
	call	HideMouse		;appel fonction C
	pop	edx
	pop	ecx
	ret

;Test clic souris
;entree: EAX=indicateur attente clic souris
;retour: EAX=1:bouton gauche, 2: bouton droit, 4: bouton milieu, ECX:X, EDX:Y, ZF=0 si EndBasicFlag
	align	16
getmous:
	push	eax			;reserve mot
	push	eax			;reserve mot
	push	eax			;reserve mot
	push	esp			;EndFlag
	push	eax			;indicateur attente clic
	lea	eax,[esp+3*4]
	push	eax			;Y
	lea	eax,[esp+5*4]
	push	eax			;X
	call	GetMouse		;appel fonction C
	add	esp,4*4
	pop	ecx			;CL=EndFlag
	test	cl,cl			;ZF=0 si EndFlag=TRUE
	pop	edx			;Y
	pop	ecx			;X
	ret

;variables locales edition
insflg	equ	byte ptr [ebp+0]	;indicateur insertion
rptflg	equ	byte ptr [ebp+1]	;indicateur desactivation repetition
charc	equ	byte ptr [ebp+2]	;nombre caracteres a effacer
buff	equ	dword ptr [ebp+4]	;debut tampon
edptr	equ	dword ptr [ebp+8]	;pointeur edition
endlin	equ	dword ptr [ebp+12]	;fin entree
endbuf	equ	dword ptr [ebp+16]	;fin tampon
edloc	equ	20			;taille variables locales

; Re-edition ligne existante
; Entree: ESI->debut tampon
;	  EDI->fin tampon
; Retour: AL=dernier caractere entree
;	  EBX->fin ligne
	align	16
redlin:
	push	ebp
	push	edi			;ENDBUF
	push	esi			;ENDLIN
	push	esi			;EDPTR
	push	esi			;BUFF
	xor	eax,eax			;INSFLG=0, RPTFLG=0 et CHARC=0
	push	eax
	mov	ebp,esp			;pointeur variables locales
	call	insoff			;desactivation insertion
	jmp	edlin11

; Edition nouvelle ligne
; Entree: ESI->debut tampon
;	  EDI->fin tampon
; Retour: AL=dernier caractere entree
;	  EBX->fin ligne
	align	16
edlin:
	push	ebp
	push	edi			;ENDBUF
	push	esi			;ENDLIN
	push	esi			;EDPTR
	push	esi			;BUFF
	xor	eax,eax			;INSFLG=0, RPTFLG=0 et CHARC=0
	push	eax
	mov	ebp,esp			;pointeur variables locales
	call	insoff			;desactivation insertion
edlin1:
	call	enablemenu		;activation menu commandes windows
	call	conin			;lecture console
	call	disablemenu		;desactivation menu commandes windows
	cmp	al,rpt			;repetition ?
	je	short edlin10		;oui, recupere edition precedente
	cmp	al,up			;fleche vers le haut ?
	je	short edlin4		;oui, recule dans historique entrees
	cmp	al,lf			;fleche vers le bas ?
	je	short edlin6		;oui, avance dans historique entrees
	cmp	al,escape		;echapement ?
	je	edlin1			;oui, ignore
edlin2:
	call	inputl1			;entree ligne avec premier caractere dans AL
	jmp	edlin14
edlin3:
	call	clrline			;effacement ligne
edlin4:
	call	prevlinebuf		;ligne precedente historique
	jmp	short edlin7
edlin5:
	call	clrline			;effacement ligne
edlin6:
	call	nextlinebuf		;ligne suivante historique
edlin7:
	mov	ebx,buff		;debut tampon
edlin8:
	lodsb				;caractere ligne historique
	test	al,al			;fin de ligne ?
	jz	short edlin9		;oui
	mov	[ebx],al		;range dans tampon
	inc	ebx			;avance
	cmp	ebx,endbuf		;fin de tampon ?
	jb	edlin8			;non, continue
edlin9:
	mov	endlin,ebx		;range fin de ligne
	call	updeol			;maj fin de ligne puis retour en position (curseur en debut de ligne)
	call	conin			;lecture console
	cmp	al,up			;fleche vers le haut ?
	je	edlin3			;oui, recule dans historique entrees
	cmp	al,lf			;fleche vers le bas ?
	je	edlin5			;oui, avance dans historique entrees
	cmp	al,escape		;echapement ?
	jne	edlin2			;oui, edition ligne
	call	clrline			;effacement ligne
	jmp	edlin1
edlin10:
	test	rptflg,0FFh		;repetition possible ?
	jnz	edlin1			;non, ignore
	mov	esi,buff		;debut tampon
edlin11:
	lodsb				;caractere tampon
	test	al,al			;zero ?
	je	short edlin12		;oui
	cmp	al,eot			;fin de chaine ?
	je	short edlin12		;oui
	cmp	al,cr			;fin de ligne ?
	je	short edlin12		;oui
	cmp	esi,endbuf		;fin tampon
	jb	edlin11			;non
	jmp	short edlin13		;fin de ligne
edlin12:
	dec	esi			;retour sur caractere de fin
edlin13:
	mov	endlin,esi		;range fin de ligne
	cmp	esi,buff		;ligne vide ?
	jbe	edlin1			;oui, ignore
	call	updeol			;maj fin de ligne puis retour en position (curseur en debut de ligne)
	call	inputl			;entree ligne
edlin14:
	mov	rptflg,0FFh		;indique plus de repetition
	jc	edlin1			;continue edition
	push	eax
	mov	esi,buff		;debut ligne
	mov	ebx,endlin		;fin de ligne
	call	addlinebuf		;ajout ligne dans historique
	call	insoff			;desactivation insertion
	pop	eax
	add	esp,edloc
	pop	ebp
	ret

; Table caracteres de controle
editab	label	byte
	db	inrt			;02h insertion
	db	ctrlc			;03h abandon
	db	del			;05h effacement caractere
	db	bs			;08h recul curseur
	db	tab			;09h tabulation
	db	cr			;0Dh fin d'edition
	db	rpt			;12h debut/fin
	db	ctrlx			;18h effacement fin de ligne et retour
	db	escape			;1Bh echapement
	db	lef			;1Dh avance curseur
	db	back			;7Fh effacement caractere precedent
edilen	equ	$-editab

; Table de branchement caracteres de controle
	align	16
editjmp	label	dword
	dd	offset inrtx
	dd	offset incancel
	dd	offset delx
	dd	offset bsx
	dd	offset tabx
	dd	offset inputl8
	dd	offset rptx
	dd	offset ctrlxx
	dd	offset incancel
	dd	offset lefx
	dd	offset backx

; Entree ligne
; Entree: EBP->variables locales edition
; Retour: CF si continue edition
	align	16
inputl:
	call	conin			;lecture console
inputl1:
	cmp	al,20h			;caratere de controle ?
	mov	ebx,edptr		;pointeur entree
	jb	short inputl5		;oui
	cmp	al,back
	je	short inputl5		;oui
	push	eax
	test	insflg,0FFh		;insertion ?
	jnz	short inputl2		;oui
	cmp	ebx,endlin		;curseur en fin de ligne ?
	jb	short inputl3		;non
inputl2:
	call	rshift			;decalage a droite
	jc	short inputl4		;tampon plein, ignore
inputl3:
	pop	eax
	mov	[ebx],al		;range caractere dans tampon
	call	dispchar		;affiche caractere avec maj EDPTR
	test	insflg,0FFh		;insertion ?
	jz	inputl			;non, attente caractere
	call	updeol			;maj fin de ligne puis retour en position
	jmp	inputl			;attente caractere
inputl4:
	pop	eax
	jmp	inputl			;attente caractere
inputl5:
	mov	edi,offset editab	;table des caracteres de control
	mov	ecx,edilen		;longueur table
	repne	scasb			;recherche code
	jne	inputl			;non trouve, ignore
	sub	edi,offset editab+1	;index table
	jmp	editjmp[edi*4]		;branchement traitement
inputl6:
	mov	eax,edptr		;pointeur entree
	cmp	eax,buff		;debut tampon ?
	jne	inputl			;non
	cmp	eax,endlin		;tampon vide ?
	jne	inputl			;non
inputl7:
	stc				;indique continue entree
	ret
inputl8:
	mov	ecx,endlin
	sub	ecx,ebx			;caracteres jusqu'a la fin de ligne
	jecxz	short inputl11		;deja en fin de ligne
	push	eax
inputl9:
	mov	al,[ebx]		;caractere tampon
	inc	ebx			;avance
	call	conout			;affichage console
	loop	inputl9			;jusqu'a la fin
inputl10:
	mov	al,cr
	call	conout			;affichage CR
	mov	al,lf
	call	conout			;affichage LF
	mov	colm,0			;raz colonne ecran
	pop	eax
	clc				;indique fin entree
	ret
inputl11:
	push	eax
	jmp	inputl10

; Insertion
	align	16
inrtx:
	test	insflg,0FFh		;mode insertion ?
	jnz	short inrtx1		;oui
	call	inson			;activation insertion
	jmp	inputl6			;attente caractere
inrtx1:
	call	insoff			;desactivation insertion
	jmp	inputl6			;attente caractere

; Annule entree
incancel:
	push	eax
	mov	ecx,ebx
	mov	ebx,buff
	mov	edptr,ebx		;maj debut de ligne
	sub	ecx,ebx			;caracteres jusqu'au debut de ligne
	jbe	short incancel1		;zero, ignore
	call	updeol5			;recule curseur
incancel1:
	jmp	ctrlxx1			;effacement fin de ligne et retour

; Effacement caractere
	align	16
delx:
	cmp	ebx,endlin		;curseur en fin de ligne ?
	jae	inputl6			;oui, ignore
	call	lshift			;efface char sous curseur (decalage a gauche)
	inc	charc			;un caractere a effacer
	call	updeol			;maj fin de ligne puis retour en position
	jmp	inputl6			;test ligne vide

; Recule curseur
	align	16
bsx:
	cmp	ebx,buff		;debut de ligne ?
	jbe	inputl6			;oui, ignore
	dec	edptr			;recule
	mov	al,bs			;et affiche
	call	conout			;affichage console
	jmp	inputl			;attente caractere

; Tabulation
	align	16
tabx:
	cmp	ebx,endlin		;fin de ligne ?
	jae	short rptx1		;oui, retour en debut de ligne
	mov	ecx,8			;longueur tabulation
tabx1:
	cmp	ebx,endlin		;fin de ligne ?
	jae	short tabx2		;oui, c'est bon
	mov	al,[ebx]		;caractere tampon
	inc	ebx			;avance
	call	conout			;affichage console
	loop	tabx1			;pour le nombre de caracteres demande
tabx2:
	mov	edptr,ebx		;maj pointeur entree
	jmp	inputl6			;attente caractere

; Repetition
	align	16
rptx:
	cmp	ebx,endlin		;fin de ligne ?
	jae	short rptx1		;oui, retour en debut de ligne
	mov	ecx,endlin
	sub	ecx,ebx			;caracteres jusqu'a la fin de ligne
	jmp	tabx1			;avance
rptx1:
	mov	ecx,ebx
	mov	ebx,buff
	mov	edptr,ebx		;maj debut de ligne
	sub	ecx,ebx			;caracteres jusqu'au debut de ligne
	jbe	inputl6			;zero, ignore
	call	updeol5			;recule curseur
	jmp	inputl			;attente caractere

; Effacement fin de ligne
	align	16
ctrlxx:
	mov	al,cr			;retour CR
	push	eax
ctrlxx1:
	cmp	ebx,endlin		;fin de ligne ?
	jae	short ctrlxx2		;oui
	mov	byte ptr [ebx],' '	;effacement caractere
	inc	ebx			;avance
	jmp	ctrlxx1			;jusqu'a fin de ligne
ctrlxx2:
	call	updeol			;mise a jour fin de ligne (avec des espaces)
	mov	ebx,edptr		;fin de ligne
	mov	endlin,ebx		;maj pointeur fin de ligne
	pop	eax			;caractere entre
	cmp	al,escape		;echapement ?
	jne	inputl11		;non, fin entree
	jmp	inputl7			;continue entree

; Avance curseur
	align	16
lefx:
	cmp	ebx,endlin		;fin de ligne ?
	jae	inputl6			;oui, ignore
	mov	al,[ebx]		;caractere tampon
	call	dispchar		;affiche caractere avec maj EDPTR
	jmp	inputl			;attente caractere

; Effacement caractere precedent
	align	16
backx:
	cmp	ebx,buff		;curseur en debut de ligne ?
	jbe	inputl6			;oui, ignore
	dec	ebx			;recule
	mov	edptr,ebx
	mov	al,bs			;recule curseur
	call	conout			;affichage console
	jmp	delx			;efface caractere sous curseur

; Desactivation insertion
	align	16
insoff:
	mov	insflg,0
	mov	cx,0707h		;curseur trait
setcur:
	jmp	sizecursor		;dimensionne curseur

; Activation insertion
	align	16
inson:
	mov	insflg,0FFh
	mov	cx,0107h		;curseur plein
	jmp	setcur

; Decalage tampon a gauche
; Entree: EBX=pointeur entree
	align	16
lshift:
	mov	ecx,endlin		;fin de ligne
	mov	edi,ebx			;destination
	mov	esi,ebx			;source
	inc	esi			;decalage d'un caractere
	sub	ecx,esi			;nombre caracteres a decaler
	rep	movsb			;recopie
	dec	endlin			;recule fin de ligne
	ret

; Decalage tampon a droite
; Retour: CF si tampon plein
	align	16
rshift:
	mov	esi,endlin		;fin de ligne
	mov	edi,esi
	inc	edi			;avance
	cmp	edi,endbuf		;debordement ?
	ja	short rshift1		;oui
	mov	endlin,edi		;maj fin de ligne
	mov	ecx,esi
	dec	esi
	sub	ecx,ebx			;nombre caracteres a decaler
	dec	edi
	std				;en arriere
	rep	movsb			;recopie
	cld				;retaure
	clc				;OK
	ret
rshift1:
	stc				;retour tampon plein
	ret

; Affiche caractere et avance le pointeur entree
; Entree: AL=caractere
	align	16
dispchar:
	inc	edptr			;avance
	jmp	conout			;affichage console

; Maj fin de ligne puis retour en position
	align	16
updeol:
	mov	esi,edptr		;pointeur entree
updeol1:
	cmp	esi,endlin		;fin de ligne ?
	jae	short updeol2		;oui
	lodsb				;caratere tampon
	call	conout			;affichage console
	jmp	updeol1			;jusqu'a la fin de ligne
updeol2:
	xor	ecx,ecx
	xchg	cl,charc		;nombre de caracteres a effacer et raz
	jecxz	updeol4			;rien a faire
	mov	al,' '			;affiche espace
updeol3:
	call	conout			;affichage console
	inc	esi			;advance pointeur ligne
	loop	updeol3
updeol4:
	mov	ecx,esi			;position fin affichage dans tampon
	sub	ecx,edptr		;nombre de caracteres depuis la position d'entree
	jecxz	short updeol7		;pas de deplacement curseur
updeol5:
	mov	al,bs			;affichage retour arriere
updeol6:
	call	conout			;affichage console
	loop	updeol6			;jusqu'au retour a la position d'entree
updeol7:
	ret

; Effacement ligne
	align	16
clrline:
	mov	ebx,buff		;pointeur tampon
	mov	ecx,endlin		;fin de ligne
	mov	endlin,ebx		;retour en debut de ligne
	sub	ecx,ebx			;caracteres ligne
	mov	byte ptr [ebx],0	;pour repetition
	jecxz	clrline2		;vide
	push	ecx
	mov	al,' '			;effacement caracteres
clrline1:
	call	conout			;affichage console
	loop	clrline1
	pop	ecx
	jmp	updeol5			;recule curseur
clrline2:
	ret

;ajout ligne dans historique lignes
;entree: ESI->ligne editee
;	 EBX->fin de ligne
	align	16
addlinebuf:
	cmp	esi,ebx			;ligne vide ?
	jae	short adl_ret		;oui, ignore
	cmp	inbuf_count,0		;ligne entree presente ?
	je	short adl_end		;non, ajout a la fin
	mov	eax,inbuf_current
	cmp	eax,inbuf_count		;fin tampon ?
	jb	short adl_line		;non, test ligne courante
	mov	eax,inbuf_count
	dec	eax			;derniere ligne
adl_line:
	mov	ecx,maxbuf
	mul	ecx
	mov	edi,InputBuffer
	push	esi
	add	edi,eax			;pointeur entree courante
	mov	ecx,maxbuf
adl_cmp:
	lodsb
	cmp	al,[edi]		;ligne modifiee ?
	jne	short adl_upper		;peut etre, test minuscule/majuscule
adl_cont:
	inc	edi
	cmp	esi,ebx			;fin de ligne editee ?
	loopne	adl_cmp			;non
	jecxz	short adl_ret_pop	;lignes identiques, ignore
	cmp	byte ptr [edi],0	;fin de ligne courante ?
	jne	short adl_end_pop	;non, lignes differentes
adl_ret_pop:
	pop	esi
adl_ret:
	ret
adl_upper:
	cmp	al,'A'			;majuscule ?
	jb	short adl_end_pop	;non, ligne modifiee
	cmp	al,'Z'
	ja	short adl_lower		;non, test minuscule
	or	al,20h			;transforme en minuscule
	cmp	al,[edi]		;ligne modifiee ?
	jne	short adl_end_pop	;oui
	jmp	adl_cont
adl_lower:
	cmp	al,'a'			;minuscule ?
	jb	short adl_end_pop	;non, ligne modifiee
	cmp	al,'z'
	ja	short adl_end_pop	;non, ligne modifiee
	and	al,0DFh			;transforme en majuscule
	cmp	al,[edi]		;ligne modifiee ?
	je	adl_cont		;non, continue la verification
adl_end_pop:
	pop	esi
adl_end:
	mov	eax,inbuf_count
	cmp	eax,maxinput		;tampon plein ?
	jb	short adl_inc		;non
	mov	edi,InputBuffer
	push	esi
	mov	esi,edi
	mov	ecx,maxbuf*(maxinput-1)
	add	esi,maxbuf
	rep	movsb			;decalage d'une ligne
	pop	esi
adl_add:
	mov	eax,inbuf_count
	mov	inbuf_current,eax
	mov	ecx,maxbuf
	dec	eax
	mul	ecx
	mov	edi,InputBuffer
	push	esi
	add	edi,eax			;pointeur derniere entree
	mov	ecx,maxbuf
alb_cpy:
	lodsb
	mov	[edi],al		;copie dans tampon
	inc	edi
	cmp	esi,ebx			;fin de ligne editee ?
	loopne	alb_cpy			;non
	jecxz	adl_ret_pop		;longueur maximale
	mov	byte ptr [edi],0	;marque de fin
	jmp	adl_ret_pop
adl_inc:
	inc	inbuf_count
	jmp	adl_add

;ligne precedente historique
;retour: ESI->ligne precedente historique
	align	16
prevlinebuf:
	cmp	inbuf_count,0		;tampon vide ?
	je	short plb_empty		;oui, retourne ligne vide
	cmp	inbuf_current,0		;debut tampon ?
	je	short plb_ptr		;oui
	dec	inbuf_current		;recule d'une ligne
plb_ptr:
	mov	eax,maxbuf
	mul	inbuf_current
	mov	esi,InputBuffer
	add	esi,eax			;pointeur entree courante
plb_ret:
	ret
plb_empty:
	mov	esi,offset empty_line	;pointeur ligne vide
	jmp	plb_ret

;ligne suivante historique
;retour: ESI->ligne suivante historique
	align	16
nextlinebuf:
	cmp	inbuf_count,0		;tampon vide ?
	je	plb_empty		;oui, retourne ligne vide
	mov	eax,inbuf_current	;ligne courante
	cmp	eax,inbuf_count		;dans tampon ?
	jae	short nlb_last		;non, retourne derniere ligne
	inc	eax			;ligne suivante
	mov	inbuf_current,eax
	cmp	eax,inbuf_count		;fin tampon ?
	jb	plb_ptr			;non
nlb_last:
	mov	eax,inbuf_count
	dec	eax
	mov	inbuf_current,eax
	jmp	plb_ptr

;activation commandes SBASIC dans le menu
	align	16
enablemenu:
	push	eax
	push	ecx
	push	edx
	call	EnableCmdMenu		;appel fonction C
ena_dis_menu_ret:
	pop	edx
	pop	ecx
	pop	eax
	ret

;desactivation commandes SBASIC dans le menu
	align	16
disablemenu:
	push	eax
	push	ecx
	push	edx
	call	DisableCmdMenu		;appel fonction C
	jmp	ena_dis_menu_ret

	end