	page	,132
	name	basic

	public	strtbasic
	public	exitbasic
	public	exittrue
	public	ready
	public	ready1
	public	ready5
	public	exec
	public	stop1
	public	gotoln

	.model	flat,c

	include sbasic.inc

	.code
	extrn	inbuf:near,edit:near,editx:near
	extrn	cursor:near
	extrn	cleargraphic:near
	extrn	gr:near,hgr:near,text:near,clrg:near,color:near
	extrn	plot:near,window:near,xmask:near,move:near
	extrn	setcolor:near,setblink:near,dash:near
	extrn	pen:near,symbol:near,arc:near,draw:near,port:near
	extrn	fill:near,gget:near,gput:near
	extrn	dimchn:near
	extrn	fldchn:near
	extrn	get:near,put:near
	extrn	chd:near,unlock:near,lockx:near
	extrn	inivar:near
	extrn	clsall:near
	extrn	open:near
	extrn	setflx:near
	extrn	wfopenread:near
	extrn	wfopenwrite:near
	extrn	wfread:near
	extrn	wfwrite:near
	extrn	wfclose:near
	extrn	wfsize:near
	extrn	readtmp:near
	extrn	close:near
	extrn	kill:near
	extrn	rename:near
	extrn	outdec:near
	extrn	outdecx:near
	extrn	pcrlf:near
	extrn	outch:near
	extrn	setfls:near
	extrn	reset:near
	extrn	print:near
	extrn	lprint:near
	extrn	input:near
	extrn	xread:near
	extrn	calllib:near
	extrn	compcmd:near
	extrn	encode:near
	extrn	synerr:near,clsch:near
	extrn	searchk:near,rpter:near,rpter4:near
	extrn	eval:near,exp:near,evluint:near
	extrn	pshpara:near,avar:near,varadr:near
	extrn	popr0:near,strcnt:near,stexp:near
	extrn	strtox:near,nxtsc:near
	extrn	evlbyt:near,evlint:near,pulint:near
	extrn	evalrn:near,pulline:near
	extrn	allocds:near,freeds:near
	extrn	comtok:near
	extrn	lepar:near
	extrn	intger:near
	extrn	dpadd:near
	extrn	floatr0:near
	extrn	skipsps:near
	extrn	esitor0:near
	extrn	dcmp:near
	extrn	dosload:near
	extrn	dobload:near
	extrn	tstned:near
	extrn	fltinit:near
	extrn	brkon:near,brkoff:near
	extrn	setsave:near,clrsave:near,chkexit:near
	extrn	prnon:near,prnoff:near
	extrn	fsystem:near
	extrn	edvar:near
	extrn	status:near,conin:near
	extrn	pmsg:near
	extrn	getasn:near
	extrn	doasv:near
	extrn	dosas:near
	extrn	clrprog:near
	extrn	clrsp:near
	extrn	frslst:near
	extrn	renpar:near
	extrn	putlin:near
	extrn	clrvr:near
	extrn	prepasn:near
	extrn	linenum:near
	extrn	initlnums:near
	extrn	dosas1:near
	extrn	setarg:near
	extrn	sublcl:near
	extrn	foreval:near
	extrn	setasn:near
	extrn	fieldc:near
	extrn	progsize:near
	extrn	prepbin:near
	extrn	markln:near
	extrn	updlin:near
	extrn	nextlin:near
	extrn	updlab:near
	extrn	chainvar:near
	extrn	updvaro:near
	extrn	dotasvar:near
	extrn	strxfr:near,strpad:near
	extrn	skpop:near
	extrn	fndlinq:near
	extrn	fndlin:near
	extrn	delete:near
	extrn	clraddr:near
	extrn	playwav:near
	extrn	listp:near
	extrn	ftime:near
	extrn	settime:near
	extrn	float:near
	extrn	ifadd:near
	extrn	ifmul:near
	extrn	dpdiv:near
	extrn	decode:near
	extrn	pmsg:near
	extrn	emptyprog:byte
	extrn	dpone:byte
	extrn	dpund:byte

signon	db	'**** SBASIC 32 BITS VERSION 4.5 ****',cr,lf
	db	'************* 21/05/23 *************',cr,lf
mtymsg	db	eot
rdymsg	db	' Pret',eot
errmsg	db	' RENUMEROTATION IMPOSSIBLE',cr,lf,eot
novars	db	' TABLE VIDE',cr,lf,eot
sortmsg	db	' TABLE DES REFERENCES',cr,lf,eot
stpmsg	db	'STOP',eot
execmsg	db	'Retour EXECUTE',eot
gsubmsg db	'Retour GOSUB',eot
callmsg	db	'Retour CALL',eot
intmsg	db	'Retour interruption ',eot
formsg	db	'Boucle FOR',eot
linemsg	db	' ligne ',eot
opttab	db	'CSPLO'
optlen	equ	$-opttab


;start_basic (argc, argv, datab, datal, codeb, codel, symbb, symbl)
;retour: TRUE si sortie explicite, FALSE si sortie forcee
argc	equ	dword ptr [ebp+8]
argv	equ	dword ptr [ebp+12]
datab	equ	dword ptr [ebp+16]
datal	equ	dword ptr [ebp+20]
codeb	equ	dword ptr [ebp+24]
codel	equ	dword ptr [ebp+28]
symbb	equ	dword ptr [ebp+32]
symbl	equ	dword ptr [ebp+36]

;Point d'entree interpreteur
	align	16
strtbasic:
	cld				;une fois pour toutes
	pushd	0			;marque fin pile execution
	mov	initsp,esp		;pointeur de pile initial
	mov	execsp,esp		;pointeur pile execution
;Recopie premier argument dans tampon de travail
	mov	eax,argc		;nombre d'arguments
	mov	esi,argv		;adresse table pointeurs argument
	mov	edi,offset pathbuf	;tampon chemin fichier
	test	eax,eax			;au moins 1 argument ?
	mov	arg_c,eax
	mov	arg_v,esi
	jz	short carg2		;non, pas d'argument
	mov	esi,[esi]		;pointeur premier argument
	mov	ecx,maxpath
carg1:
	lodsb				;caractere argument
	test	al,al			;null ?
	je	short carg2		;oui, fin d'argument
	stosb				;range
	loop	carg1			;tant qu'il y a de la place dans le tampon
carg2:
	mov	byte ptr [edi],0	;marque de fin
;Initialisation memoire
	xor	eax,eax
	mov	edi,datab
	mov	data_base,edi		;base memoire donnees
	mov	ecx,datal
	shr	ecx,2			;nombre de dword
	rep	stosd			;raz memoire donnees
	mov	data_end,edi		;fin memoire donnees
	mov	edi,codeb
	mov	prog_base,edi		;base memoire code
	mov	ecx,codel
	mov	prog_size,ecx		;taille memoire code
	shr	ecx,2			;nombre de dword
	rep	stosd			;raz memoire code
	mov	edi,symbb
	mov	symb_base,edi		;base memoire symboles
	mov	ecx,symbl
	mov	symb_size,ecx		;taille memoire symboles
	shr	ecx,2			;nombre de dword
	rep	stosd			;raz memoire symboles
;Autres initialisations
	call	fltinit			;initialisation calcul flottant
	mov	breakflg,0FFh		;activation BREAK
	call	clrprog			;effacement programme
	mov	eax,prog_base
	mov	curpc,eax		;pointeur programme au debut
	add	eax,size line		;pointeur debut premiere ligne
	mov	savebp,eax		;initialisation sauvegarde EBP
	call	clrsp			;effacement espace de travail
;Lancement programme specifie sur la ligne de commande
	mov	ebx,offset pathbuf	;tampon chemin fichier
launch1:
	cmp	byte ptr [ebx],0	;fin de chaine ?
	je	short launch2		;oui
	inc	ebx			;avance
	jmp	launch1			;jusqu'a fin de chaine
launch2:
	cmp	ebx,offset pathbuf	;nom programme vide ?
	je	short welcome		;oui, pas de lancement
	mov	al,ext_bac		;extension BAC par defaut
	call	setflx			;preparation nom de fichier
	push	ebx
	call	wfopenread		;ouverture en lecture fichier de travail
	pop	ebx
	jc	short launch3		;erreur
	mov	runline,0		;demarrage au debut
	mov	stepflg,0		;raz indicateur pas a pas
	jmp	chain4
launch3:
	jmp	rpter
;Affichage message d'accueil
welcome:
	mov	esi,offset signon	;message d'accueil
	call	pmsg
;;;	jmp	short ready

;Boucle invite READY
	align	16
ready:
	movzx	eax,noedf		;edition source non autorisee ?
	or	eax,arg_c		;ou programme specifie ?
	jnz	exittrue		;oui, pas d'invite
ready1:
	xor	eax,eax
	mov	dirflg,al		;raz indicateur mode direct
	mov	pbinflg,al		;raz indicateur preparation image binaire
	mov	asnflg,al		;raz indicateur affectation
	mov	vrtasn,al		;raz indicateur affectation tableau virtuel
	mov	stepflg,al		;raz indicateur pas a pas
	mov	intmask,al		;raz masque interruptions
	mov	intflags,al		;raz indicateurs interruptions
	call	prnoff			;desactivation redirection affichage sur imprimante
	cmp	colm,0			;curseur en debut de ligne ?
	je	short ready2		;oui
	call	pcrlf			;saut de ligne
ready2:
	mov	esi,offset rdymsg
ready3:
	call	pmsg			;affichage READY
	call	pcrlf			;saut de ligne
ready4:
	call	initlnums		;initialise premiere et derniere lignes
	xor	eax,eax
	mov	filswi,al		;pas de fichier d'entree
	mov	filswo,al		;pas de fichier de sortie
	mov	iport,eax		;raz port entree
	mov	oport,eax		;raz port sortie
	call	prnoff			;desactivation redirection affichage sur imprimante
	mov	inflg,0			;raz indicateur INPUT
	call	inbuf			;entree ligne
ready5:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	inptr,ebx		;maj pointeur caractere
	call	clsch			;type caractere
	test	al,al			;separateur ?
	jnz	short ready7		;non, chiffre ou lettre
	cmp	ah,cr			;fin de ligne ?
	je	ready4			;oui, ignore
	cmp	ah,'?'			;? ?
	je	short ready8		;oui, execution en mode direct
	cmp	ah,'+'			;+ ?
	je	ready11			;oui, execution commande systeme
	cmp	ah,'!'			;! ?
	jne	short ready6		;non, erreur
	inc	ebx			;mange !
	mov	inptr,ebx		;maj pointeur caractere
	call	prnon			;activation redirection affichage sur imprimante
	jmp	ready5			;continue l'analyse de la ligne
ready6:
	jmp	synerr			;erreur de syntaxe
ready7:
	cmp	al,clsch_num		;chiffre ?
	je	short ready10		;oui, numero de ligne
ready8:
;Execution en mode direct
	mov	eax,prog_base		;debut programme
	mov	curpc,eax		;ligne en cours d'execution
	mov	nextpc,eax		;ligne programme suivante
	add	eax,size line		;pointeur debut premiere ligne
	mov	savebp,eax		;initialisation sauvegarde EBP
	mov	dirflg,0FFh		;indique mode direct
	mov	eax,inptr		;pointeur caractere tampon entree
	mov	nxtnam,eax		;pointeur nom sur premier mot
	mov	ebx,offset comtab	;table des commandes
	call	searchk			;nom dans la table ?
	jnc	short ready9		;non
	movzx	eax,ah			;index commande
	mov	inptr,ebx		;maj pointeur caractere
	jmp	comadr[eax*4-4]
ready9:
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	mov	nextpc,offset emptyprog.prog.begin_prog ;ligne programme suivante sur END
	jmp	execut1			;EXECUTE
;Insertion ou remplacement ligne
ready10:
	call	tstned			;test edition source autorisee
	mov	eax,prog_base
	mov	curpc,eax		;pointeur programme au debut
	add	eax,size line		;pointeur debut premiere ligne
	mov	savebp,eax		;initialisation sauvegarde EBP
	call	encode			;code ligne
	mov	dirflg,0FFh		;indique mode direct
	call	putlin			;insertion ligne
	mov	dirflg,0		;raz indicateur mode direct
	call	updlab			;mise a jour etiquettes
	call	setsave			;indique programme a sauvegarder
	jmp	ready4			;retour
;Execution commande systeme
ready11:
	inc	ebx			;mange +
	mov	edx,ebx
	mov	ecx,128
ready12:
	cmp	byte ptr [ebx],cr	;fin de ligne ?
	je	short ready13		;oui
	inc	ebx
	loop	ready12
	jmp	ready			;ligne trop longue, ignore
ready13:
	mov	byte ptr [ebx],0	;marque fin de ligne
	cmp	ebx,edx			;ligne vide ?
	je	short ready14		;oui
	call	fsystem			;execution commande systeme
ready14:
	jmp	ready			;retour invite BASIC

; Sortie BASIC
exitx:
	call	chkexit			;test sauvegarde programme
	jc	ready14			;pas de sortie
exittrue:
	mov	al,0FFh			;retour TRUE
exitbasic:
	mov	esp,initsp		;reinitialisation pile
	pop	ebx			;mange marque de fin pile execution
	push	eax
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	mov	breakflg,0		;desactivation BREAK
	pop	eax
	ret

; Moteur execution
	align	16
exec1:
	mov	eax,[ebx].strg.str_addr	;chainage
	push	eax
	mov	eax,[ebx].strg.str_len	;longueur allocation temporaire
	call	freeds			;liberation memoire
	pop	ebx
	test	ebx,ebx			;fin de chaine ?
	jnz	exec1			;oui, pour toutes les allocations temporaires
	mov	sschn,ebx		;raz chaine
	jmp	short exec3
exec2:
	cmp	byte ptr [ebp],k_else	;ELSE ?
	je	short exec4		;oui, execution ligne suivante
	cmp	byte ptr [ebp],k_colon	;: ?
	lea	ebp,[ebp+1]		;mange : sans influer sur le test
	je	short exec5		;oui, execution instruction suivante sur la meme ligne
	mov	al,err_line_end		;erreur fin de ligne
	jmp	rpter
	align	16
exec:
	mov	ebx,sschn		;chaine des sous-chaines temporaires
	test	ebx,ebx			;vide ?
	jnz	short exec1		;non
exec3:
	cmp	byte ptr [ebp],k_cr	;fin de ligne?
	jne	short exec2		;non
exec4:
	mov	ebx,nextpc		;pointeur ligne programme suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	mov	curpc,ebx		;pointeur ligne programme courante
	js	short exec11		;oui
	movzx	eax,[ebx].line.l_len	;longueur ligne
	lea	ebp,[ebx+size line]	;pointeur code en debut de ligne
	lea	ebx,[ebx+eax+1]		;adresse ligne suivante
	mov	nextpc,ebx		;ligne suivante
	test	stepflg,0FFh		;pas a pas ?
	jnz	short exec10		;oui
exec5:
	movzx	eax,byte ptr [ebp]	;token
	test	trcflg,0FFh		;trace ?
	jnz	short exec16		;oui
exec6:
	test	intflags,0FFh		;interruption ?
	jnz	short exec9		;oui
exec7:
	jmp	exectab[eax*4]		;branchement execution instruction
