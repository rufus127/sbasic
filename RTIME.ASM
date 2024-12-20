	page	,132
	name	rtime

	public	emptyprog
	public	rpter
	public	rpter4
	public	clrprog
	public	initlnums
	public	clrsp
	public	outdec
	public	outdecx
	public	outdc
	public	pcrlf
	public	pmsg
	public	edvar
	public	sublcl
	public	frslst
	public	pulline
	public	renpar
	public	fndlinq
	public	fndlin
	public	putlin
	public	clraddr
	public	linenum
	public	delete
	public	avar
	public	varadr
	public	clrvr
	public	getasn
	public	prepasn
	public	doasv
	public	setarg
	public	dosas
	public	dosas1
	public	setasn
	public	strxfr
	public	strpad
	public	chstv
	public	compcmd
	public	fieldc
	public	foreval
	public	dosload
	public	dobload
	public	markln
	public	updlin
	public	chainvar
	public	updvaro
	public	updlab
	public	clrvars
	public	dotasvar
	public	prepbin
	public	progsize
	public	nextlin
	public	skpop
	public	tstned
	public	listp
	public	allocds
	public	freeds

	.model	flat,c

	include sbasic.inc

debug_mem	equ	0

	.data

;Variables execution
progbuf		db	prog_head dup (?) ;tampon entete fichier binaire
loadoff		dd	?		;offset chargement
addrflg		db	?		;indicateur adresse positionnee

	.code
	extrn	skipsps:near,clsch:near
	extrn	eval:near,exp:near
	extrn	evlint:near,pulint:near,pulins:near
	extrn	lepar:near,ripar:near,comtok:near
	extrn	putsym:near
	extrn	wfread:near
	extrn	wfclose:near
	extrn	writetmp:near
	extrn	inch:near,outch:near
	extrn	inbufd:near
	extrn	gotoln:near
	extrn	ready1:near
	extrn	closebasic:near
	extrn	exittrue:near
	extrn	prnoff:near
	extrn	encode:near,encode1:near
	extrn	decode:near
	extrn	clrsave:near
	extrn	clsall:near
	extrn	synerr:near
	extrn	intger:near
	extrn	strtobuf:near
	extrn	variab:near
	extrn	sstmp:near
	extrn	setvrt:near
	extrn	getrec:near
	extrn	putrec:near
	extrn	strcnt:near
	extrn	strtox:near,nxtsc:near
	extrn	floatr0:near
	extrn	dwordten:dword

;Programme vide
emptyprog	label	byte
;premiere ligne
	db	prog_head-1		;longueur ligne 0
	dd	0			;ligne 0
	db	k_return		;token RETURN
	db	k_cr			;token fin de lign
	db	0,0,0,0,0,0,0,0		;nom programme
	db	0			;type programme
	dd	size prog		;longueur programme
	dd	1			;nombre de lignes
	dd	0			;taille table symboles
	dd	0			;nombre de symboles
	dd	0			;premiere ligne
	dd	0			;derniere ligne
;derniere ligne
	db	last_len-1		;longueur derniere ligne
	dd	maxline+1		;numero derniere ligne
	db	k_end			;token END

; Messages
erst		db	'ERREUR ',eot
erst2		db	' A LA LIGNE ',eot
erst3		db	' - ',eot
s_e0		db	eot
s_e2		db	'LE FICHIER REQUIS EST DEJA UTILISE',eot
s_e3		db	'LE FICHIER SPECIFIE EXISTE DEJA',eot
s_e4		db	'LE FICHIER SPECIFIE N',quote,'A PAS ETE TROUVE',eot
s_e5		db	'ERREUR EN OUVERTURE DE FICHIER',eot
s_e6		db	'CREATION FICHIER IMPOSSIBLE',eot
s_e7		db	'TOUT L',quote,'ESPACE DISQUE A ETE UTILISE',eot
s_e8		db	'FIN DE FICHIER RENCONTREE EN LECTURE',eot
s_e9		db	'ERREUR DE LECTURE SUR DISQUE',eot
s_e10		db	'ERREUR D',quote,'ECRITURE SUR DISQUE',eot
s_e11		db	'FICHIER OU DISQUE PROTEGE EN ECRITURE',eot
s_e12		db	'FICHIER TROP GRAND',eot
s_e13		db	'BLOC DE CONTROLE DE FICHIER ILLEGAL',eot
s_e15		db	'NUMERO D',quote,'UNITE DISQUE ILLEGAL',eot
s_e16		db	'UNITE DISQUE NON PRETE',eot
s_e17		db	'LE FICHIER EST PROTEGE - ACCES REFUSE',eot
s_e18		db	'FORMAT FICHIER COMPILE INCOMPATIBLE',eot
s_e20		db	'TYPE DE FICHIER A ACCES DIRECT NON DEFINI',eot
s_e21		db	'SPECIFICATION FICHIER ILLEGALE',eot
s_e22		db	'ERREUR EN FERMETURE FICHIER',eot
s_e23		db	'DEBORDEMENT TABLE ALLOCATION - DISQUE TROP SEGMENTE',eot
s_e24		db	'NUMERO D',quote,'ENREGISTREMENT INEXISTANT',eot
s_e29		db	'ENREGISTREMENT VERROUILLE',eot
s_e30		db	'TYPE DE DONNEES NON CONCORDANT',eot
s_e31		db	'HORS DONNEE DANS UNE INSTRUCTION "READ"',eot
s_e32		db	'MAUVAIS ARGUMENT DANS UNE INSTRUCTION "ON"',eot
s_e40		db	'ERREUR DE CANAL',eot
s_e41		db	'FICHIER DEJA OUVERT',eot
s_e42		db	'MODE D',quote,'OUVERTURE DU FICHIER ERRONE',eot
s_e43		db	'LE FICHIER N',quote,'A PAS ETE OUVERT',eot
s_e44		db	'ERREUR D',quote,'ETAT FICHIER',eot
s_e45		db	'TAILLE TROP GRANDE DANS FIELD',eot
s_e49		db	'REPERTOIRE NON TROUVE',eot
s_e50		db	'INSTRUCTION NON RECONNUE',eot
s_e51		db	'CARACTERE ILLEGAL DANS LA LIGNE',eot
s_e52		db	'ERREUR DE SYNTAXE',eot
s_e53		db	'FIN DE LIGNE ILLEGALE',eot
s_e54		db	'NUMERO DE LIGNE ILLEGAL ( <=0 )',eot
s_e55		db	'PARENTHESES NON BALANCEES',eot
s_e56		db	'REFERENCE ILLEGALE A UNE FONCTION',eot
s_e58		db	'"THEN" MANQUANT DANS UNE INSTRUCTION "IF"',eot
s_e60		db	'LIGNE NON TROUVEE',eot
s_e61		db	'RETURN SANS "CALL" OU SANS "GOSUB"',eot
s_e62		db	'ERREUR "FOR.NEXT"',eot
s_e63		db	'NE PEUT CONTINUER',eot
s_e64		db	'SOURCE ABSENT',eot
s_e65		db	'MAUVAIS-FICHIER.NE PEUT ETRE CHARGE',eot
s_e66		db	'RESUME HORS TRAITEMENT ERREUR',eot
s_e67		db	'MAUVAIS ARGUMENTS DANS DIGITS',eot
s_e68		db	'ARGUMENT INVALIDE',eot
s_e69		db	'FORMAT FICHIER IMAGE INVALIDE',eot
s_e70		db	'ERREUR DE TYPE DANS UN "PRINT USING"',eot
s_e71		db	'FORMAT ILLEGAL DANS UN "PRINT USING"',eot
s_e72		db	'TYPES DES OPERANDES INCOMPATIBLES',eot
s_e73		db	'EXPRESSION ILLEGALE',eot
s_e74		db	'ARGUMENT <0 OU >255',eot
s_e75		db	'ARGUMENT <=0',eot
s_e76		db	'TYPE DE VARIABLE ILLEGAL',eot
s_e77		db	'REFERENCE A UN TABLEAU HORS DIMENSION',eot
s_e78		db	'REFERENCE A UN TABLEAU NON DIMENSIONNE',eot
s_e79		db	'MAUVAIS ARGUMENT DANS UNE INSTRUCTION SWAP',eot
s_e80		db	'DEBORDEMENT MEMOIRE',eot
s_e81		db	'DEBORDEMENT TABLEAU',eot
s_e82		db	'DEBORDEMENT MEMOIRE PROGRAMME',eot
s_e83		db	'CHAINE TROP LONGUE',eot
s_e84		db	'TROP D',quote,'ARGUMENTS DANS SUB ET LOCAL',eot
s_e85		db	'CHAINE VIDE DANS "EXECUTE"',eot
s_e86		db	'CHAINE TROP LONGUE DANS "EXECUTE"',eot
s_e88		db	'REDIMENSIONNEMENT D',quote,'UN TABLEAU',eot
s_e89		db	'EFFACEMENT D',quote,'UNE LIGNE REFERENCEE',eot
s_e90		db	'FONCTION USR NON DEFINIE',eot
s_e92		db	'ARGUMENT VIRTUEL NON AUTORISE DANS L',quote,'INSTRUCTION',eot
s_e93		db	'"SUB" SANS "CALL"',eot
s_e94		db	'MAUVAISE LONGUEUR DE CHAINE SPECIFIEE',eot
s_e95		db	'"LOCAL" SANS "SUB"',eot
s_e96		db	'LIBERATION PAR CLEAR D',quote,'UN TABLEAU VIRTUEL NON FERME',eot
s_e97		db	'POSITION CURSEUR IMPOSSIBLE',eot
s_e98		db	'MAUVAIS ARGUMENT DANS L',quote,'INSTRUCTION CLEAR',eot
s_e99		db	'TYPE ERRONE DANS LES ARGUMENTS D',quote,'UN CALL',eot
s_e100		db	'EXPRESSION TROP COMPLEXE',eot
s_e101		db	'DEBORDEMENT VIRGULE FLOTTANTE',eot
s_e102		db	'ARGUMENT TROP GRAND',eot
s_e103		db	'DIVISION PAR ZERO',eot
s_e104		db	'REEL TROP GRAND POUR UNE CONVERSION EN ENTIER',eot
s_e105		db	'ARGUMENT NEGATIF OU NUL POUR "LOG"',eot
s_e106		db	'ERREUR DE CONVERSION EN ENTIER DANS UNE INSTRUCTION "INPUT"',eot
s_e107		db	'RACINE CARREE IMAGINAIRE',eot
s_e108		db	'ERREUR DE CONVERSION (NOMBRE TROP GRAND)',eot
s_e109		db	'DEBORDEMENT DANS UNE OPERATION ENTIERE',eot
s_e110		db	'NUMERO DE COULEUR ERRONE',eot
s_e111		db	'NUMERO DE PORT IMPOSSIBLE',eot
s_e114		db	'LIGNE VIDE DANS EDIT',eot
s_e115		db	'NO DE LIGNE ABSENT DANS EDIT',eot
s_e128		db	'ERREUR NON RECUPERABLE',eot

; Table des messages d'erreur
	align	16
errtab	dd	s_e0			;0
	dd	s_e0			;1
	dd	s_e2
	dd	s_e3
	dd	s_e4
	dd	s_e5
	dd	s_e6
	dd	s_e7
	dd	s_e8
	dd	s_e9
	dd	s_e10
	dd	s_e11
	dd	s_e12
	dd	s_e13
	dd	s_e0			;14
	dd	s_e15
	dd	s_e16
	dd	s_e17
	dd	s_e18
	dd	s_e0			;19
	dd	s_e20
	dd	s_e21
	dd	s_e22
	dd	s_e23
	dd	s_e24
	dd	s_e0			;25
	dd	s_e0			;26
	dd	s_e0			;27
	dd	s_e0			;28
	dd	s_e29
	dd	s_e30
	dd	s_e31
	dd	s_e32
	dd	s_e0			;33
	dd	s_e0			;34
	dd	s_e0			;35
	dd	s_e0			;36
	dd	s_e0			;37
	dd	s_e0			;38
	dd	s_e0			;39
	dd	s_e40
	dd	s_e41
	dd	s_e42
	dd	s_e43
	dd	s_e44
	dd	s_e45
	dd	s_e0			;46
	dd	s_e0			;47
	dd	s_e0			;48
	dd	s_e49
	dd	s_e50
	dd	s_e51
	dd	s_e52
	dd	s_e53
	dd	s_e54
	dd	s_e55
	dd	s_e56
	dd	s_e0			;57
	dd	s_e58
	dd	s_e0			;59
	dd	s_e60
	dd	s_e61
	dd	s_e62
	dd	s_e63
	dd	s_e64
	dd	s_e65
	dd	s_e66
	dd	s_e67
	dd	s_e68
	dd	s_e69
	dd	s_e70
	dd	s_e71
	dd	s_e72
	dd	s_e73
	dd	s_e74
	dd	s_e75
	dd	s_e76
	dd	s_e77
	dd	s_e78
	dd	s_e79
	dd	s_e80
	dd	s_e81
	dd	s_e82
	dd	s_e83
	dd	s_e84
	dd	s_e85
	dd	s_e86
	dd	s_e0			;87
	dd	s_e88
	dd	s_e89
	dd	s_e90
	dd	s_e0			;91
	dd	s_e92
	dd	s_e93
	dd	s_e94
	dd	s_e95
	dd	s_e96
	dd	s_e97
	dd	s_e98
	dd	s_e99
	dd	s_e100
	dd	s_e101
	dd	s_e102
	dd	s_e103
	dd	s_e104
	dd	s_e105
	dd	s_e106
	dd	s_e107
	dd	s_e108
	dd	s_e109
	dd	s_e110
	dd	s_e111
	dd	s_e0			;112
	dd	s_e0			;113
	dd	s_e114
	dd	s_e115
	dd	s_e0			;116
	dd	s_e0			;117
	dd	s_e0			;118
	dd	s_e0			;119
	dd	s_e0			;120
	dd	s_e0			;121
	dd	s_e0			;122
	dd	s_e0			;123
	dd	s_e0			;124
	dd	s_e0			;125
	dd	s_e0			;126
	dd	s_e0			;127
	dd	s_e128

