	page	,132
	name	inout

	public	lprint
	public	print
	public	input
	public	xread

	.model	flat,c

	include sbasic.inc

	.data
;Variables entrees/sorties
pustr		dd	?		;adresse chaine PRINT USING
puptr		dd	?		;pointeur chaine PRING USING
pulen		dd	?		;longueur chaine PRINT USING
trmflg		db	?		;indicateur terminaison PRINT
pexflg		db	?		;indicateur expression PRINT
puflg		db	?		;indicateur PRINT USING
eoform		db	?		;indicateur fin de chaine PRINT USING
inform		db	?		;indicateur dans format
readflg		db	?		;indicateur READ
dataflg		db	?		;indicateur donnes dans tampon
;compteurs format PRINT USING
pucount		label byte
puexc		db	?		;!
pubs		db	?		;\
pudp		db	?		;.
pudig		db	?		;chiffre
pudol		db	?		;$
puast		db	?		;*
pucom		db	?		;,
puup		db	?		;^
rsign		db	?		;-

	.code
	extrn	synerr:near
	extrn	rpter:near
	extrn	eval:near,subexp:near
	extrn	strcnt:near,pshstr:near
	extrn	strtox:near,nxtsc:near
	extrn	pulbyt:near
	extrn	allocds:near,freeds:near
	extrn	comtok:near
	extrn	floatr0:near
	extrn	skipsps:near
	extrn	ftoa:near,itoa:near,atof:near
	extrn	exec:near
	extrn	pmsg:near
	extrn	getasn:near,doasv:near,dosas:near
	extrn	outchn:near,inchn:near
	extrn	outch:near,inbuf:near
	extrn	prnon:near,prnoff:near
	extrn	pcrlf:near
	extrn	TextCols:dword

; Invite entree
qust	db	'?',eot

; LPRINT
	align	16
lprint:
	call	prnon			;activation impression
;;;	jmp	short print

; PRINT
print:
	inc	ebp			;mange PRINT ou LPRINT
	xor	eax,eax
	mov	trmflg,al		;raz indicateur terminaison
	mov	pexflg,al		;raz indicateur expression
	mov	puflg,al		;raz indicateur PRINT USING
	mov	eoform,al		;fin de chaine PRINT USING
	mov	format,al		;format automatique
	call	outchn			;canal de sortie
	cmp	al,k_using		;USING ?
	jne	short print1		;non
	inc	ebp			;mange USING
	skipst				;saut espace et token
	mov	puflg,0FFh		;indique PRINT USING
	mov	eoform,0FFh		;non fin de chaine PRINT USING
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	print10			;non, erreur
	call	strcnt			;longueur chaine
	test	eax,eax			;nulle ?
	jz	print10			;oui, erreur
	inc	eax			;plus fin de chaine
	mov	pulen,eax		;longueur chaine PRINT USING
	call	allocds			;allocation memoire
	mov	pustr,ebx		;adresse chaine PRINT USING
	mov	puptr,ebx		;pointeur chaine PRINT USING
	call	strtox			;copie chaine
	mov	byte ptr [ebx],0	;marque de fin
	call	comtok			;mange ,
print1:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short print2		;non
	cmp	al,k_colon		;fin instruction ?
	jae	print7			;oui
	cmp	al,k_else		;ELSE ?
	je	print7			;oui
	cmp	al,k_comma		;, ?
	je	print11			;oui
	cmp	al,k_semicolon		;; ?
	je	print14			;oui
print2:
	test	trmflg,0FFh		;terminaison faite ?
	jnz	short print3		;oui
	test	pexflg,0FFh		;expression en cours ?
	jnz	print10			;oui, erreur
print3:
	mov	trmflg,0		;raz indicateur terminaison
	mov	pexflg,0FFh		;indique expression
	cmp	al,k_spc		;SPC ?
	je	print19			;oui
	cmp	al,k_tab		;TAB?
	je	print22			;oui
	call	eval			;evalue expression
	test	puflg,0FFh		;PRINT USING ?
	jnz	print4			;oui
	test	strflg,0FFh		;expression chaine ?
	jnz	print17			;oui
	test	al,intbit		;expression entiere ?
	jz	short print5		;non
	call	itoa			;conversion entier en ASCII
	jmp	short print6