exec8:
	inc	ebp			;mange token indirection
	movzx	eax,byte ptr [ebp]	;code extension
	jmp	exttab[eax*4]		;branchement execution instruction etendue
exec9:
	jmp	exec19
exec10:
	skipst				;saut espace et token
	cmp	al,k_sub		;SUB ?
	je	exec5			;oui, pas de pas a pas
	jmp	exec24
exec11:
	test	dirflg,0FFh		;mode direct ?
	jnz	short exec13		;oui
exec12:
	mov	esp,initsp		;reinitialisation pile
	mov	execsp,esp		;et pile execution
	call	clsall			;fermeture tous fichiers
	mov	contflg,0		;raz indicateur CONTINUE
exec13:
	jmp	ready			;retour invite BASIC
exec14:
	inc	ebp			;mange compte espace
exec15:
	inc	ebp			;mange espace
	jmp	exec5			;continue
exec16:
	skipst				;saut espace et token
	movzx	eax,al			;pour JMP EXECTAB
	cmp	al,k_sub		;SUB ?
	je	exec6			;oui, pas de trace
	test	intmask,0FFh		;interruptions masquees ?
	jnz	exec6			;oui, pas de trace
	push	eax
	mov	ebx,curpc		;pointeur ligne courante
	mov	eax,[ebx].line.l_number	;numero de ligne .
	test	eax,eax			;ligne 0 ?
	jz	short exec17		;oui, pas d'affichage
	push	eax
	mov	al,'['
	call	outch			;affiche [
	pop	eax
	call	outdec			;affiche numero de ligne
	mov	al,']'
	call	outch			;affiche ]
	mov	al,' '
	call	outch			;affiche espace
exec17:
	pop	eax
	jmp	exec6
exec18:
	popfd
	jmp	exec7
exec19:
	pushfd
	skipst				;saut espace et token
	movzx	eax,al			;pour JMP EXECTAB
	cmp	al,k_sub		;SUB ?
	je	exec18			;oui, pas de BREAK
	popfd
	jns	short exec21		;pas BREAK
	push	eax
	call	status			;touche clavier ?
	jz	short exec20		;non
	call	conin			;mange touche (a priori CtrlC)
exec20:
	pop	eax
	cmp	inttbl+4*break_int,0	;vecteur BREAK ?
	je	short exec23		;non
exec21:
	test	intmask,0FFh		;interruptions masquee ?
	jnz	exec7			;oui, ignore
	movzx	eax,intflags		;indicateurs interruptions
	and	intflags,trace_mask	;raz interruptions (sauf interruption trace)
	shl	eax,16			;en position R_FLAGS
	mov	intmask,0FFh		;masque interruptions
	mov	ax,7*256+interrupt_mark	;marque interruption et interruption 7
	push	ebp			;PUSH pointeur code
	push	nextpc			;PUSH pointeur ligne suivant
	push	curpc			;PUSH pointeur ligne courante
	push	eax			;marque interruption, numero interruption et indicateurs interruptions
	mov	execsp,esp		;maj pointeur pile execution
	mov	ecx,7			;numero interruption
	mov	al,10000000b		;masque interruption 7
	jmp	retint2			;continue traitement interruption
exec23:
	xor	al,al
	mov	intmask,al		;raz masque interruptions
	mov	intflags,al		;raz indicateurs interruptions
	jmp	stop1			;STOP
exec24:
	mov	contnxt,ebx		;range pointeur ligne suivante
	mov	contebp,ebp		;range pointeur code
	mov	ebx,curpc		;pointeur ligne courante
	mov	contcur,ebx		;range pointeur ligne courante
	mov	contflg,0FFh		;indique CONTINUE possible
	xor	eax,eax
	mov	errs,eax		;raz dernier code d'erreur
	mov	stepflg,al		;raz indicateur pas a pas
	mov	intmask,al		;raz masque interruptions
	mov	intflags,al		;raz indicateurs interruptions
	call	prnoff			;desactivation redirection affichage sur imprimante
	cmp	colm,0			;curseur en debut de ligne ?
	je	short exec25		;oui
	call	pcrlf			;saut de ligne
exec25:
	mov	eax,[ebx].line.l_number	;numero de ligne
	mov	ebx,ebp			;debut code
	mov	erls,eax		;dans ERL
	mov	listcolflg,0		;pas d'affichage couleur
	xor	ecx,ecx			;pas de minimum de caracteres pour affichage numero de ligne
	call	decode			;decodage ligne
	mov	esi,offset buffer
	jmp	ready3			;attente nouvelle commande

; Commandes
;----------

; Table nom commandes
comtab	db	'SAVE'
	db	c_save+tok_mark
	db	'CPM'
	db	c_exit+tok_mark
	db	'MSDOS'
	db	c_exit+tok_mark
	db	'FLEX'
	db	c_exit+tok_mark
	db	'SYSTEM'
	db	c_exit+tok_mark
	db	'LIST'
	db	c_list+tok_mark
	db	'NEW'
	db	c_new+tok_mark
	db	'RUN'
	db	c_run+tok_mark
	db	'GOTO'
	db	c_goto+tok_mark
	db	'CONTINUE'
	db	c_cont+tok_mark
	db	'CONT'
	db	c_cont+tok_mark
	db	'STEP'
	db	c_step+tok_mark
	db	'CLEAR'
	db	c_clear+tok_mark
	db	'EDIT'
	db	c_edit+tok_mark
	db	'PLIST'
	db	c_plist+tok_mark
	db	'TRACE'
	db	c_trace+tok_mark
	db	'BREAK'
	db	c_break+tok_mark
	db	'RENUMBER'
	db	c_renum+tok_mark
	db	'RENUM'
	db	c_renum+tok_mark
	db	'TRIVAR'
	db	c_trivar+tok_mark
	db	'TASVAR'
	db	c_tasvar+tok_mark
	db	'REFSUB'
	db	c_refsub+tok_mark
	db	'STACK'
	db	c_stack+tok_mark
	db	0

; Table mots cles ON/OFF
onoftab	db	'ON'
	db	c_on+tok_mark
	db	'OFF'
	db	c_off+tok_mark
	db	0

	align	16
; Table branchement commandes
comadr	dd	offset save		;1
	dd	offset exitx		;2
	dd	offset listc		;3
	dd	offset new		;4
	dd	offset run		;5
	dd	offset gotoc		;6
	dd	offset cont		;7
	dd	offset step		;8
	dd	offset clear		;9
	dd	offset edit		;10
	dd	offset plist		;11
	dd	offset trace		;12
	dd	offset break		;13
	dd	offset renum		;14
	dd	offset trivar		;15
	dd	offset tasvar		;16
	dd	offset refsub		;17
	dd	offset stackc		;18

; Table branchement TRACE
tradr	dd	offset trace2		;1
	dd	offset trace4		;2

; Table branchement BREAK
brkadr	dd	offset break2		;1
	dd	offset break4		;2

; SAVE
	align	16
save:
	mov	ebx,prog_base		;debut programme
	test	[ebx].prog.begin_prog.line.l_number.long.l_b3,0FFh ;premiere ligne = fin de programme ?
	js	short save1		;oui, programme vide
	call	tstned			;test edition source autorisee
	call	compcmd			;compile ligne de commande
	mov	al,ext_bas		;extension .BAS par defaut
	call	setfls			;evaluation nom de fichier
	call	wfopenwrite		;ouverture en ecriture fichier de travail
	jc	short save2		;erreur ouverture fichier
	call	frslst			;evaluation premiere et derniere ligne
	mov	listcolflg,0		;pas d'affichage couleur
	call	listp			;affichage code source dans fichier
	call	wfclose			;fermeture fichier de travail
	call	clrsave			;raz indicateur sauvegarde source
save1:
	jmp	ready			;retour invite BASIC
save2:
	jmp	rpter

; LIST
	align	16
plist:
	call	prnon			;activation redirection affichage sur imprimante
listc:
	call	tstned			;test edition source autorisee
	call	compcmd			;compile ligne de commande
	call	frslst			;evaluation premiere et derniere ligne
	mov	listcolflg,0FFh		;indique affichage couleur
	call	listp			;affichage code source
	call	prnoff			;desactivation redirection affichage sur imprimante
	jmp	ready			;retour invite BASIC

; NEW
	align	16
new:
	call	clrprog			;effacement programme
;;;	jmp	short clear

; CLEAR
clear:
	mov	esp,initsp		;reinitialisation pile
	mov	execsp,esp		;et pile execution
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	call	inivar			;reinitialisation variables windows
	call	clrsp			;effacement espace de travail
	call	updlab			;mise a jour etiquettes
	mov	contflg,0		;raz indicateur CONTINUE
	jmp	ready			;retour invite BASIC

; RUN
	align	16
run:
	mov	runline,0		;demarrage au debut par defaut
	mov	lineflg,0FFh		;indique numero de ligne
	mov	labflg,1		;indique reference etiquette	
	call	compcmd			;compile ligne de commande
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	run2			;oui
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	je	short run1		;oui
	test	al,labbit		;etiquette ?
	jz	chain1			;non
run1:
	mov	esp,initsp		;reinitialisation pile
	mov	execsp,esp		;et pile execution
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	call	inivar			;reinitialisation variables windows
	call	clrsp			;effacement espace de travail
	call	updlab			;mise a jour etiquettes
	mov	dirflg,0		;raz indicateur mode direct
	mov	contflg,0		;raz indicateur CONTINUE
	jmp	goto1			;execution GOTO
run2:
	mov	esp,initsp		;reinitialisation pile
	mov	execsp,esp		;et pile execution
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	call	inivar			;reinitialisation variables windows
	call	clrsp			;effacement espace de travail
	call	updlab			;mise a jour etiquettes
	mov	dirflg,0		;raz indicateur mode direct
	mov	contflg,0		;raz indicateur CONTINUE
run3:
	mov	eax,runline
	test	eax,eax			;line demarrage specifiee ?
	jnz	short run4		;oui
	mov	eax,prog_base		;debut programme
	add	eax,offset prog.begin_prog ;premiere ligne programme
	mov	nextpc,eax		;pointeur ligne courante
	jmp	exec4			;execution a partir de la premiere ligne
run4:
	jmp	gotoln			;branchement a la ligne

; GOTO (commande)
	align	16
gotoc:
	mov	lineflg,0FFh		;indique numero de ligne
	mov	labflg,1		;indique reference etiquette	
	call	compcmd			;compile ligne de commande
	jmp	goto1			;execution GOTO

; CONT
	align	16
cont:
	test	contflg,0FFh		;CONTINUE possible ?
	jz	short cont4		;non, erreur
cont1:
	mov	contflg,0		;raz indicateur CONTINUE
	mov	dirflg,0		;raz indicateur mode direct
	mov	eax,contcur
	mov	curpc,eax		;restaure CURPC
	mov	eax,contnxt
	mov	nextpc,eax		;restaure NEXTPC
	mov	ebp,contebp		;restaure pointeur programme
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short cont3		;non
	cmp	al,k_colon		;fin instruction ?
	jae	short cont2		;oui
	cmp	al,k_else		;ELSE ?
	jne	short cont3		;non
cont2:
	jmp	exec			;fin execution ligne
cont3:
	jmp	exec5			;continuation execution
cont4:
	mov	al,err_continue		;impossible de continuer
	jmp	rpter

; STEP
	align	16
step:
	test	contflg,0FFh		;CONTINUE possible ?
	jz	cont4			;non, erreur
	mov	stepflg,0FFh		;indique pas a pas
	jmp	cont1

; TRACE
	align	16
trace:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	nxtnam,ebx		;pointeur nom sur premier mot
	mov	ebx,offset onoftab	;table des mots cles BREAK
	call	searchk			;nom dans la table ?
	jnc	short trace1		;non
	movzx	eax,ah
	jmp	tradr[eax*4-4]
trace1:
	jmp	synerr			;erreur de syntaxe
trace2:
	mov	trcflg,0FFh		;indique trace
	or	intflags,trace_mask	;indique interruption trace
trace3:
	jmp	ready			;retour invite BASIC
trace4:
	xor	eax,eax
	mov	trcflg,al		;raz indicateur trace
	and	intflags,not trace_mask ;raz indicateur interruption trace
	mov	inttbl+4*trace_int,eax	;raz vecteur interruption trace
	jmp	trace3

; BREAK
	align	16
break:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	nxtnam,ebx		;pointeur nom sur premier mot
	mov	ebx,offset onoftab	;table des mots cles BREAK
	call	searchk			;nom dans la table ?
	jnc	short break1		;non
	movzx	eax,ah
	jmp	brkadr[eax*4-4]
break1:
	jmp	synerr			;erreur de syntaxe
break2:
	mov	breakflg,0FFh		;activation BREAK
	call	brkon			;reactive BREAK par Control-C
break3:
	jmp	ready			;retour invite BASIC
break4:
	xor	eax,eax
	mov	breakflg,al		;desactivation BREAK
	call	brkoff			;desactive BREAK par Control-C
	mov	inttbl+4*break_int,eax	;raz vecteur BREAK
	jmp	break3

; RENUM
	align	16
renum:
	call	tstned			;test edition source autorisee
	mov	first,1			;premiere ligne au minimum
	mov	lastx,maxline		;derniere ligne au maximum
	mov	startnum,10		;premiere ligne par defaut
	mov	incnum,10		;pas par defaut
	call	compcmd			;compile ligne de commande
	call	renpar			;evaluation parametre
	jc	short renum4		;plus de parametre
	jz	short renum1		;valeur par defaut
	mov	startnum,ebx		;numero premiere ligne
renum1:
	call	renpar			;evaluation parametre
	jc	short renum4		;plus de parametre
	jz	short renum2		;valeur par defaut
	mov	incnum,ebx		;pas lignes
renum2:
	call	renpar			;evaluation parametre
	jc	short renum4		;plus de parametre
	jz	short renum3		;valeur par defaut
	mov	first,ebx		;debut intervalle
renum3:
	call	renpar			;evaluation parametre
	jbe	short renum4		;plus de parametre ou valeur par defaut
	mov	lastx,ebx		;fin intervalle
renum4:
	mov	eax,first		;premiere ligne intervalle
	call	fndlin			;recherche ligne
	mov	ebx,prvlin		;ligne precedente
	mov	edx,startnum		;nouveau numero premiere ligne intervalle
	mov	eax,[ebx].line.l_number
	cmp	eax,edx			;avant nouveau numero premiere ligne intervalle ?
	jae	short renum9		;non, erreur
	sub	edx,incnum
renum5:
	call	nextlin			;ligne suivante
	js	short renum7		;fin code
	cmp	eax,lastx		;fin intervalle ?
	ja	short renum6		;non, continue
	add	edx,incnum		;nouveau numero
	js	short renum9		;debordement
	jmp	renum5
renum6:
	cmp	edx,eax			;nouveau numero derniere ligne intervalle avant numero ligne suivante ?
	jae	short renum9		;non, erreur
renum7:
	call	markln			;marque les numeros de ligne dans le programme
	mov	ebx,prog_base		;debut programme
	mov	edx,startnum		;nouveau numero premiere ligne intervalle
renum8:
	call	nextlin			;ligne suivante
	js	short renum10		;fin code
	cmp	eax,first		;avant intervalle ?
	jb	short renum8		;oui, avance
	cmp	eax,lastx		;apres intervalle ?
	ja	short renum10		;oui
	mov	[ebx].line.l_number,edx
	add	edx,incnum
	jmp	renum8