; Affichage erreur
; Entree: AL=code erreur
	align	16
rpter:
	mov	esp,execsp		;restauration pile execution
	test	al,0FFh			;code erreur valide ?
	jns	short rpter1		;oui
	mov	al,err_fatal		;erreur fatale
rpter1:
	movzx	eax,al			;code erreur
	mov	errs,eax		;sauve
	mov	ebx,curpc		;pointeur ligne en erreur
	mov	eax,[ebx].line.l_number	;numero de ligne
	mov	erls,eax		;sauve
	call	wfclose			;fermeture fichier de travail
	call	prnoff			;arret impression fichier
	xor	eax,eax
	mov	vrtasn,al		;raz indicateur affectation virtuelle
	mov	asnflg,al		;raz indicateur affectation
	mov	offst,eax		;raz deplacement
	mov	ebx,curpc		;pointeur ligne en erreur
	cmp	ebx,prog_base		;debut programme ?
	je	short rpter2		;oui
	test	onerflg,0FFh		;traitement ON ERROR ?
	jnz	short rpter2		;oui
	mov	onerflg,0FFh		;indique traitement ON ERROR
	mov	eax,ergol		;ligne branchement ON ERROR
	test	eax,eax			;definie ?
	jnz	short rpter6		;oui
rpter2:
	mov	onerflg,0		;raz indicateur traitement erreur en cours
	cmp	colm,0			;curseur en debut de ligne ?
	je	short rpter3		;oui
	call	pcrlf			;saut de ligne
rpter3:
	mov	esi,offset erst		;message
	call	pmsg			;affichage message
	mov	eax,errs		;code erreur
	call	outdec			;affichage code erreur
	mov	eax,erls		;ligne erreur
rpter4:
	test	eax,eax			;defini ?
	jz	short rpter5		;non
	push	eax
	mov	esi,offset erst2	;message
	call	pmsg			;affichage message
	pop	eax
	call	outdec			;affichage numero de ligne
rpter5:
	mov	esi,offset erst3	;message
	call	pmsg			;affichage message
	mov	eax,errs		;code erreur
	mov	esi,errtab[eax*4]	;pointeur message
	call	pmsg			;affichage message
	movzx	eax,noedf		;edition source non autorisee ?
	or	eax,arg_c		;ou programme specifie ?
	jz	ready1			;non, invite
	call	closebasic		;OK fermeture fenetre BASIC
	jmp	exittrue		;sortie BASIC
rpter6:
	jmp	gotoln			;branchement ligne

; Effacement programme
	align	16
clrprog:
	mov	esi,offset emptyprog	;image programme vide
	mov	edi,prog_base		;base memoire programme
	mov	ecx,size prog		;taille programme vide
	rep	movsb			;recopie
	xor	al,al
	mov	trcflg,al		;raz mode trace
	mov	contflg,al		;raz indicateur CONTINUE
	mov	addrflg,al		;raz indicateur adresse positionee
	mov	noedf,al		;edition source autorisee
	call	clrsave			;raz indicateur sauvegarde source
;;;	jmp	short initlnums

; Initialisation premiere et derniere lignes
initlnums:
	xor	eax,eax
	mov	first,eax		;premiere ligne a zero
	mov	offst,eax		;deplacement a zero
	mov	lastx,maxline		;derniere ligne au maximum
	ret

; Effacement espace de travail
; Important: CLSALL doit avoir ete execute avant
; Sortie: EAX=nombre de symboles
	align	16
clrsp:
	xor	eax,eax
	mov	intmask,al		;raz masque interruptions
	mov	intflags,al		;raz indicateurs interruptions
	mov	edi,offset inttbl	;raz vecteurs d'interruption
	mov	ecx,8			;8 vecteurs
	rep	stosd
	mov	datapt,eax		;raz pointeur DATA
	mov	ergol,eax		;raz ligne ON ERROR
	mov	errs,eax		;raz code d'erreur
	mov	erls,eax		;raz ligne erreur
	mov	sschn,eax		;raz chaine des sous-chaines temporaires
	mov	excchn,eax		;raz chaine lignes EXECUTE
	mov	onerflg,al		;raz indicateur ON ERREUR
	mov	vrtasn,al		;raz indicateur affectation virtuelle
	mov	asnflg,al		;raz indicateur affectation
	mov	eax,prog_base		;base memoire programme
	mov	dataln,eax		;pointeur DATA
	mov	atos,offset astack	;sommet pile arithmetique
	mov	ebx,data_base		;base memoire donnees
	mov	eax,data_end		;fin memoire donnees
	mov	fstavl,ebx		;debut memoire libre
	sub	eax,ebx			;memoire libre
	mov	[ebx].free_mem.link,0	;fin de chaine
	mov	[ebx].free_mem.len,eax
;;;	jmp	short clrvars		;effacement variables

; Effacement variables
; Sortie: EAX=nombre de symboles
clrvars:
	mov	esi,symb_base		;table des symboles
	mov	edi,prog_base		;base memoire programme
	mov	edx,esi
	add	edx,[edi].prog.sym_len	;fin table symboles
	xor	ecx,ecx			;raz compteur symboles
clrvars1:
	cmp	esi,edx			;fin table ?
	jae	short clrvars3		;oui
	mov	[esi].symb.s_addr,0	;raz adresse variable ou variable
	inc	ecx			;un symbole de plus
	add	esi,size symb		;saut entete
clrvars2:
	lodsb				;caractere
	test	al,al			;type du symbole suivant ?
	jns	clrvars2		;non, continue
	dec	esi			;retour sur type
	jmp	clrvars1		;pour toute la table
clrvars3:
	mov	eax,ecx			;nombre de symboles
	ret

; Affichage entier sans minimum de caracteres
; Entree: EAX=entier a afficher
	align	16
outdec:
	xor	ecx,ecx			;zero caractere minimum affichage
outdecx:
	mov	edi,offset outbuf	;tampon de travail
	push	edi
	call	outdc			;conversion chaine ASCII
	pop	esi
	jmp	pmsg			;affichage chaine

; Conversion numero de ligne en chaine ASCII
; Entree: EAX=numero de ligne
;	  ECX=nombre minimum de caracteres chaine
	align	16
outdc:
	test	eax,eax			;mode directe ?
	jz	short outd1		;oui
	sub	eax,offst		;prise en compte deplacement
	ja	short outd1		;strictement positif
	mov	al,err_line_num		;numero de ligne invalide
	jmp	rpter
outd1:
	push	esi
	xor	esi,esi			;compteur caracteres
outdc0:
	xor	edx,edx
	div	dwordten		;division par 10
	push	edx			;reste=chiffre
	inc	esi			;un chiffre de plus
	test	eax,eax			;dividende nul ?
	jnz	outdc0			;non, continue
	sub	ecx,esi			;assez de caracteres ?
	jbe	short outdc2		;oui
outdc1:
	mov	byte ptr [edi],' '	;espace en debut de chaine
	inc	edi
	loop	outdc1			;tant que necessaire
outdc2:
	mov	ecx,esi			;nombre de chiffres
outdc3:
	pop	eax			;chiffre
	add	al,'0'			;caractere ASCII
	mov	[edi],al		;range
	inc	edi
	loop	outdc3			;pour tous les chiffres
	mov	byte ptr [edi],eot	;fin de chaine
	pop	esi
	ret

; Affichage fin de ligne
	align	16
pcrlf:
	mov	al,cr
	call	outch			;affichage CR
	mov	al,lf
	call	outch			;affichage LF
	test	filswo,0FFh		;redirection sortie fichier ?
	push	ebx
	jnz	short pcrlfa		;oui
	mov	ebx,oport
	mov	colm[ebx],0		;raz position colonne
pcrlf_end:
	pop	ebx
	ret
pcrlfa:
	mov	ebx,fcbout		;FCB fichier redirection sortie
	mov	[ebx].fcb.fcb_fcolm,0	;raz position colonne
	jmp	pcrlf_end

; Affichage chaine
; Entree: ESI->message termine par EOT
	align	16
pmsg:
	push	eax
pmsg0:
	mov	al,[esi]		;caractere
	inc	esi
	cmp	al,eot			;fin de chaine ?
	je	short pmsg1		;oui
	call	outch			;affichage caractere
	jmp	pmsg0			;jusqu'a EOT
pmsg1:
	pop	eax
	ret

; Affichage references variable
; Entree: EBX->entree symbole
; Sortie: EBX->symbole suivant
	align	16
edvar:
	mov	al,[ebx].symb.s_type	;type symbole
	lea	esi,[ebx].symb.s_addr	;pointeur debut chaine references
	mov	vartyp,al		;sauve
	add	ebx,size symb		;debut symbole
	mov	ecx,maxsymb		;limite caracteres symbole
edvar1:
	mov	al,[ebx]
	inc	ebx
	test	al,al			;type symbole suivant ?
	js	short edvar3		;oui
	call	outch			;affichage caractere
	loop	edvar1			;compte caractere, limite non atteinte
edvar2:
	mov	al,[ebx]
	inc	ebx
	test	al,al			;type symbole suivant ?
	jns	edvar2			;non, saute caractere
edvar3:
	dec	ebx			;retour sur type symbole
	push	ebx
	add	ecx,4			;caracteres suplementaires pour type
	mov	al,vartyp
	test	al,intbit		;entier ?
	jz	short edvar4		;non
	mov	al,'%'			;affiche %
	jmp	short edvar5
edvar4:
	test	al,strbit		;chaine ?
	jz	short edvar6		;non
	mov	al,'$'			;affiche %
edvar5:
	call	outch
	dec	ecx			;compte caractere
edvar6:
	mov	al,vartyp
	test	al,labbit		;etiquette ?
	jz	short edvar7		;non
	mov	al,' '			;affiche espace
	call	outch
	mov	al,'#'			;affiche ##
	call	outch
	jmp	short edvar8
edvar7:
	test	al,arrbit		;tableau ?
	jz	short edvar9		;non
	mov	al,'('			;affiche (*)
	call	outch
	mov	al,'*'
	call	outch
	mov	al,')'
edvar8:
	call	outch
	sub	ecx,3			;compte 3 caracteres
	jbe	edvar10
edvar9:
	mov	al,'.'			;remplissage avec .
	call	outch
	loop	edvar9			;jusqu'a 14+4 caracteres
edvar10:
	mov	ecx,maxnref		;numeros par ligne affichage
	inc	ecx
	mov	ebx,prog_base		;debut programme
	call	nextlin			;ligne suivante
edvar11:
	test	eax,eax			;fin code ?
	js	short edvar16		;oui
	mov	edi,eax			;numero ligne courante
	mov	edx,ebx			;debut ligne
	call	nextlin			;ligne suivante
	push	eax			;numero ligne suivante
	push	esi
edvar12:
	mov	esi,[esi]		;chainage references
	test	esi,esi			;fin de chaine ?
	jz	short edvar15		;oui
	add	esi,prog_base		;adresse programme
	cmp	esi,edx			;avant debut ligne ?
	jb	short edvar15		;oui, ligne non concernee
	cmp	esi,ebx			;apres fin ligne
	jae	edvar12			;oui, continue a remonter la chaine
	loop	edvar14			;encore de la place
	call	pcrlf			;saut de ligne
	mov	ecx,maxsymb+4		;saut nom symbole
	mov	al,' '
edvar13:
	call	outch			;output one
	loop	edvar13			;repeat
	mov	ecx,maxnref
edvar14:
	mov	al,' '			;affichage espace
	call	outch
	mov	eax,edi			;numero de ligne
	push	ecx
	mov	ecx,minlnum		;minimum caracteres
	call	outdecx			;affichage numero de ligne
	pop	ecx
edvar15:
	pop	esi
	pop	eax
	jmp	edvar11
edvar16:
	pop	ebx
	jmp	pcrlf			;saut de ligne et retour

; Saut (*) si tableau
; Entree: AL=type
; Sortie: token
	align	16
sublcl:
	mov	ah,al			;sauve tyoe
	add	ebp,1+size_o		;mange token et offset
	skipst				;saut espace et token
	test	ah,arrbit		;tableau ?
	jnz	short xsublc		;oui
	ret
