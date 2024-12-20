	page	,132
	name	file

	public	open
	public	close
	public	kill
	public	rename
	public	get,put
	public	reset
	public	port
	public	unlock,lockx
	public	chd
	public	calllib
	public	selchn,inchn,outchn
	public	wfopenread
	public	wfopenwrite
	public	wfclose
	public	wfsize
	public	wfread,wfwrite
	public	readtmp,writetmp
	public	setfls
	public	setflx
	public	clsall
	public	inch
	public	outch
	public	dimchn,fldchn
	public	setvrt
	public	getrec
	public	putrec
	public	evalrn

	.model	flat,c

	include sbasic.inc

	.data
;Variables fichier
saveesp		dd	?		;sauvegarde ESP appel point d'entree
workfcb		fcb	<>		;FCB fichier de travail
opent		db	?		;type ouverture

	.code
	extrn	exec:near
	extrn	consolon:near,consoloff:near
	extrn	conin:near,conout:near,prnout:near
	extrn	fread:near,fwrite:near,fkill:near,frename:near
	extrn	fopen:near,fclose:near,fsize:near,fcreate:near,fseek:near
	extrn	fchd:near,flock:near,funlock:near
	extrn	libload:near,libfree:near,procaddress:near
	extrn	sbmemalloc:near,sbmemfree:near,sbprintstr:near
	extrn	eval:near,exp:near
	extrn	pshpara:near,avar:near
	extrn	strcnt:near
	extrn	strtox:near
	extrn	evlbyt:near,evlint:near,pulint:near
	extrn	allocds:near,freeds:near
	extrn	comtok:near
	extrn	synerr:near
	extrn	rpter:near
	extrn	evluint:near

; Interface call-back
sbasic_util	label	dword
	dd	1			;version 1
	dd	sbu_len			;taille interface
	dd	sbmemalloc		;allocation memoire
	dd	sbmemfree		;liberation memoire
	dd	sbprintstr		;affichage chaine de caracteres
sbu_len	equ	$-sbasic_util

; OPEN
	align	16
open:
	inc	ebp			;mange OPEN
	mov	opent,opn_rw		;ouverture en lecture/ecriture par defaut
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short open5		;non
	cmp	al,k_append		;APPEND ?
	jne	short open1		;non
	mov	opent,opn_apd		;acces en mode ajout
	jmp	short open4
opener:
	jmp	synerr			;erreur de syntaxe
open1:
	cmp	al,k_new		;NEW ?
	jne	short open3		;non
	mov	opent,opn_w		;acces en ecriture
	jmp	short open4
open2:
	cmp	al,k_library		;LIBRARY ?
	jne	short open5		;non
	inc	ebp			;mange LIBRARY
	mov	opent,opn_lib		;acces librairie
	mov	al,ext_dll		;extension .DLL par defaut
	jmp	short open6
open3:
	cmp	al,k_old		;OLD ?
	jne	open2			;non
	mov	opent,opn_r		;acces en lecture
open4:
	inc	ebp			;mange APPEND, NEW ou OLD
open5:
	mov	al,ext_dat		;extension .DAT par defaut
open6:
	call	setfls			;evaluation nom de fichier
	skipst				;saut espace et token
	cmp	al,k_as			;AS ?
	jne	opener			;non
	inc	ebp			;mange AS
	call	getchn			;evaluation canal
	lea	ebx,filtab[eax*4]	;entree table des fichiers
	cmp	dword ptr [ebx],0	;FCB alloue ?
	jne	open18			;oui, fichier deja ouvert
	push	ebx
	mov	eax,size fcb
	call	allocds			;allocation memoire
	mov	eax,ebx
	pop	ebx
	mov	[ebx],eax		;adresse FCB dans table
	mov	dword ptr [ebx+numfil*4],0 ;non virtuel
	mov	edi,eax
	push	edi
	xor	eax,eax
	mov	ecx,(size fcb)/4
	rep	stosd
	pop	esi
	cmp	opent,opn_rw		;acces en lecture/ecriture
	jne	short open13		;non, pas de longueur
	mov	[esi].fcb.fcb_lockhigh,-1 ;pas de verou
	mov	eax,defrec		;longueur enregistrement par defaut
	mov	[esi].fcb.fcb_cntlen,eax
	skipst				;saut espace et token
	cmp	al,k_hashtag		;# ?
	jne	short open7		;non
	inc	ebp			;mange #
	skipst				;saut espace et token
open7:
	test	al,al			;mot cle ?
	js	short open9		;non, evalue longueur
	cmp	al,k_len		;LEN ?
	je	short open8		;oui, evalue longueur
	cmp	al,k_record		;RECORD ?
	jne	short open10		;non, longueur par defaut
open8:
	inc	ebp			;mange LEN
open9:
	push	esi
	push	ebx
	call	evalrn			;evalue longueur
	pop	ebx
	pop	esi
	mov	[esi].fcb.fcb_cntlen,eax ;range longueur enregistrement
open10:
	mov	[esi].fcb.fcb_opntyp,opn_rw ;ouverture en lecture/ecriture
	call	openfile		;ouverture fichier existant
	jnc	short open12		;ok
	call	createfile		;creation fichier
	jnc	short open12		;ok
open11:
	call	openerr			;erreur ouverture fichier
	xor	ebx,ebx			;handle fichier nul
open12:
	mov	[esi].fcb.fcb_handle,ebx ;maj handle
	jmp	exec			;fin execution ligne
open13:
	cmp	opent,opn_w		;acces en ecriture ?
	je	short open15		;oui
	cmp	opent,opn_r		;acces en lecture ?
	je	short open14		;oui
	cmp	opent,opn_lib		;acces librairie ?
	je	short open17		;oui
	call	openappend		;ouverture en ajout
	jc	open11			;erreur
	mov	opent,opn_w		;indique acces en ecriture
	jmp	short open16
open14:
	call	openread		;ouverture fichier en lecture
	jnc	short open16		;ok
	jmp	open11			;erreur
open15:
	call	openwrite		;ouverture en ecriture
	jc	open11			;erreur