renum9:
	mov	esi,offset errmsg
	call	pmsg			; AFFICHER ERREUR
	jmp	ready			;retour invite BASIC
renum10:
	call	updlin			;mise a jour numeros de ligne
	call	updlab			;mise a jour etiquettes
	jmp	ready			;retour invite BASIC

; TRIVAR
	align	16
trivar:
	call	tstned			;test edition source autorisee
	mov	esi,offset sortmsg
	call	pmsg			;affichage message reference variables
	call	clsall			;fermeture tous fichiers
	call	clrsp			;effacement espace de travail
	shl	eax,2			;nombre variables *4
	jz	trivar5			;pas de variable
	push	eax
	call	allocds			;allocation tampon de travail
	pop	eax
	mov	first,ebx		;adresse tampon tri
	sub	eax,4			;plus d'une variable ?
	setnz	sortflg			;positionne indicateur tri
	jz	trivar12		;une seule variable
	mov	ebx,prog_base		;base memoire programme
	mov	eax,symb_base		;table des symboles
	add	eax,[ebx].prog.sym_len	;fin table symboles
	mov	lastx,eax		;fin table symboles
	mov	ebx,symb_base		;debut table symboles
	mov	edx,first		;pointeur tampon tri
trivar1:
	cmp	ebx,lastx		;fin table symboles ?
	jae	trivar12		;oui, fin tri
	mov	esi,edx			;pointeur tri
trivar2:
	cmp	esi,first		;debut tampon atteint ?
	ja	short trivar6		;non
	mov	[esi],ebx		;le symbole a trier devient le premier symbole
trivar3:
	add	edx,size_i		;avance pointeur tri
	add	ebx,size_o		;saut offset
trivar4:
	inc	ebx
	mov	al,[ebx]		;caractere suivant
	test	al,al			;type symbole suivant ?
	jns	trivar4			;non, continue
	jmp	trivar1			;symbole suivant
trivar5:
	mov	esi,offset novars
	call	pmsg
	jmp	ready			;retour invite BASIC
trivar6:
	push	esi
	mov	edi,ebx			;pointeur symbole a trier
	mov	esi,[esi-size_i]	;pointeur symbole trie precedent
	mov	ah,[edi]		;type symbole a trier
	add	edi,size_o		;saut offset
	mov	al,[esi]		;type symbole trie
	cmp	ah,al			;comparaison type
	jne	short trivar10		;differents, fin tri symbole
	add	esi,size_o		;saut offset
trivar7:
	inc	esi
	mov	al,[esi]		;caractere suivant symbole trie
	test	al,al			;type symbole suivant ? (CF=0)
	jns	short trivar8		;non
	jmp	short trivar10		;symbole trie plus court
trivar8:
	inc	edi
	mov	ah,[edi]		;caractere suivant symbole a trier
	test	ah,ah			;type symbole suivant
	jns	short trivar9		;non
	stc				;symbole a trier plus court
	jmp	short trivar10
trivar9:
	cmp	ah,al			;comparaison caracteres
	je	trivar7			;identiques
trivar10:
	pop	esi
	jc	trivar11		;symbole a trier avant symbole trie
	mov	[esi],ebx		;position symbole
	jmp	trivar3			;avance pointeur tri
trivar11:
	sub	esi,size_i		;recule pointeur tri
	mov	eax,[esi]		;decalage pointeur symbole
	mov	[esi+size_i],eax
	jmp	trivar2			;compare symbole precedent
trivar12:
	push	edx
	call	chainvar		;chainage symboles
	pop	edx
	test	sortflg,0FFh		;tri effectue ?
	jnz	short trivar14		;oui
	mov	ebx,symb_base
trivar13:
	call	edvar			;affichage reference symbole
	jmp	short trivar16
trivar14:
	mov	ebx,first		;debut tampon tri
trivar15:
	cmp	ebx,edx			;fin tampon tri ?
	jae	short trivar16		;oui
	push	ebx
	push	edx
	mov	ebx,[ebx]		;adresse symbole
	call	edvar			;affichage reference symbole
	pop	edx
	pop	ebx
	add	ebx,size_i		;avance pointeur tri
	jmp	trivar15		;pour tous les symboles tries
trivar16:
	call	updvaro			;maj offset symboles
	jmp	ready			;retour invite BASIC

; TASVAR
	align	16
tasvar:
	call	clsall			;fermeture tous fichiers
	call	clrsp			;effacement espace de travail
	mov	cmpopt,0		;raz options compilation
	call	dotasvar		;suppression des symboles non utilises
	call	updvaro			;maj offset symboles et etiquettes
	jmp	ready			;retour invite BASIC

; REFSUB
	align	16
refsub:
	mov	ebx,prog_base		;debut programme
	mov	ecx,maxlref		;nombre de references affiches par ligne
refsub1:
	call	nextlin			;ligne suivante
	js	short refsub4		;fin de code
	mov	ebp,ebx
	lea	ebp,[ebx+size line]	;debut code ligne 
	skipst				;saut espace et token
	cmp	al,k_sub		;SUB ?
	je	short refsub2		;oui
	cmp	al,k_label		;LABEL
	jne	refsub1			;non, ligne suivant
refsub2:
	inc	ebp			;mange SUB ou LABEL
	skipst				;saut espace et token
	test	al,labbit		;etiquette ?
	jz	refsub1			;non, ignore
	mov	esi,[ebp+1]		;offset symbole
	add	esi,symb_base		;pointeur symbole
	push	ecx
	add	esi,size_a		;debut symbole
	mov	eax,[ebx].line.l_number	;numero de ligne
	push	esi
	mov	ecx,minlnum		;minimum caracteres
	call	outdecx			;affichage numero de ligne
	pop	esi
	pop	ecx
	mov	al,' '
	call	outch			;affiche espace
	mov	edx,maxlabl		;nombre de caracteres symbole affiches
refsub3:
	lodsb				;caractere symbole
	test	al,al			;type symbole suivant ?
	js	short refsub6		;oui
	test	edx,edx			;maximum caracteres affiches ?
	jz	short refsub6		;oui		
	dec	edx			;decompte caractere
	call	outch			;affichage caractere
	jmp	refsub3			;pour tout le symbole
refsub4:
	cmp	ecx,maxlref		;debut de ligne ?
	je	short refsub5		;oui
	call	pcrlf			;saut de ligne
refsub5:
	jmp	ready			;retour invite BASIC
refsub6:
	test	edx,edx			;remplisage nom symbole ?
	jz	short refsub7		;non
	dec	edx			;decompte caractere
	mov	al,' '
	call	outch			;affichage espace
	jmp	refsub6			;pour tout le remplissage
refsub7:
	loop	refsub8			;pour toute la ligne
	call	pcrlf			;saut de ligne
	mov	ecx,maxlref		;nombre de references affiches par ligne
refsub8:
	jmp	refsub1

; STACK
	align	16
stackc:
	mov	ebx,execsp		;pointeur pile execution
stackc1:
	mov	al,[ebx].rete.r_mark	;signature pile execution
	cmp	al,execute_mark		;retour EXECUTE ?
	jne	short stackc2		;non
	mov	esi,offset execmsg	;message retour EXECUTE
stackc10:
	mov	edi,[ebx].rete.r_curpc	;ligne retour
	add	ebx,size rete		;saut entree pile
stackc100:
	cmp	edi,prog_base		;mode direct ?
	je	stackc9			;oui, fin pile
	call	pmsg			;affichage
	mov	eax,[edi].line.l_number	;numero de ligne
	and	eax,eax			;definie ?
	jz	short stackc11		;non
	push	eax
	mov	esi,offset linemsg	;message ligne
	call	pmsg			;affichage
	pop	eax
	call	outdec			;affichage numero de ligne
stackc11:
	call	pcrlf			;saut de ligne
	jmp	stackc1
stackc2:
	cmp	al,gosub_mark		;retour GOSUB ?
	jne	short stackc3		;non
	mov	esi,offset gsubmsg	;message retour GOSUB
	jmp	stackc10
stackc3:
	cmp	al,call_mark		;retour CALL ?
	jne	short stackc4		;non
	mov	dl,[ebx].rete.r_count	;nombre arguments
	test	dl,dl			;RETURN sans SUB ?
	jns	short stackc31		;non
	xor	dl,dl			;pas d'argument
stackc31:
	mov	eax,size calla		;taille entree argument
	mul	dl			;*nombre arguments
	add	ebx,eax			;saut arguments
	mov	esi,offset callmsg	;message retour CALL
	jmp	stackc10
stackc4:
	cmp	al,interrupt_mark	;retour interruption ?
	jne	short stackc5		;non
	mov	esi,offset intmsg	;message retour interruption
	call	pmsg			;affichage
	mov	al,[ebx].rete.r_count	;numero interruption
	add	al,'0'
	call	outch			;affichage caractere
	mov	esi,offset mtymsg	;message retour interruption
	jmp	stackc10
stackc5:
	cmp	al,for_mark		;entree FOR ?
	jne	short stackc9		;non
	mov	esi,offset formsg
	mov	edi,[ebx].fore.f_curpc	;ligne boucle
	add	ebx,size fore		;saut entree FOR
	jmp	stackc100
stackc9:
	jmp	ready			;retour invite BASIC

; Instructions
;-------------
; Table branchement traitement instructions
	align	16
exectab	dd	offset ready6		;0
	dd	offset xgoto		;1
	dd	offset gosub		;2
	dd	offset resume		;3
	dd	offset digits		;4
	dd	offset rem		;5
	dd	offset let		;6
	dd	offset print		;7
	dd	offset input		;8
	dd	offset execut		;9
	dd	offset swap		;10
	dd	offset xfor		;11
	dd	offset poke		;12
	dd	offset lprint		;13
	dd	offset next		;14
	dd	offset xread		;15
	dd	offset return		;16
	dd	offset xif		;17
	dd	offset dim		;18
	dd	offset on		;19
	dd	offset set		;20
	dd	offset xend		;21
	dd	offset stop		;22
	dd	offset rem		;23 DATA
	dd	offset restore		;24
	dd	offset xcall		;25
	dd	offset open		;26
	dd	offset close		;27
	dd	offset chain		;28
	dd	offset kill		;29
	dd	offset rename		;30
	dd	offset get		;31
	dd	offset put		;32
	dd	offset field		;33
	dd	offset lset		;34
	dd	offset rset		;35
	dd	offset xexec		;36
	dd	offset dpoke		;37
	dd	offset exec8		;38 indirection
	dd	offset xsub		;39
	dd	offset xlabel		;40
	dd	offset ready6		;41
	dd	offset ready6		;42
	dd	offset ready6		;43
	dd	offset ready6		;44
	dd	offset ready6		;45
	dd	offset ready6		;46
	dd	offset ready6		;47
	dd	offset ready6		;48
	dd	offset ready6		;49
	dd	offset ready6		;50
	dd	offset ready6		;51
	dd	offset ready6		;52
	dd	offset ready6		;53
	dd	offset ready6		;54
	dd	offset ready6		;55
	dd	offset ready6		;56
	dd	offset ready6		;57
	dd	offset ready6		;58
	dd	offset ready6		;59
	dd	offset ready6		;60
	dd	offset ready6		;61
	dd	offset ready6		;62
	dd	offset ready6		;63
	dd	offset ready6		;64
	dd	offset ready6		;65
	dd	offset ready6		;66
	dd	offset ready6		;67
	dd	offset ready6		;68
	dd	offset ready6		;69
	dd	offset ready6		;70
	dd	offset ready6		;71
	dd	offset ready6		;72
	dd	offset ready6		;73
	dd	offset ready6		;74
	dd	offset ready6		;75
	dd	offset ready6		;76
	dd	offset ready6		;77
	dd	offset ready6		;78
	dd	offset ready6		;79
	dd	offset ready6		;80
	dd	offset ready6		;81
	dd	offset ready6		;82
	dd	offset ready6		;83
	dd	offset ready6		;84
	dd	offset ready6		;85
	dd	offset ready6		;86
	dd	offset ready6		;87
	dd	offset ready6		;88
	dd	offset ready6		;89
	dd	offset ready6		;90
	dd	offset ready6		;91
	dd	offset ready6		;92
	dd	offset ready6		;93
	dd	offset ready6		;94
	dd	offset ready6		;95
	dd	offset ready6		;96
	dd	offset ready6		;97
	dd	offset ready6		;98
	dd	offset ready6		;99
	dd	offset ready6		;100
	dd	offset ready6		;101
	dd	offset ready6		;102
	dd	offset ready6		;103
	dd	offset ready6		;104
	dd	offset ready6		;105
	dd	offset ready6		;106
	dd	offset ready6		;107
	dd	offset ready6		;108
	dd	offset ready6		;109
	dd	offset ready6		;110
	dd	offset ready6		;111
	dd	offset ready6		;112
	dd	offset ready6		;113
	dd	offset ready6		;114
	dd	offset ready6		;115
	dd	offset ready6		;116
	dd	offset ready6		;116
	dd	offset ready6		;118
	dd	offset ready6		;119
	dd	offset ready6		;120
	dd	offset ready6		;121
	dd	offset ready6		;122
	dd	offset ready6		;123
	dd	offset ready6		;124
	dd	offset ready6		;125
	dd	offset exec15		;126 espace
	dd	offset exec14		;127 espaces multiples