xsublc:
	cmp	al,k_lbracket		;( ?
	jne	short sub10		;non, erreur
	inc	ebp			;mange (
	skipst				;saut espace et token
	cmp	al,k_mul		;* ?
	jne	short sub10		;non, erreur
	inc	ebp			;mange *
	skipst				;saut espace et token
	cmp	al,k_rbracket		;) ?
	jne	short sub10		;non, erreur
	inc	ebp			;mange )
	skipst				;saut espace et token
	ret
sub10:
	jmp	synerr			;erreur de syntaxe

; Evaluation premiere et derniere ligne
	align	16
frslst:
	call	initlnums		;initialise premiere et derniere lignes
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jnz	short frsls1		;presente
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short frsls3		;oui
	ret
frsls1:
	call	pulline			;numero de ligne
	mov	first,eax		;premiere ligne
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short frsls3		;oui
	mov	eax,first
	mov	lastx,eax		;derniere=premiere
frsls2:
	ret
frsls3:
	inc	ebp			;mange ,
	call	exp			;evaluation expression
	jz	short frsls4		;non presente
	call	pulline			;numero de ligne
	mov	lastx,eax		;derniere ligne
frsls4:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	frsls2			;non
	inc	ebp			;mange ,
	call	exp			;evaluation expression
	jz	frsls2			;non presente
	call	pulline			;numero de ligne
	mov	offst,eax		;deplacement
	ret

; Test numero de ligne
; Retour: EAX=numero de ligne
	align	16
pulline:
	call	pulint			;entier
	mov	eax,r0i
	test	eax,eax			;strictement positif ?
	jle	short evlli0		;non erreur
	ret
evlli0:
	mov	al,err_line_num		;numero de ligne invalide
	jmp	rpter

; Evaluation parametre RENUM
; Retour: CF si fin parametres
;	  ZF si valeur par defaut
;	  EAX=valeur
	align	16
renpar:
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short renpar2		;non presente
	call	pulint			;entier
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short renpar1		;non
	inc	ebp			;mange ,
renpar1:
	mov	eax,r0i			;valeur parametre
	test	eax,eax			;nul ?
	jz	short renpar4		;oui, erreur
	ret				;retour valeur parametre (CF=0, ZF=0)
renpar2:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short renpar3		;non, fin parametres
	inc	ebp			;mange ,
	xor	eax,eax			;retour valeur par defaut (CF=0, ZF=1)
	ret
renpar3:
	stc				;retour fin parametres (CF=1)
	ret
renpar4:
	jmp	synerr			;erreur de syntaxe

; Recherche (rapide) ligne
; Entree: EAX=numero de ligne
; Sortie: ZF si trouve
;	  ECX = rang ligne
;	  EBX->ligne
;	  PRVLIN->ligne precedente
	align	16
fndlinq:
	mov	ebx,curpc		;ligne courante ?
	cmp	eax,[ebx].line.l_number	;compare avec ligne recherchee
	je	short fndlin3		;trouvee
	ja	short fndlin1		;apres
fndlin:
	mov	ebx,prog_base		;avant, recherche a partir du debut
	xor	ecx,ecx
	jmp	short fndlin2
fndlin1:
	inc	ecx			;une ligne de plus
	mov	prvlin,ebx		;sauve pointeur ligne precedente
	movzx	edx,[ebx].line.l_len
	lea	ebx,[ebx+edx+1]		;ligne suivante
fndlin2:
	cmp	eax,[ebx].line.l_number	;apres ?
	ja	fndlin1			;non, continue
fndlin3:
	ret

; Insertion ligne
; Entree: ligne codee dans LINBUF
;	  LINO=numero de ligne
putlin_empty:
	mov	linlen,0		;ligne vide
	jmp	short putlin1
putlin_full:
	mov	al,err_prog_ovf
putlin_err:
	jmp	rpter
	align	16
putlin:
	mov	ebp,offset linbuf
	skipst				;saut espace et token
	cmp	al,k_cr			;EOL ?
	je	putlin_empty		;oui, ligne vide
putlin1:
	push	first
	push	lastx
	mov	eax,linum		;numero de ligne
	mov	first,eax		;premiere ligne
	mov	lastx,eax		;derniere ligne
	call	delete			;efface les lignes dans l'intervalle (EBX->ligne suivante)
	pop	lastx
	pop	first
	jc	putlin_err		;erreur
	movzx	edx,linlen		;longueur ligne
	test	edx,edx			;ligne vide ?
	jz	short clraddr		;oui, pas d'insertion
	add	edx,size line		;ajout taille entete ligne
	mov	edi,ebx			;fin code non deplace
	call	updpcs			;mise a jour pointeurs programme
	mov	eax,prog_base		;base memoire programme
	mov	esi,[eax].prog.prog_len	;offset fin programme
	mov	edi,esi
	add	edi,edx			;nouvel offset fin programme
	jc	putlin_full		;debordement
	cmp	edi,prog_size		;rentre dans memoire programme ?
	ja	putlin_full		;non, debordement
	add	esi,eax			;pointeur source
	add	edi,eax			;pointeur destination
	mov	ecx,esi
	dec	esi
	sub	ecx,ebx			;octets a deplacer
	dec	edi
	std				;deplacement vers le bas
	rep	movsb			;deplacement
	cld				;deplacement vers le haut par defaut
	add	[eax].prog.prog_len,edx	;ajuste longueur programme
	inc	[eax].prog.prog_line	;une ligne de plus
	mov	ecx,edx
	mov	edi,ebx
	mov	esi,offset linlen	;pointeur image ligne avec entete
	dec	ecx
	lodsb
	add	al,size_i		;ajout taille numero de ligne
	stosb
	rep	movsb			;insertion ligne
;;;	jmp	short clraddr

; Raz adresse dans numeros de ligne et etiquettes
clraddr:
	test	addrflg,0FFh		;adresse positionnee ?
	jz	short clraddr2		;non, retour
	mov	addrflg,0		;raz indicateur
	mov	ebx,prog_base		;base memoire programme
clraddr1:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short clraddr2		;oui
	lea	ebp,[ebx+size line]	;saut entete ligne
	jmp	short clraddr4
clraddr2:
	ret
clraddr3:
	inc	ebp			;mange token
	cmp	al,k_indirect		;indirection ?
	je	short clraddr9		;oui
	cmp	al,k_rem		;REM ?
	je	clraddr1		;oui, fin de ligne
	cmp	al,k_data		;DATA ?
	je	clraddr1		;oui, fin de ligne
	cmp	al,k_cr			;EOL ?
	je	clraddr1		;oui, fin de ligne
clraddr4:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short clraddr10		;oui
	test	al,al			;mot cle ?
	jns	clraddr3		;oui
	test	al,conbit		;constante ?
	jnz	short clraddr6		;oui
	test	al,labbit		;etiquette ?
	jnz	short clraddr5		;oui
	add	ebp,1+size_o		;saute token et offset symbole
	jmp	clraddr4
clraddr5:
	mov	dword ptr [ebp+5],0	;raz adresse ligne
	add	ebp,1+size_i+size_a	;saute token, numero de ligne (ou offset etiquette) et adresse ligne
	jmp	clraddr4
clraddr6:
	test	al,strbit		;chaine ?
	jnz	short clraddr8		;oui
	test	al,linbit		;numero de ligne ?
	jnz	clraddr5		;oui
	test	al,intbit
	jnz	short clraddr7
	add	ebp,size_f-size_i	;saut flottant
clraddr7:
	add	ebp,size_i-1		;saut entier
clraddr8:
	inc	ebp			;saut token
	inc	ebp			;saut longueur chaine
	movzx	eax,byte ptr [ebp]	;longueur representation
	inc	ebp			;saut longueur representation
	add	ebp,eax			;saut representation
	jmp	clraddr4		;continue
clraddr9:
	inc	ebp			;mange token extension
	jmp	clraddr4
clraddr10:
	je	short clraddr11		;espace
	inc	ebp			;saut compte espaces
clraddr11:
	inc	ebp			;saut espace
	jmp	clraddr4

; Evaluation numero de ligne
; Sortie: EBX=pointeur ligne (zero si non trouvee)
	align	16
linenum:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short lnum5		;oui
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	jne	short lnum4		;non
	mov	ebx,[ebp+5]		;adresse ligne
	test	ebx,ebx			;connue ?
	jnz	short lnum2		;oui
	mov	eax,[ebp+1]		;numero de ligne
lnum1:
	test	eax,eax			;nul ?
	jz	short lnum3		;oui, non trouve
	call	fndlinq			;recherche ligne
	jne	short lnum3		;non trouvee
	mov	[ebp+5],ebx		;maj adresse ligne
	mov	addrflg,0FFh		;indique adresse positionnee
lnum2:
	add	ebp,1+size_i+size_a	;mange token, numero de ligne et adresse ligne
	skipst				;saut espace et token
	ret
lnum3:
	xor	ebx,ebx			;retourne pointeur nul
	add	ebp,1+size_i+size_a	;mange token, numero de ligne et adresse ligne
	skipst				;saut espace et token
	ret
lnum4:
	test	al,labbit		;etiquette ?
	jz	short lnum5		;non
	mov	ebx,[ebp+5]		;adresse ligne
	test	ebx,ebx			;connue ?
	jnz	short lnum2		;oui
	mov	eax,[ebp+1]		;offset symbole
	add	eax,symb_base		;pointeur symbole
	mov	eax,[eax]		;valeur (numero de ligne)
	jmp	lnum1			;continue comme numero de ligne
lnum5:
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jnz	short lnum9		;oui
	test	al,intbit		;entier ?
	jnz	short lnum6		;oui
	call	intger			;conversion R0 en entier
lnum6:
	mov	eax,r0i			;valeur (numero de ligne)
lnum7:
	test	eax,eax			;strictement positif ?
	jle	short lnum10		;non, erreur
	call	fndlinq			;recherche ligne
	jne	lnum8			;non trouvee
	ret
lnum8:
	xor	ebx,ebx			;pointeur ligne a zero
	ret
lnum9:
	call	strtobuf		;copie chaine dans BUFFER
	mov	nxtnam,offset buffer	;debut chaine
	mov	labflg,1		;indique etiquette
	mov	tokflg,0FFh		;indique pas de rangement token
	call	variab			;recherche variable
	mov	labflg,0		;raz indicateur sous programme 
	mov	tokflg,0		;raz indicateur rangement token
	jnc	short lnum11		;etiquette non trouvee
	test	al,labbit		;etiquette ?
	jz	short lnum11		;non
	mov	eax,[edi]		;numero de ligne
	jmp	lnum7
lnum10:
	mov	al,err_line_num		;numero de ligne invalide
	jmp	rpter
lnum11:
	mov	al,err_no_line		;ligne non trouvee
	jmp	rpter

; Suppression ligne(s)
; Entree: FIRST:LAST=intervalle lignes a supprimer (bornes incluses)
; Sortie: EBX->premiere ligne apres intervalle
;	  CF si erreur, AL=code erreur
	align	16
delete:
	mov	eax,first		;debut intervalle
	test	eax,eax			;positif ?
	js	short delete7		;non, erreur
	jz	short delete4		;zero
delete1:
	call	fndlin			;recherche ligne
	jne	short delete5		;non trouvee
delete2:
	mov	edi,ebx			;pointeur premiere ligne intervalle
	mov	eax,lastx		;fin intervalle
	test	eax,eax			;positif ?
	js	short delete7		;non, erreur
	push	ecx
	call	fndlin			;recherche ligne
	pop	eax			;rang premiere ligne
	jne	short delete3		;derniere ligne non trouvee
	movzx	esi,[ebx].line.l_len
	lea	ebx,[ebx+esi+1]		;ligne suivante
	inc	ecx			;une ligne de plus
delete3:
	cmp	ebx,edi			;ligne(s) a effacer ?
	jbe	delete6			;non, retour
	sub	ecx,eax			;nombre de lignes a effacer
	call	chkpcs			;mise a jour pointeurs programme
	jc	short delete8		;impossible
	mov	edx,edi
	sub	edx,ebx			;deplacement code (negatif)
	call	updpcs			;mise a jour pointeurs programme
	mov	eax,prog_base		;base memoire programme
	sub	[eax].prog.prog_line,ecx ;maj nombre de lignes
	mov	esi,ebx			;pointeur ligne apres intervalle
	mov	ecx,[eax].prog.prog_len	;longueur programme
	add	ecx,eax			;fin programme
	sub	ecx,ebx			;octets a deplacer
	mov	ebx,edi			;pointeur premiere ligne apres intervalle
	rep	movsb			;deplacement
	sub	esi,edi			;nombre d'octets supprimes
	sub	[eax].prog.prog_len,esi	;maj taille programme
	clc				;retour OK
	ret
delete4:
	inc	eax			;EAX=1
	jmp	delete1
delete5:
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	jns	short delete2		;non
delete6:
	clc				;retour OK
	ret
delete7:
	mov	al,err_line_num		;numero de ligne invalide
	stc				;retour erreur
	ret
delete8:
	mov	al,err_del_ref_lin	;effacement avant ligne referencee
	stc				;retour erreur
	ret