open16:
	mov	eax,buflen		;longueur tampon lecture ou ecriture
	call	allocds			;allocation memoire
	mov	[esi].fcb.fcb_bufadr,ebx ;adresse tampon
	mov	[esi].fcb.fcb_posrec,ebx ;debut tampon
	jmp	exec			;fin execution ligne
open17:
	mov	[esi].fcb.fcb_opntyp,opn_lib ;indique ouverture librairie
	mov	edx,offset pathbuf	;nom de fichier
	call	libload			;chargement librairie
	jnc	open12			;ok
	jmp	open11			;erreur
open18:
	mov	al,err_alrdy_open	;fichier deja ouvert
	jmp	rpter

; CLOSE
	align	16
close:
	inc	ebp			;mange CLOSE
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short close3		;pas d'expression, ferme tous les fichiers
close1:
	call	pulint			;POP entier
	mov	eax,r0i
	call	getchn1			;fin evaluation numero de canal
	call	closechn		;fermeture canal
	call	exp			;evaluation expression
	jne	close1
close2:
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
close3:
	call	clsall			;fermeture tous fichiers
	jmp	close2

; KILL
	align	16
kill:
	inc	ebp			;mange KILL
	mov	al,ext_bas		;extension .BAS par defaut
	call	setfls			;evaluation nom de fichier
	mov	edx,offset pathbuf	;tampon de travail
	call	fkill			;suppression fichier
	jc	short filerr		;erreur
	jmp	exec			;fin execution ligne
filerr:
	jmp	rpter

; GET
	align	16
get:
	inc	ebp			;mange GET
	call	setrecord		;evaluation numeros canal et enregistrement
	call	getrec			;lecture enregistrement
	jmp	exec			;fin execution ligne

; PUT
	align	16
put:
	inc	ebp			;mange PUT
	call	setrecord		;evaluation numeros canal et enregistrement
	call	putrec			;ecriture enregistrement
	jmp	exec			;fin execution ligne

; RENAME
	align	16
rename:
	inc	ebp			;mange RENAME
	mov	al,ext_bas		;extension .BAS par defaut
	call	setfls			;evaluation nom de fichier
	mov	esi,offset pathbuf	;tampon nom de fichier
	sub	ebx,esi			;longueur nom
	mov	ecx,ebx
	inc	ecx
	mov	edi,offset linbuf	;tampon
	rep	movsb			;recopie
	call	comtok			;mange ,
	mov	al,ext_bas		;extension .BAS par defaut
	call	setfls			;evaluation nom de fichier
	mov	edi,offset pathbuf
	mov	edx,offset linbuf
	call	frename			;renomme non de fichier dans LINBUF par nom dans WORKBUF
	jc	filerr			;erreur
	jmp	exec			;fin execution ligne

; RESET
	align	16
reset:
	inc	ebp			;mange RESET
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; PORT
	align	16
port:
	inc	ebp			;mange PORT
	call	evlbyt			;evaluation octet
	cmp	al,maxport		;numero de port valide ?
	jae	port4			;non erreur
	movzx	eax,al
	push	eax
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	port5			;non
	inc	ebp			;mange ,
	mov	al,ext_none		;pas d'extension par defaut
	call	setfls			;evaluation nom de fichier
	cmp	ebx,offset pathbuf	;nom de fichier vide ?
	je	port7			;oui, fermeture
	pop	ebx
	test	ebx,ebx			;port 0 ?
	jz	short port4		;oui, erreur
	cmp	ebx,10			;port entree ?
	jae	short port2		;oui
	mov	colm[ebx],0		;raz compteur colonne
	shl	ebx,2			;*4
	xor	eax,eax
	xchg	eax,oport[ebx]		;handle port et RAZ
	push	ebx
	test	eax,eax			;port ouvert ?
	jz	short port1		;non
	mov	ebx,eax
	call	closefilex		;fermeture handle
	jc	short port4		;erreur
port1:
	call	wfopenwrite		;ouverture en ecriture fichier de travail
	jc	short port4		;erreur
	mov	eax,ebx
	pop	ebx
	mov	oport[ebx],eax		;range handle
	shr	ebx,2
	mov	oport,ebx		;port sortie
	jmp	port12
port2:
	je	short port4		;port 10, erreur
	sub	ebx,10			;offset port entree
	shl	ebx,2			;*4
	xor	eax,eax
	xchg	eax,iport[ebx]		;handle port et RAZ
	push	ebx
	test	eax,eax			;port ouvert ?
	jz	short port3		;non
	mov	ebx,eax
	call	closefilex		;fermeture handle
	jc	short port4		;erreur
port3:
	call	wfopenread		;ouverture en lecture fichier de travail
	jc	short port4		;erreur
	mov	eax,ebx
	pop	ebx
	mov	iport[ebx],eax		;range handle
	mov	iport,eax		;handle entree
	jmp	port12
port4:
	mov	al,err_port_num		;numero port invalide
	jmp	rpter
port5:
	pop	ebx
	cmp	ebx,10			;port entree ?
	ja	port6			;oui
	mov	oport,ebx		;selection port sortie
	jmp	short port12
port6:
	shl	ebx,2			;*4
	mov	eax,oport[ebx]		;handle
	mov	iport,eax		;selectionne handle entree
	jmp	short port12
port7:
	pop	ebx
	shl	ebx,2			;numero port
	jz	short port12		;port 0, ignore
	cmp	ebx,4*10		;port entree ?
	jae	short port9		;oui
	mov	eax,oport		;port de sortie courant
	shl	eax,2			;*4
	cmp	eax,ebx			;identique au port specifie ?
	jne	short port8		;non 
	mov	oport,0			;plus de fichier de sortie
port8:
	xor	eax,eax
	xchg	eax,oport[ebx]		;handle fichier de sortie
	test	eax,eax			;port ouvert ?
	jz	short port12		;non
	jmp	short port11
port9:
	sub	ebx,4*10		;offset port entree
	je	short port12		;port 0, ignore
	xor	eax,eax
	xchg	eax,iport[ebx]		;handle port et RAZ
	cmp	eax,iport		;identique au handle entree courant 
	jne	short port10		;non
	mov	iport,0			;plus de fichier de sortie