;
	dd	offset letnum		;128
	dd	offset letstr		;129
	dd	offset letnum		;130
	dd	offset letstr		;131
	dd	offset letnum		;132
	dd	offset letstr		;133
	dd	offset letnum		;134
	dd	offset letstr		;135
	dd	offset letnum		;136
	dd	offset letstr		;137
	dd	offset letnum		;138
	dd	offset letstr		;139
	dd	offset letnum		;140
	dd	offset letstr		;141
	dd	offset letnum		;142
	dd	offset letstr		;143
	dd	offset letnum		;144
	dd	offset letstr		;145
	dd	offset letnum		;146
	dd	offset letstr		;147
	dd	offset letnum		;148
	dd	offset letstr		;149
	dd	offset letnum		;150
	dd	offset letstr		;151
	dd	offset letnum		;152
	dd	offset letstr		;153
	dd	offset letnum		;154
	dd	offset letstr		;155
	dd	offset letnum		;156
	dd	offset letstr		;157
	dd	offset letnum		;158
	dd	offset letstr		;159
	dd	offset leterr		;160
	dd	offset rem		;161 TOK_MARK+CONBIT+STRBIT
	dd	offset leterr		;162
	dd	offset leterr		;163
	dd	offset leterr		;164
	dd	offset leterr		;165
	dd	offset leterr		;166
	dd	offset leterr		;167
	dd	offset leterr		;168
	dd	offset leterr		;169
	dd	offset leterr		;170
	dd	offset leterr		;171
	dd	offset leterr		;172
	dd	offset leterr		;173
	dd	offset leterr		;174
	dd	offset leterr		;175
	dd	offset leterr		;176
	dd	offset leterr		;177
	dd	offset leterr		;178
	dd	offset leterr		;179
	dd	offset leterr		;180
	dd	offset leterr		;181
	dd	offset leterr		;182
	dd	offset leterr		;183
	dd	offset leterr		;184
	dd	offset leterr		;185
	dd	offset leterr		;186
	dd	offset leterr		;187
	dd	offset leterr		;188
	dd	offset leterr		;189
	dd	offset leterr		;190
	dd	offset leterr		;191
	dd	offset letnum		;192
	dd	offset letstr		;193
	dd	offset letnum		;194
	dd	offset letstr		;195
	dd	offset letnum		;196
	dd	offset letstr		;197
	dd	offset letnum		;198
	dd	offset letstr		;199
	dd	offset letnum		;200
	dd	offset letstr		;201
	dd	offset letnum		;202
	dd	offset letstr		;203
	dd	offset letnum		;204
	dd	offset letstr		;205
	dd	offset letnum		;206
	dd	offset letstr		;207
	dd	offset letnum		;208
	dd	offset letstr		;209
	dd	offset letnum		;210
	dd	offset letstr		;211
	dd	offset letnum		;212
	dd	offset letstr		;213
	dd	offset letnum		;214
	dd	offset letstr		;215
	dd	offset letnum		;216
	dd	offset letstr		;217
	dd	offset letnum		;218
	dd	offset letstr		;219
	dd	offset letnum		;220
	dd	offset letstr		;221
	dd	offset letnum		;222
	dd	offset letstr		;223
	dd	offset leterr		;224
	dd	offset leterr		;225
	dd	offset leterr		;226
	dd	offset leterr		;227
	dd	offset leterr		;228
	dd	offset leterr		;229
	dd	offset leterr		;230
	dd	offset leterr		;231
	dd	offset leterr		;232
	dd	offset leterr		;233
	dd	offset leterr		;234
	dd	offset leterr		;235
	dd	offset leterr		;236
	dd	offset leterr		;237
	dd	offset leterr		;238
	dd	offset leterr		;239
	dd	offset leterr		;240
	dd	offset leterr		;241
	dd	offset leterr		;242
	dd	offset leterr		;243
	dd	offset leterr		;244
	dd	offset leterr		;245
	dd	offset leterr		;246
	dd	offset leterr		;247
	dd	offset leterr		;248
	dd	offset leterr		;249
	dd	offset leterr		;250
	dd	offset leterr		;251
	dd	offset leterr		;252
	dd	offset leterr		;253
	dd	offset leterr		;254
	dd	offset leterr		;255

; Table branchement traitement instructions etendues
exttab	dd	offset ready6		;0
	dd	offset gr		;1
	dd	offset text		;2
	dd	offset color		;3
	dd	offset hgr		;4
	dd	offset play		;5
	dd	offset setcolor		;6
	dd	offset setblink		;7
	dd	offset plot		;8
	dd	offset port		;9
	dd	offset xclear		;10
	dd	offset tron		;11
	dd	offset troff		;12
	dd	offset cursor		;13
	dd	offset delte		;14
	dd	offset ovrlay		;15
	dd	offset load		;16
	dd	offset bload		;17
	dd	offset xlocal		;18
	dd	offset clrg		;19
	dd	offset move		;20
	dd	offset dash		;21
	dd	offset symbol		;22
	dd	offset arc		;23
	dd	offset fill		;24
	dd	offset draw		;25
	dd	offset xmask		;26
	dd	offset window		;27
	dd	offset pen		;28
	dd	offset compile		;29
	dd	offset onbrk		;30
	dd	offset offbrk		;31
	dd	offset cls		;32
	dd	offset editx		;33
	dd	offset reset		;34
	dd	offset exitx		;35
	dd	offset setblink		;36
	dd	offset gget		;37
	dd	offset gput		;38
	dd	offset xlist		;39
	dd	offset unlock		;40
	dd	offset lockx		;41
	dd	offset time		;42
	dd	offset chd		;43
	dd	offset bsave		;44
	dd	offset ready6		;45
	dd	offset ready6		;46
	dd	offset ready6		;47
	dd	offset ready6		;48
	dd	offset ready6		;49
	dd	offset ready6		;50
	dd	offset ready6		;51
	dd	offset ready6		;52
	dd	offset ready6		;53
	dd	offset ready6		;54
	dd	offset ready6		;55
	dd	offset ready6		;56
	dd	offset ready6		;57
	dd	offset ready6		;58
	dd	offset ready6		;59
	dd	offset ready6		;60
	dd	offset ready6		;61
	dd	offset ready6		;62
	dd	offset ready6		;63
	dd	offset ready6		;64
	dd	offset ready6		;65
	dd	offset ready6		;66
	dd	offset ready6		;67
	dd	offset ready6		;68
	dd	offset ready6		;69
	dd	offset ready6		;70
	dd	offset ready6		;71
	dd	offset ready6		;72
	dd	offset ready6		;73
	dd	offset ready6		;74
	dd	offset ready6		;75
	dd	offset ready6		;76
	dd	offset ready6		;77
	dd	offset ready6		;78
	dd	offset ready6		;79
	dd	offset ready6		;80
	dd	offset ready6		;81
	dd	offset ready6		;82
	dd	offset ready6		;83
	dd	offset ready6		;84
	dd	offset ready6		;85
	dd	offset ready6		;86
	dd	offset ready6		;87
	dd	offset ready6		;88
	dd	offset ready6		;89
	dd	offset ready6		;90
	dd	offset ready6		;91
	dd	offset ready6		;92
	dd	offset ready6		;93
	dd	offset ready6		;94
	dd	offset ready6		;95
	dd	offset ready6		;96
	dd	offset ready6		;97
	dd	offset ready6		;98
	dd	offset ready6		;99
	dd	offset ready6		;100
	dd	offset ready6		;101
	dd	offset ready6		;102
	dd	offset ready6		;103
	dd	offset ready6		;104
	dd	offset ready6		;105
	dd	offset ready6		;106
	dd	offset ready6		;107
	dd	offset ready6		;108
	dd	offset ready6		;109
	dd	offset ready6		;110
	dd	offset ready6		;111
	dd	offset ready6		;112
	dd	offset ready6		;113
	dd	offset ready6		;114
	dd	offset ready6		;115
	dd	offset ready6		;116
	dd	offset ready6		;116
	dd	offset ready6		;118
	dd	offset ready6		;119
	dd	offset ready6		;120
	dd	offset ready6		;121
	dd	offset ready6		;122
	dd	offset ready6		;123
	dd	offset ready6		;124
	dd	offset ready6		;125
	dd	offset ready6		;126
	dd	offset ready6		;127
;
	dd	offset ready6		;128
	dd	offset ready6		;129
	dd	offset ready6		;130
	dd	offset ready6		;131
	dd	offset ready6		;132
	dd	offset ready6		;133
	dd	offset ready6		;134
	dd	offset ready6		;135
	dd	offset ready6		;136
	dd	offset ready6		;137
	dd	offset ready6		;138
	dd	offset ready6		;139
	dd	offset ready6		;140
	dd	offset ready6		;141
	dd	offset ready6		;142
	dd	offset ready6		;143
	dd	offset ready6		;144
	dd	offset ready6		;145
	dd	offset ready6		;146
	dd	offset ready6		;147
	dd	offset ready6		;148
	dd	offset ready6		;149
	dd	offset ready6		;150
	dd	offset ready6		;151
	dd	offset ready6		;152
	dd	offset ready6		;153
	dd	offset ready6		;154
	dd	offset ready6		;155
	dd	offset ready6		;156
	dd	offset ready6		;157
	dd	offset ready6		;158
	dd	offset ready6		;159
	dd	offset ready6		;160
	dd	offset ready6		;161
	dd	offset ready6		;162
	dd	offset ready6		;163
	dd	offset ready6		;164
	dd	offset ready6		;165
	dd	offset ready6		;166
	dd	offset ready6		;167
	dd	offset ready6		;168
	dd	offset ready6		;169
	dd	offset ready6		;170
	dd	offset ready6		;171
	dd	offset ready6		;172
	dd	offset ready6		;173
	dd	offset ready6		;174
	dd	offset ready6		;175
	dd	offset ready6		;176
	dd	offset ready6		;177
	dd	offset ready6		;178
	dd	offset ready6		;179
	dd	offset ready6		;180
	dd	offset ready6		;181
	dd	offset ready6		;182
	dd	offset ready6		;183
	dd	offset ready6		;184
	dd	offset ready6		;185
	dd	offset ready6		;186
	dd	offset ready6		;187
	dd	offset ready6		;188
	dd	offset ready6		;189
	dd	offset ready6		;190
	dd	offset ready6		;191
	dd	offset ready6		;192
	dd	offset ready6		;193
	dd	offset ready6		;194
	dd	offset ready6		;195
	dd	offset ready6		;196
	dd	offset ready6		;197
	dd	offset ready6		;198
	dd	offset ready6		;199
	dd	offset ready6		;200
	dd	offset ready6		;201
	dd	offset ready6		;202
	dd	offset ready6		;203
	dd	offset ready6		;204
	dd	offset ready6		;205
	dd	offset ready6		;206
	dd	offset ready6		;207
	dd	offset ready6		;208
	dd	offset ready6		;209
	dd	offset ready6		;210
	dd	offset ready6		;211
	dd	offset ready6		;212
	dd	offset ready6		;213
	dd	offset ready6		;214
	dd	offset ready6		;215
	dd	offset ready6		;216
	dd	offset ready6		;217
	dd	offset ready6		;218
	dd	offset ready6		;219
	dd	offset ready6		;220
	dd	offset ready6		;221
	dd	offset ready6		;222
	dd	offset ready6		;223
	dd	offset ready6		;224
	dd	offset ready6		;225
	dd	offset ready6		;226
	dd	offset ready6		;227
	dd	offset ready6		;228
	dd	offset ready6		;229
	dd	offset ready6		;230
	dd	offset ready6		;231
	dd	offset ready6		;232
	dd	offset ready6		;233
	dd	offset ready6		;234
	dd	offset ready6		;235
	dd	offset ready6		;236
	dd	offset ready6		;237
	dd	offset ready6		;238
	dd	offset ready6		;239
	dd	offset ready6		;240
	dd	offset ready6		;241
	dd	offset ready6		;242
	dd	offset ready6		;243
	dd	offset ready6		;244
	dd	offset ready6		;245
	dd	offset ready6		;246
	dd	offset ready6		;247
	dd	offset ready6		;248
	dd	offset ready6		;249
	dd	offset ready6		;250
	dd	offset ready6		;251
	dd	offset ready6		;252
	dd	offset ready6		;253
	dd	offset ready6		;254
	dd	offset ready6		;255

; GOTO
	align	16
xgoto:
	inc	ebp			;mange GOTO
goto1:
	call	linenum			;evaluation numero de ligne
goto2:
	test	ebx,ebx			;ligne trouvee ?
	jz	short goto4		;non
goto3:
	mov	nextpc,ebx		;pointeur ligne suivante
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	jmp	exec			;fin execution ligne
gotoln:
	call	fndlinq			;recherche ligne
	je	goto3			;ligne trouvee
goto4:
	mov	al,err_no_line		;ligne non trouvee
	jmp	rpter

; GOSUB
	align	16
gosub:
	inc	ebp			;mange GOSUB
	call	linenum			;evaluation numero de ligne
gosub1:
	push	ebp			;PUSH pointeur code
	push	nextpc			;PUSH pointeur ligne suivante
	push	curpc			;PUSH pointeur ligne courante
	pushd	gosub_mark		;marque GOSUB
	mov	execsp,esp		;maj pointeur pile execution
	jmp	goto2			;execution ligne EBX

; RESUME
	align	16
resume:
	inc	ebp			;mange RESUME
	test	onerflg,0FFh		;traitement ON ERROR ?
	jz	short resum2		;non, erreur
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short resum4		;non
	cmp	al,k_colon		;fin instruction ?
	jae	short resum1		;oui
	cmp	al,k_else
	jne	short resum3		;non
resum1:
	mov	eax,erls		;ligne en erreur
	test	eax,eax			;definie ?
	jnz	short resum5		;oui
resum2:
	mov	al,err_resume		;erreur RESUME
	jmp	rpter
resum3:
	cmp	al,k_next		;NEXT ?
	jne	short resum7		;non, erreur
	mov	eax,erls		;ligne en erreur
	call	fndlinq			;recherche ligne
	jne	resum2			;non trouvee, erreur
	movzx	eax,[ebx].line.l_len	;longueur ligne
	lea	ebx,[ebx+eax+1]		;ligne suivante
	test	[ebx].line.l_number.long.l_b3,0FFh ;fin programme ?
	js	short resum2		;oui, erreur
	mov	onerflg,0		;raz indicateur traitement ON ERROR
	jmp	goto3			;execution ligne suivante
resum4:
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	jne	short resum6		;non
	mov	eax,[ebp+1]		;numero de ligne
	test	eax,eax			;zero ?
	jz	resum1			;oui, re-execute ligne en erreur
resum5:
	mov	onerflg,0		;raz indicateur ON ERROR
	jmp	gotoln			;branchement a la ligne
resum6:
	mov	onerflg,0		;raz indicateur ON ERROR
	jmp	goto1			;branchement
resum7:
	jmp	synerr			;erreur de syntaxe

; DIGITS
	align	16
digits:
	inc	ebp			;mange DIGITS
	mov	sigcn2,-1		;valeur par defaut
	call	evlbyt			;evaluation octet
	test	al,al			;nul ?
	jz	short digits3		;oui, erreur
	cmp	al,17			;plus que le maximum ?
	ja	short digits3		;oui, erreur
	mov	sigcnt,al		;maj nombre de chiffres significatifs
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short digits2		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short digits1		;oui, garde la valeur par defaut
	call	evlbyt			;evaluation octet
	cmp	al,sigcnt		;inferieur au nombre de chiffres significatifs ?
	jae	short digits3		;non, erreur
	mov	sigcn2,al		;range nombre de chiffres apres la virgule
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short digits2		;non
digits1:
	inc	ebp			;mange ,
	call	evlbyt			;evaluation octet
	cmp	al,sigcnt		;inferieur au nombre de chiffres significatifs ?
	jae	short digits3		;non, erreur
	cmp	al,sigcn2		;inferieur au nombre de chiffres apres la virgule ?
	jae	short digits3		;non, erreur
	neg	al			;negation
	mov	sigcnx,al		;range le seuil de basculement notation scientifique
digits2:
	jmp	exec			;fin execution ligne
digits3:
	mov	al,err_digits_arg
	jmp	rpter

; REM
	align	16
rem:
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	jmp	exec			;fin execution ligne

; LET
	align	16
let:
	inc	bp			;mange LET
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short leterr		;oui, erreur
	test	al,conbit		;constante ?
	jnz	short leterr		;oui, erreur
	test	al,strbit		;variable chaine ?
	jnz	short letstr		;oui, affectation chaine
letnum:
	call	prepasn			;prepare affectation
	test	strflg,0FFh		;expression chaine ?
	jnz	short leterr		;oui, erreur
	call	doasv			;affectation variable
	jmp	exec			;fin execution ligne
	align	16
leterr:
	mov	al,err_bad_inst
	jmp	rpter
	align	16
letstr:
	call	getasn			;adresse affectation variable
	skipst				;saut espace et token
	cmp	al,k_eq			;= ?
	jne	leterr			;non, erreur
	inc	ebp			;mange =
	skipst				;saut espace et token
	initexp				;initialise piles evaluation expression
	call	stexp			;evaluation expression chaine
	jz	leterr			;pas de chaine, erreur
	test	strflg,0FFh		;expression chaine ?
	jz	leterr			;non, erreur
	call	dosas			;affectation chaine
	jmp	exec			;fin execution ligne