print4:
	call	pusing			;traitement PRINT USING
	jmp	print1			;continue
print5:
	call	ftoa			;convertion flottant en ASCII
print6:
	mov	esi,offset outbuf	;tampon sortie
	call	pmsg			;affichage
	jmp	print1			;continue
print7:
	test	trmflg,0FFh		;terminaison faite ?
	jnz	short print8		;oui
	call	pcrlf			;retour a la ligne
print8:
	mov	filswo,0		;plus de fichier de sortie
	test	puflg,0FFh		;PRINT USING ?
	jz	short print9		;non
	mov	ebx,pustr		;adresse chaine PRINT USING
	mov	eax,pulen		;pointeur chaine PRINT USING
	call	freeds			;liberation tampon
print9:
	call	prnoff			;desactivation impression
	jmp	exec			;fin execution ligne
print10:
	jmp	synerr			;erreur de syntaxe
print11:
; Traitement ,
	call	tstcol			;ligne affichage pleine ?
	jnc	short print13		;non
print12:
	call	pcrlf			;retour a la ligne
	jmp	short print15
print13:
	not	al
	and	al,0Fh
	inc	al			;nombre d'espaces jusqu'a tabulation
	test	eoform,0FFh		;fin de chaine PRINT USING ?
	jnz	short print15		;non
	call	outbs			;affichage espaces
	jmp	short print15
print14:
; Traitement ;
	call	tstcol			;ligne affichage pleine ?
	jc	print12			;oui
print15:
	mov	trmflg,0FFh		;indique terminaison faite
	inc	ebp			;mange , ou ;
print16:
	jmp	print1			;continue
print17:
; Traitement chaine
	mov	strflg,0		;raz indicateur expression chaine
	mov	first,0			;pour NXTSC
print18:
	call	nxtsc			;caractere chaine suivant
	jz	print16			;fin de chaine
	call	outch			;affichage caractere
	jmp	print18			;pour toute la chaine
print19:
; Fonction SPC
	call	prfun			;parametre fonction
	jz	short print21		;nul
print20:
	call	outbs			;affichage espaces
print21:
	jmp	print1			;continue
print22:
; Fonction TAB
	call	prfun			;parametre fonction
	jz	print21			;nul
	mov	bl,al
	call	tstcol			;colonne courante
	dec	bl			;base 0
	sub	bl,al			;caracteres jusqu'a position demandee
	jbe	print21			;deja au dela
	mov	al,bl
	jmp	print20			;affichage espaces

; Evaluation parametre fonction
; Retour: AL=parametre
;	  ZF si parametre nul
	align	16
prfun:
	inc	ebp			;mange SPC ou TAB
	skipst				;saut espace et token
	initexp				;initialise piles evaluation expression
	call	subexp			;evaluation sous expression
	jz	short prfun4		;erreur
	call	pulbyt			;octet
	test	al,al			;nul ?
	ret
prfun4:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Affichage expression avec format
; Entree: AL=type variable
	align	16
pusing:
	test	strflg,0FFh		;expression chaine ?
	jz	short pusing1		;non
	mov	al,strbit		;type chaine
pusing1:
	push	eax
	mov	edi,offset pucount	;compteurs PRINT USING
	mov	ecx,putablen
	xor	al,al
	rep	stosb			;raz compteurs
	mov	inform,al		;raz compteur dans format
	inc	al
	mov	format,al		;pas de format scientifique
	mov	eoform,0FFh		;non fin de chaine PRINT USING
	xor	eax,eax
	mov	word ptr puleft,ax	;raz PULEFT et PURIGHT
	mov	first,eax		;pour NXTSC
	call	puform			;extrait un format de la chaine PRINT USING
	pop	eax			;type expression
	jz	short pusing5		;format nombre
	test	al,strbit		;chaine ?
	jz	short pusing4		;non, type incompatible
	mov	strflg,0		;raz indicateur expression chaine
	movzx	ecx,cl			;nombre de caracteres de la chaine PRINT USING
