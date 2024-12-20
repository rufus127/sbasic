	page	,132
	name	console

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
	public	setcursor,getcursor
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
inbuf_count	db	?		;nombre lignes entree
inbuf_current	db	?		;index ligne entree courante
prtesc		db	?		;indicateur echappement impression

	.code
	extrn	RedirConsoleOn:near
	extrn	RedirConsoleOff:near
	extrn	CheckKey:near
	extrn	SetControlC:near
	extrn	GetKey:near
	extrn	EditLine:near
	extrn	PutChar:near
	extrn	MoveCursor:near
	extrn	CursorPos:near
	extrn	SetTxtWindow:near
	extrn	SetTxtColor:near
	extrn	ResizeTxt:near
	extrn	SetGrColor:near
	extrn	OpenPrintMenu:near
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
	mov	al,break_mask		;masque BREAK 
	and	al,breakflg		;AND indicateur BREAK
	or	intflags,al		;indique interruption BREAK
	ret

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

;Sortie BASIC
endbasic:
	xor	al,al			;retour FALSE
	jmp	exitbasic		;sortie BASIC

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
;	 ZF=0 (pas de sortie BASIC)
	align	16
conin:
	push	ecx
	push	edx
	push	eax			;tampon caractere
	push	esp			;pointeur vers tampon caractere
	call	GetKey			;appel fonction C
	add	esp,1*4
	pop	eax			;caractere dans AL
	pop	edx
	pop	ecx
	and	al,al			;ZF=0
	ret

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
	clc				;pas de refus
	ret

;OK fermeture fenetre BASIC
closebasic:
	ret				;NOP

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
	call	OpenPrintMenu		;appel fonction C
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
	xor	eax,eax
	dec	eax			;TRUE
	jmp	short edlin1

; Edition nouvelle ligne
; Entree: ESI->debut tampon
;	  EDI->fin tampon
; Retour: AL=dernier caractere entree si CTRLC
;	  EBX->fin ligne
	align	16
edlin:
	xor	eax,eax			;FALSE
edlin1:
	push	ecx
	push	edx
	push	eax			;tampon nombre caracteres
	push	esp			;pointeur vers tampon caractere
	push	eax			;ReEdit
	push	edi			;EndBuffer
	push	esi			;startBuffer
	call	EditLine		;appel fonction C
	add	esp,4*4
	pop	eax			;nombre caracteres
	pop	edx
	pop	ecx
	cmp	eax,2			;au moins CR et LF recus ?
	mov	ebx,esi			;debut ligne
	mov	colm,0			;curseur en debut de ligne
	jb	short edlin2		;non, Ctrl-C
	sub	eax,2			;ignore CR et LF
	add	ebx,eax			;pointeur fin de ligne
	xor	al,al			;pas CTRLC
	ret
edlin2:
	mov	al,cr
	call	conout			;affichage CR
	mov	al,lf
	call	conout			;affichage LF
	mov	al,ctrlc		;retour CTRLC
	ret
	end