port10:
	test	eax,eax			;port ouvert ?
	jz	short port12		;non
port11:
	mov	ebx,eax			;handle fichier
	call	closefilex		;fermeture fichier
	jc	port4			;erreur
port12:
	xor	eax,eax
	mov	workfcb.fcb.fcb_handle,eax ;raz handle FCB fichier de travail
	mov	filswi,al		;pas de fichier d'entree
	mov	filswo,al		;pas de fichier de sortie
	jmp	exec			;fin execution ligne

; UNLOCK
unlock:
	inc	ebp			;mange UNLOCK
	call	evalchn			;evaluation numero de canal
	call	unlockfile		;deverouillage fichier courant
	jmp	exec			;fin execution ligne

; LOCK
	align	16
lockx:
	inc	ebp			;mange LOCK
	call	evalchn			;evaluation numero de canal
	push	esi
	call	unlockfile		;deverouillage fichier courant
	pop	esi
	push	esi
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	xor	ecx,ecx			;debut fichier
	xor	edx,edx
	mov	edi,0FFFFFFFFh		;longueur maximale
	mov	esi,7FFFFFFFh
	call	flock			;verouillage
	pop	esi
	jc	filerr			;erreur
	mov	[esi].fcb.fcb_locklow,0	;indique verouillage fichier complet
	mov	[esi].fcb.fcb_lockhigh,080000000h
	jmp	exec			;fin execution ligne

; CHD
	align	16
chd:
	inc	ebp			;mange CHD
	mov	al,ext_none		;pas d'extension pas defaut
	call	setfls			;evaluation nom de fichier
	mov	edx,offset pathbuf	;nom de repertoire
	call	fchd			;changement repertoire courant
	jc	filerr			;erreur
	jmp	exec			;fin execution ligne

; CALL #
calllib:
	inc	ebp			;mange #
	call	getchn			;evaluation canal
	jz	calllib8		;canal 0, erreur
	call	getfcbv			;FCB canal
	cmp	[esi].fcb.fcb_opntyp,opn_lib ;ouvert en librairie ?
	jne	error_status		;non, erreur
	push	[esi].fcb.fcb_handle	;handle librairie
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	calllib3		;non, erreur
	call	strcnt			;longueur chaine
	cmp	eax,maxpath		;valide ?
	jae	calllib3		;non, erreur
	mov	ebx,offset pathbuf	;chemin fichier
	push	ebx
	call	strtox			;copie chaine dans tampon
	mov	byte ptr [ebx],0	;fin de nom
	pop	edx
	pop	ebx
	call	procaddress		;point d'entree fonction
	jc	calllib9		;erreur
	push	ebx
	skipst				;saut espace et token
	cmp	al,k_lbracket		;( ?
	jne	short calllib3		;non, erreur
	inc	ebp			;mange (
	skipst				;saut espace et token
	cmp	al,k_rbracket		;) ?
	je	short calllib5		;oui, pas d'argument
calllib1:
	test	al,al			;mot cle ?
	jns	short calllib3		;oui, erreur
	test	al,conbit+linbit+labbit	;variable ?
	jnz	short calllib3		;non, erreur
	call	avar			;adresse variable
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short calllib3		;oui, erreur
	test	al,arrbit		;tableau ?
	jz	short calllib2		;non
	test	[esi].array.a_virt,0FFh	;tableau virtuel ?
	jnz	short calllib3		;oui, erreur
calllib2:
	call	pshpara			;PUSH adresse parametre
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short calllib4		;non, fin arguments
	inc	ebp			;mange ,
	skipst				;saut espace et token
	jmp	calllib1		;oui, continue
calllib3:
	jmp	synerr			;erreur syntaxe
calllib4:
	cmp	al,k_rbracket		;) ?
	jne	calllib3		;non, erreur
calllib5:
	inc	ebp			;mange )
	pop	ebx
	skipst				;saut espace et token
	call	consolon		;activation redirection console
	push	ebp			;precaution
	mov	saveesp,esp		;sauvegarde ESP
	mov	esi,atos		;pointeur pile arithmetique
	xor	ecx,ecx			;compteur parametres
calllib6:
	cmp	esi,offset astack	;debut pile arithmetique ?
	jbe	short calllib7		;oui
	sub	esi,size calla		;parametre precedent
	inc	ecx			;un parametre de plus
	movzx	eax,[esi].para.p_type	;type variable
	push	[esi].para.p_addr	;adresse variable dans la pile
	push	eax			;type variable dans la pile
	jmp	calllib6		;pour tous les parametres
calllib7:
	push	offset sbasic_util	;interface call-back
	push	ecx			;nombre de parametres
	call	ebx			;appel point d'entree
	mov	esp,saveesp		;restauration ESP
	test	al,al			;erreur ?
	pop	ebp
	pushfd
	push	eax
	call	consoloff		;desactivation redirection console
	pop	eax
	popfd
	jnz	short calllib9		;oui
	jmp	exec			;fin execution ligne
calllib8:
	mov	al,err_channel		;numero de canal invalide
calllib9:
	jmp	rpter

; Sortie caractere
; Entree: AL=caractere
	align	16
outch:
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	eax
	test	filswo,0FFh		;sortie sur fichier ?
	jz	short outch1		;non
	mov	esi,fcbout		;FCB fichier sortie
	test	esi,esi			;ouvert ?
	je	short outch1		;non, ignore
	call	putoct			;ecriture caractere
	jc	short outch5		;erreur
	jmp	short outch4		;retour
outch1:
	mov	ebx,oport		;port de sortie ?
	test	ebx,ebx			;defini ?
	jz	short outch2		;non
	inc	colm[ebx]		;maj compteur colonne
	shl	ebx,2			;x4
	mov	ebx,oport[ebx]		;handle fichier
	push	eax			;caractere dans pile
	mov	edx,esp			;pointeur caractere
	mov	ecx,1			;1 octet
	call	fwrite			;ecriture fichier
	pop	eax
	jmp	short outch4		;retour