; Test mise a jour pointeurs programme possible
; Entree: EBX=fin code a effacer
;	  EDI=debut code a effacer
; Retour: CF si maj impossible
chkpcs:
	test	pbinflg,0FFh		;preparation image binaire ?
	jnz	short chkpcs4		;oui, pas d'impacte sur les pointeurs
	mov	eax,savebp		;pointeur execution code
	call	chkpc			;test pointeur code
	jc	short chkpcs3		;dans code a effacer
	test	contflg,0FFh		;continue POSSIBLE ?
	jz	short chkpcs1		;non, ignore
	mov	eax,contebp		;pointeur code CONTINUE
	call	chkpc			;test pointeur code
	jc	short chkpcs3		;dans code a effacer
chkpcs1:
	mov	esi,execsp		;pointeur pile execution
chkpcs2:
	mov	al,[esi]		;marque entree
	cmp	al,interrupt_mark	;retour interruption ?
	je	short chkpcs6		;oui
	cmp	al,execute_mark		;retour EXECUTE ?
	je	short chkpcs6		;oui
	cmp	al,for_mark		;entree FOR ?
	je	short chkpcs7		;oui
	cmp	al,gosub_mark		;retour GOSUB ?
	je	short chkpcs6		;oui
	cmp	al,call_mark		;retour CALL ?
	je	short chkpcs8		;oui
	and	al,al			;fin de pile ?
	jz	short chkpcs4		;oui, maj possible
chkpcs3:
	test	dirflg,0FFh		;mode direct ?
	jz	short chkpcs5		;non, maj impossible
	mov	eax,curpc		;pointeur ligne courante
	cmp	eax,prog_base		;debut programme ?
	jne	short chkpcs5		;non, maj impossible
	mov	contflg,0		;raz indicateur CONTINUE
chkpcs4:
	clc				;retour OK
	ret
chkpcs5:
	stc				;retour maj impossible
	ret
chkpcs6:
	mov	eax,[esi].rete.r_ebp	;pointeur code retour
	call	chkpc			;test pointeur code
	jc	chkpcs3			;dans code a effacer
	add	esi,size rete		;saute entree
	jmp	chkpcs2			;continue
chkpcs7:
	mov	eax,[esi].fore.f_ebp	;debut boucle
	call	chkpc			;test pointeur code
	jc	chkpcs3			;dans code a effacer
	add	esi,size fore		;saute entree
	jmp	chkpcs2			;continue
chkpcs8:
	test	[esi].rete.r_count,0FFh	;en attente SUB ?
	js	chkpcs3			;oui, erreur
	mov	eax,size calla		;taille entree argument
	mul	[esi].rete.r_count	;*nombre arguments
	add	esi,eax			;saut arguments
	jmp	chkpcs6

; Test pointeur dans code a effacer
; Entree: EAX=pointeur
;	  EBX=fin code a effacer
;	  EDI=debut code a effacer
; Retour: CF si dans code a effacer
chkpc:
	cmp	eax,ebx			;apres code a effacer ?
	jae	short chkpc2		;oui (CF=0)
	cmp	eax,edi			;avant code a effacer ?
	jb	short chkpc1		;oui
	stc				;retour dans code
	ret
chkpc1:
	clc				;retour hors code
chkpc2:
	ret

; Mise a jour pointeurs programme avant deplacement
; Entree: EBX=debut code deplace
;	  EDI=fin code non deplace
;	  EDX=deplacement code
updpcs:
	test	pbinflg,0FFh		;preparation image binaire ?
	jnz	updpcs8			;oui, pas d'impacte sur les pointeurs
	mov	esi,offset savebp	;sauvegarde EBP
	call	updpc			;ajuste
	mov	esi,offset curpc	;pointeur ligne courante
	call	updpc			;ajuste
	mov	esi,offset nextpc	;pointeur ligne suivante
	call	updpc			;ajuste
	test	contflg,0FFh		;continue POSSIBLE ?
	jz	short updpcs1		;non, ignore
	mov	esi,offset contebp	;pointeur code CONTINUE
	call	updpc			;ajuste
	mov	esi,offset contcur	;pointeur ligne courante CONTINUE
	call	updpc			;ajuste
	mov	esi,offset contnxt	;pointeur ligne suivante CONTINUE
	call	updpc			;ajuste
updpcs1:
	push	ecx
	mov	esi,offset inttbl	;table vecteurs interruption
	mov	ecx,8			;nombre vecteurs
updpcs2:
	mov	eax,[esi]
	call	chkpc			;test pointeur code
	jc	short updpcs3		;dans code a effacer
	call	updpc			;ajuste
	jmp	short updpcs4
updpcs3:
	xor	eax,eax
	mov	[esi],eax		;raz vecteur
updpcs4:
	add	esi,size_a		;vecteur suivant
	loop	updpcs2
	pop	ecx
	mov	eax,dataln		;pointeur ligne DATA
	call	chkpc			;test pointeur code
	jc	short updpcs5		;dans code a effacer
	mov	esi,offset dataln	;pointeur ligne DATA
	call	updpc			;ajuste
	mov	esi,offset datapt	;pointeur DATA
	call	updpc			;ajuste
	jmp	short updpcs6
updpcs5:
	xor	eax,eax
	mov	datapt,eax		;raz pointeur DATA
	mov	eax,prog_base
	mov	dataln,eax		;pointeur ligne en debut de programme
updpcs6:
	mov	esi,execsp		;pointeur pile execution
updpcs7:
	mov	al,[esi]		;marque entree
	cmp	al,interrupt_mark	;retour interruption ?
	je	short updpcs9		;oui
	cmp	al,execute_mark		;retour EXECUTE ?
	je	short updpcs9		;oui
	cmp	al,for_mark		;entree FOR ?
	je	short updpcs10		;oui
	cmp	al,gosub_mark		;retour GOSUB ?
	je	short updpcs9		;oui
	cmp	al,call_mark		;retour CALL ?
	je	short updpcs11		;oui
updpcs8:
	ret
updpcs9:
	push	esi
	lea	esi,[esi].rete.r_ebp	;pointeur code de retour
	call	updpc			;ajuste
	add	esi,rete.r_curpc-rete.r_ebp ;pointeur ligne courante retour
	call	updpc			;ajuste
	add	esi,rete.r_nextpc-rete.r_curpc ;pointeur ligne suivante retour
	call	updpc			;ajuste
	pop	esi
	add	esi,size rete		;saute entree
	jmp	updpcs7			;continue
updpcs10:
	push	esi
	lea	esi,[esi].fore.f_ebp	;pointeur debut boucle
	call	updpc			;ajuste
	add	esi,fore.f_nextpc-fore.f_ebp ;pointeur ligne suivante debut boucle
	call	updpc			;ajuste
	add	esi,fore.f_curpc-fore.f_nextpc ;pointeur ligne courante debut boucle
	call	updpc			;ajuste
	pop	esi
	add	esi,size fore		;saute entree
	jmp	updpcs7			;continue
updpcs11:
	test	[esi].rete.r_count,0FFh	;en attente SUB ?
	js	updpcs8			;oui, erreur
	mov	eax,size calla		;taille entree argument
	mul	[esi].rete.r_count	;*nombre arguments
	add	esi,eax			;saut arguments
	jmp	updpcs9			;mise a jour

; Ajuste pointeur code
; Entree: ESI->pointeur
;	  EBX=debut code deplace
;	  EDX=deplacement code
updpc:
	mov	eax,[esi]		;pointeur
	cmp	eax,ebx			;apres debut code deplace ?
	jbe	short updpc1		;oui
	sub	eax,prog_base		;offset pointeur
	cmp	eax,prog_size		;dans segment programme ?
	jae	short updpc1		;non
	add	[esi],edx		;ajuste
updpc1:
	ret

; Evaluation adresse variable
; Entree: AL=type variable (TOK_MARK positionee)
; Retour: ESI=adresse variable
;	  AL=type variable
;	  VRTFLG=indicateur tableau virtuel
	align	16
avar:
	test	al,arrbit		;tableau ?
	jnz	short avar1		;oui
varadr:
	mov	ebx,[ebp+1]		;offset variable
	add	ebx,symb_base		;pointeur variable
	mov	esi,[ebx]		;adresse variable
	test	esi,esi			;deja alloue ?
	jz	short varad2		;non
	add	ebp,1+size_o		;saut token et offset
	ret				;finish
varad2:
	push	eax
	test	al,intbit		;variable entiere ?
	mov	eax,size_i		;taille entier
	jnz	short varad3		;oui
	mov	eax,size_v		;taille flottant ou descripteur chaine
varad3:
	push	ebx
	push	eax
	call	allocds			;allocation memoire
	pop	ecx			;taille variable
	mov	edi,ebx
	mov	esi,ebx
	xor	al,al
	rep	stosb			;raz variable
	pop	ebx
	pop	eax			;type variable
	mov	[ebx],esi		;sauve adresse variable
	add	ebp,1+size_o		;saut token et offset
	ret
avar1:
	push	eax			;sauve type
	xor	al,al			;type flottant pour allocation variable
	call	varadr			;retrouve adresse descripteur tableau
	call	lepar			;saut (
	skipst				;saut espace et token
	cmp	al,k_mul		;* ?
	jne	avar3			;non
	inc	ebp			;mange *
	call	ripar			;saut )
	pop	eax			;type
	ret
avar2:
	mov	al,err_no_dim		;tableau non dimensionne
	jmp	rpter
avar3:
	mov	strflg,0		;raz indicateur expression chaine
	mov	ebx,[esi].array.a_addr	;adresse tableau 
	test	ebx,ebx
	jz	avar2			;non dimensionne
	movzx	ecx,word ptr [esi].array.a_dim ;CL=nombre de dimensions, CH=indicateur virtuel
	push	ecx			;sauve
	movzx	ecx,cl			;nombre de dimensions
	xor	eax,eax			;offset variable
	push	ebx			;adresse tableau
avar4:
	push	eax
	push	ebx
	push	ecx
	call	exp			;evaluation expression
	jz	short avar8		;pas d'expression, erreur
	call	pulins			;entier non signe
	pop	ecx
	pop	ebx
	pop	eax
	mov	edx,r0i
	sub	ebx,4			;EBX->dimension
	cmp	edx,[ebx]		;indice < dimension ?
	jae	short avar7		;non erreur
	push	edx
	mul	dword ptr [ebx]		;calcul offset
	pop	edx
	add	eax,edx			;ajout indice
	dec	ecx			;autre dimension ?
	je	short avar5		;non
	mov	edx,eax
	call	comtok			;mange ,
	skipst				;saut espace et token
	mov	eax,edx
	jmp	avar4			;dimension suivante
avar5:
	pop	ebx			;adresse tableau
	mov	esi,eax			;numero element
	call	ripar			;mange )
	pop	ecx			;CH=indicateur virtuel
	pop	eax			;AL=type
	and	al,not arrbit		;type variable
	test	ch,ch			;tableau virtuel ?
	jnz	short avar9		;oui
	test	al,intbit		;entier ?	
	jnz	short avar6		;oui, 4 octets par element
	add	esi,esi			;8 octets par element (flottant/adresse et longueur chaine)
avar6:
	shl	esi,2			;x4
	add	esi,ebx			;adresse element
	ret
avar7:
	mov	al,err_dim_out		;depassement dimension
	jmp	rpter
avar8:
	jmp	synerr			;erreur de syntaxe
avar9:
	mov	vrtflg,0FFh		;indique tableau virtuel
	test	asnflg,0FFh		;affectation ?
	jz	short avar10		;non
	mov	vrtrec,esi		;range numero element tableau
	mov	esi,ebx			;adresse descripteur tableau virtuel
	ret
avar10:
	push	eax
	push	ebx
	mov	eax,esi			;numero element
	call	setvrt			;positionnement sur element tableau virtuel
	pop	ebx
	mov	eax,[ebx].vrta.va_size	;taille element
	test	[ebx].vrta.va_type,0FFh	;chaine ?
	jnz	short avar11		;oui
	mov	esi,tmpptr		;pointeur temporaires
	add	eax,esi			;avance pointeur
	cmp	eax,offset tmps+maxtmp	;debordement ?
	ja	short avar12		;oui, erreur
	mov	tmpptr,eax		;avance pointeur temporaires
	mov	ebx,fcbdir		;pointeur FCB acces directe
	mov	[ebx].fcb.fcb_bufadr,esi ;adresse tampon enregistrement
	push	esi
	call	getrec			;lecture enregistrement
	pop	esi			;adresse variable
	pop	eax			;type variable
	ret
avar11:
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	esi,fcbdir		;pointeur FCB acces directe
	mov	[esi].fcb.fcb_bufadr,ebx ;adresse tampon
	push	eax
	call	getrec			;lecture enregistrement
	mov	esi,tmpptr		;pointeur temporaires
	cmp	esi,offset tmps+maxtmp-size strg ;debordement ?
	pop	eax
	ja	short avar12		;oui, erreur
	add	tmpptr,size strg	;avance pointeur temporaires
	mov	[esi].strg.str_len,eax	;longueur chaine
	mov	eax,ssptr		;adresse sous-chaine
	mov	[esi].strg.str_addr,eax	;adresse chaine
	pop	eax			;type
	ret