pusing2:
	call	nxtsc			;caractere expression chaine
	jz	short pusing3		;fin de chaine
	call	outch			;affichage caractere
	loop	pusing2			;tant que le format PRINT USING le permet
	ret
pusing3:
	mov	al,cl			;reste caracteres
	jmp	outbs			;complement pour le format PRINT USING
pusing4:
	mov	al,err_pu_type
	jmp	rpter
pusing5:
	test	al,strbit		;chaine ?
	jnz	pusing4			;type incompatible
	test	al,intbit		;entier ?
	jz	short pusing6		;non
	call	floatr0			;conversion en flottant
pusing6:
	call	ftoa			;conversion en chaine ASCII
	test	ftoaerr,0FFh		;erreur conversion ?
	jnz	pusing19		;oui
	cmp	pucom,0			;, ?
	mov	esi,offset outbuf	;tampon de sortie
	je	short pusing11		;non
	call	finddp			;recherche point decimal dans la chaine ASCII
pusing7:
	dec	esi			;recule
	mov	ecx,3			;pour trois chiffres
pusing8:
	cmp	esi,offset outbuf	;debut tampon ?
	je	short pusing10		;oui
	mov	al,[esi]		;caractere
	dec	esi			;recule
	cmp	al,'9'			;chiffre ?
	ja	short pusing10		;non
	cmp	al,'0'
	jb	short pusing10		;non
	loop	pusing8			;jusqu'a trois
	mov	ah,[esi]		;caractere precedent
	cmp	ah,'9'			;chiffre aussi
	ja	short pusing10		;non
	cmp	ah,'0'
	jb	short pusing10		;non
	push	esi
	cmp	esi,offset outbuf	;debut tampon ?
	je	short pusing19		;oui, pas assez de place
	mov	al,','			;separateur
pusing9:
	xchg	al,[esi]		;insertion
	dec	esi
	cmp	esi,offset outbuf	;debut de tampon ?
	ja	pusing9			;non, continue le decalage
	cmp	byte ptr [esi],' '	;espace pour finir le decalage ?
	jne	short pusing19		;non, erreur
	mov	[esi],al		;range dernier caractere
	pop	esi
	jmp	pusing7			;continue l'insertion de separateurs
pusing10:
	mov	esi,offset outbuf
pusing11:
	cmp	puast,0			;remplissage par * ?
	je	short pusing13		;non
	cmp	byte ptr [esi],' '	;espace pour remplissage ?
	mov	al,'*'
	jne	short pusing19		;non, erreur
pusing12:
	mov	[esi],al		;remplissage
	inc	esi
	mov	ah,[esi]		;caractere remplissage
	cmp	ah,'-'			;- ?
	je	short pusing19		;oui, erreur
	cmp	ah,' '			;espace ?
	je	pusing12		;oui, continue le remplissage
pusing13:
	cmp	pudol,0			;$ ?
	je	short pusing16		;non
	cmp	byte ptr [esi],' '	;espace ?
	jne	short pusing19		;non, erreur
pusing14:
	cmp	byte ptr [esi+1],' '	;caractere suivant espace ?
	jne	short pusing15		;non
	inc	esi			;avance
	jmp	pusing14		;jusqu'au dernier espace
pusing15:
	cmp	byte ptr [esi+1],'-'	;- ?
	je	short pusing19		;oui, erreur
	mov	byte ptr [esi],'$'	;positionne $
pusing16:
	cmp	pudp,0			;point decimal demande ?
	jne	short pusing18		;oui
	call	finddp			;recherche point decimal dans la chaine ASCII
pusing17:
	mov	al,[esi+1]		;supression point decimal
	mov	[esi],al
	inc	esi
	cmp	al,eot			;fin chaine ?
	jne	pusing17		;non, continue