outch2:
	cmp	al,tab
	je	short outch6
	inc	colm			;maj compteur colonne
	call	conout			;affichage console
outch3:
	test	prtflg,0FFh		;echo sur imprimante ?
	jz	short outch4		;non
	pop	eax
	push	eax
	call	prnout			;impression caractere
outch4:
	pop	eax
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret
outch5:
	push	eax
	call	closefile		;fermeture fichier
	pop	eax			;code d'erreur
	mov	[esi].fcb.fcb_opntyp,0	;indique fichier ferme
	jmp	rpter
outch6:
	mov	al,' '			;espace
outch7:
	inc	colm			;maj compteur colonne
	call	conout			;affichage console
	test	colm,111b		;colonne multiple de 8 ?
	jnz	outch7			;non, continue
	mov	al,tab			;restaure caractere
	jmp	outch3

; Entree caractere
; Retour: AL=caractere
;	  CF et AL=code si erreur
	align	16
inch:
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	test	filswi,0FFh		;entree fichier ?
	jz	short inch1		;non
	mov	esi,fcbin		;FCB fichier entree
	test	esi,esi			;ouvert ?
	jz	short inch1		;non
	call	getoct			;lecture caratere
	jmp	short inch4		;retour
inch1:
	mov	ebx,iport		;port d'entree ?
	test	ebx,ebx			;defini ?
	jz	short inch2		;non
	push	eax			;tampon caractere
	mov	edx,esp			;pointeur tampon
	mov	ecx,1			;1 octet
	call	fread			;lecture fichier
	jc	short inch5		;erreur
	mov	ecx,eax			;nombre octets lu
	pop	eax			;caractere
	jecxz	short inch6		;fin de fichier
	jmp	short inch3		;retour
inch2:
	and	intflags,not break_mask ;raz indicateur interruption BREAK
	call	conin			;lecture console
inch3:
	clc				;pas d'erreur
inch4:
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret
inch5:
	pop	ecx			;libere tampon
	jmp	inch4			;retour
inch6:
	mov	al,err_eof		;fin de fichier
	stc				;indique erreur
	jmp	inch4			;retour

; Lecture caractere fichier
; Entree: ESI->FCB
; Retour: AL=caractere
;	  CF et AL=code si erreur
	align	16
getoct:
	cmp	[esi].fcb.fcb_opntyp,opn_r ;ouvert en lecture ?
	jne	short getputerr		;non, erreur
	mov	ecx,[esi].fcb.fcb_cntlen ;nombre de caracteres dans tampon
	jecxz	short getoct1		;vide
	dec	[esi].fcb.fcb_cntlen	;un caractere de moins
	mov	edi,[esi].fcb.fcb_posrec ;position tampon
	mov	al,[edi]		;lit caractere
	inc	[esi].fcb.fcb_posrec	;maj position tampon
	clc				;retour OK
	ret
getoct1:
	mov	eax,[esi].fcb.fcb_bufadr ;adresse tampon
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	mov	[esi].fcb.fcb_posrec,eax ;debut tampon
	mov	ecx,buflen		;longueur tampon
	mov	edx,eax
	call	fread			;lecture donnees suivantes
	jc	short getoct2		;erreur
	mov	[esi].fcb.fcb_cntlen,eax ;nombre d'octets lus
	test	eax,eax			;zero ?
	jnz	short getoct		;non, continue
	mov	al,err_eof		;fin de fichier
	stc				;erreur
getoct2:
	ret
getputerr:
	mov	al,err_open_mode	;erreur mode ouverture fichier
	jmp	rpter

; Ecriture caractere fichier
; Entree: ESI->FCB
;	  AL=caractere
; Retour: CF et AL=code si erreur
	align	16
putoct:
	cmp	[esi].fcb.fcb_opntyp,opn_w ;ouvert en ecriture ?
	jne	getputerr		;non, erreur
	cmp	[esi].fcb.fcb_cntlen,buflen ;tampon plein ?
	je	short putoct1		;oui, vidange
	inc	[esi].fcb.fcb_fcolm	;colonne suivante
	inc	[esi].fcb.fcb_cntlen	;un octet de plus
	mov	edi,[esi].fcb.fcb_posrec ;position tampon
	mov	[edi],al		;range caractere
	inc	[esi].fcb.fcb_posrec	;maj position tampon
	clc				;retour OK
	ret
putoct1:
	push	eax
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	mov	ecx,[esi].fcb.fcb_cntlen ;taille tampon
	mov	edx,[esi].fcb.fcb_bufadr ;adresse tampon
	call	fwrite			;ecriture donnees tampon
	jc	short putoct2		;erreur
	cmp	eax,[esi].fcb.fcb_cntlen ;tout ecrit ?
	mov	eax,[esi].fcb.fcb_bufadr
	mov	[esi].fcb.fcb_posrec,eax ;debut tampon
	mov	[esi].fcb.fcb_cntlen,0	;vide
	pop	eax
	je	short putoct		;oui, continue
	mov	al,err_disk_full	;disque plein
	stc				;erreur
	ret
putoct2:
	pop	ebx			;garde le code d'erreur
	ret

; Positionnement sur enregistrement fichier
; Entree: EAX=numero enregistrement
;	  ESI->FCBDIR
	align	16
dospos:
	push	eax
	mul	[esi].fcb.fcb_cntlen	;numero enregistrement * longueur enregistrement
	mov	ecx,edx
	mov	edx,eax
	mov	eax,[esi].fcb.fcb_lockhigh
	cmp	eax,080000000h		;fichier verouille ?
	je	short dopos3		;oui, pas de verouillage enregistrement
	test	eax,eax			;verouillage en cours ?
	js	short dopos2		;non
	cmp	eax,ecx			;deja verouille ?
	jne	short dopos1		;non
	cmp	edx,[esi].fcb.fcb_locklow
	je	short dopos3		;oui
dopos1:
	push	esi
	push	ecx
	push	edx
	call	dounlockf		;deverouillage courant
	pop	edx
	pop	ecx
	pop	esi