; EXECUTE
	align	16
execut:
	inc	ebp			;mange EXECUTE
	skipst				;saut espace et token
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	short execut3		;non, erreur
	call	strcnt			;longueur chaine
	test	eax,eax			;vide ?
	jz	short execut4		;oui, erreur
	cmp	eax,maxpath		;valide ?
	jae	short execut5		;non, erreur
	test	al,0FFh
	jz	short execut4		;ligne vide
	mov	ebx,offset buffer
	mov	inptr,ebx		;range pointeur caractere
	call	strtox			;copie chaine
	mov	byte ptr [ebx],cr	;marque de fin
execut1:
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	inptr,ebx		;maj pointeur caractere
	call	initlnums		;initialise premiere et derniere lignes
	call	encode			;code ligne
	cmp	linum,0			;numero de ligne specifie ?
	je	short execut6		;non, execution ligne
	mov	savebp,ebp		;sauvegarde EBP
	call	putlin			;insertion ligne
	call	updlab			;mise a jour etiquettes
	mov	ebp,savebp		;restauration EBP (eventuellement modifie par PUTLIN)
execut2:
	jmp	exec			;fin execution ligne
execut3:
	jmp	synerr			;erreur de syntaxe
execut4:
	mov	al,err_exec_empty	;ligne EXECUTE vide
	jmp	rpter
execut5:
	mov	al,err_exec_str		;ligne EXECUTE trop longue
	jmp	rpter
execut6:
	movzx	eax,linlen		;longueur ligne compilee
	test	eax,eax			;vide ?
	jz	execut2			;oui, ignore
	add	eax,size exc		;ajout taille entete
	push	eax
	call	allocds			;allocation memoire
	pop	[ebx].exc.ex_len	;range longueur
	mov	eax,excchn		;chaine lignes EXECUTE
	mov	[ebx].exc.ex_addr,eax	;chainage ligne EXECUTE
	mov	excchn,ebx
	push	ebp			;PUSH pointeur code
	push	nextpc			;PUSH pointeur ligne suivante
	push	curpc			;PUSH pointeur ligne courante
	pushd	execute_mark		;PUSH marque EXECUTE
	mov	execsp,esp		;maj pointeur pile execution
	lea	edi,[ebx+size exc]
	mov	ebp,edi			;pointeur debut code
	mov	esi,offset linbuf
	movzx	ecx,linlen		;longueur ligne compilee
	rep	movsb			;recopie ligne compilee
	mov	eax,prog_base		;debut programme
	mov	nextpc,eax		;dans ligne suivante (RETURN)
	skipst				;saut espace et token
	movzx	eax,al			;token
	jmp	exec7			;continue

; SWAP
	align	16
swap:
	inc	ebp			;mange SWAP
	skipst				;saut espace et token
	initexp				;initialise piles evaluation expression
	test	al,al			;mot cle ?
	jns	short swap4		;oui, erreur
	call	avar			;adresse variable
	and	al,arrbit+unused+intbit+linbit+strbit ;garde les bits utiles
	mov	asntype,al		;range type variables
	call	comtok			;mange ,
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short swap2		;oui, erreur
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short swap4		;oui, erreur
	push	esi
	call	avar			;adresse variable
	pop	edi
	and	al,arrbit+unused+intbit+linbit+strbit ;garde les bits utiles
	cmp	al,asntype		;meme type variable ?
	jne	short swap4		;non, erreur
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short swap2		;oui, erreur
	test	al,intbit		;entier ?
	jnz	short swap1		;oui
	mov	eax,[esi].large.l_high	;echange parties hautes flottants, longueurs chaines, nombres dimensions tableaux
	xchg	eax,[edi].large.l_high
	mov	[esi].large.l_high,eax
swap1:
	mov	eax,[esi].large.l_low	;echange parties basses flottants, adresses chaines, adresses tableaux ou entiers
	xchg	eax,[edi].large.l_low
	mov	[esi].large.l_low,eax
	jmp	exec			;fin execution ligne
swap2:
	mov	al,err_not_virtual	;virtual arg
swap3:
	jmp	rpter
swap4:
	mov	al,err_swap_arg		;erreur arguments SWAP
	jmp	swap3

; FOR
	align	16
xfor:
	inc	ebp			;mange FOR
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short for2		;oui, erreur
	test	al,conbit+labbit+arrbit+linbit+strbit ;variable entiere ou flottante ?
	jnz	short for2		;non, erreur
	mov	edi,esp			;pointeur entree pile execution
	mov	eax,[ebp+1]		;offset variable
	add	eax,symb_base		;adresse variable
for1:
	cmp	[edi].fore.f_mark,for_mark ;entree FOR dans la pile execution ?
	jne	short for4		;non, pas de FOR avec cette variable
	cmp	eax,[edi].fore.f_var	;meme variable ?
	je	short for3		;oui, supprime cette entree FOR
	add	edi,size fore		;entree suivante
	jmp	for1			;tant qu'il y a des entrees FOR
for2:
	jmp	synerr			;erreur de syntaxe
for3:
	mov	ecx,edi
	lea	esi,[edi+size fore]	;pointeur entree suivante pile execution
	sub	ecx,esp			;nombre d'octets a deplacer dans la pile
	dec	esi
	shr	ecx,2			;nombre de dword
	dec	edi
	std				;en arriere
	rep	movsd			;deplace les entrees FOR
	inc	edi
	cld
	mov	esp,edi			;ajuste pointeur pile execution
	mov	execsp,edi		;maj pointeur pile execution
for4:
	push	eax
	mov	al,[ebp]		;type variable
	call	prepasn			;prepare affectation
	test	strflg,0FFh		;expression chaine ?
	jnz	for2			;oui, erreur
	call	doasv			;affectation variable
	skipst				;saut espace et token
	cmp	al,k_to			;TO ?
	jne	for2			;non, erreur
	inc	ebp			;mange TO
	test	asntype,intbit		;variable entiere ?
	jnz	short for8		;oui
	call	foreval			;evaluation flottant
	pop	esi			;adresse variable
	push	r0.large.l_high		;PUSH valeur finale
	push	r0.large.l_low
	skipst				;saut espace et token
	cmp	al,k_step		;STEP ?
	je	short for7		;oui
	push	esi
	mov	esi,offset dpone	;1,0
	call	esitor0
	pop	esi
for5:
	push	r0.large.l_high		;PUSH pas
	push	r0.large.l_low
for6:
	push	ebp			;PUSH pointeur code debut boucle
	push	nextpc			;PUSH pointeur ligne suivante
	push	curpc			;PUSH pointeur ligne courante
	push	esi			;PUSH adresse variable
	mov	eax,for_mark		;marque FOR
	mov	ah,asntype		;type variable
	push	eax			;PUSH marque FOR et type variable
	mov	execsp,esp		;maj pointeur pile execution
	jmp	exec			;fin execution ligne
for7:
	inc	ebp			;mange STEP
	push	esi
	call	foreval			;evaluation flottant
	pop	esi
	skipst				;saut espace et token
	jmp	for5
for8:
	call	evlint			;evaluation entier
	pop	esi			;adresse variable
	pushd	0
	push	r0i			;PUSH valeur finale
	skipst				;saut espace et token
	cmp	al,k_step		;STEP ?
	je	short for10		;oui
	mov	r0i,1			;1
for9:
	pushd	0
	push	r0i			;PUSH pas
	jmp	for6
for10:
	inc	ebp			;mange STEP
	push	esi
	call	evlint			;evaluation entier
	pop	esi
	skipst				;saut espace et token
	jmp	for9

; POKE
	align	16
poke:
	inc	ebp			;mange POKE
	call	evluint			;evaluation entier non signe
	call	comtok			;mange ,
	push	r0i			;adresse
	call	evlbyt			;evaluation octet
	pop	ebx
	add	ebx,data_base		;adresse memoire ?
	cmp	ebx,data_end		;dans segment memoire ?
	jb	short poke2		;oui
poke1:
	cmp	ebx,symb_base		;dans table symboles ?
	jb	short poke3		;non
	mov	eax,ebx
	sub	eax,symb_base
	cmp	eax,symb_size
	jae	short poke3		;non
poke2:
	mov	[ebx],al		;ecrit octet
poke3:
	jmp	exec			;fin execution ligne

; NEXT
	align	16
next:
	inc	ebp			;mange NEXT
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short next3		;oui
	mov	ebx,[ebp+1]		;offset variable
	add	ebp,1+size_o		;saut token et offset variable
	add	ebx,symb_base		;adresse variable
next1:
	cmp	[esp].fore.f_mark,for_mark ;entree FOR ?
	jne	short next2		;non, erreur
	cmp	ebx,[esp].fore.f_var	;adresse variable identique ?
	je	short next4		;oui
	add	esp,size fore		;entree suivante
	mov	execsp,esp		;maj pointeur pile execution
	jmp	next1			;non
next2:
	mov	al,err_for_next		;NEXT sans FOR
	jmp	rpter
next3:
	cmp	[esp].fore.f_mark,for_mark ;entree FOR ?
	jne	next2			;non, erreur
	mov	ebx,[esp].fore.f_var	;adresse variable
next4:
	test	[esp].fore.f_type,intbit ;variable entiere ?
	mov	ebx,[ebx]		;adresse variable
	jnz	short next10		;oui
	mov	esi,offset r0
	mov	edi,ebx
	mov	eax,[esp].fore.f_step.large.l_low
	mov	[esi].large.l_low,eax	;pas dans R0
	mov	eax,[esp].fore.f_step.large.l_high
	mov	[esi].large.l_high,eax
	call	dpadd			;ajout donnee variable
	lea	ebx,[esp+offset fore.f_value] ;point to final value
	call	dcmp			;comparaison R0 et valeur finale
	lahf
	test	[esp].fore.f_step+7,0FFh ;signe pas
	jns	short next5
	sahf				;negatif
	jae	short next6		;continue la boucle
	jmp	short next8		;fin de boucle
next5:
	sahf				;positif
	ja	short next8		;fin de boucle
next6:
	movsd				;maj donnee variable flottante
	movsd
next7:
	mov	eax,[esp].fore.f_curpc	;pointeur ligne courante boucle
	mov	curpc,eax
	mov	eax,[esp].fore.f_nextpc	;pointeur ligne suivante boucle
	mov	nextpc,eax
	mov	ebp,[esp].fore.f_ebp	;pointeur code debut boucle
	jmp	exec			;fin execution ligne
next8:
	add	esp,size fore		;supprime entree FOR
	mov	execsp,esp		;maj pointeur pile execution
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
next9:
	mov	al,err_int_ovf
	jmp	rpter
next10:
	mov	eax,[ebx]		;donnee variable entiere
	mov	edx,[esp].fore.f_step.large.l_low ;pas
	add	eax,edx			;ajout pas
	jo	next9
	test	edx,edx			;signe pas
	jns	short next11
	cmp	eax,[esp].fore.f_value.large.l_low ;negatif
	jl	next8			;fin boucle
	mov	[ebx],eax		;maj donnee variable entiere
	jmp	next7
next11:
	cmp	eax,[esp].fore.f_value.large.l_low ;positif
	jg	next8			;fin boucle
	mov	[ebx],eax		;maj donnee variable entiere
	jmp	next7

; RETURN
	align	16
return:
	inc	ebp			;mange RETURN
	skipst				;saut espace et token
	cmp	al,k_indirect		;indirection ?
	je	short return7		;oui
return1:
	mov	clrflg,0		;raz indicateur CLEAR
return2:
	mov	al,[esp].rete.r_mark	;marque RETURN
	cmp	al,execute_mark		;retour EXECUTE ?
	je	short return3		;oui
	cmp	al,gosub_mark		;retour GOSUB ?
	je	short return4		;oui
	cmp	al,call_mark		;retour CALL ?
	je	retcall			;oui
	cmp	al,interrupt_mark	;retour interruption ?
	je	short retint		;oui
	cmp	al,for_mark		;entree FOR ?
	jne	short return8		;non, erreur
	add	esp,size fore		;supprime entree FOR
	mov	execsp,esp		;maj pointeur pile execution
	jmp	return2			;repeat
return3:
	mov	ebx,excchn		;chaine lignes EXECUTE
	test	ebx,ebx			;vide ?
	jz	short return4		;oui, erreur (ignore)
	mov	eax,[ebx].exc.ex_addr
	mov	excchn,eax		;sortie chaine lignes EXECUTE
	mov	eax,[ebx].exc.ex_len	;longueur allocation
	call	freeds			;liberation memoire
return4:
	pop	eax			;mange marque
return5:
	pop	curpc			;CURPC retour
	pop	nextpc			;NEXTPC retour
	pop	ebp			;pointeur code retour
	mov	execsp,esp		;maj pointeur pile execution
	test	clrflg,0FFh		;indicateur CLEAR ?
	jnz	short return6		;non
	jmp	exec			;fin execution ligne retour
return6:
	cmp	esp,initsp		;fin de pile ?
	jb	return2			;non, continue a depiler
	jmp	exec			;fin execution ligne retour
return7:
	cmp	byte ptr [ebp+1],k_clear ;CLEAR ?
	jne	return1			;non
	mov	clrflg,0FFh		;indique CLEAR
	jmp	return2
return8:
	mov	al,err_return		;RETURN sans CALL
	jmp	rpter
retint:
; Retour interruption
	movzx	ecx,[esp].rete.r_count	;numero interruption
	mov	al,00000001b		;masque interruption
	shl	al,cl			;masque indicateur interruption
retint1:
	jecxz	short retint3		;toutes les interruptions traitees
	dec	ecx			;decremente numero interruption
	shr	al,1			;ajuste masque indicateur interruption
retint2:
	test	[esp].rete.r_flags,al	;indication interruption ?
	jz	retint1			;non
	mov	ebp,inttbl[ecx*4]	;vecteur interruption
	test	ebp,ebp			;defini ?
	jz	retint1
	mov	[esp].rete.r_count,cl	;maj numero interruption en cours de traitement
	mov	eax,prog_base		;program segment base
	mov	nextpc,eax		;pointeur ligne suivante (RETURN)
	jmp	exec5			;continue execution au vecteur
retint3:
	pop	eax			;mange marque
	pop	curpc			;CURPC retour
	pop	nextpc			;NEXTPC retour
	pop	ebp			;pointeur code retour
	mov	execsp,esp		;maj pointeur pile execution
	mov	intmask,0		;raz masque interruptions
	movzx	eax,byte ptr [ebp]	;token
	jmp	exec7			;continue
; Retour CALL
retcall:
	mov	al,[esp].rete.r_count	;nombre arguments
	test	al,al
	js	return8			;RETURN sans SUB
	movzx	ecx,al			;range
retcall1:
	mov	ebx,excchn		;chaine lignes EXEC
	test	ebx,ebx			;fin de chaine ?
	jz	short retcall2		;oui
	mov	eax,[ebx].exc.ex_addr
	mov	excchn,eax		;sortie chaine
	mov	eax,[ebx].exc.ex_len	;longueur allocation
	call	freeds			;liberation
	jmp	retcall1