pusing18:
	mov	esi,offset outbuf
	jmp	pmsg			;affichage chaine modifiee
pusing19:
	mov	al,'%'			;affichage marque erreur
	call	outch
	jmp	pusing18		;affichage resultat

; INPUT
	align	16
input:
	inc	ebp			;mange INPUT
	xor	al,al
	mov	readflg,al		;raz indicateur READ
	mov	dataflg,al		;raz indicateur donnees dans tampon
	skipst				;saut espace et token
	cmp	al,k_line		;LINE ?
	je	inlin			;oui, lecture ligne
	call	inchn			;canal d'entree
input1:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short input4		;oui, erreur
	test	al,conbit+labbit	;variable ?
	jz	short input5		;oui
	test	al,conbit+strbit	;constante chaine ?
	jz	short input4		;non
	test	readflg,0FFh		;READ ?
	jnz	short input4		;oui, erreur
	inc	ebp			;saut token
	movzx	ecx,byte ptr [ebp]	;longeur chaine
	inc	ebp			;saut longueur chaine
	movzx	edx,byte ptr [ebp]	;longueur representation
	inc	ebp			;saut longueur representation
	push	ebp
	inc	ebp			;saut ' ou "
	jecxz	short input3		;longueur nulle, ignore
input2:
	mov	al,[ebp]		;caractere chaine
	inc	ebp
	call	outch			;affiche caractere
	loop	input2			;pour toute la chaine
input3:
	pop	ebp
	add	ebp,edx			;saut representation
	mov	dataflg,0		;raz indicateur donnees dans tampon
	jmp	short input11		;element suivant
input4:
	jmp	synerr			;erreur de syntaxe
input5:
	mov	ah,readflg		;READ ?
	or	ah,dataflg		;ou donnees dans tampon ?
	jnz	short input6		;oui
	call	indata			;entree donnees dans tampon
input6:
	push	eax
	call	getasn			;adresse affectation variable
	pop	eax
	test	al,strbit		;variable chaine ?
	jnz	short input9		;oui
	and	al,unused+intbit+linbit+strbit ;garde type variable
	mov	asntype,al		;range pour l'affectation
input7:
	call	getfp			;lecture nombre depuis tampon donnees
	jnz	short input8		;trouvee
	call	moredata		;demande plus de donnees
	jmp	input7
input8:
	mov	al,fltbit		;type flottant
	call	doasv			;execution affectation variable
	jmp	short input11		;element suivant
input9:
	mov	ebx,offset strstk	;initialisation pile chaines
	mov	strtos,ebx
	mov	strsptr,ebx
input10:
	call	getst			;extraction chaine du tampon de donnees
	jz	short input13		;tampon donnees vide
	mov	ssptr,ebx		;pointeur chaine pour PSHST
	call	pshstr			;PUSH chaine
	mov	strflg,0		;raz indicateur expression chaine
	call	dosas			;execution affectation chaine
input11:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	input4			;non, erreur
	cmp	al,k_comma		;, ?
	je	short input12		;oui, continue
	cmp	al,k_semicolon		;; ?
	jne	short input14		;non, fin INPUT
input12:
	inc	ebp			;mange separateur
	jmp	input1			;continue
input13:
	call	moredata		;demande plus de donnees
	jmp	short input10
input14:
	mov	filswi,0		;plus de fichier d'entree
	jmp	exec			;fin execution ligne

; INPUT LINE
	align	16
inlin:
	inc	ebp			;mange LINE
	mov	eax,offset strstk	;initialisation pile chaines
	mov	strtos,eax
	mov	strsptr,eax
	call	inchn			;canal d'entree
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short inlin8		;oui, erreur ?
	cmp	al,tok_mark+strbit	;variable chaine ?
	je	short inlin2		;oui
	cmp	al,tok_mark+arrbit+strbit ;tableau chaine ?
	jne	short inlin8		;non, erreur
inlin2:
	call	getasn			;adresse affectation variable
	call	indata			;entree donnees dans tampon
	mov	ebx,inptr		;pointeur caractere tampon entree
	mov	ssptr,ebx		;pointeur sous-chaine pour PSHST
	xor	ah,ah			;compteur