dopos2:
	test	[esi].fcb.fcb_opntyp,opn_fld ;FIELD specifie ?
	jz	short dopos3		;non, pas de verouillage
	push	esi
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	mov	edi,[esi].fcb.fcb_cntlen ;longueur enregistrement
	xor	esi,esi
	call	flock			;verouillage
	pop	esi
	jc	short dopos5		;erreur
	mov	[esi].fcb.fcb_locklow,edx ;nouveau verou
	mov	[esi].fcb.fcb_lockhigh,ecx
dopos3:
	pop	eax
	cmp	eax,[esi].fcb.fcb_posrec ;enregistrement courant ?
	je	short dopos4		;oui
	push	eax
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	xor	al,al			;positionnement absolu
	call	fseek			;offset ECX|EDX
	jc	short dopos5		;erreur
	pop	eax
dopos4:
	inc	eax			;avance enregistrement
	and	eax,7FFFFFFFh		;retour au debut si debordement
	mov	[esi].fcb.fcb_posrec,eax ;maj numero enregistrement
	ret
dopos5:
	jmp	rpter

; Lecture enregistrement
	align	16
getrec:
	push	edx
	push	ecx
	push	ebx
	mov	esi,fcbdir		;pointeur FCB acces directe
	mov	edx,[esi].fcb.fcb_bufadr ;adresse tampon
	mov	ecx,[esi].fcb.fcb_cntlen ;longueur enregistrement
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	call	fread			;lecture enregistrement
	jc	short getrec2		;erreur
	cmp	eax,[esi].fcb.fcb_cntlen ;tout lu ?
	jne	short getrec1		;non, erreur
	pop	ebx
	pop	ecx
	pop	edx
	ret
getrec1:
	mov	al,err_record_num	;enregistrement non trouve
getrec2:
	jmp	rpter

; Ecriture enregistrement
	align	16
putrec:
	push	edx
	push	ecx
	push	ebx
	mov	esi,fcbdir		;pointeur FCB acces directe
	mov	edx,[esi].fcb.fcb_bufadr ;adresse tampon
	mov	ecx,[esi].fcb.fcb_cntlen ;longueur enregistrement
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	call	fwrite			;ecriture enregistrement
	jc	short putrec2
	cmp	eax,[esi].fcb.fcb_cntlen ;tout ecrit ?
	jne	short putrec1		;non, erreur
	pop	ebx
	pop	ecx
	pop	edx
	ret
putrec1:
	mov	al,err_disk_full	;disque plein
putrec2:
	jmp	rpter

; Ouverture fichier de travail en lecture
	align	16
wfopenread:
	mov	esi,offset workfcb	;FCB fichier de travail	
	call	openread		;ouverture en lecture
	jc	openerr			;erreur
	mov	eax,offset pathbuf	;chemin fichier
	mov	[esi].fcb.fcb_bufadr,eax ;adresse tampon
	mov	[esi].fcb.fcb_posrec,eax ;debut tampon travail
	mov	fcbin,esi		;FCB entree
	mov	filswi,0FFh		;indique entree depuis fichier
	ret

; Ouverture fichier de travail en ecriture
	align	16
wfopenwrite:
	mov	esi,offset workfcb	;FCB fichier de travail	
	call	openwrite		;ouverture en ecriture
	jc	openerr			;erreur		
	mov	eax,offset pathbuf	;chemin fichier
	mov	[esi].fcb.fcb_bufadr,eax ;adresse tampon
	mov	[esi].fcb.fcb_posrec,eax ;debut tampon travail
	mov	fcbout,esi		;FCB sortie
	mov	filswo,0FFh		;indique sortie sur fichier
	ret

; Fermeture fichier de travail
	align	16
wfclose:
	mov	esi,offset workfcb	;FCB fichier de travail	
	call	closef			;fermeture fichier
	mov	[esi].fcb.fcb_opntyp,0	;indique fichier ferme
	mov	[esi].fcb.fcb_bufadr,0	;libere tampon travail
	ret

; Taille fichier de travail
	align	16
wfsize:
	mov	esi,offset workfcb	;FCB fichier de travail	
	mov	ebx,[esi].fcb.fcb_handle ;handle ficihier
	jmp	fsize			;taille fichier

; Lecture fichier de travail
; Entree: EBX->donnees
;	  ECX=longueur
	align	16
wfread:
	mov	edx,ebx
	mov	esi,offset workfcb	;FCB fichier de travail	
	mov	ebx,[esi].fcb.fcb_handle ;handle ficihier
	jmp	fread

; Ecriture fichier de travail
; Entree: EBX->donnees
;	  ECX=longueur
	align	16
wfwrite:
	mov	edx,ebx
	mov	esi,offset workfcb	;FCB fichier de travail	
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	jmp	fwrite

file_tmp	db	'S_B_A_S_.tmp',0

; Lecture programme a partir fichier temporaire
; Retour: CF si erreur
	align	16
readtmp:
	mov	edx,offset file_tmp
	mov	al,0			;ouverture fichier temporaire en lecture
	call	fopen			;ouverture fichier
	jc	short readtmp1		;erreur
	mov	edx,prog_base		;base programme
	mov	ecx,lcode		;longueur code
	call	fread			;lecture code
	jc	short readtmp2		;erreur
	mov	edx,symb_base		;base table symboles
	mov	ecx,lsymb		;longueur table symboles
	call	fread			;lecture table symboles
readtmp2:
	pushfd
	call	closefilex		;fermeture fichier temporaire
	mov	edx,offset file_tmp
	call	fkill			;supression fichier temporaire
	popfd
readtmp1:
	ret

; Ecriture programme dans fichier temporaire
; Retour: CF si erreur
	align	16
writetmp:
	mov	edx,offset file_tmp
	mov	al,1			;ouverture en ecriture
	call	fcreate			;ouverture fichier temporaire
	jc	short writetmp1		;erreur
	mov	edx,prog_base		;base programme
	mov	ecx,lcode		;longueur code
	call	fwrite			;ecriture code
	jc	short writetmp2		;erreur
	mov	edx,symb_base		;base table symboles
	mov	ecx,lsymb		;longueur table symboles
	call	fwrite			;ecriture table symboles