retcall2:
	jecxz	retcall6		;pas d'argument
	lea	ebp,[esp+4]		;pointeur parametres
retcall3:
	mov	al,[ebp].para.p_type	;type parametre
	test	al,al			;reference par adresse ?
	js	short retcall4		;oui
	mov	ebx,[ebp].para.p_symb	;adresse symbole
	call	clrvr			;effacement parametre
retcall4:
	add	ebp,size para		;argument suivant
	loop	retcall3		;pour tous les parametres
	pop	eax			;mange marque CALL
	movzx	ecx,ah			;nombre parametres
retcall5:
	pop	eax			;type parametre
	pop	eax			;adresse sauvegardee
	pop	ebx			;adresse symbole
	mov	[ebx],eax		;restaure adresse ou valeur
	loop	retcall5		;pour tous les parametres
	jmp	return5			;marque CALL deja mangee
retcall6:
	jmp	return4

; IF
	align	16
xif:
	inc	ebp			;mange IF
	call	evlint			;evaluation entier
	mov	eax,r0i
	test	eax,eax			;vrai ?
	jz	short if5		;non, faux
	skipst				;saut espace et token
	cmp	al,k_then		;THEN ?
	je	short if3		;oui
	cmp	al,k_goto		;GOTO ?
	je	xgoto			;oui
	mov	al,err_then_no_if	;IF sans THEN 
	jmp	rpter
if3:
	inc	ebp			;mange THEN ou ELSE
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short if4		;oui
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	je	goto1			;oui
if4:
	movzx	eax,byte ptr [ebp]	;token
	jmp	exec7			;continue
if5:
	xor	ecx,ecx			;raz niveau IF
if6:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short if9		;non
	cmp	al,k_else		;ELSE ?
	je	short if10		;oui
	cmp	al,k_if			;IF ?
	je	short if8		;oui
	cmp	al,k_rem		;REM
	je	short if11		;oui
	cmp	al,k_cr			;fin de ligne ?
	je	short if11		;oui
	cmp	al,k_indirect		;indirection token ?
	jne	short if7		;non
	inc	ebp			;mange extension
if7:
	inc	ebp			;mange token
	jmp	if6			;continue
if8:
	inc	ecx			;incremente niveau IF
	inc	ebp			;mange IF
	jmp	if6
if9:
	call	skpop			;saut operande
	jmp	if6			;continue
if10:
	jecxz	if3			;niveau IF nul, prise en compte ELSE
	dec	ecx			;decremente niveau IF
	inc	ebp			;mange ELSE
	jmp	if6			;continue
if11:
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	jmp	exec			;fin execution ligne

; DIM
	align	16
dim:
	inc	ebp			;mange TOKEN ou ,
	skipst				;saut espace et token
	mov	virtchn,0		;raz canal tableau virtuel
	test	al,al			;mot cle ?
	js	short dim1		;non
	cmp	al,k_hashtag		;# ?
	jne	dim6			;non, erreur
	call	dimchn			;configuration canal
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	dim6			;oui, erreur
dim1:
	test	al,labbit+conbit	;constante ou etiquette ?
	jnz	dim6			;oui, erreur
	test	al,arrbit		;tableau ?
	jz	dim6			;non, erreur
	push	eax
	xor	al,al			;type flottant pour allocation variable
	call	varadr			;adresse variable
	cmp	[esi].array.a_addr,0	;deja dimensionne ?
	mov	arayptr,esi		;range adresse tableau
	jne	dim7			;oui, erreur
	pop	eax
	mov	vartyp,al		;range type variable
	call	lepar			;(
	mov	eax,1			;nombre elements
	xor	ebx,ebx			;compteur dimensions
	push	eax
	push	ebx
dim2:
	call	evlint			;evaluation dimension
	pop	ecx
	pop	eax
	mov	ebx,r0i
	inc	ebx			;base zero
	push	ebx			;PUSH dimension
	mul	ebx			;calcul nombre elements
	test	edx,edx			;debordement ?
	jnz	dim8			;oui, erreur
	push	eax
	inc	ecx			;une dimension de plus
	push	ecx
	skipst				;saut espace et token
	inc	ebp			;mange , ou )
	cmp	al,k_comma		;, ?
	je	dim2			;oui, continue
	cmp	al,k_rbracket		;) ?
	jne	short dim6		;non, erreur
	test	virtchn,0FFh		;tableau virtuel ?
	jnz	dim9			;oui
dim3:
	pop	ecx			;nombre de dimensions
	pop	eax			;nombre elements
	test	vartyp,intbit		;entier ?
	jnz	short dim4		;oui, 4 octets par element
	add	eax,eax			;x2, 8 octets par element
	jc	short dim8		;debordement
dim4:
	add	eax,eax			;x2
	jc	short dim8		;debordement
	add	eax,eax			;x2
	jc	short dim8		;debordement
	lea	edx,[ecx*4+4]		;nombre dimensions*4+4 pour la taille
	mov	edi,eax			;taille tableau
	add	eax,edx			;taille totale
	jc	short dim8		;debordement
	push	eax
	call	allocds			;allocation memoire
	pop	dword ptr [ebx]		;range taille totale
	add	ebx,4
	mov	dl,cl			;nombre dimensions
dim5:
	pop	dword ptr [ebx]		;range dimension
	add	ebx,4
	loop	dim5			;pour toutes les dimensions
	mov	ecx,edi			;taille tableau
	mov	edi,ebx			;debut tableau
	mov	ebx,arayptr		;descripteur tableau
	xor	eax,eax
	shr	ecx,2			;nombre de DWORD
	mov	[ebx].array.a_addr,edi	;range adresse tableau
	mov	[ebx].array.a_dim,dl	;nombre de dimensions
	mov	[ebx].array.a_virt,al	;raz indicateur tableau virtuel
	rep	stosd			;raz tableau
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	dim			;oui
	jmp	exec			;fin execution ligne
dim6:
	jmp	synerr			;erreur de syntaxe
dim7:
	mov	al,err_dim_resize	;deja dmensionne
	jmp	rpter
dim8:
	mov	al,err_dim_ovf
	jmp	rpter			;tableau trop grand
dim9:
	pop	ecx
	pop	eax
	lea	eax,[ecx*4+size vrta]	;taille entete tableau virtuel + nombre de dimensions*4
	call	allocds			;allocation memoire
	mov	dl,cl
dim10:
	pop	dword ptr [ebx]		;range dimension
	add	ebx,4
	loop	dim10
	push	ebx			;sauve pointeur entete tableau virtuel
	mov	al,vartyp		;type variable
	and	al,strbit		;garde indicateur chaine
	mov	[ebx].vrta.va_type,al	;indicateur chaine
dim11:
	mov	al,virtchn		;canal tableau virtuel
	mov	[ebx].vrta.va_chan,al	;range
	mov	virtchn,0		;raz
	mov	eax,ebx
	mov	ebx,arayptr		;pointeur descripteur tableau virtuel
	mov	[ebx].array.a_addr,eax	;range adresse
	mov	[ebx].array.a_dim,dl	;nombre de dimensions
	mov	[ebx].array.a_virt,0FFh	;indique tableau virtuel
	mov	al,vartyp		;type variable
	test	al,strbit		;chaine ?
	jnz	short dim12		;oui
	test	al,intbit		;entier ?
	mov	ecx,offset r0		;R0 est le tampon
	mov	eax,size_f		;taille flottant
	jz	short dim13		;non		
	mov	eax,size_i		;taille entier
	jmp	short dim13
dim12:
	skipst				;saut espace et token
	cmp	al,k_eq			;= ?
	mov	eax,defstr		;longueur par defaut chaine
	jne	short dim13		;non
	inc	ebp			;mange =
	call	evalrn			;evaluation longueur chaine
	xor	ecx,ecx			;pas de tampon
dim13:
	pop	ebx			;pointeur entete tableau viruel
	mov	[ebx].vrta.va_size,eax	;taille 
	test	eax,eax			;nulle ?
	jz	short dim14		;oui, erreur
	mov	esi,fcbdir		;pointeur FCB acces directe
	mov	[esi].fcb.fcb_cntlen,eax ;longueur enregistrement
	mov	[esi].fcb.fcb_bufadr,ecx ;adresse tampon
	movzx	eax,[ebx].vrta.va_chan
	mov	ebx,arayptr		;pointeur description tableau virtuel
	mov	vatab[eax*4],ebx	;range
	jmp	exec			;fin execution ligne
dim14:
	mov	al,err_bad_len		;longueur invalide
	jmp	rpter

; ON
	align	16
on:
	inc	ebp			;mange ON
	skipst				;saut espace et token
	cmp	al,k_error		;ERROR ?
	je	onerr			;oui
	cmp	al,k_int		;INT ?
	je	onint			;oui
	call	evlint			;evaluation entier
	mov	eax,r0i
	test	eax,eax			;rang negatif ?
	js	short on5		;oui
on1:
	mov	ecx,eax			;rang
	skipst				;saut espace et token
	cmp	al,k_gosub		;GOTO ou GOSUB ?
	ja	short on9		;non, erreur
	mov	dl,al			;sauve TOKEN
on2:
	inc	ebp			;mange GOTO, GOSUB ou ,
	skipst				;saut espace et token
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	je	short on3		;oui
	test	al,labbit		;etiquette ?
	jnz	short on3		;oui
	cmp	al,tok_mark+strbit	;variable chaine ?
	jne	short on7		;non
	dec	cl			;rang atteint ?
	je	short on6		;oui
	add	ebp,1+size_o		;mange token et offset symbole
	jmp	short on4
on3:
	dec	cl			;rang atteint ?
	je	short on6		;oui
	add	ebp,1+size_i+size_a	;mange token, numero de ligne (ou offset etiquette) et adresse ligne
on4:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	on2			;oui
	jmp	short on7
on5:
	xor	eax,eax			;rang a zero
	jmp	on1
on6:
	cmp	dl,k_goto		;ON n GOTO ?
	je	goto1			;oui, execution GOTO
	call	linenum			;evaluation numero de ligne
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	jmp	gosub1			;DO GOSUB
on7:
	cmp	al,k_else		;ELSE ?
	jne	short on8		;non
	inc	ebp			;mange ELSE
	skipst				;saut espace et token
	jmp	exec5			;execution instruction
on8:
	jmp	exec			;fin execution ligne
on9:
	mov	al,err_on_arg		;erreur argument ON
	jmp	rpter
onerr:
; ON ERROR
	inc	ebp			;mange ERROR
	skipst				;saut espace et token
	cmp	al,k_goto		;GOTO ?
	jne	short onerr4
	inc	ebp			;mange GOTO
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short onerr3		;oui, raz
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	jne	short onerr2		;non
	mov	eax,[ebp+1]		;numero
	add	ebp,1+size_i+size_a	;mange token, numero de ligne et adresse ligne
onerr1:
	mov	ergol,eax		;range
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
onerr2:
	test	al,labbit		;etiquette ?
	jz	short onerr4		;non, erreur
	mov	eax,[ebp+1]		;offset symbole
	add	ebp,1+size_o+size_a	;mange token, offset etiquette et adresse ligne
	add	eax,symb_base		;pointeur symbole
	mov	eax,[eax]		;valeur (numero de ligne)
	jmp	onerr1
onerr3:
	mov	ergol,0			;raz ERGOL
	jmp	exec			;fin execution ligne
onerr4:
	jmp	synerr			;erreur de syntaxe
onint:
; ON INT
	inc	ebp			;mange INT
	call	evlbyt			;evaluation octet
	cmp	al,break_int		;numero interruption valide ?
	ja	short onint5		;non, erreur
	test	dirflg,0FFh		;mode direct ?
	jnz	short onint6		;oui, erreur
onint1:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short onint2		;non
	cmp	al,k_colon		;fin instruction ?
	jb	short onint2		;non
	xor	ebp,ebp			;vecteur nul
onint2:
	mov	eax,r0i			;numero interruption
	test	eax,eax			;interruption BREAK ?
	jnz	short onint3		;non
	test	ebp,ebp			;vecteur defini ?
	jz	short onint4		;non
	or	intflags,trace_mask	;indique interruption trace
onint3:
	mov	inttbl[eax*4],ebp	;range vecteur
	mov	ebp,offset emptyprog.prog.end_of_line ;pointeur code sur fin de ligne
	jmp	exec			;fin execution ligne
onint4:
	and	intflags,not trace_mask ;raz indicateur interruption trace
	jmp	onint3
onint5:
	mov	al,err_arg_ovf
	jmp	rpter
onint6:
	jmp	synerr			;erreur de syntaxe

; SET
	align	16
set:
	inc	ebp			;saut SET
	skipst				;saut espace et token
	call	evlint			;evaluation entier
	mov	ebx,r0i
	test	ebx,ebx			;strictement positif ?			
	jle	short set2		;non
	dec	ebx			;base zero
	push	ebx
	call	comtok			;mange ,
	call	setasn			;prepare affectation dans une chaine existante
	pop	edx			;position
	add	ebx,edx			;ajuste pointeur chaine existante
	sub	ecx,edx			;ajuste longueur chaine existante
	jbe	short set1		;position hors chaine
	call	strxfr			;transfert chaine
set1:
	jmp	exec			;fin execution ligne
set2:
	mov	al,err_neg_arg		;argument negatif
	jmp	rpter

; END
	align	16
xend:
	mov	eax,prog_base		;debut programme
	mov	curpc,eax		;pointeur programme au debut
	mov	nextpc,eax		;ligne suivante au debut
	add	eax,size line		;pointeur debut premiere ligne
	mov	savebp,eax		;initialisation sauvegarde EBP
	jmp	exec12			;non

; STOP
	align	16
stop:
	inc	ebp			;mange STOP
stop1:
	cmp	colm,0			;curseur en debut de ligne ?
	je	short stop2		;oui
	call	pcrlf			;saut de ligne
stop2:
	mov	esi,offset stpmsg
	call	pmsg			;affichage STOP
	xor	eax,eax
	mov	contflg,al		;raz indicateur CONTINUE possible
	mov	errs,eax		;raz dernier code d'erreur
	mov	ebx,curpc		;pointeur ligne courante
	cmp	ebx,prog_base		;debut programme ?
	je	short stop3		;oui, ignore
	mov	contcur,ebx		;range pointeur ligne courante
	mov	eax,nextpc		;pointeur ligne suivante
	mov	contnxt,eax		;range pointeur ligne suivante
	mov	contebp,ebp		;range pointeur code
	mov	contflg,0FFh		;indique CONTINUE possible
	mov	eax,[ebx].line.l_number
	mov	erls,eax		;numero de ligne dans ERL
stop3:
	jmp	rpter4

; RESTORE
	align	16
restore:
	inc	ebp			;mange RESTORE
	xor	eax,eax
	mov	datapt,eax		;raz pointeur DATA
	mov	eax,prog_base
	mov	dataln,eax		;pointeur ligne en debut de programme
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short resto1		;oui
	call	linenum			;evaluation numero de ligne
	test	ebx,ebx			;ligne trouvee ?
	jz	short resto2		;non
	mov	dataln,ebx		;maj pointeur ligne DATA
resto1:
	jmp	exec			;fin execution ligne
resto2:
	mov	al,err_no_line		;ligne non trouvee
	jmp	rpter

; CALL
	align	16