avar12:
	mov	al,err_too_complex
	jmp	rpter

; Effacement variable
; Entree: EBX->adresse dans table symboles
;	  AL=type variable
	align	16
clrvr:
	test	al,arrbit		;tableau ?
	jnz	short clrvr4		;oui
	push	ebx
	mov	ebx,[ebx]		;adresse variable
	test	ebx,ebx			;variable allouee ?
	jz	short clrvr2		;non, rien a faire
	test	al,strbit		;chaine ?
	jz	short clrvr1		;non
	call	clrstr			;effacement chaine
clrvr1:
	mov	eax,size_v		;taille variable
	call	freeds			;liberation memoire
	pop	ebx
	mov	dword ptr [ebx],0	;marque variable non allouee
	ret
clrvr2:
	pop	ebx
	ret
clrvr3:
	mov	al,err_virtual_clr	;effacement tableau virtuel interdit
	jmp	rpter
clrvr4:
	push	ebx
	mov	ebx,[ebx]		;adresse variable
	test	ebx,ebx			;variable allouee ?
	jz	clrvr2			;non, rien a faire
	mov	edx,[ebx].array.a_addr	;adresse donnees
	test	edx,edx			;alloue ?
	jz	clrvr2			;non
	test	[ebx].array.a_virt,0FFh	;tableau virtuel ?
	jnz	clrvr3			;oui, erreur
	test	al,strbit		;tableau de chaines ?
	jz	short clrvr6		;non
	push	ebx
	push	ecx
	push	edx
	movzx	ecx,[ebx].array.a_dim	;nombre de dimensions
	mov	ebx,edx			;adresse descripteurs chaine
	inc	ecx			;entree taille totale
	shl	ecx,2			;x4 (taille dimensions et taille totale)
	sub	ebx,ecx
	mov	eax,[ebx]		;taille totale
	sub	eax,ecx
	shr	eax,3			;nombre de descripteurs chaine
	mov	ebx,edx			;adresse descripteurs chaine
	mov	ecx,eax
clrvr5:
	call	clrstr			;effacement chaine
	add	ebx,size strg		;descripteur chaine suivant
	loop	clrvr5			;pour toutes les chaines
	pop	edx
	pop	ecx
	pop	ebx
clrvr6:
	push	ebx
	movzx	eax,[ebx].array.a_dim	;nombre de dimensions
	mov	ebx,edx			;adresse donnees
	inc	eax			;entree taille totale
	shl	eax,2			;x4 (taille dimensions et taille totale)
	sub	ebx,eax
	mov	eax,[ebx]		;taille totale
	call	freeds			;liberation memoire
	pop	ebx
	jmp	clrvr1			;liberation variable

; Effacement chaine
clrstr:
	mov	eax,[ebx].strg.str_len	;longueur chaine
	test	eax,eax			;indicateur FIELD ?
	js	short clrstr2		;oui, pas d'effacement
	push	ebx
	mov	ebx,[ebx].strg.str_addr ;adresse chaine
	test	ebx,ebx			;allouee ?
	jz	short clrstr1		;non
	call	freeds			;liberation memoire
clrstr1:
	pop	ebx
clrstr2:
	ret

; Adresse affectation variable
; Entree: AL=type (TOK_MARK positionne)
; Retour: ASNADR=adresse variable ou descripteur tableau virtuel
;	  AL=type variable
;	  VRTASN=indicateur affectation virtuelle
	align	16
getasn:
	mov	asnflg,1		;indique affectation
	mov	vrtflg,0		;raz indicateur tableau virtuel
	call	avar			;adresse variable
	mov	asnadr,esi		;range adresse affectation ou descripteur tableau virtuel
	mov	asnflg,0		;raz indicateur affectation
	mov	ah,vrtflg		;indicateur tableau virtuel
	mov	vrtasn,ah		;indique affectation tableau virtuel
	ret

; Prepare affectation
; Retour: si entier ou flottant: resultat dans R0 et AL=type
;	  si chaine: pile sous-chaine et STRFL positionne
	align	16
prepasn:
	call	getasn			;adresse affectation variable
	and	al,unused+intbit+linbit+strbit ;garde les bits utiles
	mov	asntype,al		;type affectation
	skipst				;saut espace et token
	cmp	al,k_eq			;'='?
	jne	dosasn_err		;non
	inc	ebp			;mange =
	jmp	eval			;evalue expression dans R0
dosasn_err:
	mov	al,err_bad_inst		;erreur instruction
	jmp	rpter

; Execution affectation variable
; Entree: AL=type evaluation (TOK_MARK non positionne)
;	  R0=valeur flottante
;	  R0I=valeur entiere
	align	16
doasv:
	cmp	al,asntype		;meme type que variable ?
	jne	short doasv3		;non
doasv1:
	test	al,intbit		;entier ?
	jz	short doasv4		;non
doasv2:
	test	vrtasn,0FFh		;affectation virtuelle ?
	jnz	short doasv6		;oui
	mov	edi,asnadr		;adresse affectation
	mov	eax,r0i			;affectation entier
	mov	[edi],eax
	ret
doasv3:
	jb	short doasv5		;entier=flottant
	call	floatr0			;flottant=entier
doasv4:
	test	vrtasn,0FFh		;affectation virtuelle ?
	jnz	short doasv6		;oui
	mov	esi,offset r0
	mov	edi,asnadr		;adresse affectation
	movsd				;range resultat dans variable
	movsd
	ret
doasv5:
	call	intger			;conversion R0 en entier
	jmp	doasv2
doasv6:
	mov	vrtasn,0		;raz indicateur affectation virtuelle
	mov	eax,vrtrec		;numero element tableau virtuel
	mov	ebx,asnadr		;descripteur tableau virtuel
	call	setvrt			;positionnement sur element tableau virtuel
	jmp	putrec			;ecriture enregistrement


; Allocation et affectation argument
; Entree: AL=type argument
	align	16
setarg:
	push	eax
	test	al,intbit		;entier ?
	mov	eax,size_f		;taille flottant par defaut
	jz	short setar1		;non
	mov	eax,size_i		;taille entier
setar1:
	call	allocds			;allocation memoire
	mov	asnadr,ebx		;range adresse affectation
	pop	eax
	jmp	doasv1			;affectation

; Execution affectation chaine
	align	16
dosas:
	test	vrtasn,0FFh		;affectation virtuelle ?
	jnz	short dosas6		;oui
	mov	ebx,asnadr		;adresse affectation
	mov	eax,[ebx].strg.str_len	;longueur ancienne chaine
	mov	ebx,[ebx].strg.str_addr	;adresse ancienne chaine
dosas1:
	mov	oldstr.strg.str_addr,ebx ;sauvegarde addresse et longueur ancienne chaine
	mov	oldstr.strg.str_len,eax
	call	strcnt			;longueur nouvelle chaine ?
	cmp	eax,oldstr.strg.str_len	;meme longueur ?
	jne	short dosas2		;non
	mov	ebx,strsptr
	cmp	[ebx].strg.str_len,0	;nouvelle chaine vide ?
	jne	short dosas2		;non
	cmp	oldstr.strg.str_addr,0	;ancienne chaine vide ?
	je	short dosas2		;oui
	xor	ebx,ebx
	xchg	ebx,oldstr.strg.str_addr ;garde espace ancienne chaine
	jmp	short dosas4		;pour la nouvelle
dosas2:
	test	eax,eax			;longueur nulle ?
	push	eax
	jz	short dosas3		;oui, chaine vide
	call	allocds			;allocation memoire
	mov	eax,ebx			;adresse
dosas3:
	mov	ebx,asnadr
	mov	[ebx].strg.str_addr,eax	;affectation adresse
	pop	[ebx].strg.str_len	;affectation longueur
	mov	ebx,eax			;adresse rangement chaine
dosas4:
	call	strtox			;rangement chaine
	mov	ebx,oldstr.strg.str_addr
	test	ebx,ebx			;ancienne chaine vide ?
	jz	short dosas5		;oui, pas de liberation
	mov	eax,oldstr.strg.str_len	;longueur ancienne chaine
	test	eax,eax			;chaine FIELD ou de longueur nulle ?
	jle	short dosas5		;oui, pas de liberation
	jmp	freeds			;liberation memoire
dosas5:
	ret
dosas6:
	mov	vrtasn,0		;raz indicateur affectation virtuelle
	mov	eax,vrtrec		;numero element tableau virtuel
	mov	ebx,asnadr		;descripteur tableau virtuel
	push	[ebx].vrta.va_size	;longueur chaine
	call	setvrt			;positionnement sur element tableau virtuel
	pop	eax
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	esi,fcbdir		;pointeur FCB acces directe
	mov	[esi].fcb.fcb_bufadr,ebx ;adresse tampon
	mov	ecx,eax			;longueur chaine
	call	strxfr			;transfert chaine
	jecxz	short dosas7		;pas de remplissage
	call	strpad			;remplissage
dosas7:
	jmp	putrec			;ecriture enregistrement

	
; Prepare affectation dans une chaine existante
; Retour: EBX->chaine existante
;	  ECX=longueur chaine existante
	align	16
setasn:
	skipst				;saut espace et token
	call	chstv			;test variable chaine
	call	prepasn			;prepare affectation
	test	strflg,0FFh		;expression chaine ?
	jz	short setasn1		;non
	test	vrtasn,0FFh		;affectation virtuelle ?
	jnz	short setasn2		;oui, erreur
	mov	ebx,asnadr		;adresse affectation
	mov	ecx,[ebx].strg.str_len	;longueur chaine existante
	and	ecx,7FFFFFFFh		;raz indicateur FIELD
	mov	ebx,[ebx].strg.str_addr	;adresse chaine existante
	ret
setasn1:
	jmp	synerr			;erreur de syntaxe
setasn2:
	mov	al,err_not_virtual	;action sur chaine virtuelle non supportee
	jmp	rpter

; Transfer chaine dans chaine existante
; Entree: EBX->chaine existante
;	  ECX=longueur chaine existante
; Retour: ECX=longueur jusqu'a fin de chaine
;	  EBX->fin chaine existante
	align	16
strxfr:
	mov	first,0			;pour NXTSC
	jecxz	short strxfr2		;fin chaine
strxfr1:
	call	nxtsc			;caractere suivant
	jz	short strxfr2		;fin de chaine
	mov	[ebx],al		;range
	inc	ebx
	loop	strxfr1			;tant qu'il y a de la place
strxfr2:
	ret

; Remplissage fin de chaine
; Entree: EBX->chaine
;	  ECX=longueur
	align	16
strpad:
	mov	byte ptr [ebx],' '	;espace
	inc	ebx
	loop	strpad			;pour toute la longueur
	ret

; Test variable chaine
; Entree: AL=type (TOK_MARK positionne)
	align	16
chstv:
	cmp	al,tok_mark+strbit	;chaine simple ?
	je	short chstv1		;oui
	cmp	al,tok_mark+arrbit+strbit ;tableau de chaines ?
	jne	short chstv2		;non
chstv1:
	ret
chstv2:
	jmp	synerr			;erreur de syntaxe

; Compilation ligne de commande
	align	16
compcmd:
	mov	ebp,offset linbuf	;adresse ligne de commande
	mov	linptr,ebp		;pointeur donnees
	xor	al,al
	mov	bckcnt,al		;raz compte parentheses
	mov	lineflg,al		;raz indicateur numero de ligne
	jmp	encode1			;compile ligne

; Traitement commun FIELD et FIELD#
; Retour: EAX=longueur calculee FIELD
;	  ESI=adresse variable chaine associee
;	  ZF si fini par ,
	align	16
fieldc:
	call	evlint			;evaluation entier
	mov	eax,r0i
	test	eax,eax			;entier strictement positif ?
	jle	short field2		;non, erreur
	push	eax
	skipst				;saut espace et token
	cmp	al,k_as			;AS ?
	jne	short field3		;non, erreur
	inc	ebp			;mange AS
	skipst				;saut espace et token
	call	chstv			;check string var
	call	avar			;adresse variable
	test	al,arrbit		;tableau ?
	jnz	short field3		;oui, erreur
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short field3		;oui, erreur
	mov	eax,[esi].strg.str_len
	test	eax,eax			;chaine FIELD ou vide ?
	jle	short field1		;oui, pas de liberation
	mov	ebx,[esi].strg.str_addr
	test	ebx,ebx			;chaine nulle ?
	jz	short field1		;oui, pas de liberation
	call	freeds			;liberation memoire
field1:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	pop	eax			;retour longueur FIELD
	ret
field2:
	mov	al,err_field_size	;longueur FIELD invalide
	jmp	rpter
field3:
	jmp	synerr			;erreur de syntaxe

; Argument FOR
; Retour: R0=valeur
	align	16
foreval:
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jnz	short forev2		;oui, erreur
	test	al,intbit		;entier ?
	jnz	short forev1		;oui
	ret
forev1:
	jmp	floatr0			;conversion flottant
forev2:
	mov	al,err_arg_type		;erreur type expression
	jmp	rpter

; Chargement fichier source
	align	16