writetmp2:
	pushfd
	call	closefilex		;fermeture fichier temporaire
	popfd
writetmp1:
	ret

; Fermeture de tous les fichiers
	align	16
clsall:
	xor	eax,eax			;canal 0
clsal1:
	push	eax
	call	closechn		;fermeture canal
	pop	eax
	inc	eax			;canal suivant
	cmp	eax,numfil		;pour tous les canaux
	jb	clsal1
	ret

; Fermeture canal
; Entree: EAX=numero de canal
	align	16
closechn:
	lea	ebx,filtab[eax*4]	;entree table des fichiers
	mov	esi,[ebx]		;pointeur FCB
	test	esi,esi			;fichier ouvert ?
	jz	closechn6		;non, retour
	xor	eax,eax
	mov	dword ptr [ebx],0	;raz pointeur FCB
	push	esi
	cmp	[esi].fcb.fcb_opntyp,opn_rw ;ouverture en lecture ecriture ?
	jae	short closechn2		;oui
	cmp	[esi].fcb.fcb_opntyp,0	;ouvert OS ?
	je	short closechn1		;non
	call	closef			;fermeture fichier
	mov	ebx,[esi].fcb.fcb_bufadr ;adresse tampon
	mov	eax,buflen		;longueur tampon
	call	freeds			;liberation memoire tampon
closechn1:
	pop	ebx
	mov	eax,size fcb
	jmp	freeds			;liberation memoire FCB et retour
closechn2:
	cmp	[esi].fcb.fcb_opntyp,opn_lib ;ouverture librairie ?
	je	short closechn7		;oui
	mov	ebx,[ebx+4*numfil]	;tableau virtuel attache
	test	ebx,ebx			;defini ?
	jz	short closechn3		;non
	push	ebx
	movzx	eax,[ebx].array.a_dim	;nombre de dimensions
	mov	ebx,[ebx].array.a_addr	;adresse
	shl	eax,2			;x4
	sub	ebx,eax			;debut descripteur tableau virtuel
	add	eax,size vrta		;ajout entete tableau virtuel
	call	freeds			;liberation memoire
	pop	ebx
	xor	eax,eax
	mov	[ebx],eax		;raz adresse tableau virtuel
	jmp	short closechn4
closechn3:
	mov	ebx,[esi].fcb.fcb_bufadr ;adresse tampon enregistrement
	test	ebx,ebx			;alloue ?
	jz	short closechn4		;non
	mov	eax,[esi].fcb.fcb_cntlen ;longueur enregistrement
	call	freeds			;liberation memoire
closechn4:
	pop	esi
	push	esi			;restaure pointeur FCB
	call	closef			;fermeture fichier
closechn5:
	pop	ebx
	push	eax
	pushfd
	mov	eax,size fcb
	call	freeds			;liberation memoire FCB
	popfd
	pop	eax
	jc	short closechn9		;erreur fermeture
closechn6:
	ret
closechn7:
	mov	ebx,[esi].fcb.fcb_handle ;handle librairie
	test	ebx,ebx			;fichier ouvert ?
	jz	short closechn8	;non
	call	libfree			;liberation librairie
closechn8:
	mov	[esi].fcb.fcb_handle,0	;raz handle
	jmp	closechn5		;liberation FCB
closechn9:
	jmp	rpter

; Evaluation numeros canal et enregistrement
	align	16
setrecord:
	call	evalchn			;evaluation numero de canal
	jnz	error_status		;tableau virtuel
	test	[esi].fcb.fcb_opntyp,opn_fld ;FIELD specifie ?
	jz	short setrecord3	;non
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short setrecord1	;non
	cmp	al,k_record		;RECORD ?
	jne	short setrecord2	;non, enregistrement suivant
	inc	ebp			;mange RECORD
setrecord1:
	push	esi
	call	evalrn			;evaluation numero enregistrement
	pop	esi
	dec	eax			;base 0
	and	eax,7FFFFFFFh		;retour au debut si debordement
	jmp	dospos			;positionnement sur enregistement
setrecord2:
	mov	eax,[esi].fcb.fcb_posrec ;enregistrement courant
	jmp	dospos			;positionnement sur enregistement
setrecord3:
	mov	al,err_no_type		;FIELD non defini
	jmp	rpter

; Evaluation numero enregistrement
; Retour: EAX=numero enregistrement
	align	16
evalrn:
	call	evluint			;evaluation entier non signe
	mov	eax,r0i			;numero enregistrement
	test	eax,eax			;nul ?
	jz	short evalrn1		;oui, erreur
	ret
evalrn1:
	mov	al,err_record_num	;numero enregistrement invalide
	jmp	rpter

	align	4
tab_ext	label	dword
	db	'BAS',0
	db	'DAT',0
	db	'BAC',0
	db	'WAV',0
	db	'DLL',0

; Evaluation nom de fichier
; Entree: AL=type extension par defaut
; Sortie: EBX->fin de nom
	align	16
setfls:
	push	eax
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	short setfls7		;non, erreur
	call	strcnt			;longueur chaine
	cmp	eax,maxpath		;valide ?
	jae	short setfls7		;non, erreur
	and	eax,eax			;longueur nulle ?
	mov	ebx,offset pathbuf	;chemin fichier
	jz	short setfls4		;oui
	call	strtox			;copie chaine dans tampon
	mov	byte ptr [ebx],0	;fin de nom
	pop	eax
setflx:
; Entree avec tampon de travail deja garnis et EBX->fin de nom
	push	eax
	cmp	pathbuf+1,'.'		;separateur unite FLEX ?
	jne	short setfls1		;non
	mov	al,pathbuf		;numero unite
	sub	al,'0'
	cmp	al,9			;valide ?
	ja	short setfls1
	add	al,'A'			;unite DOS
	mov	pathbuf,al
	mov	pathbuf+1,':'
setfls1:
	push	ebx
setfls2:
	cmp	ebx,offset pathbuf	;debut tampon ?
	jbe	short setfls5		;oui, pas d'extension trouvee
	dec	ebx
	cmp	byte ptr [ebx],'\'	;debut de nom ?
	je	short setfls5		;oui, pas d'extention trouvee
	cmp	byte ptr [ebx],'.'	;separateur extension ?
	jne	setfls2			;non, continue a reculer
	pop	ebx			;garde l'extension