xcall:
	inc	ebp			;mange CALL
	skipst				;saut espace et token
	cmp	al,k_hashtag		;# ?
	je	calllib			;oui
	call	linenum			;evaluation numero de ligne
	push	ebx
	initexp				;initialise piles evaluation expression
	skipst				;saut espace et token
	cmp	al,k_lbracket		;( ?
	jne	call8			;pas de parametre
call1:
	inc	ebp			;mange ( ou ,
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short call2		;oui, passage par valeur
	test	al,conbit		;constante ?
	jnz	short call2		;oui, passage par valeur
	push	ebp			;range pointeur token
	call	avar			;adresse variable
	call	pshpara			;PUSH adresse parametre
	pop	ebx
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	call1			;oui, continue
	cmp	al,k_rbracket		;) ?
	je	call7			;fin de liste
	sub	atos,size para		;depile argument variable
	mov	ebp,ebx			;retour sur debut argument
call2:
	mov	strflg,0		;raz indicateur expression chaine
	call	exp			;evaluation expression
	jz	short call3		;pas d'expression, erreur
	test	strflg,0FFh		;expression chaine ?
	jz	short call4		;non
	mov	eax,size strg		;taille descripteur chaine
	call	allocds			;allocation memoire
	mov	asnadr,ebx		;adresse affectation
	xor	ebx,ebx			;pas d'ancienne chaine
	call	dosas1			;affectation chaine
	mov	al,strbit		;type chaine
	jmp	short call5
call3:
	jmp	synerr			;erreur syntaxe
call4:
	call	popr0			;POP resultat expression
	push	eax			;type variable
	call	setarg			;allocation et affectation argument
	pop	eax
call5:
	mov	esi,asnadr		;adresse affectation
	call	pshpara			;PUSH adresse parametre
	mov	al,[ebp]		;token suivant
	cmp	al,k_comma		;, ?
	je	call1			;oui
call6:
	cmp	al,k_rbracket		;) ?
	jne	call3			;non, erreur
call7:
	inc	ebp			;mange )
	skipst				;saut espace et token
call8:
	pop	ebx			;pointeur ligne SUB
	push	ebp			;PUSH pointeur code
	push	nextpc			;PUSH pointeur ligne suivante
	push	curpc			;PUSH pointeur ligne courante
	pushd	10000000b*256+call_mark	;PUSH marque CALL et indicateur attente SUB
	mov	execsp,esp		;maj pointeur pile execution
	jmp	goto2			;execution ligne EBX

; CHAIN
	align	16
chain:
	inc	ebp			;mange CHAIN
chain1:
	mov	al,ext_bac		;extension .BAC par defaut
	call	setfls			;evaluation nom de fichier
	push	ebx
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short chain2		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
chain2:
	mov	runline,0		;demarrage au debut par defaut 
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short chain3		;pas d'expression
	call	pulint			;POP entier
	mov	eax,r0i
	mov	runline,eax		;ligne demarrage
chain3:
	call	wfopenread		;ouverture en lecture fichier de travail
	pop	ebx
	jc	short chain7		;erreur
	mov	esp,initsp		;reinitialisation pile
	mov	execsp,esp		;et pile execution
	push	ebx
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	call	inivar			;reinitialisation variables windows
	call	clrprog			;effacement programme
	mov	eax,prog_base
	mov	curpc,eax		;pointeur programme au debut
	add	eax,size line		;pointeur debut premiere ligne
	mov	savebp,eax		;initialisation sauvegarde EBP
	call	clrsp			;effacement espace de travail
	pop	ebx			;fin nom de fichier
chain4:
	mov	dirflg,0FFh		;indique mode direct
	mov	eax,[ebx-4]		;extension fichier
	and	eax,0DFDFDFFFh		;majuscule
	cmp	eax,'CAB.'		;extension BAC ?
	je	short chain5		;oui
	call	dosload			;chargement fichier source
	jmp	short chain6
chain5:
	call	dobload			;chargement fichier binaire
	jc	short chain7		;erreur
chain6:
	call	wfclose			;fermeture fichier de travail
	mov	dirflg,0		;raz indicateur mode direct
	mov	contflg,0		;raz indicateur CONTINUE
	jmp	run3			;execution fichier charge
chain7:
	jmp	rpter

; FIELD STATEMENT
	align	16
field:
	inc	ebp			;mange FIELD
	skipst				;saut espace et token
	cmp	al,k_hashtag		;IS IT "#"?
	jne	short field2		;non
	call	fldchn			;configuration cannal FIELD
	mov	fldptr,edx		;pointeur tampon FIELD
	add	edx,ecx			;ajout longueur
	mov	fldend,edx		;fin tampon FIELD
field1:
	call	fieldc			;adresse variable et longueur chaine element
	pushfd
	mov	ebx,fldptr		;pointeur tampon FIELD
	mov	ecx,ebx
	add	ebx,eax			;fin tampon utilise
	cmp	ebx,fldend		;rentre dans le tampon FIELD
	mov	fldptr,ebx		;maj pointeur tampon FIELD
	ja	short field4		;non, erreur
	or	eax,080000000h		;indique FIELD
	mov	[esi].strg.str_addr,ecx	;maj adresse chaine
	mov	[esi].strg.str_len,eax	;maj longueur chaine
	popfd				;ZF si ,
	jne	short field3		;fin description FIELD
	inc	ebp			;mange ,
	jmp	field1			;continue
field2:
	call	fieldc			;adresse variable et longueur chaine element
	pushfd
	push	eax			;longueur chaine
	call	allocds			;allocation memoire
	mov	[esi].strg.str_addr,ebx	;maj adresse chaine
	pop	[esi].strg.str_len	;maj longueur		
	popfd				;ZF si ,
	jne	short field3
	inc	ebp			;mange ,
	jmp	field2
field3:
	jmp	exec			;fin execution ligne
field4:
	mov	al,err_field_size	;FIELD to long
	jmp	rpter

; LSET
	align	16
lset:
	inc	ebp			;mange LSET
	call	setasn			;prepare affectation dans une chaine existante
	call	strxfr			;transfert chaine
	jecxz	short lset1		;pas de remplissage
	call	strpad			;remplissage
lset1:
	jmp	exec			;fin execution ligne

; RSET
	align	16
rset:
	inc	ebp			;mange RSET
	call	setasn			;prepare affectation dans une chaine existante
	push	ebx
	push	ecx
	call	strcnt			;longueur chaine affectee
	pop	ecx			;longueur chaine existante
	pop	ebx			;adresse chaine
	mov	eax,ecx
	sub	eax,r0i			;remplissage ?
	push	ebx
	js	short rset1		;non
	add	ebx,eax			;position remplissage
rset1:
	call	strxfr			;transfert chaine
	pop	ebx
	jecxz	rset2			;pas de remplissage
	call	strpad			;remplissage
rset2:
	jmp	exec			;fin execution ligne

; EXEC
	align	16
xexec:
	inc	ebp			;mange EXEC
	skipst				;saut espace et token
	initexp				;initialise piles evaluation expression
	call	stexp			;evaluation expression chaine
	jz	short xexec1		;pas de chaine, erreur
	test	strflg,0FFh		;expression chaine ?
	jz	short xexec1		;non
	call	strcnt			;longueur chaine
	test	eax,eax			;vide ?
	jz	short xexec1		;oui
	cmp	eax,maxcmd		;rentre dans tampon ligne ?
	ja	short xexec1		;non, erreur
	mov	ebx,offset buffer	;tampon de travail
	push	ebx
	call	strtox			;copie chaine
	mov	byte ptr [ebx],0	;matque de fin
	pop	edx
	call	fsystem			;execution commande systeme
	jmp	exec			;fin execution ligne
xexec1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; DPOKE
	align	16
dpoke:
	inc	ebp			;mange DPOKE
	call	evluint			;evaluation entier non signe
	call	comtok			;mange ,
	push	r0i			;adresse
	call	evlint			;evaluation entier
	pop	eax
	mov	ebx,eax
	add	eax,size_i-1		;adresse fin donnee
	cmp	ebx,data_base		;dans segment donnees ?
	jb	short dpoke1		;non
	cmp	eax,data_end
	jb	short dpoke2		;oui
dpoke1:
	cmp	ebx,symb_base		;dans table symboles ?
	jb	short dpoke3		;non
	sub	eax,symb_base
	cmp	eax,symb_size
	jae	short dpoke3		;non
dpoke2:
	mov	eax,r0i			;donnee
	mov	[ebx],eax		;ecriture
dpoke3:
	jmp	exec			;fin execution ligne

; SUB
	align	16
xsub:
	inc	ebp			;mange SUB
	skipst				;saut espace et token
	cmp	[esp].rete.r_mark,call_mark ;entree CALL ?
	jne	sub4			;non, erreur
	test	[esp].rete.r_count,0FFh	;en attente SUB ?
	jns	sub4			;non, erreur
	test	al,al			;mot cle ?
	jns	short sub1		;oui, pas d'etiquette
	test	al,labbit		;etiquette ?
	jz	short sub3		;non, erreur
	add	ebp,1+size_o+size_a	;mange token, offset etiquette et adresse ligne
	skipst				;saut espace et token
sub1:
	add	esp,4			;mange marque CALL en attente SUB
	mov	ebx,offset astack	;pile arithmetique
	mov	ecx,2			;compteur parametres (ERGOL et EXCCHN)
	cmp	ebx,atos		;fin parametress ?
	jae	sub14			;oui
	cmp	al,k_lbracket		;( ?
	jne	short sub3		;non, erreur
sub2:
	inc	ebp			;mange ( ou ,
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short sub3		;oui, erreur
	test	al,conbit+linbit+labbit ;variable ?
	jnz	short sub3		;non, erreur
	xor	al,[ebx].calla.ca_type	;type parametre XOR type argument
	test	al,not tok_mark		;identique ?
	jz	short sub8		;oui
	test	al,arrbit+strbit	;types compatibles ?
	jnz	short sub5		;non, erreur
	mov	al,[ebx].calla.ca_type	;type argument
	test	al,al			;variable (TOK_MARK positionne) ?
	js	short sub5		;oui, erreur
	test	al,intbit		;valeur entiere ?
	jz	short sub6		;non
	and	[ebx].calla.ca_type,not intbit ;convertion en flottant
	push	ecx
	push	ebx
	mov	ebx,[ebx].calla.ca_addr	;adresse valeur
	mov	eax,[ebx]		;valeur entiere
	mov	r0i,eax
	mov	eax,size_i		;taille entier
	call	freeds			;liberation memoire
	call	floatr0			;convertion
	jmp	short sub7
sub3:
	jmp	synerr			;erreur syntaxe
sub4:
	mov	al,err_sub		;SUB sans CALL
	jmp	rpter
sub5:
	mov	al,err_call_type	;erreur type
	jmp	rpter
sub6:
	or	[ebx].calla.ca_type,intbit ;conversion entier
	push	ecx
	push	ebx
	mov	ebx,[ebx].calla.ca_addr	;adresse valeur
	mov	esi,ebx
	call	esitor0			;copie flottant
	mov	eax,size_f		;taille flottant
	call	freeds			;liberation memoire
	call	intger			;convertion R0 en entier
sub7:
	pop	ebx
	mov	al,[ebx].calla.ca_type	;type argument
	push	ebx
	call	setarg			;allocation et affectation parametre
	pop	ebx
	pop	ecx
	mov	eax,asnadr		;adresse affectation
	mov	[ebx].calla.ca_addr,eax ;maj adresse variable
sub8:
	mov	esi,[ebp+1]		;offset parametre
	add	esi,symb_base		;adresse parametre
	mov	eax,[esi]		;adresse valeur parametre
	cmp	eax,[ebx].calla.ca_addr ;adresse valeur parametre et adresse valeur argument (ne peut pas etre nulle) identiques ?
	je	short sub9		;oui, meme symbole
	mov	[ebx].calla.ca_symb,esi ;sauvegarde adresse symbole
sub9:
	mov	al,[ebx].calla.ca_type	;type parametre
	add	ebx,size calla		;parametre suivant
	call	sublcl			;mange (*) si tableau, token
	cmp	ebx,atos		;fin parametres ?
	jae	short sub11		;oui
	cmp	al,k_comma		;, ?
	je	sub2			;oui, suivant
sub10:
	jmp	synerr			;erreur syntaxe
sub11:
	cmp	al,k_rbracket		;) ?
	jne	sub10			;non, erreur
	inc	ebp			;mange )
	skipst				;saut espace et token
	mov	ebx,offset astack	;pile aritmetique
sub12:
	cmp	ebx,atos		;fin parametre ?
	jae	short sub14
	mov	esi,[ebx].calla.ca_symb	;adresse symbole
	test	esi,esi			;nulle ?
	jz	short sub13		;oui, pas de sauvegarde
	push	esi			;PUSH sauvegarde adresse parametre
	push	dword ptr [esi]		;PUSH ancienne adresse valeur
	mov	eax,[ebx].calla.ca_addr	;nouvelle adresse valeur
	mov	[esi],eax		;maj valeur parametre
	movzx	eax,[ebx].calla.ca_type
	push	eax			;PUSH type parametre
	inc	cl			;un parametre de plus
	js	short sub15		;trop de parametres
sub13:
	add	ebx,size calla		;parametre suivant
	jmp	sub12
sub14:
	mov	ebx,offset ergol	;ligne branchement ON ERROR
	push	ebx			;PUSH adresse ERGOL
	push	dword ptr [ebx]		;PUSH valeur ERGOL
	pushd	tok_mark+intbit		;PUSH type entier et reference par adresse
	mov	dword ptr [ebx],0	;raz ERGOL
	mov	ebx,offset excchn	;chaine des lignes EXECUTE
	push	ebx			;PUSH adresse EXCCHN
	push	dword ptr [ebx]		;PUSH valeur EXCCHN
	pushd	tok_mark+intbit		;PUSH type entier et reference par adresse
	mov	dword ptr [ebx],0	;raz EXCCHN
	mov	eax,call_mark		;marque CALL
	mov	ah,cl			;nombre arguments
	push	eax			;PUSH marque CALL et nombre arguments
	mov	execsp,esp		;maj pointeur pile execution
	jmp	exec			;fin execution ligne
sub15:
	mov	al,err_too_arg		;trop de parametres
	jmp	rpter

; LABEL
	align	16
xlabel:
	inc	ebp			;mange LABEL
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short label1		;oui, erreur
	test	al,labbit		;etiquette ?
	jz	short label1		;non, erreur
	add	ebp,1+size_o+size_a	;mange token, offset symbole et adresse ligne
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
label1:
	jmp	synerr

; PLAY
	align	16
play:
	inc	ebp			;mange PLAY
	mov	al,ext_wav		;extension .WAV par defaut
	call	setfls			;evaluation nom de fichier
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	mov	eax,0			;pas d'attente par defaut
	jne	short play1		;non, pas d'indicateur
	inc	ebp			;mange,
	call	evlint			;evaluation entier
	mov	eax,r0i			;indicateur attente
play1:
	call	playwav			;joue le fichier
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; CLEAR
	align	16