inlin4:
	mov	al,[ebx]		;caractere
	inc	ebx			;mange caractere
	cmp	al,cr			;fin de ligne ?
	je	short inlin5		;oui
	inc	ah			;un caractere de plus
	jmp	inlin4			;continue
inlin5:
	movzx	eax,ah			;longueur chaine
	call	pshstr			;PUSH chaine
	mov	strflg,0		;raz indicateur expression chaine
	call	dosas			;execution affectation chaine
	mov	filswi,0		;plus de fichier d'entree
	jmp	exec			;fin execution ligne
inlin8:
	mov	al,err_var_type		;type variable invalide
	jmp	rpter

; READ
	align	16
xread:
	inc	ebp			;mange READ
	mov	readflg,0FFh		;indique READ
read1:
	mov	ebx,datapt		;pointeur DATA
	test	ebx,ebx			;defini ?
	jz	short read3		;non, recherche DATA
	mov	inptr,ebx		;maj pointeur caractere
	jmp	input1			;entree
read3:
	mov	ebx,dataln		;ligne DATA
	call	fdata1			;pointeur DATA
	jmp	input1			;entree

;Table des caracteres format PRINT USING
putab	db	'!','\','.','#','$','*',',','^','-',0
putablen equ	$-offset putab

	align	16
putabx	dd	offset puform13		;!
	dd	offset puform12		;\
	dd	offset puform1		;.
	dd	offset puform5		;#
	dd	offset puform7		;$
	dd	offset puform7		;*
	dd	offset puform10		;,
	dd	offset puform1		;^
	dd	offset puform11		;-

; Extraction format de la chaine PRINT USING
; Retour si chaine: NZ et CL=nombre de caracteres
	align	16
puform:
	mov	ebx,puptr		;pointeur format
puform1:
	mov	al,[ebx]		;caractere
	test	al,al			;fin de chaine PRINT USING ?
	jz	puform17		;oui
	inc	ebx			;saut caractere
	cmp	pubs,0			;entre \ ?
	je	short puform2		;non
	inc	pubs			;oui, un caratere de plus
	cmp	al,'\'			;second \ ?
	jne	puform1			;non, caractere suivant
	jmp	puform16		;finalise
puform2:
	mov	edi,offset putab	;table des caracteres format
	mov	ecx,putablen		;longueur table
	repne	scasb			;recherche caractere
	je	short puform4		;trouve
	cmp	inform,0		;dans un format ?
	jne	puform15		;oui
puform3:
	call	outch			;affiche caractere
	jmp	puform1			;caractere suivant
puform4:
	sub	edi,offset putab+1	;index caractere
	inc	inform			;compte dans format
	inc	pucount[edi]		;compte caractere
	jmp	putabx[edi*4]		;traitement
puform5:
; #
	cmp	pudp,0			;#, avant point decimal ?
	je	short puform6		;oui
	inc	puright			;compte chiffre a droite
	jmp	puform1			;caractere suivant
puform6:
	inc	puleft			;compte chiffre a gauche
	jmp	puform1			;caractere suivant
puform7:
; $ ou *
	cmp	al,[ebx]		;paire de $ ou de * ?
	jne	short puform8		;non
	cmp	inform,1		;deja dans format ?
	ja	short puform14		;oui, nouveau format
	add	puleft,2		;indique 2 caracteres a gauche du point decimale
	inc	ebx			;saut second caractere
	jmp	puform1			;caractere suivant
puform8:
	cmp	inform,1		;deja dans format ?
	ja	short puform14		;oui, nouveau format
puform9:
	dec	pucount[edi]		;decompte caractere
	dec	inform			;decompte dans format
	jmp	puform3			;affiche caractere
puform10:
; ,
	cmp	pudp,0			;apres point decimal ?
	jne	short puform14		;oui, nouveau format
	cmp	puleft,0		;dans un nombre ?
	je	short puform9		;non, affichage
	inc	puleft			;un caractere a gauche du point decimale
	jmp	puform1			;caractere suivant