setfls3:
	pop	eax
	ret
setfls4:
	mov	byte ptr [ebx],0	;fin de nom
	jmp	setfls3			;chaine vide, pas d'extension
setfls5:
	pop	ebx			;fin nom
	pop	eax			;type extension par defaut
	cmp	al,ext_none		;pas de defaut ?
	je	short setfls6		;oui
	movzx	eax,al
	mov	byte ptr [ebx],'.'	;ajoute separateur extension
	mov	eax,tab_ext[eax*4]	;extension et fin de nom
	mov	[ebx+1],eax		;ajoute
	add	ebx,4			;fin de nom
setfls6:
	ret
setfls7:
	jmp	synerr

; Selection canal
	align	16
selchn:
	call	getchn1			;fin evaluation numero de canal
	jz	short selchn1
	mov	filswi,0FFh		;indique entree depuis fichier
	call	getfcb
	mov	fcbin,esi
selchn1:
	ret

; Test canal entree
	align	16
inchn:
	mov	filswi,0		;pas de fichier d'entree
	skipst				;saut espace et token
	cmp	al,k_hashtag		;# ?
	jne	short inchn1		;non
	mov	filswi,0FFh		;indique entree depuis fichier
	call	cfgchn			;configuration canal
	mov	fcbin,esi		;FCB fichier entree
inchn1:
	ret

; Test canal sortie
	align	16
outchn:
	mov	filswo,0		;pas de fichier de sortie
	skipst				;saut espace et token
	cmp	al,k_hashtag		;# ?
	jne	short outchn1		;non
	mov	filswo,0FFh		;indique sortie sur fichier
	call	cfgchn			;configuration canal
	mov	fcbout,esi		;FCB fichier sortie
outchn1:
	ret

; Configuration canal tableau virtuel 
	align	16
cfgchnv:
	inc	ebp			;bump pointer
	call	getchn			;evaluation canal
	jz	short cfgchnv1		;channel 0, erreur
	mov	virtchn,al		;range canal tableau virtuel
	jmp	short getfcbv		;FCB canal tableau virtuel
cfgchnv1:
	mov	al,err_channel		;numero de canal invalide
	jmp	rpter

; Configuration canal
	align	16
cfgchn:
	inc	ebp			;mange #
	call	getchn			;evaluation canal
;;;	jmp	short getfcb

; FCB canal
; Entree: EAX=canal
; Retour: ESI->FCB
getfcb:
	jnz	short getfcbv		;canal non zero
	mov	ebx,offset filtab
	mov	esi,[ebx]		;FCB canal 0
	test	esi,esi			;ouvert ?
	jnz	short getfcb1		;oui
	mov	filswo,0		;pas de fichier de sortie
	ret

; FCB canal tableau virtuel
; Entree: EAX=canal
; Retour: ESI->FCB
;	  EAX->tableau virtuel
	align	16
getfcbv:
	lea	ebx,filtab[eax*4]
	mov	esi,[ebx]		;FCB canal
	test	esi,esi			;ouvert ?
	jz	short getfcb4		;non, erreur
getfcb1:
	mov	eax,[ebx+numfil*4]	;tableau virtuel
	test	[esi].fcb.fcb_opntyp,0FFh ;fichier ouvert ?
	jz	short getfcb2		;non
	ret
getfcb2:
	mov	al,[esi].fcb.fcb_fcolm	;code erreur ouverture
getfcb3:
	jmp	rpter
getfcb4:
	mov	al,err_not_opened	;canal non ouvert
	jmp	getfcb3

; Evaluation numero de canal
; Retour: EAX=numero de canal
;	  ZF si canal 0
	align	16
getchn:
	call	evlint			;evaluation entier
	mov	eax,r0i
getchn1:
; Entree avec EAX=numero de canal
	cmp	eax,numfil		;numero valide ?
	jae	short chnerr		;non, erreur
	push	eax
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short getchn2		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
getchn2:
	pop	eax
	test	eax,eax
	ret
chnerr:
	mov	al,err_channel		;numero de canal invalide
	jmp	rpter

; Evaluation numero de canal
; Retour: DIRFCB->FCB canal
;	  NZ si tableau virtuel
	align	16
evalchn:
	skipst				;saut espace et token
	cmp	al,k_hashtag		;'#' ?
	jne	short evalchn1		;non, erreur
	inc	ebp			;mange #
	call	getchn			;evaluation canal
	jz	short evalchn2		;canal 0, erreur
	call	getfcbv			;FCB canal
	jz	short error_open	;canal non ouvert
	mov	cl,[esi].fcb.fcb_opntyp	;type ouverture
	and	cl,not opn_fld		;masque indicateur FIELD
	cmp	cl,opn_rw		;ouvert en lecture/ecriture ?
	jne	short error_status	;non, erreur
	test	eax,eax			;tableau virtuel ?
	mov	fcbdir,esi		;range pointeur FCB
	ret
evalchn1:
	jmp	synerr
evalchn2:
	mov	al,err_channel		;numero de canal invalide
	jmp	rpter
error_status:
	mov	al,err_file_state	;non ouvert en lecture/ecriture
	jmp	rpter
error_open:
	mov	al,err_not_opened	;canal non ouvert
	jmp	rpter

; Configuration canal FIELD
; Retour: EDX->tampon enregistrement
;	  ECX=longueur enregistrement
	align	16
fldchn:
	call	cfgchnv			;configuration canal
	test	eax,eax			;tableau virtuel defini ?
	jnz	short fldchn2		;oui, erreur
	mov	al,[esi].fcb.fcb_opntyp	;type ouverture
	test	al,al			;FIELD deja defini ?
	js	short fldchn1		;oui
	cmp	al,opn_rw		;ouverture en lecture/ecriture ?
	jne	dimchn_err		;non, erreur
	or	al,opn_fld		;indique FIELD specifie
	mov	[esi].fcb.fcb_opntyp,al
	mov	eax,[esi].fcb.fcb_cntlen ;longueur enregistrement
	call	allocds			;allocation memoire
	mov	[esi].fcb.fcb_bufadr,ebx ;adresse tampon enregistrement