dosload:
	call	inbufd			;entree ligne depuis fichier
	jc	short doslod3		;erreur ou fin de fichier
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	inptr,ebx		;maj pointeur caractere
	call	clsch			;type caractere
	cmp	al,clsch_num		;chiffre ?
	jne	short doslod1		;non, erreur ?
	push	esi
	call	encode			;code ligne
	pop	esi
	ja	short doslod4		;au dela de l'intervalle
	jne	dosload			;avant l'intervalle
	push	esi
	call	putlin			;insertion ligne
	pop	esi
	jmp	dosload			;continue
doslod1:
	cmp	ah,cr			;ligne vide ?
	je	dosload			;oui, ignore
	mov	al,err_illegal_chr	;caractere illegal
doslod2:
	jmp	rpter
doslod3:
	cmp	al,err_eof		;fin de fichier ?
	jne	doslod2			;non, erreur
	call	updlab			;mise a jour etiquettes
doslod4:
	ret

; Chargement fichier binaire
; Retour: CF et AL=code si erreur
	align	16
dobload:
	mov	ecx,prog_head		;taille entete fichier
	mov	ebx,offset progbuf	;tampon
	push	ebx
	call	wfread			;lecture entete fichier
	pop	ebx
	jc	doblod2			;erreur
	mov	eax,[ebx]		;signature
	cmp	eax,dword ptr emptyprog ;signature OK ?
	jne	doblod3			;non, erreur
	mov	eax,[ebx].prog.prog_len ;longueur programme
	cmp	eax,prog_size		;assez de memoire ?
	ja	doblod4			;non, erreur
	mov	eax,[ebx].prog.sym_len
	inc	eax			;prise en compte marque fin de table
	cmp	eax,symb_size		;assez de memoire ?
	ja	short doblod4		;non, erreur
	mov	al,[ebx].prog.prog_type ;type binaire
	test	al,protected		;fichier protege ?
	jz	short doblod1		;non
	mov	noedf,0FFh		;indique edition source non autorisee
doblod1:
	test	al,compressed+nosymb+librairy+overlay ;autre type ?
	jnz	short doblod6		;oui
; Chargement programme complet
	test	dirflg,0FFh		;mode direct ?
	jz	short doblod3		;non, erreur
	mov	eax,curpc		;pointeur ligne courante
	cmp	eax,prog_base		;debut programme ?
	jne	short doblod3		;non, erreur
	cmp	offst,0			;deplacement specifie ?
	jne	short doblod3		;oui, erreur
	mov	contflg,0		;raz indicateur CONTINUE
	mov	ecx,prog_head		;longueur entete
	mov	esi,ebx			;tampon entete
	mov	edi,prog_base		;debut memoire programme
	rep	movsb			;recopie
	mov	ecx,[ebx].prog.prog_len	;longueur programme
	push	ebx
	sub	ecx,prog_head
	mov	ebx,edi			;apres entete
	call	wfread			;lecture code programme
	pop	ebx
	jc	short doblod2		;erreur
	mov	ecx,[ebx].prog.sym_len
	mov	ebx,symb_base
	inc	ecx			;prise en compte marque fin de table
	call	wfread			;lecture table symboles
	jc	short doblod2		;erreur
	call	clrvars			;effacement variables
	call	clraddr			;raz adresse dans numeros de ligne et etiquettes
	call	updlab			;mise a jour etiquettes
	clc
	ret
doblod3:
	mov	al,err_bac_format	;erreur format binaire
	stc
doblod2:
	ret
doblod4:
	mov	al,err_bad_file		;fichier invalide
	stc
	ret
doblod5:
	mov	al,err_line_num		;numero de ligne invalide
	stc
	ret
doblod6:
; Chargement en extension du programme en memoire
	mov	eax,[ebx].prog.first_line ;premiere ligne programme a charger
	mov	ecx,[ebx].prog.last_line ;derniere ligne
	add	eax,offst		;ajout deplacement
	js	doblod5			;debordement numero de ligne
	add	ecx,offst
	js	doblod5			;debordement numero de ligne
	mov	first,eax		;range pour DELETE
	mov	lastx,ecx
	mov	edi,prog_base		;debut programme en memoire
	mov	[edi].prog.first_line,eax ;range pour LINECHANGE
	mov	[edi].prog.last_line,ecx
	call	progsize		;taille programme en memoire
	add	eax,[ebx].prog.prog_len ;ajout taille programme a charger
	jc	doblod4			;debordement, erreur
	cmp	eax,prog_size		;assez de place en memoire programme ?
	ja	doblod4			;non, erreur
	add	edx,[ebx].prog.sym_len	;ajout taille symboles
	jc	doblod4			;debordement, erreur
	cmp	edx,symb_size		;assez de place en memoire symboles ?
	ja	doblod4			;non, erreur
	call	delete			;effacement lignes en memoire dans intervalle programme a charger (EBX->ligne suivante)
	push	ebx
	call	clraddr			;raz adresse dans numeros de ligne et etiquettes
	pop	ebx			;adresse insertion
	mov	loadoff,ebx		;sauve position chargement
	mov	edi,prog_base		;base memoire programme
	mov	ecx,[edi].prog.prog_len ;longueur programme en memoire
	add	ecx,edi
	mov	esi,ecx			;fin programme en memoire
	sub	ecx,ebx			;longueur a deplacer
	mov	edi,progbuf.prog.prog_len ;longueur programme a charger
	sub	edi,size prog		;moins longueur entete programme et derniere ligne
	jbe	doblod3			;programme vide
	mov	edx,edi			;longueur insertion
	push	esi
	push	edi
	mov	edi,ebx			;fin code non deplace
	call	updpcs			;mise a jour pointeurs programme
	pop	edi
	pop	esi
	push	edi
	add	edi,esi			;nouvelle fin programme en memoire
	dec	esi
	dec	edi
	std				;en arriere
	rep	movsb			;fait la place pour le programme a charger
	cld
	pop	ecx
	call	wfread			;charge code
	jc	doblod2			;erreur
	mov	eax,maxline		;numero maximum ligne
	call	fndlin			;recherche ligne
	add	ebx,last_len		;ajout longueur derniere ligne
	mov	edi,prog_base		;base memoire programme
	sub	ebx,edi			;longueur programme
	mov	[edi].prog.prog_len,ebx	;maj longueur programme
	mov	[edi].prog.prog_line,ecx ;maj nombre de lignes
	mov	ecx,last_len
doblod7:
	call	inch			;saut derniere ligne dans programme a charger 
	jc	doblod2			;erreur
	loop	doblod7
	sub	loadoff,prog_head	;offset programme charge
	call	inch			;lecture premier octet table symboles a charger
	jc	doblod2			;erreur
doblod8:
	cmp	al,0FFh			;fin de table ?
	je	short doblod14		;oui
	mov	vartyp,al		;type symbole
	mov	ebx,offset buffer	;tampon symbole
	mov	stbeg,ebx
	mov	ecx,size_o		;taille offset
doblod9:
	call	inch			;lecture octet
	jc	short doblod16		;erreur
	mov	dl,al			;range
	ror	edx,8
	loop	doblod9			;pour tout l'offset
	mov	ebp,edx			;offset chainage symbole (ECX=0)
doblod10:
	call	inch			;lecture caractere
	jc	short doblod16		;erreur
	test	al,al			;type symbole suivant ?
	js	short doblod11		;oui
	inc	ecx			;un caractere de plus
	mov	[ebx],al		;range dans tampon
	inc	ebx
	jmp	doblod10		;repeat
doblod11:
	push	eax
	mov	al,vartyp		;type variable
	mov	count,cl		;nombre de caracteres
	call	putsym			;ajout symbole
	mov	ebx,ebp			;offset chainage symbole
	mov	edx,symoff		;offset symbole dans table
doblod12:
	test	ebx,ebx			;fin chaine ?
	jz	short doblod13		;oui
	add	ebx,loadoff		;adresse chainage 
	mov	eax,[ebx]		;chainage
	mov	[ebx],edx		;maj offset symbole dans table
	mov	ebx,eax
	jmp	doblod12		;pour toute la chaine
doblod13:
	pop	eax
	jmp	doblod8
doblod14:
	cmp	offst,0			;deplacement nul ?
	je	short doblod15		;oui, pas de mise a jour numeros de ligne (NC)
	mov	ebx,loadoff
	add	ebx,prog_head		;debut programme charge
	mov	eax,[ebx].line.l_number	;numero premiere ligne programme charge
	mov	esi,prog_base		;base memoire programme
	call	linechange		;maj numeros de ligne
doblod15:
	pushfd
	push	eax
	call	updlab			;mise a jour etiquettes
	pop	eax
	popfd
doblod16:
	ret

; Marque les numeros de ligne dans l'intervalle
	align	16
markln:
	mov	ebx,prog_base		;base memoire programme
markln1:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short markln2		;oui
	lea	ebp,[ebx+size line]	;saut entete ligne
	jmp	short markln4
markln2:
	ret
markln3:
	inc	ebp			;mange token
	cmp	al,k_indirect		;indirection ?
	je	markln12		;oui
	cmp	al,k_rem		;REM ?
	je	markln1			;oui, fin de ligne
	cmp	al,k_data		;DATA ?
	je	markln1			;oui, fin de ligne
	cmp	al,k_cr			;EOL ?
	je	markln1			;oui, fin de ligne
markln4:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short markln13		;oui
	test	al,al			;mot cle ?
	jns	markln3			;oui
	test	al,conbit		;constante ?
	jnz	short markln9		;oui
	test	al,labbit		;etiquette ?
	jnz	short markln7		;oui
	add	ebp,1+size_o		;saute token et offset symbole
	jmp	markln4
markln5:
	mov	eax,[ebp+1]		;numero de ligne
	cmp	eax,first		;dans l'intervalle ?
	jb	short markln7		;non
	cmp	eax,lastx
	ja	short markln7		;non
	cmp	dword ptr [ebp+5],0	;adresse ligne connue ?
	jne	short markln6		;oui
	push	ebx
	call	fndlinq			;recherche ligne
	jne	short markln8		;non trouvee
	mov	[ebp+5],ebx		;range adresse ligne
	mov	addrflg,0FFh		;indique adresse positionnee
	pop	ebx
markln6:
	mov	byte ptr [ebp],0FFh	;marque
markln7:
	add	ebp,1+size_i+size_a	;saute token, numero de ligne (ou offset etiquette) et adresse ligne
	jmp	markln4			;repeat
markln8:
	pop	ebx
	jmp	markln6
markln9:
	test	al,strbit		;chaine ?
	jnz	short markln11		;oui
	test	al,linbit		;numero de ligne ?
	jnz	markln5			;oui
	test	al,intbit
	jnz	short markln10
	add	ebp,size_f-size_i	;saut flottant
markln10:
	add	ebp,size_i-1		;saut entier
markln11:
	inc	ebp			;saut token
	inc	ebp			;saut longueur chaine
	movzx	eax,byte ptr [ebp]	;longueur representation
	inc	ebp			;saut longueur representation
	add	ebp,eax			;saut representation
	jmp	markln4			;continue
markln12:
	inc	ebp			;mange token extension
	jmp	markln4
markln13:
	je	short markln14		;espace
	inc	ebp			;saut compte espaces
markln14:
	inc	ebp			;saut espace
	jmp	markln4

; Mise a jour les numeros de ligne
	align	16
updlin:
	mov	ebx,prog_base		;base memoire programme
updlin1:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short updlin2		;oui
	lea	ebp,[ebx+size line]	;saut entete ligne
	jmp	short updlin4
updlin2:
	ret
updlin3:
	inc	ebp			;mange token
	cmp	al,k_indirect		;indirection ?
	je	short updlin10		;oui
	cmp	al,k_rem		;REM ?
	je	updlin1			;oui, fin de ligne
	cmp	al,k_data		;DATA ?
	je	updlin1			;oui, fin de ligne
	cmp	al,k_cr			;EOL ?
	je	updlin1			;oui, fin de ligne
updlin4:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short updlin11		;oui
	test	al,al			;mot cle ?
	jns	updlin3			;oui
	cmp	al,0FFh			;marque ?
	je	short updlin5		;oui
	test	al,conbit		;constante ?
	jnz	short updlin7		;oui
	test	al,labbit		;etiquette ?
	jnz	short updlin6		;oui
	add	ebp,1+size_o		;saute token et offset symbole
	jmp	updlin4
updlin5:
	mov	esi,[ebp+5]		;adresse ligne
	mov	eax,[esi].line.l_number	;numero de ligne
	mov	[ebp+1],eax		;mise a jour
	mov	byte ptr [ebp],tok_mark+conbit+linbit ;restaure token
updlin6:
	add	ebp,1+size_i+size_a	;saute token, numero de ligne (ou offset etiquette) et adresse ligne
	jmp	updlin4			;repeat
updlin7:
	test	al,strbit		;chaine ?
	jnz	short updlin9		;oui
	test	al,linbit		;numero de ligne ?
	jnz	updlin6			;oui
	test	al,intbit
	jnz	short updlin8
	add	ebp,size_f-size_i	;saut flottant
updlin8:
	add	ebp,size_i-1		;saut entier