xclear:
	inc	ebp			;mange CLEAR
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short clear3		;oui
clear1:
	test	al,conbit+labbit	;constante ou etiquette ?
	jnz	short clear2		;oui, erreur
	mov	ebx,[ebp+1]		;offset variable
	add	ebx,symb_base		;adresse variable
	push	eax
	call	clrvr			;effacement variable
	pop	eax
	call	sublcl			;mange (*) si tableau, token
	cmp	al,k_comma		;, ?
	jne	short clear4		;non, fin de liste
	inc	ebp			;mange ,
	skipst				;saut espace et token
	jmp	clear1			;continue
clear2:
	mov	al,err_clr_arg		;erreur argument CLEAR
	jmp	rpter
clear3:
	call	clsall			;fermeture tous fichiers
	call	cleargraphic		;fermeture fenetre graphique
	call	inivar			;reinitialisation variables windows
	call	clrsp			;effacement espace de travail
	push	ebp
	call	updlab			;mise a jour etiquettes
	pop	ebp
clear4:
	jmp	exec			;fin execution ligne

; TRON
	align	16
tron:
	inc	ebp			;mange TRON
	mov	trcflg,0FFh		;indique trace
	or	intflags,trace_mask	;indique interruption trace
	test	dirflg,0FFh		;mode direct ?
	jnz	short tron3		;oui, fin execution
	mov	eax,trace_int		;numero interruption trace
tron2:
	mov	r0i,eax
	jmp	onint1
tron3:
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; TROFF
	align	16
troff:
	inc	ebp			;mange TROFF
	xor	eax,eax
	mov	trcflg,al		;raz indicateur trace
	and	intflags,not trace_mask ;raz indicateur interruption trace
	mov	inttbl+4*trace_int,eax	;raz vecteur interruption trace
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; DELETE
	align	16
delte:
	inc	ebp			;mange DELETE
	call	frslst			;evaluation premiere et derniere ligne
	mov	savebp,ebp		;sauvegarde EBP
	call	delete			;efface les lignes dans l'intervalle
	jc	short delte1
	call	clraddr			;raz adresse dans numeros de ligne et etiquettes
	call	updlab			;mise a jour etiquettes
	mov	ebp,savebp		;restauration EBP (eventuellement modifie par DELETE)
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
delte1:
	jmp	rpter

; LOAD
	align	16
load:
	inc	ebp			;mange LOAD
	mov	al,ext_bas		;default .BAS extension
	call	setfls			;evaluation nom de fichier
	call	wfopenread		;ouverture en lecture fichier de travail
	jc	short load2		;erreur
load1:
	call	frslst			;evaluation premiere et derniere ligne
	mov	savebp,ebp		;sauvegarde EBP
	call	dosload			;chargement fichier source
	mov	ebp,savebp		;restauration EBP (eventuellement modifie par DOSLOAD)
	call	wfclose			;fermeture fichier de travail
	call	initlnums		;initialise premiere et derniere lignes
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
load2:
	jmp	rpter			;erreur fichier

; BLOAD
	align	16
bload:
	inc	ebp			;mange BLOAD
	mov	al,ext_bac		;extension .BAC par defaut
	call	setfls			;evaluation nom de fichier
	call	wfopenread		;ouverture en lecture fichier de travail
	jc	bload3			;erreur
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	bload5			;non
	push	eax
	call	initlnums		;initialise premiere et derniere lignes
	pop	eax
	cmp	al,k_comma		;, ?
	jne	short bload1		;non, pas de parametre
	inc	ebp			;mange ,
	call	comtok			;mange seconde ,
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short bload1		;non presente
	call	pulline			;numero de ligne
	mov	offst,eax		;deplacement
bload1:
	mov	savebp,ebp		;sauvegarde EBP
	call	dobload			;chargement fichier binaire
	mov	ebp,savebp		;restauration EBP (eventuellement modifie par DOBLOAD)
	push	eax
	pushfd
	call	initlnums		;initialise premiere et derniere lignes
	call	wfclose			;fermeture fichier de travail
	popfd
	pop	eax
	jc	short bload3		;erreur
	call	clrsave			;raz indicateur sauvegarde source
	jmp	exec			;fin execution ligne
bload2:
	mov	al,err_not_virtual	;virtual arg
bload3:
	jmp	rpter
bload4:
	jmp	synerr			;erreur de syntaxe
bload5:
	test	al,conbit+linbit+labbit ;variable ?
	jnz	bload4			;non, erreur
	test	al,strbit		;chaine ?
	jz	bload4			;non, erreur
	call	getasn			;adresse affectation variable
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	bload2			;oui, erreur
	mov	ebx,asnadr		;adresse affectation
	mov	eax,[ebx].strg.str_len	;longueur ancienne chaine
	mov	ebx,[ebx].strg.str_addr	;adresse ancienne chaine
	test	ebx,ebx			;ancienne chaine vide ?
	jz	short bload7		;oui, pas de liberation
	test	eax,eax			;chaine FIELD ou de longueur nulle ?
	jle	short bload6		;oui, pas de liberation
	call	freeds			;liberation memoire
bload6:
	mov	ebx,asnadr
	xor	eax,eax
	mov	[ebx].strg.str_addr,eax	;desaffectation chaine
	mov	[ebx].strg.str_len,eax	;longueur nulle
bload7:
	call	wfsize			;taille fichier de travail
	jc	bload3			;erreur
	test	eax,eax			;longueur nulle ?
	jz	short bload8		;oui, chaine vide (CF=0)
	push	eax
	call	allocds			;allocation memoire
	mov	eax,ebx			;adresse
	pop	ecx
	mov	ebx,asnadr
	mov	[ebx].strg.str_addr,eax	;affectation adresse
	mov	[ebx].strg.str_len,ecx	;affectation longueur
	mov	ebx,eax			;adresse rangement chaine
	call	wfread			;lecture fichier
bload8:
	pushfd
	push	eax
	call	wfclose			;fermeture fichier de travail
	pop	eax
	popfd
	jc	bload3
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; OVERLAY
	align	16
ovrlay:
	inc	ebp			;mange OVERLAY
	skipst				;saut espace et token
	cmp	al,k_colon		;fin instruction ?
	jge	short ovrlay1		;oui
	call	evlint			;evaluation entier
ovrlay1:
	jmp	exec			;fin execution ligne

; LOCAL
	align	16
xlocal:
	inc	ebp			;mange LOCAL
	cmp	[esp].rete.r_mark,call_mark ;marque CALL ?
	jne	short local3		;non, erreur
	mov	al,[esp].rete.r_count	;nombre arguments
	test	al,al			;en attente de SUB ?
	js	short local3		;oui, LOCAL sans SUB
	movzx	ecx,al			;range
	pop	eax			;mange marque CALL et nombre arguments
local1:
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short local5		;oui, erreur
	test	al,conbit+linbit+labbit ;variable ?
	jnz	short local5		;non, erreur
	mov	ebx,[ebp+1]		;offset variable
	add	ebx,symb_base		;adresse variable
	and	al,not tok_mark		;indique reference par valeur
	push	ebx			;PUSH adresse variable
	push	[ebx]			;PUSH valeur courant
	movzx	eax,al
	mov	dword ptr [ebx],0	;raz valeur
	push	eax			;PUSH type
	inc	ecx			;un argument de plus
	js	short local4		;trop d'arguments
	call	sublcl			;mange (*) si tableau, token
	cmp	al,k_comma		;, ?
	jne	short local2		;non
	inc	ebp			;mange ,
	jmp	local1			;argument suivant
local2:
	mov	eax,call_mark		;marque CALL
	mov	ah,cl			;nombre arguments
	push	eax			;PUSH marque CALL et nombre arguments
	mov	execsp,esp		;maj pointeur pile execution
	jmp	exec			;fin execution ligne
local3:
	mov	al,err_local		;erreur LOCAL sans SUB
	jmp	rpter
local4:
	mov	al,err_too_arg		;trop d'arguments
	jmp	rpter
local5:
	jmp	synerr			;erreur de syntaxe

; COMPILE
	align	16
compile:
	inc	ebp			;mange COMPILE
	mov	cmpopt,0		;raz options compilation
	call	tstned			;test edition source autorisee
	mov	al,ext_bac		;extension .BAC par defaut
	call	setfls			;evaluation nom de fichier
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	compile5		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	compile5		;oui, pas d'option
	test	al,strbit		;chaine ?
	jz	short compile5		;non, pas d'option
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	short compile3		;non, erreur
	push	first			;sauvegarde FIRST et LASTX utilises par NXTSC
	push	lastx
	mov	first,0			;raz pour NXTSC
compile1:
	call	nxtsc			;caractere chaine suivant
	jz	short compile4		;fin de chaine
compile2:
	and	al,11011111b		;majuscule
	mov	ecx,optlen
	mov	edi,offset opttab	;caracteres options
	repne	scasb
	jne	compile1		;non trouve
	sub	edi,offset opttab+1	;index option
	mov	ecx,edi
	mov	al,00000001b
	shl	al,cl
	or	cmpopt,al		;positionne option compilation
	jmp	compile1
compile3:
	jmp	synerr			;erreur de syntaxe
compile4:
	pop	lastx			;restauration FIRST et LASTX
	pop	first
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short compile6		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
compile5:
	call	frslst			;evaluation premiere et derniere ligne
compile6:
	push	ebp
	call	progsize		;taille programme en memoire
	cmp	eax,size prog		;programme vide ?
	jbe	short compile9		;oui, rien a compiler
	call	wfopenwrite		;ouverture en ecriture fichier de travail
	call	clraddr			;raz adresse dans numeros de ligne et etiquettes
	call	prepbin			;prepare image binaire
	jc	short compile10		;erreur
	call	progsize		;taille 
	mov	ecx,eax			;taille code
	mov	ebx,prog_base		;program segment base
	mov	al,cmpopt		;options de compilation
	mov	[ebx].prog.prog_type,al ;range dans entete
	push	edx
	call	wfwrite			;ecriture fichier travail
	pop	ecx			;taille table symboles
	jc	short compile7		;erreur
	mov	ebx,symb_base		;base table symboles
	call	wfwrite			;ecriture fichier travail
compile7:
	pushfd
	push	eax
	call	wfclose			;fermeture fichier de travail
	test	cmpopt,compressed+nosymb+librairy+overlay ;image binaire transformee ?
	jz	short compile8		;non
	call	readtmp			;restauration programme a partir fichier temporaire
compile8:
	pop	eax
	popfd
	jc	short compile10		;erreur
	call	clrsave			;raz indicateur sauvegarde source
compile9:
	call	initlnums		;initialise premiere et derniere lignes
	pop	ebp
	jmp	exec			;fin execution ligne
compile10:
	jmp	rpter

; BRON
	align	16
onbrk:
	inc	ebp			;mange BRON
	mov	breakflg,0FFh		;activation BREAK
	call	brkon			;reactive BREAK par Control-C
	test	dirflg,0FFh		;mode direct ?
	jnz	short onbrk2		;oui, fin execution
	mov	eax,break_int		;numero interruption BREAK
	jmp	tron2
onbrk2:
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; BROFF
	align	16
offbrk:
	inc	ebp			;mange BROFF
	xor	eax,eax
	mov	breakflg,al		;desactivation BREAK
	call	brkoff			;desactive BREAK par Control-C
	mov	inttbl+4*break_int,eax	;raz vecteur BREAK
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; CLS
	align	16
cls:
	inc	ebp			;mange CLS
	mov	filswi,0		;pas de fichier d'entree
	mov	al,ff
	call	outch			;affichage Form Feed
	mov	colm,0			;debut de ligne
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; LIST
	align	16
xlist:
	inc	ebp			;mange LIST
	call	frslst			;evaluation premiere et derniere ligne
	push	ebp
	mov	listcolflg,0		;pas d'affichage couleur
	call	listp
	pop	ebp
	jmp	exec			;fin execution ligne

; TIME
	align	16
time:
	inc	ebp			;mange TIME
	skipst				;saut espace et token
	cmp	al,k_print		;PRINT ?
	je	short time1		;oui
	cmp	al,tok_mark+fltbit	;variable flottante ?
	je	short time1		;oui
	call	ftime
	mov	tcx,cx			;sauve heure courante
	mov	tdx,dx
	jmp	exec			;fin execution ligne
time1:
	push	eax
	call	ftime			;CH=heure, CL=minute, DH=seconde, DL=centieme
	mov	ax,tcx			;heure de depart
	mov	bx,tdx
	sub	dl,bl			;difference centiemes
	jae	short time2		;positive
	add	dl,100			;ajuste
	inc	bh			;une seconde de moins
time2:
	sub	dh,bh			;difference secondes
	jae	short time3		;positive
	add	dh,60			;ajust
	inc	al			;une minute de moins
time3:
	sub	cl,al			;difference minutes
	jnc	short time4		;positive
	add	cl,60			;ajuste
	inc	ah			;une heure de moins
time4:
	sub	ch,ah			;difference heures
	jnc	short time5		;positive
	add	ch,24			;ajuste
time5:
	pop	eax
	cmp	al,k_print		;PRINT ?
	jne	short time6		;non
	mov	edi,offset outbuf	;tampon
	mov	esi,edi			;pour PMSG
	call	settime			;chaine heure
	mov	byte ptr [edi],eot	;pour PMSG
	call	pmsg			;impression chaine
	inc	ebp			;mange PRINT
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
time6:
	push	edx
	mov	ah,ch			;heures
	mov	al,60
	mul	ah
	add	al,cl			;minutes
	adc	ah,0
	movzx	eax,ax
	mov	esi,offset r0
	mov	[esi],eax		;minutes + heures x 60
	call	float			;conversion flottant
	mov	eax,60
	call	ifmul			;x 60
	pop	eax
	push	eax
	movzx	eax,ah
	call	ifadd			;+ secondes
	mov	eax,100
	call	ifmul			;x 100
	pop	eax
	movzx	eax,al			;centiemes
	call	ifadd			;ajout
	mov	ebx,offset dpund
	call	dpdiv			;/100
	push	esi
	xor	al,al			;type flottant pour allocation variable
	call	varadr			;adresse variable flottante
	mov	edi,esi
	pop	esi
	movsd				;range resultat dans variable
	movsd
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; BSAVE
	align	16
bsave:
	inc	ebp			;mange BLOAD
	mov	al,ext_none		;pas d'extension par defaut
	call	setfls			;evaluation nom de fichier
	call	wfopenwrite		;ouverture en ecriture fichier de travail
	jc	short bsave2		;erreur
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short bsave3		;oui, erreur
	test	al,conbit+linbit+labbit ;variable ?
	jnz	short bsave3		;non, erreur
	test	al,strbit		;chaine ?
	jz	short bsave3		;non, erreur
	call	getasn			;adresse affectation variable
	test	vrtflg,0FFh		;tableau virtuel ?
	jnz	short bsave1		;oui, erreur
	mov	ebx,asnadr		;adresse affectation
	mov	ecx,[ebx].strg.str_len	;longueur chaine
	mov	ebx,[ebx].strg.str_addr	;adresse chaine
	and	ecx,7FFFFFFFh		;raz indicateur FIELD
	call	wfwrite			;ecriture fichier travail
	pushfd
	push	eax
	call	wfclose			;fermeture fichier de travail
	pop	eax
	popfd
	jc	short bsave2		;erreur
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne
bsave1:
	mov	al,err_not_virtual	;virtual arg
bsave2:
	jmp	rpter
bsave3:
	jmp	synerr			;erreur de syntaxe

	end