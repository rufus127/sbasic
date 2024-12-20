	page	,132
	name	edit

	public	edit
	public	editx
	public	cursor
	public	inbuf
	public	inbufd

	.model	flat,c

	include sbasic.inc

	.data
;Variables entree ligne
ilbuf		db	maxbuf dup (?)	;tampon entree ligne

	.code
	extrn	ready:near
	extrn	ready5:near
	extrn	brkon:near,brkoff:near
	extrn	compcmd:near
	extrn	tstned:near
	extrn	stop1:near
	extrn	exec:near
	extrn	fndlinq:near
	extrn	decode:near
	extrn	rpter:near
	extrn	synerr:near
	extrn	exp:near
	extrn	avar:near
	extrn	evlbyt:near,pulbyt:near
	extrn	comtok:near
	extrn	setcursor:near
	extrn	getcursor:near
	extrn	chstv:near
	extrn	edlin:near,redlin:near
	extrn	inch:near

; EDIT (commande)
	align	16
edit:
	call	tstned			;test edition source autorisee
	call	compcmd			;compile ligne de commande
	skipst				;saut espace et token
	cmp	al,k_cr			;fin de ligne ?
	je	short edit1		;oui, edition ligne courante
	cmp	al,tok_mark+conbit+intbit ;constante entiere ?
	jne	edit4			;non, erreur
	mov	eax,[ebp+1]		;numero de ligne
	mov	linum,eax		;range
edit1:
	mov	eax,linum		;numero de ligne
	test	eax,eax			;valide ?
	jle	short edit4		;non
	call	fndlinq			;recherche line
	jnz	short edit3		;non, trouvee
	add	ebx,size line		;saut entete ligne
	mov	listcolflg,0		;pas de couleur affichage
	xor	ecx,ecx			;pas de minimum de caracteres pour affichage numero de ligne
	call	decode			;decode ligne
	mov	esi,offset buffer	;debut tampon
	mov	edi,offset buffer+maxbuf-1 ;fin tampon
	call	brkoff			;desactive BREAK par Control-C 
	call	redlin			;re-edition ligne
	mov	byte ptr [ebx],cr	;marque fin de ligne
	call	brkon			;reactive BREAK par Control-C
	cmp	al,ctrlc		;CtrlC ?
	je	short edit2		;oui
	mov	inptr,offset buffer
	jmp	ready5			;prise en compte comme nouvelle ligne de commande
edit2:
	jmp	ready			;ignore la ligne
edit3:
	mov	al,err_edit_empty	;ligne non trouvee
	jmp	rpter
edit4:
	mov	al,err_edit_line	;numero de ligne invalide
	jmp	rpter

; EDIT (instruction)
	align	16
editx:
	inc	ebp			;mange EDIT
	skipst				;saut espace et token
	call	chstv			;test variable chaine
	call	avar			;adresse variable
	test	al,arrbit		;tableau ?
	jnz	short editx5		;non, erreur
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short editx5		;oui, erreur
	mov	eax,[esi].strg.str_len	;longueur chaine
	and	eax,07FFFFFFFh		;raz indicateur FIELD
	jz	short editx3		;longueur nulle, pas d'edition
	cmp	eax,maxbuf		;valide ?
	ja	short editx4		;non
	mov	edi,[esi].strg.str_addr	;adresse chaine
	mov	esi,edi
	add	edi,eax			;fin de chaine
	push	ebp
	push	edi
	call	brkoff			;desactive BREAK par Control-C 
	call	redlin			;re-edition ligne
	pop	edi			;pointeur fin de chaine
editx1:
	cmp	ebx,edi			;fin de chaine ?
	jae	editx2			;oui
	mov	byte ptr [ebx],' '	;complete avec des espaces
	inc	ebx
	jmp	editx1
editx2:
	call	brkon			;reactive BREAK par Control-C
	pop	ebp
	skipst				;saut espace et token
editx3:
	jmp	exec			;fin execution ligne
editx4:
	mov	al,err_str_len		;chaine trop longuer
	jmp	rpter
editx5:
	jmp	synerr

; CURSOR
	align	16
cursor:
	inc	ebp			;mange CURSOR
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short cursor1		;pas d'expression
	call	pulbyt			;POP octet
	push	eax			;ligne
	call	comtok			;mange ,
	call	evlbyt			;evaluation octet
	pop	ebx
	test	eax,eax			;colonne nulle ?
	jz	short cursor2		;oui, erreur
	dec	eax
	call	setcursor		;positionne curseur ecran
	jc	short cursor2		;erreur
	mov	colm,al			;maj colonne ecran
	jmp	exec			;fin execution ligne
cursor1:
	call	getcursor		;recuperation position curseur
	movzx	ebx,ah
	movzx	eax,al			;ligne 0-24
	inc	eax			;colonne 1-80
	mov	peny,ebx
	mov	penx,eax
	jmp	exec			;fin execution ligne
cursor2:
	mov	al,err_seek		;position invalide
	jmp	rpter

; Entree ligne
; Retour: INPT->tampon
	align	16
inbuf:
	test	filswi,0FFh		;entree depuis fichier ?
	jz	short inbuf1		;non
	mov	eax,fcbin		;FCB fichier entree
	test	eax,eax			;ouvert ?
	jnz	short inbuf2		;oui
inbuf1:
	mov	eax,iport		;port d'entree
	test	eax,eax			;port 0 ?
	jz	short inbuf3		;oui
inbuf2:
	call	inbufd			;entree ligne depuis fichier
	jnc	short inbuf4		;OK
	mov	inflg,0			;raz indicateur INPUT
	jmp	rpter
inbuf3:
	mov	esi,offset ilbuf	;debut tampon
	mov	edi,offset ilbuf+maxbuf-1 ;fin tampon
	mov	inptr,esi		;range pointeur caractere entree
	call	brkoff			;desactive BREAK par Control-C
	call	edlin			;edition ligne
	mov	byte ptr [ebx],cr	;marque fin de ligne
	call	brkon			;reactive BREAK par Control-C
	cmp	al,ctrlc		;CtrlC ?
	je	short inbuf5		;interrupt
inbuf4:
	ret
inbuf5:
	test	inflg,0FFh		;INPUT ?
	jz	ready			;non, ignore l'entree
	mov	ebp,curpc		;pointeur ligne courante
	add	ebp,size line		;saut entete ligne
	mov	esp,execsp		;reinitialisation pile
	jmp	stop1			;STOP

; Lecture ligne depuis fichier
; Retour: INPT->tampon
;	  CF et AL=code si erreur
	align	16
inbufd:
	mov	ebx,offset buffer	;debut tampon
	mov	inptr,ebx		;range pointeur caractere entree
inbufd1:
	call	inch			;lecture caractere
	jc	short inbufd3		;fin de fichier
	test	al,al			;caractere nul ?
	jz	inbufd1			;oui, ignore
	cmp	al,ctrlz		;CtrlZ ?
	je	short inbufd4		;oui, erreur
	cmp	al,cr			;fin de ligne ?
	je	inbufd1			;oui, ignore
	cmp	al,lf			;saut de ligne ?
	je	short inbufd2		;oui
	mov	[ebx],al		;range caractere
	inc	ebx
	cmp	ebx,offset buffer+maxbuf-1 ;place pour fin de ligne ?
	jb	inbufd1			;oui
inbufd2:
	mov	byte ptr [ebx],cr	;fin de ligne
	clc				;retour OK
inbufd3:
	ret
inbufd4:
	mov	al,err_eof		;fin de fichier
	stc				;retour erreur
	ret

	end