fldchn1:
	mov	edx,[esi].fcb.fcb_bufadr ;adresse tampon enregistrement
	mov	ecx,[esi].fcb.fcb_cntlen ;longueur enregistrement
	ret
fldchn2:
	jmp	error_status		;erreur usage fichier

; Configuration canal DIM
	align	16
dimchn:
	call	cfgchnv			;configuration canal tableau virtuel
	cmp	[esi].fcb.fcb_opntyp,opn_rw ;ouverture en lecture/ecriture ?
	jne	short dimchn_err	;non, erreur
	mov	fcbdir,esi		;range pointeur FCB
	ret
dimchn_err:
	jmp	error_status		;erreur usage fichier

; Positionnement sur element tableau virtuel
; Entree: EAX=numero element
;	  EBX->descripteur tableau virtuel
	align	16
setvrt:
	push	eax
	movzx	eax,[ebx].vrta.va_chan	;canal
	call	getfcbv			;FCB canal tableau virtuel
	jz	short setvrt1		;non ouvert, erreur
	test	eax,eax			;tableau virtuel ?
	mov	fcbdir,esi		;range pointeur FCB
	jz	short setvrt2		;non, erreur
	pop	eax			;enregistrement=numero element
	jmp	dospos			;positionnement sur element
setvrt1:
	jmp	error_open		;fichier non ouvert
setvrt2:
	jmp	error_status		;erreur usage fichier

; Ouverture fichier en lecture
; Entree: ESI->FCB
; Retour: CF et AL=code si erreur
	align	16
openread:
	mov	[esi].fcb.fcb_opntyp,opn_r ;indique ouverture en lecture
	call	openfile		;ouverture fichier
opencont:
	jc	short openerr		;erreur
	mov	[esi].fcb.fcb_handle,ebx ;range handle
	mov	[esi].fcb.fcb_cntlen,0	;raz taille tampon
	mov	[esi].fcb.fcb_bufadr,0	;raz adresse tampon
	clc
	ret
openerr:
	mov	[esi].fcb.fcb_opntyp,0	;fichier non ouvert
	mov	[esi].fcb.fcb_fcolm,al	;code erreur ouverture
	ret


; Ouverture fichier en ecriture
; Entree: ESI->FCB
	align	16
openwrite:
	mov	[esi].fcb.fcb_opntyp,opn_w ;indique ouverture en ecriture
	call	createfile		;creation fichier
	jmp	opencont		;continue ouverture

; Ouverture fichier en extension
; Entree: ESI->FCB
	align	16
openappend:
	mov	[esi].fcb.fcb_opntyp,opn_w ;indique ouverture en ecriture
	call	openfile		;ouverture fichier
	jc	openwrite		;erreur
	call	opencont		;fin ouverture
	xor	ecx,ecx			;offset 0
	xor	edx,edx
	mov	al,2			;positionnement en fin de fichier
	jmp	fseek

; Fermeture fichier
; Entree: ESI->FCB
	align	16
closef:
	cmp	[esi].fcb.fcb_opntyp,0	;fichier ouvert ?
	je	short closef2		;non
	cmp	[esi].fcb.fcb_opntyp,opn_w ;ouvert en ecriture ?
	jne	short closef1		;non
	mov	ecx,[esi].fcb.fcb_cntlen ;nombre de caracteres dans tampon
	jecxz	short closef1		;vide
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	mov	edx,[esi].fcb.fcb_bufadr ;adresse tampon
	call	fwrite			;vidage tampon
	jc	short closef2		;erreur
closef1:
	call	closefile		;fermeture fichier
closef2:
	mov	eax,0			;preserve CF
	mov	[esi].fcb.fcb_handle,eax ;raz handle
	mov	fcbin,eax		;fin redirection entree
	mov	fcbout,eax		;fin redirection sortie
	mov	filswi,al		;pas de fichier d'entree
	mov	filswo,al		;pas de fichier de sortie
	ret

; Deverouillage courant fichier
; Entree: ESI->FCB
	align	16
unlockfile:
	mov	ecx,[esi].fcb.fcb_lockhigh
	cmp	ecx,080000000h		;verouillage fichier complet ?
	jne	short dounlockf		;non
	mov	[esi].fcb.fcb_lockhigh,-1 ;indique pas de verouillage
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	xor	ecx,ecx			;debut fichier
	xor	edx,edx
	mov	edi,0FFFFFFFFh
	mov	esi,7FFFFFFFh		;longueur maximale
	jmp	funlock			;deverouillage
dounlockf:
	mov	ecx,[esi].fcb.fcb_lockhigh
	test	ecx,ecx			;verouillage en cours ?
	js	short nounlock		;non
	mov	[esi].fcb.fcb_lockhigh,-1 ;indique pas de verouillage
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
	mov	edx,[esi].fcb.fcb_locklow ;ECX|EDX=position
	mov	edi,[esi].fcb.fcb_cntlen ;longueur enregistrement
	xor	esi,esi
	jmp	funlock			;deverouillage
nounlock:
	ret

; Creation ou ouverture fichier
	align	16
createfile:
	mov	al,[esi].fcb.fcb_opntyp	;type ouverture
	dec	al			;1=ecriture,2=lecture/ecriture
	mov	edx,offset pathbuf	;chemin fichier
	jmp	fcreate			;creation fichier

; Ouverture fichier
	align	16
openfile:
	mov	al,[esi].fcb.fcb_opntyp	;type ouverture
	dec	al			;0=lecture,1=ecriture,2=lecture/ecriture
	mov	edx,offset pathbuf	;chemin fichier
	jmp	fopen			;ouverture fichier

; Fermeture fichier
	align	16
closefile:
	mov	ebx,[esi].fcb.fcb_handle ;handle fichier
closefilex:
	test	ebx,ebx			;fichier ouvert ?
	jz	short closefile1
	jmp	fclose			;fermeture fichier
closefile1:
	ret

	end