updlin9:
	inc	ebp			;saut token
	inc	ebp			;saut longueur chaine
	movzx	eax,byte ptr [ebp]	;longueur representation
	inc	ebp			;saut longueur representation
	add	ebp,eax			;saut representation
	jmp	updlin4			;continue
updlin10:
	inc	ebp			;mange token extension
	jmp	updlin4
updlin11:
	je	short updlin12		;espace
	inc	ebp			;saut compte espaces
updlin12:
	inc	ebp			;saut espace
	jmp	updlin4

; Chaine les variables dans le programme
; Important: CLRVARS doit avoir ete execute avant
	align	16
chainvar:
	mov	ebx,prog_base		;base memoire programme
chainvar1:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short chainvar2		;oui
	lea	ebp,[ebx+size line]	;saut entete ligne
	jmp	short chainvar4
chainvar2:
	ret
chainvar3:
	inc	ebp			;mange token
	cmp	al,k_indirect		;indirection ?
	je	short chainvar9	;oui
	cmp	al,k_rem		;REM ?
	je	short chainvar1		;oui, fin de ligne
	cmp	al,k_data		;DATA ?
	je	short chainvar1		;oui, fin de ligne
	cmp	al,k_cr			;EOL ?
	je	short chainvar1		;oui, fin de ligne
chainvar4:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short chainvar10	;oui
	test	al,al			;mot cle ?
	jns	chainvar3		;oui
	test	al,conbit		;constante ?
	jnz	short chainvar6		;oui
	mov	esi,[ebp+1]		;offset symbole
	lea	edx,[ebp+1]		;adresse chainage
	add	esi,symb_base		;pointeur symbole
	sub	edx,prog_base		;offset programme
	xchg	edx,[esi]		;chainage symbole
	mov	[ebp+1],edx
	test	al,labbit		;etiquette ?
	jnz	short chainvar5		;oui
	add	ebp,1+size_o		;saute token et offset symbole
	jmp	chainvar4
chainvar5:
	add	ebp,1+size_i+size_a	;saute token, numero de ligne (ou offset etiquette) et adresse ligne
	jmp	chainvar4		;repeat
chainvar6:
	test	al,strbit		;chaine ?
	jnz	short chainvar8		;oui
	test	al,linbit		;numero de ligne ?
	jnz	chainvar5		;oui
	test	al,intbit
	jnz	short chainvar7
	add	ebp,size_f-size_i	;saut flottant
chainvar7:
	add	ebp,size_i-1		;saut entier
chainvar8:
	inc	ebp			;saut token
	inc	ebp			;saut longueur chaine
	movzx	eax,byte ptr [ebp]	;longueur representation
	inc	ebp			;saut longueur representation
	add	ebp,eax			;saut representation
	jmp	chainvar4		;continue
chainvar9:
	inc	ebp			;mange token extension
	jmp	chainvar4
chainvar10:
	je	short chainvar11	;espace
	inc	ebp			;saut compte espaces
chainvar11:
	inc	ebp			;saut espace
	jmp	chainvar4

; Mise a jour offset variables
; Important: UPDLAB doit etre execute apres
	align	16
updvaro:
	mov	esi,symb_base		;table des symboles
	mov	edi,prog_base		;base memoire programme
	mov	edx,esi
	mov	ebp,esi
	add	edx,[edi].prog.sym_len	;fin table symboles
	dec	ebp			;pour saut type variable
updvaro1:
	cmp	esi,edx			;fin table ?
	jae	short updlab		;oui, mise a jour etiquettes
	mov	ecx,esi
	sub	ecx,ebp			;offset symbole
	xor	eax,eax
	xchg	eax,[esi].symb.s_addr	;debut chaine
updvaro2:
	test	eax,eax			;fin de chaine ?
	mov	ebx,eax			;offset chaine
	jz	short updvaro3		;oui
	add	ebx,edi			;adresse programme
	mov	eax,ecx
	xchg	eax,[ebx]		;maj a jour offset symbole
	jmp	updvaro2		;continue
updvaro3:
	add	esi,size symb		;saut entete symbole
updvaro4:
	lodsb				;caractere
	test	al,al			;type du symbole suivant ?
	jns	updvaro4		;non, continue
	dec	esi			;retour sur type
	jmp	updvaro1		;pour toute la table
updvaro5:
	ret

; Mise a jour numero de ligne etiquettes
	align	16
updlab:
	mov	esi,symb_base		;table des symboles
	mov	edi,prog_base		;base memoire programme
	mov	edx,esi
	add	edx,[edi].prog.sym_len	;fin table symboles
	xor	ah,ah			;indicateur etiquette trouvee
	mov	al,[esi].symb.s_type	;type premier symbole
updlab1:
	cmp	esi,edx			;fin table ?
	jae	short updlab5		;oui
	test	al,labbit		;etiquette ?
	jz	short updlab2		;non
	mov	[esi].symb.s_addr,0	;raz numero de ligne
	mov	ah,0FFh			;indique etiquette trouvee
updlab2:
	add	esi,size symb		;saut entete symbole
updlab3:
	lodsb				;caractere
	test	al,al			;type du symbole suivant ?
	jns	updlab3			;non, continue
	dec	esi			;retour sur type
	jmp	updlab1			;pour toute la table
updlab4:
	ret
updlab5:
	test	ah,ah			;etiquette trouvee ?
	jz	updlab4			;non
	mov	ebx,prog_base		;base memoire programme
updlab6:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	mov	edx,[ebx].line.l_number	;numero ligne suivante
	test	edx,edx			;fin code
	js	updlab4			;oui
	lea	ebp,[ebx+size line]	;saut entete ligne
updlab7:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short updlab9		;oui
	cmp	al,k_sub		;SUB ?
	je	short updlab8		;oui
	cmp	al,k_label		;LABEL ?
	jne	updlab6			;non, ligne suivante
updlab8:
	inc	ebp			;mange SUB, LABEL ou espace
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	short updlab11		;oui
	test	al,al			;mot cle ?
	jns	updlab6			;oui, ligne suivante
	test	al,labbit		;etiquette ?
	jz	updlab6			;non, ligne suivante
	mov	esi,[ebp+1]		;offset etiquette
	add	esi,symb_base		;adresse etiquette
	mov	[esi],edx		;maj numero de ligne
	jmp	updlab6			;ligne suivante
updlab9:
	je	short updlab10		;espace
	inc	ebp			;saut compte espaces
updlab10:
	inc	ebp			;saut espace
	jmp	updlab7
updlab11:
	je	short updlab8		;espace
	inc	ebp			;saut compte espaces
	jmp	updlab8

; Suppression des symboles non utilises
; Important: CLRVARS doit avoir ete execute avant
	align	16
dotasvar:
	call	chainvar		;chaine les variables
	mov	esi,symb_base		;table des symboles
	mov	ebx,prog_base		;base memoire programme
	mov	edx,esi
	mov	edi,esi
	add	edx,[ebx].prog.sym_len	;fin table symboles
	xor	ecx,ecx			;raz compteur symboles
tasvar1:
	cmp	esi,edx			;fin de table ?
	jae	short tasvar8		;oui
	mov	ah,[esi].symb.s_type	;type variable
	cmp	[esi].symb.s_addr,0	;symbole utilise ?
	je	short tasvar6		;non, supprimme
	inc	ecx			;un symbole de plus
	push	ecx
	mov	ecx,size symb
	add	esi,ecx			;saut entete symbole
tasvar2:
	lodsb				;caractere
	inc	ecx
	test	al,al			;type du symbole suivant ?
	jns	tasvar2			;non, continue
	sub	esi,ecx			;debut symbole
	dec	ecx			;ajuste
	test	cmpopt,nosymb		;suppression nom ?
	jnz	short tasvar5		;oui
tasvar3:
	cmp	esi,edi			;recopie necessaire ?
	je	short tasvar4		;non
	rep	movsb			;recopie symbole
	pop	ecx
	jmp	tasvar1
tasvar4:
	add	esi,ecx			;saute symbole
	add	edi,ecx
	pop	ecx
	jmp	tasvar1
tasvar5:
	test	ah,labbit		;etiquette ?
	jnz	tasvar3			;oui, garde nom
	mov	al,[esi].symb.s_type	;recopie type
	mov	[edi].symb.s_type,al
	mov	eax,[esi].symb.s_addr	;recopie adresse
	mov	[edi].symb.s_addr,eax
	add	esi,ecx			;saute symbole
	add	edi,size symb		;saute type et adresse
	pop	ecx
	jmp	tasvar1
tasvar6:
	add	esi,size symb		;saut entete
tasvar7:
	lodsb				;caractere
	test	al,al			;type du symbole suivant ?
	jns	tasvar7			;non, continue
	dec	si			;retour sur type symbole suivant
	jmp	tasvar1
tasvar8:
	mov	byte ptr [edi],0FFh	;fin de table
	sub	edi,symb_base		;taille table
	mov	[ebx].prog.sym_count,ecx ;maj nombre de symboles
	mov	[ebx].prog.sym_len,edi	;maj longueur table symboles
	ret

; Preparation image binaire
; Retour: CF et AL=code si erreur
	align	16
prepbin:
	test	cmpopt,compressed+nosymb+librairy+overlay ;transformation image binaire ?
	jnz	short prepbin2		;oui
	cmp	first,0			;intervalle specifie ?
	jne	short prepbin2		;oui
	cmp	lastx,maxline
	jne	short prepbin2		;oui
	cmp	offst,0			;changement numero premiere ligne ?
	jne	short prepbin2		;oui
	clc				;rien a faire, retour OK
prepbin1:
	ret
prepbin2:
	call	progsize		;longueurs programme
	mov	lcode,eax		;range longueur code
	mov	lsymb,edx		;range longueur table symboles
	call	writetmp		;ecriture programme dans fichier temporaire
	jc	prepbin1		;erreur
	mov	pbinflg,0FFh		;indique preparation image binaire
	mov	eax,first		;debut intervalle
	push	eax
	push	lastx
	dec	eax			;ligne avant intervalle
	mov	lastx,eax		;derniere ligne a effacer
	mov	first,1			;premiere ligne a effacer
	call	delete			;effacement lignes avant intervalle (EBX->ligne suivante)
	mov	esi,prog_base		;base programme
	mov	eax,[ebx].line.l_number	;numero premiere ligne
	mov	[esi].prog.first_line,eax ;range dans image binaire
	pop	eax
	push	eax
	inc	eax			;ligne apres intervalle
	mov	first,eax		;premiere ligne a effacer
	mov	lastx,maxline		;derniere ligne a effacer		
	call	delete			;effacement lignes apres intervalle
	call	clraddr			;raz adresse dans numeros de ligne et etiquettes
	mov	eax,maxline		;numero de ligne maximum
	call	fndlin			;recherche ligne
	je	short prepbin3		;existe!
	mov	ebx,prvlin		;adresse derniere ligne
prepbin3:
	mov	esi,prog_base		;base programme
	mov	eax,[ebx].line.l_number	;numero derniere ligne
	mov	[esi].prog.last_line,eax ;range dans image binaire
	pop	lastx			;restaure intervalle
	pop	first
	mov	pbinflg,0		;raz indicateur preparation image binaire
	or	cmpopt,overlay		;indique image inserable
	test	cmpopt,compressed	;option C ?
	jz	short prepbin4		;non
	call	compress		;compression code
prepbin4:
	call	clrvars			;effacement variables
	call	dotasvar		;chainage variables
	mov	eax,offst		;nouveau numero premiere ligne
	test	eax,eax			;zero ?
	jz	short prepbin5		;oui, pas de decalage (NC)
	mov	esi,prog_base		;debut programme
	sub	eax,[esi].prog.first_line ;decalage
	jz	short prepbin5		;pas de changement (NC)
	add	[esi].prog.first_line,eax ;maj numero premiere ligne
	jle	short prepbin6		;invalide
	add	[esi].prog.last_line,eax ;maj numero derniere ligne
	jle	short prepbin6		;invalide
	mov	offst,eax		;range decalage
	mov	ebx,esi			;debut programme
	call	nextlin			;ligne suivante
	js	short prepbin5		;fin code (NC)
	mov	ebx,esi
	add	ebx,prog_head		;premiere ligne programme
	mov	eax,[ebx].line.l_number	;numero premiere ligne programme
	call	linechange		;mise a jour numeros de ligne (CF si erreur)
prepbin5:
	ret
prepbin6:
	mov	al,err_line_num		;illegal line number
	stc
	ret

; Taille programme en memoire
; Retour: EAX=taille code
;	  EDX=taille symboles
	align	16
progsize:
	push	ebx
	mov	ebx,prog_base		;program segment base
	mov	eax,[ebx].prog.prog_len
	mov	edx,[ebx].prog.sym_len
	pop	ebx
	inc	edx			;prise en compte marque fin de table
	ret

; Mise a jour numeros de ligne
; Entree: EBX->premiere ligne programme charge
;	  EAX=numero premiere ligne programme charge
;	  OFFST=decalage numero de ligne
;	  CF et AL code si erreur
	align	16
linechange1:
	call	checkeol		;fin ligne ?
	jne	short linechange3	;non