puform11:
; -
	mov	al,puleft		;dans un nombre ?
	or	al,puright
	jz	puform9			;non, affichage
	jmp	short puform16		;fin format
puform12:
; \
	cmp	inform,1		;deja dans format ?
	ja	short puform14		;oui, nouveau format
	jnz	short puform14		;oui, nouveau format
	jmp	puform1			;caractere suivant
puform13:
; !
	cmp	inform,1		;deja dans format ?
	jbe	short puform16		;non, debut format
puform14:
	dec	pucount[edi]		;decompte caractere
puform15:
	dec	ebx			;retour sur caractere
puform16:
	cmp	byte ptr [ebx],0	;fin de chaine PRINT USING ?
	jne	short puform18		;non
puform17:
	mov	ebx,pustr		;retour en debut de chaine
	mov	eoform,0		;fin de chaine PRINT USING
puform18:
	mov	puptr,ebx		;maj pointeur chaine PRINT USING
	mov	al,puup			;nombre de ^
	test	al,al
	jz	short puform19		;aucun
	cmp	al,4			;exactement 4 ?
	jne	short puform20		;non, erreur
	cmp	pucom,0			;, ?
	jne	short puform20		;oui, erreur
	mov	al,puast		;* ou ^ ?
	or	al,pudol
	jnz	short puform20		;oui, erreur
	mov	al,puleft		;nombre ?
	or	al,puright
	jz	short puform20		;non, erreur
	mov	format,-1		;indique format scientifique
puform19:
	cmp	pudp,1			;plusieurs points decimaux ?
	ja	short puform20		;oui, erreur
	cmp	inform,0		;dans un format ?
	je	short puform20		;non, erreur
	mov	cl,pubs			;chaine ?
	or	cl,puexc		;retour NZ si chaine
	ret
puform20:
	mov	al,err_pu_format	;erreur format PRINT USING
	jmp	rpter

; Entree donnes dans tampon
	align	16
indata:
	push	eax
	movsx	eax,filswi		;redirection entree ou sortie ?
	or	eax,oport
	or	eax,iport
	jnz	short indat2		;oui
	mov	esi,offset qust
	call	pmsg			;affichage invite entree
indat2:
	mov	inflg,0FFh		;indique INPUT
	call	inbuf			;entree ligne
	mov	inflg,0			;raz indicateur INPUT
	mov	dataflg,0FFh		;indique donnees dans tampon
	pop	eax
	ret

; Demande plus de donnees
	align	16
moredata:
	test	readflg,0FFh		;READ ?
	je	indata			;non, entree donnees dans tampon
;;;	jmp	short fdata		;ligne DATA suivante

; Positionnement pointeur DATA
; Retour: INPT->donnees
fdata:
	mov	ebx,dataln		;ligne DATA
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short fdata5		;oui, erreur
	movzx	eax,[ebx].line.l_len
	lea	ebx,[ebx+eax+1]		;ligne suivante
	mov	dataln,ebx		;ligne suivante
fdata1:
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short fdata5		;oui, erreur
	mov	esi,ebx
	add	ebx,size line		;saut entete ligne
fdata2:
	mov	al,[ebx]		;token
	test	al,al			;mot cle ?
	js	short fdata		;non, saut ligne
	cmp	al,k_space		;espace(s) ?
	jae	short fdata3		;oui
	cmp	al,k_data		;DATA ?
	jne	short fdata		;non, saut ligne
	inc	ebx			;mange DATA
	inc	ebx			;saut longueur representation
	mov	datapt,ebx		;pointeur DATA
	mov	inptr,ebx		;maj pointeur caractere
	ret
fdata3:
	je	short fdata4		;un seul
	inc	ebx			;saut nombre espaces
fdata4:
	inc	ebx			;saut token
	jmp	fdata2
fdata5:
	mov	al,err_read_data	;erreur DATA
	jmp	rpter

; Test remplissage ligne
; Retour: AL=colonne courante
;	  CF si ligne pleine
	align	16