linechange2:
	call	nextlin			;ligne suivante
	js	short linechange5	;fin code
linechange:
	add	eax,offst		;nouveau numero de ligne
	cmp	eax,[esi].prog.first_line ;dans intervalle ?
	jb	linechange2		;avant
	cmp	eax,[esi].prog.last_line
	ja	short linechange5	;apres
	mov	[ebx].line.l_number,eax	;maj numero de ligne
	lea	ebp,[ebx+size line]	;pointeur code sur debut ligne
linechange3:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	linechange1		;oui
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	je	short linechange4	;oui
	call	skpop			;saut operande
	jmp	linechange3		;continue
linechange4:
	mov	eax,[ebp+1]		;numero de ligne
	add	ebp,1+size_i+size_a	;mange token, numero de ligne et adresse ligne
	test	eax,eax			;nul ?
	jz	linechange3		;oui, ignore (?)
	add	eax,offst		;nouveau numero
	cmp	eax,[esi].prog.first_line ;dans intervalee
	jb	short linechange6 ;non, erreur
	cmp	eax,[esi].prog.last_line
	ja	short linechange6 ;non erreur
	mov	[ebp-size_a-size_i],eax ;mise a jour
	jmp	linechange3		;token suivant
linechange5:
	clc
	ret
linechange6:
	mov	eax,[ebx].line.l_number
	sub	eax,offst
	mov	erls,eax		;numero ligne original en erreur
	mov	al,err_line_num
	stc
	ret

; Compression programme (suppression commentaires et espaces)
	align	16
compress:
	mov	ebx,prog_base		;base programme
	call	nextlin			;ligne suivante
	mov	edi,ebx			;pointeur destination
compress1:
	mov	esi,ebx			;pointeur source
	call	nextlin			;ligne suivante
	mov	edx,eax			;numero de ligne
	mov	ebp,edi
	movsb				;recopie longueur ligne
	movsd				;recopie numero de ligne	
compress2:
	lodsb				;octet source
	test	al,al			;mot cle ?
	js	short compress6		;non
	cmp	al,k_space		;espace
	je	compress2		;oui, saute
	cmp	al,k_mspace		;espaces multiples ?
	je	short compress4		;non
	stosb				;recopie octet
	cmp	al,k_indirect		;indirection ?
	je	short compress5		;oui
	cmp	al,k_data		;DATA ?
	je	short compress3		;oui
	cmp	al,k_rem		;REM ?
	je	short compress7		;oui
	cmp	al,k_cr			;EOL ?
	jne	compress2		;non
	mov	eax,edi
	sub	eax,ebp
	dec	eax			;nouvelle longueur ligne
	mov	[ebp],al		;maj
	test	edx,edx			;fin programme ?
	jns	compress1		;non, continue
	movzx	ecx,byte ptr [esi]	;longueur derniere ligne
	mov	ebx,prog_base		;program segment base
	inc	ecx			;prise en compte longueur
	rep	movsb			;recopie derniere ligne
	sub	edi,ebx			;nouvelle longueur programme
	mov	[ebx].prog.prog_len,edi	;mise a jour
	ret
compress3:
	movzx	ecx,byte ptr [esi]
	inc	ecx			;prise en compte longueur chaine
	rep	movsb			;recopie longueur et chaine
	jmp	compress2
compress4:
	inc	esi			;saut nombre espaces
	jmp	compress2
compress5:
	movsb				;recopie token extension
	jmp	compress2
compress6:
	stosb				;recopie token
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	je	short compress10	;oui
	test	al,conbit		;constante
	jz	short compress11	;non
	test	al,intbit		;entier ?
	jz	short compress8		;non
	movsd				;recopie entier
compress7:
	xor	ah,ah
	lodsb				;longueur representation origine
	xchg	ah,al
	stosb				;longueur nulle pour representation destination
	movzx	eax,ah
	add	esi,eax			;saut representation origine
	jmp	compress2
compress8:
	test	al,strbit		;chaine ?
	jnz	short compress9		;oui
	movsd				;recopie flottant
	movsd
	jmp	compress7		;representation
compress9:
	movzx	ecx,byte ptr [esi+1]	;longueur representation
	add	ecx,1+1			;prise en compte longueur chaine et longueur representation
	rep	movsb			;recopie longueurs et representation
	jmp	compress2
compress10:
	movsd				;recopie numero de ligne
compress11:
	movsd				;recopie adresse (0) ou offset symbole
	jmp	compress2

; Ligne suivante
; Entree: EBX->ligne courante
; Sortie: EBX->ligne suivante
;	  EAX->numero ligne suivante
;	  S si fin code
	align	16
nextlin:
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	mov	eax,[ebx].line.l_number	;numero ligne suivante
	test	eax,eax			;fin code ?
	ret

; Test fin de ligne (inclut REM et DATA)
; Retour: ZF si fin de ligne
	align	16
checkeol:
	inc	ebp			;saut token
	cmp	al,k_indirect		;indirection ?
	je	short checkeol2		;oui
	cmp	al,k_rem		;REM ?
	je	short checkeol1		;oui, retour ZF
	cmp	al,k_data		;DATA ?
	je	short checkeol1		;oui, retour ZF
	cmp	al,k_cr			;EOL ?
checkeol1:
	ret
checkeol2:
	inc	ebp			;saut token extension
	ret				;retour NZ

; Saut operande
; Entree: AL=token
;	  EBP->token operande
; Sortie: EBP apres operande
	align	16
skpop:
	inc	ebp			;mange token
	test	al,conbit		;constante ?
	jnz	short skpop2		;oui
	test	al,labbit		;etiquette ?
	jnz	short skpop1		;oui
	add	ebp,size_o		;saut offset symbole
	ret
skpop1:
	add	ebp,size_i+size_o	;saute numero de ligne (ou offset symbole) et offset ligne
	ret
skpop2:
	test	al,strbit		;chaine ?
	jnz	short skpop3		;oui
	test	al,linbit		;numero de ligne ?
	jnz	skpop1			;oui
	test	al,intbit
	jnz	short skpo25
	add	ebp,size_f-size_i	;saut flottant
skpo25:
	add	ebp,size_i-1		;saut entier
skpop3:
	inc	ebp			;saut longueur chaine
	movzx	eax,byte ptr [ebp]
	inc	ebp			;saut longueur representation
	add	ebp,eax
	ret

; Test edition autorisee
	align	16
tstned:
	test	noedf,0FFh		;edition source autorisee ?
	jnz	short tstne2		;non, erreur
	ret
tstne2:
	mov	al,err_no_source	;source protege
	jmp	rpter

; Affichage code source programme
; Entree: FIRST et LASTX=intervalle affichage
;	  LISTCOLFLG=indicateur affichage couleur
	align	16
listp:
	mov	ebx,prog_base
	add	ebx,offset prog.begin_prog ;pointeur debut programme
listp1:
	mov	eax,[ebx].line.l_number	;numero de ligne
	test	eax,eax			;fin du code ?
	js	short listp3		;oui
	cmp	eax,first		;dans intervalle ?
	jb	short listp2		;non
	cmp	eax,lastx		
	ja	short listp3		;non
	push	ebx
	add	ebx,size line		;saut entete ligne
	mov	ecx,5			;5 caracateres minimum pour l'affichage du numero de ligne
	call	decode			;decodage ligne
	mov	esi,offset buffer
	call	pmsg			;affichage ligne
	call	pcrlf			;saut de ligne
	pop	ebx
listp2:
	movzx	eax,[ebx].line.l_len	;longueur ligne
	lea	ebx,[ebx+eax+1]		;ligne suivante
	jmp	short listp1
listp3:
	ret

if	debug_mem
checkds:
	push	eax
	push	ebx
	push	esi
	mov	esi,offset fstavl	;pointeur sur debut chaine memoire libre
	mov	ebx,data_base		;debut segment de donnees
check1:
	mov	eax,[esi].free_mem.link	;chainage
	and	eax,eax			;fin de chaine ?
	jz	short check3		;oui
	cmp	eax,data_base		;dans segment de donnees ?
	jb	short check2		;non, erreur
	cmp	eax,data_end
	jae	short check2		;non, erreur
	cmp	eax,ebx			;apres bloc libre precedent ?
	jb	short check2		;non, erreur
	mov	ebx,eax
	add	ebx,[ebx].free_mem.len	;fin bloc libre
	jc	short check2		;debordement, erreur
	cmp	ebx,data_end		;dans segment de donnees ?
	ja	short check2		;non, erreur
	mov	esi,eax
	jmp	check1			;continue
check2:
	int	3
	jmp	check2
check3:
	cmp	ebx,data_end		;fin segment ?
	jne	check2			;non
	pop	esi
	pop	ebx
	pop	eax
	ret
endif	;debug_mem

; Allocation memoire donnees
; Entree: EAX=taille memoire
; Sortie: EBX->memoire allouee
	align	16
allocds:
if	debug_mem
	call	checkds			;test chaine memoire libre
endif	;debug_mem
	add	eax,size free_mem-1
	push	esi
	push	edi
	and	al,not (size free_mem-1) ;alignement sur taille entete
	mov	esi,offset fstavl	;pointeur sur debut chaine memoire libre
	add	eax,size free_mem	;ajout taille entete
alloc1:
	mov	edi,esi
	mov	esi,[esi].free_mem.link	;bloc libre suivant
	test	esi,esi			;fin de chaine ?
	je	short alloc3		;oui
	cmp	eax,[esi].free_mem.len	;assez de memoire dans ce bloc ?
	ja	alloc1			;non, continue
alloc2:
	sub	eax,size free_mem	;retranche taille entete
	mov	ebx,esi			;adresse memoire allouee
	add	esi,eax			;pointeur nouvel entete
	mov	[edi].free_mem.link,esi	;reservation memoire
	mov	edx,[ebx].free_mem.link
	mov	[esi].free_mem.link,edx	;recopie chainage
	mov	edx,[ebx].free_mem.len
	sub	edx,eax			;ajuste longueur bloc
	mov	[esi].free_mem.len,edx	;dans nouvel entete
	pop	edi
	pop	esi
	ret
alloc3:
	pop	edi
	pop	esi
	mov	al,err_memory_ovf	;debordement memoire
	jmp	rpter

; Liberation memoire donnnees
; Entree: EAX=taille memoire
;	  EBX->memoire a liberer
	align	16
freeds:
if	debug_mem
	call	checkds			;test chaine memoire libre
endif	;debug_mem
	test	ebx,ebx			;pointeur nul ?
	jz	short free5		;oui, ignore
	test	eax,eax			;longueur nulle ?
	jz	short free5		;oui, ignore
	add	eax,size free_mem-1
	push	esi
	push	edi
	and	al,not (size free_mem-1) ;alignement sur taille entete
	mov	esi,offset fstavl	;pointeur sur debut chaine memoire libre
free1:
	mov	edi,esi
	mov	esi,[esi].free_mem.link	;bloc libre suivant
	cmp	ebx,esi			;memoire a liberer avant bloc libre suivant ?
	ja	free1			;non, continue
	mov	edx,[edi].free_mem.len
	add	edx,edi			;fin bloc libre precedent
	cmp	ebx,edx			;fini a la memoire a liberer ?
	jne	free2			;non
	add	[edi].free_mem.len,eax	;etend le bloc libre precedent
	jmp	short free3
free2:
	mov	[edi].free_mem.link,ebx	;chaine nouveau bloc libre
	mov	edi,ebx
	mov	[ebx].free_mem.link,esi
	mov	[ebx].free_mem.len,eax	;longueur nouveau bloc libre
free3:
	mov	edx,[edi].free_mem.len
	add	edx,edi			;fin nouveau bloc libre
	cmp	edx,esi			;fini au bloc libre suivant ?
	jne	short free4		;non
	mov	edx,[esi].free_mem.link
	mov	[edi].free_mem.link,edx	;fusionne les 2 blocs libres
	mov	edx,[esi].free_mem.len
	add	[edi].free_mem.len,edx	;ajust longueur nouveau bloc libre
free4:
	pop	edi
	pop	esi
free5:
	ret

	public	sbmemalloc
	public	sbmemfree
	public	sbprintstr

;allocation memoire
;PUCHAR SbMemAlloc(ULONG Size)
sbmemalloc:
	push	ebx
	mov	eax,[esp+2*4]		;Size
	call	allocds			;allocation memoire
	mov	eax,ebx			;retour pointeur memoire
	pop	ebx
	ret

;liberation memoire
;VOID SbMemFree(PUCHAR Ptr, ULONG Size)
sbmemfree:
	push	ebx
	mov	eax,[esp+3*4]		;Size
	mov	ebx,[esp+2*4]		;Ptr
	call	freeds			;liberation memoire
	pop	ebx
	ret

;affichage chaine terminee par zero
;VOID SbPrintStr(PUCHAR Str)
sbprintstr:
	push	esi
	mov	esi,[esp+2*4]		;Str
sbpstr1:
	lodsb				;caratere
	test	al,al			;fin de chaine ?
	jz	short sbpstr2		;oui
	call	outch			;affichage caractere
	jmp	sbpstr1
sbpstr2:
	pop	esi
	ret

	end