tstcol:
	push	ebx
	test	filswo,0FFh		;sortie sur fichier ?
	mov	ah,max_cols		;maximum colonnes par defaut
	jnz	short tstco3		;oui
	mov	ebx,oport		;port de sortie
	mov	al,colm[ebx]		;colonne
	test	ebx,ebx			;port 0 ?
	jnz	short tstco1		;non
	mov	ah,byte ptr TextCols	;colonnes ecran
tstco1:
	push	eax
	mov	pexflg,0		;raz indicateur expression
	add	al,print_room		;ajout garde
	jc	short tstco2		;debordement
	cmp	ah,al			;place restante ? CF si non
tstco2:
	pop	eax
	pop	ebx
	ret
tstco3:
	mov	ebx,fcbout		;FCB fichier de sortie
	mov	al,[ebx].fcb.fcb_fcolm	;colonne
	jmp	tstco1

; Affichage espaces
; Entree: AL=nombre espaces (non nul)
	align	16
outbs:
	push	eax
	mov	al,' '
	call	outch			;affichage espace
	pop	eax
	dec	al
	jnz	outbs			;tant que demande
	ret

; Recherche du point decimale
; Entree: ESI->chaine
; Sortie: ESI->position dans la chaine
	align	16
finddp:
	cmp	byte ptr [esi],'.'	;. ?
	je	short finddp1		;oui
	inc	esi
	jmp	finddp
finddp1:
	ret

; Lecture nombre depuis tampon donnees
; Retour: ZF si fin tampon donnees
;	  R0=donnee flottante
	align	16
getfp:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	cmp	ah,cr			;fin de ligne ?
	je	short getfp4		;oui, retour ZF
	mov	inptr,ebx		;maj pointeur caractere
	call	atof			;conversion chaine en flottant dans R0
getfp1:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	cmp	ah,cr			;fin de ligne ?
	je	short getfp2		;oui
	cmp	ah,','			;, ?
	jne	short getfp5		;non, erreur
	inc	ebx			;mange ,
getfp2:
	mov	inptr,ebx		;maj pointeur caractere
	test	readflg,0FFh		;READ ?
	jz	short getfp3		;non
	mov	datapt,ebx		;maj pointeur DATA
getfp3:
	xor	al,al
	dec	al			;retour NZ
getfp4:
	ret
getfp5:
	mov	al,err_no_fit		;erreur entree
	jmp	rpter

; Extraction chaine du tampon de donnees
; Retour: EAX=longueur
;	  ZF si tampon donnees vide
	align	16
getst:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	cmp	ah,cr			;fin de ligne ?
	je	short getst9		;oui
	mov	len,0			;raz longueur
	cmp	ah,'"'			;" ?
	je	short getst5		;oui
	cmp	ah,quote		;' ?
	je	short getst5		;oui
	mov	stbeg,ebx		;debut chaine
getst2:
	inc	len			;un caractere de plus
	cmp	ah,cr			;fin de ligne ?
	je	short getst8		;oui
	cmp	ah,','			;, ?
	je	short getst8		;oui
	inc	ebx			;mange caractere
	mov	ah,[ebx]		;caractere suivant
	jmp	getst2			;continue
getst5:
	inc	ebx			;mange " ou '
	mov	stbeg,ebx		;debut chaine
	mov	al,ah			;range separateur
gets55:
	inc	len			;un caractere de plus
	mov	ah,[ebx]		;caractere suivant
	inc	ebx			;mange
	cmp	ah,al			;separateur ?
	je	short getst8		;oui
	cmp	ah,cr			;fin de ligne ?
	jne	gets55			;non, continue
	jmp	getfp5			;erreur
getst8:
	mov	inptr,ebx		;maj pointeur caractere
	call	getfp1			;fin extraction
	mov	eax,len			;longueur
	dec	eax			;moins caractere de fin
	mov	ebx,stbeg		;debut chaine
	test	ebx,ebx			;retour NZ
getst9:
	ret

	end