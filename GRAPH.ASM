	page	,132
	name	graph

	public	gr,hgr,text,clrg,color
	public	plot,fill,window,xmask,move
	public	setcolor,setblink,dash,pointx
	public	pen,symbol,arc,draw,pdl
	public	gget,gput
	public	cleargraphic
	public	destroygra

	.model	flat,c

	include sbasic.inc

bmph		struct
bmph_sign	dw	?		;"BM"
bmph_fsize	dd	?		;taille fichier
bmph_fill	dd	?
bmph_ioffset	dd	?		;debut image
bmph_desclen	dd	?		;longueur descripteur (40)
bmph_width	dd	?		;largueur image en pixels
bmph_height	dd	?		;hauteur image en pixels
bmph_planes	dw	?		;nombre de plans (1)
bmph_deep	dw	?		;bits couleur
bmph_compress	dd	?		;compression (0)
bmph_psize	dd	?		;taille image
bmph_hordef	dd	?		;definition horisontale
bmph_verdef	dd	?		;definition verticale
bmph_colcount	dd	?		;nombre de couleurs (256)
bmph_maincols	dd	?		;nombre de couleurs principales
bmph_rgb	dd	256 dup (?)	;palette
bmph		ends

	.data
	align	4
;Variables affichage graphique
graphbase	dd	?		;base memoire graphique
linesize	dd	?		;taille ligne graphique
swidth		dd	0		;largeur ecran
sheight		dd	0		;hauteur ecran
xminw		dd	?		;Xmin fenetre graphique
yminw		dd	?		;Ymin fenetre graphique
xmaxw		dd	?		;Xmax fenetre graphique
ymaxw		dd	?		;Ymax fenetre graphique
gcrx		dd	?		;courant X
gcry		dd	?		;courant Y
x1temp		dd	?		;debut trace
y1temp		dd	?
x2temp		dd	?		;fin trace
y2temp		dd	?
formfactor	dd	?		;facteur de forme * 256
reverse		dw	?		;masque inversion
dashmask	dw	?		;trait plein au depart
colmask		label	word		;pour charger MASKVAR et GTRCL en meme temps
maskvar		db	11111111b	;masque couleur
gtrcl		db	15		;couleur trace
dispmode	db	m_text		;mode affichage courant
graphmode	db	m_text		;mode graphique courant

	align	4
;Parametres
grarg	db	36 dup(?)

	.code
	extrn	exec:near
	extrn	chstv:near
	extrn	getasn:near
	extrn	dosas:near
	extrn	synerr:near
	extrn	rpter:near
	extrn	eval:near,exp:near
	extrn	pushi:near
	extrn	strcnt:near
	extrn	strtox:near
	extrn	chrd1:near
	extrn	evlbyt:near,evlint:near,pulint:near
	extrn	pulfp:near
	extrn	allocds:near,freeds:near
	extrn	comtok:near
	extrn	lepar:near,ripar:near
	extrn	intger:near
	extrn	dpmul:near,dpdiv:near
	extrn	float:near
	extrn	r0tor1:near
	extrn	status:near,conin:near,endbasic:near
	extrn	focusgr:near,focustxt:near,opengraphic:near,closegraphic:near,grcolor:near
	extrn	txtwindow:near,txtcolor:near,txtresize:near
	extrn	showmous:near,getmous:near,hidemous:near
	extrn	WScreen:dword
	extrn	HScreen:dword
	extrn	RefreshFlag:byte
	extrn	TextCols:dword
	extrn	TextLines:dword
	extrn	Color32:dword
	extrn	dppi:byte

; GR
	align	16
gr:
	inc	ebp			;mange GR
	call	screensize		;evaluation parametres dimension
	mov	esi,offset grarg	;pointeur arguments
	call	grx			;selection mode graphique
	jmp	short color1		;fin instruction

; HGR
	align	16
hgr:
	inc	ebp			;mange HGR
	call	grh			;selection mode graphique haute resolution
	jmp	short color1		;fin instruction

; TEXT
	align	16
text:
	inc	ebp			;mange TEXT
	call	screensize		;evaluation parametres dimension
	mov	esi,offset grarg	;pointeur arguments
	call	gtext			;selection mode texte
	jmp	short color1		;fin instruction

; CLRG
	align	16
clrg:
	inc	ebp			;mange CLRG
	call	gclrg			;effacement ecran graphique
	jmp	short color1		;fin instruction

; COLOR
	align	16
color:
	inc	ebp			;mange COLOR
	call	evlbyt			;evaluation octet
	mov	dl,al			;couleur
	call	gcolor			;selection couleur
color1:
	skipst				;saut espace et token
	jmp	exec			;fin execution ligne

; PLOT
	align	16
plot:
	inc	ebp			;mange PLOT
	skipst				;saut espace et token
	cmp	al,k_to			;TO ?
	jne	short plot1		;non
	inc	ebp			;mange TO
	call	firstxy			;evaluation coordonnees
	mov	esi,offset grarg	;pointeur arguments
	call	gplott			;PLOT TO x,y
	jmp	color1			;fin instruction
plot1:
	call	firstxy			;evaluation coordonnees
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	js	short plot3		;non, erreur
	cmp	al,k_to			;TO ?
	jne	short plot2		;non
	inc	ebp			;mange TO
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.aplot.xx2,ebx	;range
	mov	grarg.aplot.yy2,eax
	mov	esi,offset grarg	;pointeur arguments
	call	gplots			;PLOT x1,y1 TO x2,y2
	jmp	color1			;fin instruction
plot2:
	mov	esi,offset grarg	;pointeur arguments
	call	gplotp			;PLOT x,y
	jmp	color1			;fin instruction
plot3:
	jmp	synerr			;erreur de syntaxe

; FILL
	align	16
fill:
	inc	ebp			;mange FILL
	call	firstxy			;evaluation coordonnees
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short fill2		;oui
	mov	esi,offset grarg	;pointeur arguments
	call	gfill			;FILL X,Y
fill1:
	jmp	color1			;fin instruction
fill2:
	inc	ebp			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.afill.col,al	;couleur
	mov	esi,offset grarg	;pointeur arguments
	call	gfillc			;FILL C
	jmp	color1			;fin instruction

; WINDOW
	align	16
window:
	inc	ebp			;mange WINDOW
	call	firstxy			;evaluation coordonnees
	call	comtok			;saut ,
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.awin.xright,ebx	;range
	mov	grarg.awin.yup,eax
	mov	grarg.awin.typ,-1	;type non specifie par defaut
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short windowx		;non
	inc	ebp			;mange ,
	skipst				;saut espace et token
	call	evlint			;evaluation entier
	mov	eax,r0i
	mov	grarg.awin.typ,eax	;type
windowx:
	mov	esi,offset grarg	;pointeur arguments
	call	gwindo			;WINDOW X1,Y1,X2,Y2[,type]
	jmp	color1			;fin instruction

; MASK
	align	16
xmask:
	inc	ebp			;mange MASK
	call	evlbyt			;evaluation octet
	mov	grarg.amask.r,al
	call	comtok			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.amask.g,al
	call	comtok			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.amask.b,al
	mov	esi,offset grarg	;pointeur arguments
	call	gmask			;MASK R,V,B
	jmp	color1			;fin instruction

; MOVE
	align	16
move:
	inc	ebp			;mange MOVE
	call	firstxy			;evaluation coordonnees
	mov	esi,offset grarg	;pointeur arguments
	call	gmove			;MOVE X,Y
	jmp	color1			;fin instruction

; SETCOLOR
	align	16
setcolor:
	inc	ebp			;mange SETCOLOR
	call	defclr			;evaluation parametres couleur
	mov	esi,offset grarg	;pointeur arguments
	call	gscolr			;SETCOLOR C,R,V,B
	jmp	color1			;fin instruction

; SETBLINK
	align	16
setblink:
	inc	ebp			;mange SETBLINK
	call	defclr
	mov	esi,offset grarg	;pointeur arguments
	call	gsblnk			;SETBLINK C,R,V,B
	jmp	color1			;fin instruction

; DASH
	align	16
dash:
	inc	ebp			;mange DASH
	call	evlbyt			;evaluation octet
	mov	dl,al
	call	gdash
	jmp	color1			;fin instruction

; POINT
	align	16
pointx:
	inc	ebp			;mange POINT
	call	lepar			;mange (
	call	firstxy1		;evaluation coordonnees (sans INITEXP)
	call	ripar			;mange )
	mov	esi,offset grarg	;pointeur arguments
	call	gpoint			;POINT(X,Y)
	movzx	ebx,al			;couleur point
	jmp	pushi			;PUSH entier

; PEN
	align	16
pen:
	inc	ebp			;mange PEN
	xor	dl,dl			;attente par defaut
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short pen1		;oui, pas d'argument
	call	evlbyt			;evaluation octet
	mov	dl,al			;parametre
pen1:
	mov	esi,offset penx		;pointeur PENX et PENY
	call	gpen			;GPEN C
	mov	grarg,al		;range code touche
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short pen2		;non
	initexp				;initialise piles evaluation expression
	mov	eax,strtos		;pointeur pile chaine
	mov	strsptr,eax		;nouvelle chaine
	inc	ebp			;mange ,
	skipst				;saut espace et token
	call	chstv			;test variable chaine
	call	getasn			;adresse affectation variable
	mov	al,grarg		;code touche
	call	chrd1			;allocation chaine de 1 octet avec code touche
	call	dosas			;execution affectation chaine
pen2:
	jmp	color1			;fin instruction

; SYMBOL
	align	16
symbol:
	inc	ebp			;mange SYMBOL
	call	firstxy			;evaluation coordonnees
	call	comtok			;mange ,
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	short symb1		;non, erreur
	call	strcnt			;longueur chaine
	mov	grarg.asymb.len,eax	;range
	call	allocds			;allocation memoire
	mov	grarg.asymb.adr,ebx	;range adresse chaine
	call	strtox			;copie chaine
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short symb2		;oui
	mov	grarg.asymb.w,1		;largeur=1 
	mov	grarg.asymb.h,1		;hauteur=1 
	mov	grarg.asymb.dir,0	;chaine horizontale par defaut
	jmp	short symb3
symb1:
	jmp	synerr			;erreur de syntaxe
symb2:
	inc	ebp			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.asymb.w,al	;largeur
	call	comtok			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.asymb.h,al	;hauteur
	call	comtok			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.asymb.dir,al	;direction
symb3:
	mov	esi,offset grarg	;pointeur arguments
	call	gsymb			;SYMBOL X,Y,$,L,H,D
	mov	eax,grarg.asymb.len	;longueur chaine
	mov	ebx,grarg.asymb.adr	;adresse chaine
	call	freeds			;liberation memoire
	jmp	color1			;fin instruction

; ARC
	align	16
arc:
	inc	ebp			;mange ARC
	mov	grarg.acirc.angle,360*10 ;cercle complet par defaut
	mov	grarg.acirc.factor,0	;pas de facteur de forme par defaut
	call	firstxy			;evaluation coordonnees centre
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	arc1			;non
	inc	ebp			;mange ,
	call	exp			;evaluation expression
	jz	short arc3		;pas d'expression
	call	pulfp			;expression dans R0
	mov	esi,offset r0
	mov	ebx,offset dppi
	call	dpdiv			;R0=R0/PI
	push	esi
	call	r0tor1			;dans R1
	pop	esi
	mov	dword ptr [esi],180*10	;pour 180 degres
	call	float			;conversion flottant dans R0
	mov	ebx,offset r1
	call	dpmul			;R0=R1*1800.0
	call	intger			;convertion R0 en entier
	mov	eax,r0i
	mov	grarg.acirc.angle,eax	;angle arc de cercle en 1/10 de degre
arc3:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short arc1		;non
	inc	ebp			;mange ,
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.acirc.xxs,ebx	;point de depart
	mov	grarg.acirc.yys,eax
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short arc9		;non
	inc	ebp			;mange ,
	call	evlint			;evaluation entier
	mov	eax,r0i
	mov	grarg.acirc.factor,eax	;facteur de forme
arc9:
	mov	esi,offset grarg	;pointeur arguments
	call	gcircs			;ARC XC,YC,R,X,Y,F
arc2:
	jmp	color1			;fin instruction
arc1:
	mov	esi,offset grarg	;pointeur arguments
	call	gcirc			;ARC XC,YC,R
	jmp	color1			;fin instruction

; DRAW
	align	16
draw:
	inc	ebp			;mange DRAW
	call	firstxy			;evaluation coordonnees
	call	comtok			;mange ,
	call	eval			;evalue expression
	test	strflg,0FFh		;expression chaine ?
	jz	short draw2		;non erreur
	call	strcnt			;longueur chaine
	mov	grarg.adraw.len,eax
	call	allocds			;allocation memoire
	mov	grarg.adraw.adr,ebx	;pointeur chaine
	call	strtox			;copie chaine
	mov	grarg.adraw.dir,0	;direction par defaut
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short draw1		;non
	inc	ebp			;mange ,
	call	evlbyt			;evaluation octet
	mov	grarg.adraw.dir,al	;direction
draw1:
	mov	esi,offset grarg	;pointeur arguments
	call	gdraw			;DRAW X,Y,$,D
	mov	eax,grarg.adraw.len	;longueur chaine
	mov	ebx,grarg.adraw.adr	;adresse chaine
	call	freeds			;liberation memoire
	jmp	color1			;fin instruction
draw2:
	jmp	synerr			;erreur de syntaxe


; GGET
	align	16
gget:
	inc	ebp			;mange GGET
	skipst				;saut espace et token
	call	chstv			;test variable chaine
	call	getasn			;adresse affectation variable
	call	comtok			;saut ,
	call	firstxy			;evaluation coordonnees
	call	comtok			;saut ,
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.aget.xright,ebx	;range
	mov	grarg.aget.yup,eax
	mov	ebx,asnadr		;adresse affectation
	mov	eax,[ebx].strg.str_len	;longueur ancienne chaine
	mov	ebx,[ebx].strg.str_addr	;adresse ancienne chaine
	test	ebx,ebx			;ancienne chaine vide ?
	jz	short gget2		;oui, pas de liberation
	test	eax,eax			;chaine FIELD ou de longueur nulle ?
	jle	short gget1		;oui, pas de liberation
	call	freeds			;liberation memoire
gget1:
	mov	ebx,asnadr
	xor	eax,eax
	mov	[ebx].strg.str_addr,eax	;desaffectation chaine
	mov	[ebx].strg.str_len,eax	;longueur nulle
gget2:
	mov	esi,offset grarg	;pointeur arguments
	call	ggget			;GGET $,x1,y1,x2,y2
	mov	ebx,asnadr
	mov	eax,grarg.aget.adr	;adresse bitmap
	mov	[ebx].strg.str_addr,eax	;adresse chaine
	mov	eax,grarg.aget.len	;longueur bitmap
	mov	[ebx].strg.str_len,eax	;longueur chaine
	jmp	color1			;fin instruction

; GPUT
	align	16
gput:
	inc	ebp			;mange GPUT
	skipst				;saut espace et token
	call	chstv			;test variable chaine
	call	getasn			;adresse affectation variable
	mov	ebx,asnadr		;adresse affectation
	mov	eax,[ebx].strg.str_len	;longueur chaine
	mov	ebx,[ebx].strg.str_addr	;adresse chaine
	and	eax,7FFFFFFFh		;raz indicateur FIELD
	mov	grarg.aput.adr,ebx	;adresse bit map
	mov	grarg.aput.len,eax
	call	comtok			;saut ,
	call	firstxy			;evaluation coordonnees
	mov	grarg.aput.mode,0	;pas de traitement par defaut
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	je	short gput3		;oui
gput1:
	mov	esi,offset grarg	;pointeur arguments
	call	ggput			;GPUT $,x,y,m
	jmp	color1			;fin instruction
gput3:
	inc	ebp			;mange ,
	call	exp			;evaluation expression
	jz	short gput2		;pas d'expression, erreur
	call	pulint			;mode
	mov	eax,r0i
	mov	grarg.aput.mode,eax
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	gput1			;non
	inc	ebp			;mange ,
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.aput.xleft,ebx	;range
	mov	grarg.aput.ydown,eax
	mov	grarg.aput.xright,-1	;point haut droit bitmap par defaut
	mov	grarg.aput.yup,-1
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	short gput4		;non
	inc	ebp			;mange ,
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.aput.xright,ebx	;range
	mov	grarg.aput.yup,eax
gput4:
	mov	esi,offset grarg	;pointeur arguments
	call	ggputw			;GPUT $,x,y,m,x1,y1,x2,y2
	jmp	color1			;fin instruction
gput2:
	jmp	synerr			;erreur de syntaxe

; PDL
	align	16
pdl:
	mov	eax,r0i			;numero manette
	cmp	eax,255			;valide ?
	ja	short pdl1		;non, erreur
	mov	dl,al
	call	gpdl			;PDL(N)
	mov	r0i,eax
	ret
pdl1:
	mov	al,err_paddle		;erreur selection manette
	jmp	rpter

; Decode coordonnees entieres et range dans arguments
	align	16
firstxy:
	initexp				;initialise piles evaluation expression
firstxy1:
	call	nextxy			;EBX=X, EAX=Y
	mov	grarg.axy.xx,ebx
	mov	grarg.axy.yy,eax
	ret

; Decode coordonnees entieres
	align	16
nextxy:
	call	exp			;evaluation expression
	jz	short nextxy1		;pas d'expression, erreur
	call	pulint			;X
	push	r0i
	call	comtok			;mange ,
	call	exp			;evaluation expression
	jz	short nextxy1		;pas d'expression, erreur
	call	pulint			;Y
	mov	eax,r0i
	pop	ebx
	ret
nextxy1:
	jmp	synerr			;erreur de syntaxe

; Decode dimension ecran
	align	16
screensize:
	xor	eax,eax
	mov	grarg.axy.xx,eax	;pas d'argument par defaut
	mov	grarg.axy.yy,eax
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression
	jz	short screensize1	;pas d'expression
	call	pulint			;largeur ou nombre colonnes ecran
	mov	eax,r0i
	mov	grarg.axy.xx,eax
	call	comtok			;mange ,
	call	exp			;evaluation expression
	jz	short screensize2	;non expression
	call	pulint			;hauteur ou nombre lignes ecran
	mov	eax,r0i
	mov	grarg.axy.yy,eax
screensize1:
	ret
screensize2:
	jmp	synerr			;erreur de syntaxe

; Evaluation parametres couleur
	align	16
defclr:
	call	evlnbl			;evaluation octet suivi par virgule
	mov	grarg.acol.col,al	;couleur
	call	evlnbl			;evaluation octet suivi par virgule
	mov	grarg.acol.r,al		;rouge
	call	evlnbl			;evaluation octet suivi par virgule
	mov	grarg.acol.g,al		;vert
	call	evlbyt			;evaluation octet
	mov	grarg.acol.b,al		;bleu
	ret

; Evaluation octet suivi par virgule
	align	16
evlnbl:
	call	evlbyt			;evaluation octet
	push	eax
	call	comtok			;mange ,
	pop	eax
	ret

; Fermeture fenetre graphique si ouverte
	align	16
cleargraphic:
	cmp	graphmode,m_text	;mode graphique selectionne ?
	je	short cg_ret		;non
	call	closegraphic		;fermeture fenetre graphique
	jmp	gr11
cg_ret:
	ret

; Fermeture fenetre graphique
	align	16
destroygra:
	jmp	gr11			;plus de mode graphique selectionne

; Graphique pour Windows
;-----------------------

; Selection mode graphique
; Entree: [esi]   : largeur ecran
;	  [esi+4] : hauteur ecran
	align	16
grx:
	mov	ebx,[esi].axy.xx	;largeur
	mov	ecx,[esi].axy.yy	;hauteur
	mov	al,m_gr			;mode graphique
gr1:
	cmp	dispmode,al		;mode affichage deja actif ?
	je	short gr2		;oui
	mov	dispmode,al		;mode courant
	cmp	graphmode,al		;mode graphique deja selectionne ?
	jne	short gr4		;non
gr2:
	mov	eax,ebx
	or	eax,ecx			;arguments specifies ?
	jz	short gr3		;non
	cmp	ebx,swidth		;largeur courante ?
	jne	short gr4		;non
	cmp	ecx,sheight		;hauteur courante ?
	jne	short gr4		;non
gr3:
	jmp	focusgr			;activation fenetre graphique
gr4:
	cmp	graphmode,m_text	;mode graphique actif ?
	je	short gr5		;non
	push	eax
	call	closegraphic		;fermeture fenetre graphique
	pop	eax
gr5:
	mov	graphmode,al		;mode graphique courant
	mov	eax,ebx
	or	eax,ecx			;arguments specifies ?
	jnz	short gr6		;oui
	mov	ebx,gr_width		;hauteur par defaut
	mov	ecx,gr_height		;largeur par defaut
gr6:
	cmp	ebx,gr_width		;largeur minimale respectee?
	jge	short gr7		;oui
	mov	ebx,gr_width		;ajuste
gr7:
	cmp	ebx,WScreen		;largeur maximale respectee ?
	jbe	short gr8		;oui
	mov	ebx,WScreen		;ajuste
gr8:
	cmp	ecx,gr_height		;hauteur minimale respectee?
	jge	short gr9		;oui
	mov	ecx,gr_height		;ajuste
gr9:
	cmp	ecx,HScreen		;hauteur maximale respectee ?
	jbe	short gr10		;oui
	mov	ecx,HScreen		;ajuste
gr10:
	xor	eax,eax			;0
	mov	swidth,ebx		;range dimensions ecran
	mov	sheight,ecx
	mov	xminw,eax
	mov	yminw,eax
	mov	eax,ebx			;fenetre graphique=ecran
	dec	eax			;X max fenetre
	mov	xmaxw,eax
	mov	eax,ecx
	dec	eax			;Y max fenetre
	mov	ymaxw,eax
	push	ebx
	push	ecx
	shr	ebx,1			;centre
	shr	ecx,1
	mov	gcrx,ebx		;position initiale
	mov	gcry,ecx
	pop	ecx
	pop	ebx
	mov	reverse,0		;raz masque inversion
	mov	dashmask,0FFFFh		;trait plein au depart
	mov	linesize,ebx
	mov	colmask,15*256+11111111b ;couleur et masque par defaut
	call	opengraphic		;ouverture fenetre graphique
	test	eax,eax			;OK ?
	mov	graphbase,eax		;base memoire graphique
	jnz	short gr12		;oui, retour
gr11:
	mov	dispmode,m_text		;affichage texte
	mov	graphmode,m_text	;pas de graphique
gr12:
	ret

; Selection mode graphique 800x600
	align	16
grh:
	mov	ebx,hgr_width
	mov	ecx,hgr_height
	mov	al,m_hgr		;mode graphique haute resolution
	jmp	gr1

; Selection mode alphanumerique
	align	16
gtext:
	mov	ebx,[esi].axy.xx	;lignes
	mov	ecx,[esi].axy.yy	;colonnes
	mov	dispmode,m_text		;mode courant texte
	mov	eax,ebx
	or	eax,ecx			;arguments specifies ?
	jz	short gtext5		;non
	cmp	ebx,text_lines		;lignes minimum ?
	jae	short gtext1		;oui
	mov	ebx,text_lines		;ajuste
gtext1:
	cmp	ebx,max_lines		;lignes maximum ?
	jbe	short gtext2		;oui
	mov	ebx,max_lines		;ajuste
gtext2:
	cmp	ecx,text_cols		;colonnes minimum ?
	jae	short gtext3		;oui
	mov	ecx,text_cols		;ajuste
gtext3:
	cmp	ecx,max_cols		;colonnes maximum ?
	jbe	short gtext4		;oui
	mov	ecx,max_cols		;ajuste
gtext4:
	cmp	ebx,TextLines		;lignes courantes ?
	jne	short gtext6		;non
	cmp	ecx,TextCols		;colonnes courantes ?
	jne	short gtext6		;non
gtext5:
	call	focustxt		;activation fenetre texte
	jmp	gr12
gtext6:
	call	txtresize		;redimensionnement
	jmp	gr12

; Effacement ecran graphique
	align	16
gclrg:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gclrg2		;non, ignore
	mov	ecx,xminw		;gauche fenetre
	mov	edx,xmaxw		;droite fenetre
	mov	ebx,yminw		;bas fenetre
gclrg1:
	call	plotseg			;trace segment horizontal
	inc	ebx
	cmp	ebx,ymaxw		;haut fenetre ?
	jbe	gclrg1			;non, continue pour toute la fenetre
	mov	refreshflag,1
gclrg2:
	ret

; Selection couleur courante
; Entree: DL=couleur
	align	16
gcolor:
	mov	gtrcl,dl
	ret

; PLOT X,Y
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
	align	16
gplotp:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gplotp1		;non, ignore
	mov	ecx,[esi].axy.xx
	mov	edx,[esi].axy.yy
	mov	gcrx,ecx		;X
	mov	gcry,edx		;Y
	cmp	ecx,xminw		;X < Xmin ?
	jl	short gplotp1		;oui, ignore
	cmp	ecx,xmaxw		;X > Xmax ?
	jg	short gplotp1		;oui, ignore
	cmp	edx,yminw		;Y < Ymin ?
	jl	short gplotp1		;oui, ignore
	cmp	edx,ymaxw		;Y > Ymax ?
	jg	short gplotp1		;oui, ignore
	call	dashpixel		;dessin point
	mov	refreshflag,1
gplotp1:
	ret

; PLOT X1,Y1 TO X2,Y2
; Entree: [esi]   : abscisse origin
;	  [esi+4] : ordonnee origin
;	  [esi+8] : abscisse destination
;	  [esi+12] : ordonnee destination
	align	16
gplots:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gplots2		;non, ignore
	mov	edi,[esi].axy.xx	;recopie les coordonnees
	mov	x1temp,edi
	mov	edi,[esi].axy.yy
	mov	y1temp,edi
	add	esi,2*4			;saut origine
gplots1:
	mov	edi,[esi].axy.xx
	mov	eax,[esi].axy.yy
	mov	x2temp,edi
	mov	gcrx,edi		;nouveau courant X
	mov	y2temp,eax
	mov	gcry,eax		;nouveau courant Y
	call	gtrace
	mov	refreshflag,1
gplots2:
	ret

; PLOT TO X,Y
; Entree: [esi]   : abscisse destination
;	  [esi+4] : ordonnee destination
;Le point destination devient le point courant.
	align	16
gplott:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	gplots2			;non, ignore
	mov	edi,gcrx		;X1 = courant X
	mov	x1temp,edi
	mov	edi,gcry		;Y1 = courant Y
	mov	y1temp,edi
	jmp	gplots1

; Definition fenetre graphique
; Entree: [esi]    : abscisse coin inferieur gauche
;	  [esi+4]  : ordonnee coin inferieur gauche
;	  [esi+8]  : abscisse coin superieur droit
;	  [esi+12] : ordonnee coin superieur droit
;	  [esi+16] : type (<0->mode courant, 0->texte, >0->graphique)
	align	16
gwindo:
	mov	eax,[esi].awin.typ	;type
	test	eax,eax
	js	short gwindo2		;<0, mode courant
	jnz	short gwindo3		;>0, graphique
gwindo1:
	jmp	txtwindow		;fenetre texte
gwindo2:
	cmp	dispmode,m_text		;mode courant texte ?
	je	gwindo1			;oui
gwindo3:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gwindo10		;non, ignore
	mov	eax,[esi].awin.xleft	;Xmin
	mov	edx,[esi].awin.xright	;EAX=Xmin,EDX=Xmax
	cmp	eax,edx			;EAX<=EDX ?
	jle	short gwindo4		;oui
	xchg	eax,edx			;echange
gwindo4:
	test	eax,eax			;Xmin dans ecran ?
	jns	short gwindo5		;oui
	xor	eax,eax			;limite
	test	edx,edx			;limite aussi Xmax ?
	jns	short gwindo5		;non
	mov	edx,eax			;limite
gwindo5:
	cmp	edx,swidth		;Xmax dans ecran ?
	jl	short gwindo6		;oui
	mov	edx,swidth		;limite
	dec	edx
	cmp	eax,edx			;limite aussi Xmin ?
	jle	short gwindo6		;non
	mov	eax,edx			;limite
gwindo6:
	mov	xminw,eax		;Xmin
	mov	xmaxw,edx		;Xmax
	mov	eax,[esi].awin.ydown
	mov	edx,[esi].awin.yup	;EAX=Ymin,EDX=Ymax
	cmp	eax,edx			;EAX<=EDX ?
	jle	short gwindo7		;oui
	xchg	eax,edx			;echange
gwindo7:
	test	eax,eax			;Ymin dans ecran ?
	jns	short gwindo8		;oui
	xor	eax,eax			;limite
	test	edx,edx			;limite aussi Ymax ?
	jns	short gwindo8		;non
	mov	edx,eax			;limite
gwindo8:
	cmp	edx,sheight		;Ymax dans fenetre
	jl	short gwindo9		;oui
	mov	edx,sheight		;limite
	dec	edx
	cmp	eax,edx			;limite aussi Ymin ?
	jle	short gwindo9		;non
	mov	eax,edx			;limite
gwindo9:
	mov	yminw,eax		;Ymin
	mov	ymaxw,edx		;Ymax
gwindo10:
	ret

; Variables locales remplissage
filltype	equ	byte ptr [ebp+0]
fillcolor	equ	byte ptr [ebp+1]
x1		equ	dword ptr [ebp+4]
x2		equ	dword ptr [ebp+8]
y		equ	dword ptr [ebp+12]
z1		equ	dword ptr [ebp+16]
z2		equ	dword ptr [ebp+20]
sign		equ	dword ptr [ebp+24]
stackptr	equ	dword ptr [ebp+28]
fillstack	equ	32
fillloc		equ	32*4*4+fillstack

; Remplissage zone
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
	align	16
gfill:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gfill1		;non, ignore
	call	checkfill		;test point dans fenetre
	jc	short gfill1		;hors fenetre, ignore		
	call	getpixel		;couleur zone
	xor	ah,ah			;indique zone
	jmp	short gfillc1
gfill1:
	ret

; Remplissage contour
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
;	  [esi+8] : couleur contour
	align	16
gfillc:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	gfill1			;non, ignore
	call	checkfill		;test point dans fenetre
	jc	gfill1			;hors fenetre, ignore		
	mov	al,[esi].afill.col	;couleur frontiere
	mov	ah,0FFh			;indique limite
gfillc1:
	push	ebp
	sub	esp,fillloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	stackptr,fillstack	;pointeur pile remplissage
	mov	filltype,ah		;range type
	mov	fillcolor,al		;range couleur
	call	freepoint		;point libre ?
	jc	gfillc17		;non, fin
	mov	y,edx			;range Y
	push	ecx
	mov	ebx,xminw		;limite gauche
	call	goleft			;maximum libre a gauche
	mov	x1,ecx			;sauve maximum gauche
	pop	ecx			;X
	mov	ebx,xmaxw		;limite droite
	call	goright			;maximum libre a droite
	mov	x2,ecx			;sauve maximum droit
	mov	ecx,x1
	mov	edx,x2
	mov	ebx,y
	mov	eax,-1
	call	pushfill		;empile remplissage de X1,Y a X2,Y avec signe -
	mov	eax,1
	call	pushfill		;empile remplissage de X1,Y a X2,Y avec signe +
	call	plotseg			;trace segment horizontal
gfillc2:
	call	popfill			;depile remplissage
	jc	gfillc17		;fin
	mov	sign,eax
gfillc3:
	test	eax,eax			;signe positif ?
	js	short gfillc4		;non
	cmp	ebx,ymaxw		;haut de la fenetre ?
	jb	short gfillc5		;non
	jmp	gfillc2			;fin remplissage
gfillc4:
	cmp	ebx,yminw		;bas de la fenetre ?
	jbe	gfillc2			;oui, fin remplissage
gfillc5:
	add	ebx,eax			;ajout signe
	mov	y,ebx			;maj Y
	mov	x1,ecx			;range gauche
	mov	z1,ecx
	mov	x2,edx			;range droite
	mov	z2,edx
	xchg	ebx,edx
	call	freepoint		;point libre ?
	jnc	short gfillc7		;oui
gfillc6:
	cmp	ecx,ebx			;maximum a droite ?
	jae	gfillc2			;oui, fin remplissage
	inc	ecx			;avance vers la droite
	call	freepoint		;point libre ?
	jc	gfillc6			;non, continue
	mov	x1,ecx			;nouvelle gauche
	jmp	short gfillc11		;determine la droite
gfillc7:
	mov	ebx,xminw		;limite gauche
	call	goleft			;maximum libre a gauche
	mov	x1,ecx			;minimum gauche
	mov	eax,z1
	sub	eax,ecx			;points a gauche
	jbe	short gfillc10		;aucun, rien a faire sur la gauche
	dec	eax			;1 point ?
	jz	short gfillc10		;oui, rien a faire sur la gauche
	mov	ecx,z1			;depart
	mov	edx,y			;ordonnee
	sub	edx,sign		;soustraction signe
gfillc8:
	dec	ecx			;recule
	cmp	ecx,x1			;minimum gauche ?
	jbe	short gfillc9		;oui, rien a faire sur la gauche
	call	freepoint		;point libre ?
	jc	gfillc8			;oui, recule
	mov	edx,ecx			;nouvelle droite
	mov	ecx,x1			;nouvelle gauche
	mov	ebx,y			;nouvelle ordonnee
	mov	eax,sign		;signe
	neg	eax			;inversion
	call	pushfill		;empile remplissage
gfillc9:
	mov	edx,y
gfillc10:
	mov	ecx,z1			;depart
gfillc11:
	mov	ebx,xmaxw		;limite droite
	call	goright			;maximum libre droite
	mov	x2,ecx			;maximum droite
	mov	eax,ecx
	sub	eax,z2			;points a droite
	jb	short gfillc15		;non, rien a faire sur la droite
	cmp	eax,2			;0 ou 1 point ?
	jb	short gfillc14		;oui, rien a faire sur la droite
	mov	ecx,z2			;depart
	mov	edx,y			;ordonnee
	sub	edx,sign		;soustraction signe
gfillc12:
	inc	ecx			;avance
	cmp	ecx,x2			;maximum droit ?
	je	short gfillc14		;oui, rien a faire sur la droite
	call	freepoint		;point libre ?
	jc	gfillc12		;oui, avance
	mov	edx,x2			;nouvelle droite
	mov	ebx,y			;nouvelle ordonnee
	mov	eax,sign		;signe
	neg	eax			;inversion
gfillc13:
	call	pushfill		;empile remplissage
gfillc14:
	mov	ecx,x1
	mov	edx,x2
	mov	ebx,y
	call	plotseg			;trace segment horizontal
	mov	eax,sign		;restaurer le signe
	jmp	gfillc3			;continue
gfillc15:
	inc	eax			;zero point ?
	je	gfillc14		;oui, trace
	mov	ecx,x2
	mov	edx,y
gfillc16:
	inc	ecx			;avance
	cmp	ecx,z2			;limite droite
	jae	gfillc14		;oui, rien a faire au milieu
	call	freepoint		;point libre ?
	jc	gfillc16		;oui, avance
	mov	edx,z2			;nouvelle droite
	mov	ebx,y
	mov	eax,sign		;signe
	sub	ebx,eax			;nouvelle ordonnee
	jmp	gfillc13
gfillc17:
	add	esp,fillloc		;liberation variables locales
	pop	ebp
	mov	refreshflag,1
	ret

; Masque ecriture
; Entree: [esi]   : masque rouge
;	  [esi+1] : masque vert
;	  [esi+2] : masque bleu
	align	16
gmask:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gmask1		;non, ignore
	mov	al,[esi].amask.r
	and	al,00000001b
	shl	al,2			;rouge->bit 2
	mov	ah,[esi].amask.g
	and	ah,00000001b
	shl	ah,1			;vert->bit 1
	or	al,ah
	mov	ah,[esi].amask.b
	and	ah,00000001b
	or	al,ah			;bleu->bit 0
	not	al			;masque
	mov	maskvar,al
gmask1:
	ret

; Positionnement point courant
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
	align	16
gmove:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gmove1		;non, ignore
	mov	edi,[esi].axy.xx
	mov	eax,[esi].axy.yy
	mov	gcrx,edi		;nouvelle courant X
	mov	gcry,eax		;nouvelle courant Y
gmove1:
	ret

; Modification couleur
; Entree: [esi]   : couleur 0 a 255
;	  [esi+1] : niveau rouge 0 a 255
;	  [esi+2] : niveau vert 0 a 255
;	  [esi+3] : niveau bleu 0 a 255
;
	align	16
gscolr:
	cmp	dispmode,m_text		;mode texte ?
	je	short gscolr1		;oui
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gscolr2		;non, ignore
	jmp	grcolor
gscolr1:
	jmp	txtcolor
gscolr2:
	ret

;
; Modification couleur alternative
; Entree: [esi]   : couleur 0 a 255
;	  [esi+1] : niveau rouge 0 a 255
;	  [esi+2] : niveau vert 0 a 255
;	  [esi+3] : niveau bleu 0 a 255
	align	16
gsblnk:
	ret				;pas d'action

; Table masque trace
	even
dashtab	dw	0FFFFh,0CCCCh,0F0F0h,0FFCCh

; Selection mode de trace
; Entree: DL=0:trait continu, 1:pointille fin, 2:pointille gras, 3:mixte (trait point), 4:inversion video
	align	16
gdash:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gdash2		;non, ignore
	cmp	dl,4			;inversion ?
	je	short gdash1		;oui
	mov	reverse,0		;raz masque inversion
	and	edx,11b			;modulo 4
	mov	ax,dashtab[ebx*2]
	mov	dashmask,ax		;masque trace
	ret
gdash1:
	mov	reverse,0FFFFh		;positionne masque inversion
gdash2:
	ret

; Lecture couleur point
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
; Retour: AL=couleur point
	align	16
gpoint:
	xor	al,al			;couleur 0 par defaut
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gpoint1		;non, ignore
	mov	ecx,[esi].axy.xx
	mov	edx,[esi].axy.yy
	cmp	ecx,swidth		;point dans ecran ?
	jae	short gpoint1		;non (test non signe, nombre negatif > SWIDTH)
	cmp	edx,sheight
	jae	short gpoint1		;non (test non signe, nombre negatif > SHEIGHT)
	jmp	getpixel		;couleur point
gpoint1:
	ret

; Lecture position pointeur
; Entree: DL=0:attente, 1 ou 2:test, 3:renvoi du point courant
; Sortie: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
;	  AL=code touche
	align	16
gpen:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gpen2		;non, ignore
	test	dl,dl			;attente bouton souris ou touche clavier ? 
	jz	short gpen3		;oui
	cmp	dl,3			;point courant ?
	jae	short gpen2		;oui
	xor	eax,eax			;pas d'attente clic
	call	getmous			;etat souris (EAX=1:bouton gauche, 2: bouton droit, 4: bouton milieu, ECX:X, EDX:Y)
	jnz	short gpen1		;sortie SBASIC demandee
	call	status			;touche clavier ?
	jz	short gpen6		;non, retour
	call	conin			;lecture touche
	jnz	short gpen6		;retour code touche
gpen1:
	jmp	endbasic		;sortie SBASIC
gpen2:
	xor	al,al			;pas de caractere
	mov	ecx,gcrx		;point courant
	mov	edx,gcry
	jmp	short gpen6		;retour
gpen3:
	call	showmous		;allumage curseur souris
gpen4:
	mov	eax,1			;attente clic souris
	call	getmous			;etat souris (EAX=1:bouton gauche, 2: bouton droit, 4: bouton milieu, ECX:X, EDX:Y)
	jnz	gpen1			;sortie SBASIC
	test	eax,eax			;bouton presse ?
	jnz	short gpen5		;oui
	call	status			;touche clavier ?
	jz	gpen4			;non
	call	conin			;lecture touche
	jz	gpen1			;sortie SBASIC
gpen5:
	push	eax
	call	hidemous		;extinction curseur souris
	pop	eax
gpen6:
	mov	[esi].axy.xx,ecx	;abscisse
	mov	[esi].axy.yy,edx	;ordonnee
	ret

; Variables locales affichage texte
xcar		equ	dword ptr [ebp+0] ;X caractere
ycar		equ	dword ptr [ebp+4] ;Y caractere
repx		equ	dword ptr [ebp+8] ;repetition en X caractere
repy		equ	dword ptr [ebp+12] ;repetition en Y caractere
incdotx		equ	dword ptr [ebp+16] ;deplacement point en x caractere
incdoty		equ	dword ptr [ebp+20] ;deplacement point en y caractere
incrowx		equ	dword ptr [ebp+24] ;deplacement rangee en x caractere
incrowy		equ	dword ptr [ebp+28] ;deplacement rangee en y caractere
dxnext		equ	dword ptr [ebp+32] ;delta X caractere suivant
dynext		equ	dword ptr [ebp+36] ;delta Y caractere suivant
charcnt		equ	dword ptr [ebp+40] ;compte caracteres
plotflg		equ	byte ptr [ebp+44] ;indicateur trace
pattern		equ	byte ptr [ebp+45] ;motif rangee caratere
symbloc		equ	48

; Table branchement direction
	align	16
dirtabx	dd	offset gsymb1		;horizontal
	dd	offset gsymb2		;horizontal penche
	dd	offset gsymb3		;vertical
	dd	offset gsymb4		;vertical penche

;Trace de texte
; Entree: [esi]   : abscisse du point de depart
;	  [esi+4] : ordonnee du point de depart
;	  [esi+8] : largeur caractere (1..16)
;	  [esi+9] : hauteur caractere (1..16)
;	  [esi+10] : direction  0 = horizontal
;				1 = horizontal penche
;				2 = vertical
;				3 = vertical penche
;	  [esi+12] : adresse de la chaine
;	  [esi+16] : longueur de la chaine
	align	16
gsymb:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	gsymb10			;non, ignore
	push	ebp
	sub	esp,symbloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	eax,[esi].asymb.xx	;abscisse depart
	mov	xcar,eax		;range
	mov	edx,[esi].asymb.yy	;ordonnee depart
	mov	ycar,edx		;range
	mov	al,[esi].asymb.w	;largeur caractere
	dec	al
	and	al,00001111b		;modulo 16
	inc	al			;0->16
	movzx	eax,al
	mov	repx,eax		;range
	mov	al,[esi].asymb.h	;hauteur caractere
	dec	al
	and	al,00001111b		;modulo 16
	inc	al			;0->16
	movzx	eax,al
	mov	repy,eax		;range
	mov	edx,repx		;repetition
	shl	edx,3			;*8
	movzx	ebx,[esi].asymb.dir	;direction
	and	bl,00000011b		;modulo 4
	jmp	dirtabx[ebx*4]
gsymb1:
	mov	incdotx,1		;horizontal
	mov	incrowx,0
	mov	incdoty,0
	mov	incrowy,1
	mov	dxnext,edx
	mov	dynext,0
	jmp	short gsymb5
gsymb2:
	mov	incdotx,1		;horizontal penche
	mov	incrowx,1
	mov	incdoty,0
	mov	incrowy,1
	mov	dxnext,edx
	mov	dynext,0
	jmp	short gsymb5
gsymb3:
	mov	incdotx,0		;vertical
	mov	incrowx,-1
	mov	incdoty,1
	mov	incrowy,0
	mov	dxnext,0
	mov	dynext,edx
	jmp	short gsymb5
gsymb4:
	mov	incdotx,0		;vertical penche
	mov	incrowx,-1
	mov	incdoty,1
	mov	incrowy,1
	mov	dxnext,0
	mov	dynext,edx
gsymb5:
	mov	ecx,[esi].asymb.len	;longueur chaine
	mov	edi,[esi].asymb.adr	;pointeur chaine
	jecxz	short gsymb9		;chaine vide
gsymb6:
	push	ecx
	mov	ecx,xcar		;position caractere
	mov	edx,ycar
	cmp	ecx,xminw		;caractere dans fenetre graphique ?
	jl	short gsymb7		;non
	cmp	ecx,xmaxw
	jg	short gsymb7		;non
	cmp	edx,yminw
	jl	short gsymb7		;non
	cmp	edx,ymaxw
	jg	short gsymb7		;non
	mov	al,[edi]		;caractere
	call	paintchar		;dessin caractere
gsymb7:
	mov	eax,dxnext		;position caratere suivante
	add	xcar,eax
	mov	eax,dynext
	add	ycar,eax
gsymb8:
	pop	ecx
	inc	edi
	loop	gsymb6			;pour toute la chaine
gsymb9:
	add	esp,symbloc		;liberation variables locales
	pop	ebp
	mov	refreshflag,1
gsymb10:
	ret

; Constante arc de cercle
	align	16
factor	dd	1839			;(101*2**16)/3600

; Variables locales dessin arc de cercle
xcenter equ	dword ptr [ebp+0]
ycenter equ	dword ptr [ebp+4]
xradius	equ	dword ptr [ebp+8]
yradius	equ	dword ptr [ebp+12]
frac	equ	dword ptr [ebp+16]
sgn	equ	byte ptr [ebp+20]
full	equ	byte ptr [ebp+21]
arcloc	equ	24

; Dessin d'un arc de cercle avec point de depart
; Entree: [esi]   : abscisse du centre
;	  [esi+4] : ordonnee du centre
;	  [esi+8] : angle signe en 1/10 de degree
;	  [esi+12] : abscisse du point de depart
;	  [esi+16] : ordonnee du point de depart
;	  [esi+20] : facteur de forme * 256
	align	16
gcircs:
	mov	eax,[esi].acirc.xxs	;depart
	mov	gcrx,eax
	mov	eax,[esi].acirc.yys
	mov	gcry,eax
;;;	jmp	short gcirc

; Dessin d'un arc de cercle
; Entree: [esi]   : abscisse du centre
;	  [esi+4] : ordonnee du centre
;	  [esi+8] : angle signe en 1/10 de degree
gcirc:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	gcirc15			;non, ignore
	mov	eax,[esi].acirc.factor	;facteur de forme
	shl	eax,8			;*256
	mov	formfactor,eax
	mov	edi,[esi].acirc.xxc	;centre
	mov	ebx,[esi].acirc.yyc
	mov	eax,[esi].acirc.angle	;angle de trace (signe)
	xor	cl,cl			;positif par defaut
	test	eax,eax			;angle nul ?
	jz	gcirc15			;oui, ignore
	jns	gcirc1			;angle positif
	neg	eax			;valeur absolue
	dec	cl			;indique negatif
gcirc1:
	push	ebp
	sub	esp,arcloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	sgn,cl			;range signe angle
	mov	xcenter,edi		;range centre
	mov	ycenter,ebx
	push	eax
	mov	eax,gcrx		;X courant
	mov	x1temp,eax
	sub	eax,edi			;X rayon
	shl	eax,16			;pour 16 bits de fraction
	mov	xradius,eax
	mov	eax,gcry		;Y courant
	mov	y1temp,eax
	sub	eax,ebx			;Y rayon
	cmp	formfactor,0		;facteur de forme ?
	je	short gcirc2		;non
	shl	eax,8			;*256
	idiv	formfactor		;applique le facteur de forme
gcirc2:
	shl	eax,16			;pour 16 bits de fraction
	mov	yradius,eax
	pop	eax
	xor	cl,cl			;cercle non plein par defaut
	cmp	eax,3600		;>=360 degres ?
	jb	short gcirc3		;non
	dec	cl			;indique cercle plein
	mov	eax,3600		;limite
gcirc3:
	mov	full,cl			;range indicateur cercle plein
	mul	factor			;angle*((101*2**16)/3600)
	mov	ecx,eax
	and	eax,00000FFFFh
	shr	ecx,16			;nombre de pas (101*angle/3600)
	shr	eax,1			;fraction de pas/2
	mov	frac,eax
gcirc4:
	push	ecx
	mov	eax,xradius		;X rayon
	mov	ebx,yradius		;Y rayon
	test	sgn,0FFh		;angle positif ?
	jnz	gcirc5			;non
;X=X-(X/32+Y)/16
;Y=Y-(Y/32-X)/16
	call	deltap			;(X/32+Y)/16
	push	eax
	xchg	eax,ebx
	mov	ebx,xradius
	call	deltam			;(Y/32-X)/16
	jmp	short gcirc6
gcirc5:
;X=X-(X/32-Y)/16
;Y=Y-(Y/32+X)/16
	call	deltam			;(X/32-Y)/16
	push	eax
	xchg	eax,ebx
	mov	ebx,xradius
	call	deltap			;(Y/32+X)/16
gcirc6:
	sub	yradius,eax		;ajuste Y rayon
	pop	eax
	sub	xradius,eax		;ajuste X rayon
	mov	eax,xradius		;X rayon
	add	eax,00008000h		;arrondi
	sar	eax,16			;partie entiere
	add	eax,xcenter
	mov	x2temp,eax		;nouveau point cercle
	push	eax
	sub	eax,x1temp		;variation en X
	mov	ebx,eax
	mov	eax,yradius		;Y rayon
	add	eax,00008000h		;arrondi
	sar	eax,16			;partie entiere
	cmp	formfactor,0		;facteur de forme ?
	je	short gcirc7		;non
	imul	formfactor
	sar	eax,8			;*facteur de forme
gcirc7:
	add	eax,ycenter
	mov	y2temp,eax		;nouveau point cercle
	push	eax
	sub	eax,y1temp		;variation en Y
	or	eax,ebx			;variation en X ou Y ?
	jnz	short gcirc9		;oui
	pop	eax
	pop	eax
	jmp	short gcirc10
gcirc8:
	jmp	gcirc4
gcirc9:
	call	gtrace			;trace de X1,Y1 a X2,Y2
	pop	y1temp			;Y1=Y2
	pop	x1temp			;X1=X2
gcirc10:
	pop	ecx
	loop	gcirc8			;pour tous les pas
	test	full,0FFh		;cercle complet ?
	jnz	short gcirc14		;oui
	test	sgn,0FFh		;angle positif ?
	jnz	short gcirc11		;non
	mov	eax,yradius		;Y rayon
	sar	eax,16			;partie entier
	imul	frac
	sar	eax,4			;Y*fraction/16
	sub	xradius,eax		;ajuste X rayon
	mov	eax,xradius		;X rayon
	sar	eax,16			;partie entiere
	imul	frac
	sar	eax,4			;X*fraction/16
	add	yradius,eax		;ajuste Y rayon
	jmp	short gcirc12
gcirc11:
	mov	eax,xradius		;X rayon
	sar	eax,16			;partie entiere
	imul	frac
	sar	eax,4			;X*fraction/16
	sub	yradius,eax		;ajuste Y rayon
	mov	eax,yradius		;Y rayon
	sar	eax,16			;partie entiere
	imul	frac
	sar	eax,4			;Y*fraction/16
	add	xradius,eax		;ajuste X rayon
gcirc12:
	mov	eax,xradius		;X rayon
	add	eax,00008000h		;arrondi
	sar	eax,16			;partie entiere
	add	eax,xcenter
	mov	gcrx,eax		;dernier point cercle
	mov	eax,yradius		;Y rayon
	add	eax,00008000h		;arrondi
	sar	eax,16			;partie entiere
	cmp	formfactor,0		;facteur de forme ?
	je	short gcirc13		;non
	imul	formfactor
	sar	eax,8			;*facteur de forme
gcirc13:
	add	eax,ycenter
	mov	gcry,eax		;dernier point cercle
gcirc14:
	mov	eax,gcrx
	mov	x2temp,eax
	mov	eax,gcry
	mov	y2temp,eax
	call	gtrace			;fermeture cercle ou dernier trace
	add	esp,arcloc		;liberation variables locales
	pop	ebp
	mov	refreshflag,1
gcirc15:
	ret

; Variables locales desssin motif
xold		equ	dword ptr [ebp+0]
yold		equ	dword ptr [ebp+4]
xdepl		equ	dword ptr [ebp+8]
ydepl		equ	dword ptr [ebp+12]
down		equ	byte ptr [ebp+16]
direction	equ	byte ptr [ebp+17]
drawloc		equ	20

; Dessin motif
; Entree: [esi]   : abscisse origine
;	  [esi+4] : ordonnee origine
;	  [esi+8] : adresse chaine
;	  [esi+12] : longueur chaine
;	  [esi+16] : direction
	align	16
gdraw:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short gdraw5		;non, ignore
	mov	ecx,[esi].adraw.len	;longueur chaine
	jecxz	short gdraw5		;longueur nulle
	push	ebp
	sub	esp,drawloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	eax,[esi].adraw.xx	;point de depart
	mov	xold,eax		;X
	mov	eax,[esi].adraw.yy
	mov	yold,eax		;Y
	mov	al,[esi].adraw.dir	;direction
	and	al,00000111b		;modulo 8
	mov	direction,al
	mov	esi,[esi].adraw.adr	;adresse chaine
	mov	down,0FFh		;indicateur plume baissee
	mov	xdepl,0			;raz deplacement
	mov	ydepl,0
gdraw1:
	push	ecx
	lodsb				;caractere
	sub	al,'0'			;chiffre ?
	jc	short gdraw4		;non, ignore
	cmp	al,8			;code couleur ?
	ja	short gdraw3		;non
	mov	bl,0			;plume haute
	je	short gdraw2		;couleur 8, pas de trace
	add	al,8			;ajoute intensite
	mov	gtrcl,al		;nouvelle couleur courante
	dec	bl			;plume baissee
gdraw2:
	mov	down,bl
	jmp	short gdraw4
gdraw3:
	sub	al,'A'-'0'		;lettre majuscule ?
	jc	short gdraw4		;non
	cmp	al,'Z'-'A'		;code DX ?
	ja	short gdraw6		;non
	sub	al,13			;offset
	movsx	eax,al
	mov	xdepl,eax		;deplacement en X
gdraw4:
	pop	ecx
	loop	gdraw1			;pour toute la chaine
	add	esp,drawloc		;liberation variables locales
	pop	ebp
	mov	refreshflag,1
gdraw5:
	ret
gdraw6:
	sub	al,'a'-'A'		;caractere minuscule ?
	jc	gdraw4			;non, ignore
	cmp	al,'z'-'a'
	ja	gdraw4			;non, ignore
	sub	al,13			;offset
	movsx	eax,al
	mov	ydepl,eax		;deplacement en Y
	mov	eax,xold		;debut segment
	mov	x1temp,eax
	mov	eax,yold
	mov	y1temp,eax
	movzx	ebx,direction
	push	ebx
	mov	eax,xdepl		;deplacement en X
	call	xadjust			;ajuste en X suivant direction
	pop	ebx
	mov	eax,ydepl		;deplacement en Y
	call	yadjust			;ajuste en Y suivant direction
	test	down,0FFh		;plume baissee ?
	jz	short gdraw7		;non, pas de trace
	mov	eax,xold		;fin segment
	mov	x2temp,eax
	mov	eax,yold
	mov	y2temp,eax
	call	gtrace			;trace du segment
gdraw7:
	jmp	gdraw4			;suite chaine

; Variables locales bitmap
bwidth		equ	dword ptr [ebp+0]
bheight		equ	dword ptr [ebp+4]
bleft		equ	dword ptr [ebp+8]
bdown		equ	dword ptr [ebp+12]
bmloc		equ	16

; Sauvegarde bitmap graphique
; Entree: [esi]   : abscisse point bas gauche
;	  [esi+4] : ordonnee point bas gauche
;	  [esi+8] : abscisse point haut droite
;	  [esi+12] : ordonnee point haut droite
; Retour: [esi+16] : adresse bitmap
;	  [esi+20] : longueur bitmap
ggget:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	ggget2			;non, erreur
	mov	ebx,[esi].aget.xright
	cmp	ebx,swidth		;X droit dans ecran ?
	jae	ggget3			;non, traitement complet (test non signe, nombre negatif > SWIDTH)
	mov	eax,[esi].aget.xleft
	test	eax,eax			;X gauche dans ecran ?
	js	ggget3			;non, traitement complet
	sub	ebx,eax
	jl	ggget2			;erreur
	inc	ebx			;largeur image
	mov	ecx,[esi].aget.yup
	cmp	ecx,sheight		;Y haut dans ecran ?
	jae	ggget3			;non, traitement complet (test non signe, nombre negatif > SHEIGHT)
	mov	eax,[esi].aget.ydown
	test	eax,eax			;Y bas dans ecran ?
	js	ggget3			;non, traitement complet
	sub	ecx,eax
	jl	ggget2			;erreur
	inc	ecx			;hauteur image
	call	prepbmp			;preparation image bitmap
	mov	eax,sheight
	dec	eax
	sub	eax,[esi].aget.ydown
	push	edx
	mul	swidth
	pop	edx
	add	eax,[esi].aget.xleft	;offset point bas gauche
	mov	esi,graphbase		;adresse memoire graphique
	add	esi,eax			;adresse point bas gauche
	mov	ecx,[ebx].bmph.bmph_height ;hauteur image
ggget1:
	push	ecx
	push	esi
	push	edi
	mov	ecx,[ebx].bmph.bmph_width ;largeur image
	rep	movsb			;recopie ligne
	pop	edi
	pop	esi
	pop	ecx
	sub	esi,swidth		;debut ligne precedente
	add	edi,edx			;ligne suivante image
	loop	ggget1
	ret
ggget2:
	mov	al,err_bad_arg		;argument invalide
	jmp	rpter
ggget3:
	push	ebp
	sub	esp,bmloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	ebx,[esi].aget.xright
	sub	ebx,[esi].aget.xleft
	jl	ggget2			;erreur
	inc	ebx			;largeur image
	mov	ecx,[esi].aget.yup
	sub	ecx,[esi].aget.ydown
	jl	ggget2			;erreur
	inc	ecx			;hauteur image
	call	prepbmp			;preparation image bitmap
	mov	eax,[ebx].bmph.bmph_width ;largueur image en pixels
	mov	bwidth,eax		;largeur bitmap dans fenetre
	mov	ecx,[esi].aget.xleft
	xor	eax,eax
	test	ecx,ecx			;X gauche dans ecran ?
	jns	short ggget4		;oui
	mov	[esi].aget.xleft,eax	;X a gauche ecran
	mov	eax,ecx
	add	bwidth,ecx		;ajuste largeur bitmap dans fenetre
	neg	eax
ggget4:
	mov	bleft,eax		;espace vide a gauche
	mov	eax,[esi].aget.xright
	inc	eax
	sub	eax,swidth		;X droit dans ecran ?
	jle	short ggget5		;oui
	sub	bwidth,eax		;ajuste largeur bitmap dans fenetre
	jle	short ggget9		;fenetre vide
ggget5:
	mov	eax,[ebx].bmph.bmph_height ;hauteur image en pixels
	mov	bheight,eax		;hauteur bitmap dans fenetre
	mov	ecx,[esi].aget.ydown
	xor	eax,eax
	test	ecx,ecx			;Y bas dans ecran ?
	jns	short ggget6		;oui
	mov	[esi].aget.ydown,eax	;Y en bas ecran
	mov	eax,ecx
	add	bheight,ecx		;ajuste hauteur bitmap dans fenetre
	neg	eax
ggget6:
	mov	bdown,eax		;espace vide en bas
	mov	eax,[esi].aget.yup
	inc	eax
	sub	eax,sheight		;Y haut dans ecran ?
	jle	short ggget7		;oui
	sub	bheight,eax		;ajuste hauteur bitmap dans fenetre
	jle	short ggget9		;fenetre vide
ggget7:
	mov	eax,sheight
	dec	eax
	sub	eax,[esi].aget.ydown
	push	edx
	mul	swidth
	pop	edx
	add	eax,[esi].aget.xleft	;offset point bas gauche
	mov	esi,graphbase		;adresse memoire graphique
	add	esi,eax			;adresse point bas gauche
	mov	eax,bdown		;espace vide en bas
	push	edx
	mul	edx
	pop	edx
	add	edi,eax			;saut espace libre en bas dans image
	mov	ecx,bheight		;hauteur image
ggget8:
	push	ecx
	push	esi
	push	edi
	add	edi,bleft		;saut espace libre a gauche dans image
	mov	ecx,bwidth		;largeur image
	rep	movsb			;recopie ligne
	pop	edi
	pop	esi
	pop	ecx
	sub	esi,swidth		;debut ligne precedente
	add	edi,edx			;ligne suivante image
	loop	ggget8
ggget9:
	add	esp,bmloc		;liberation variables locales
	pop	ebp
	ret


; Restauration bitmap graphique
; Entree: [esi]   : abscisse point bas gauche
;	  [esi+4] : ordonnee point bas gauche
;	  [esi+8] : adresse bitmap
;	  [esi+12] : longueur bitmap
;	  [esi+16] : indicateur traitement fond
ggput:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	short ggput2		;non, ignore
	call	chkbmp			;verification image bitmap
	push	edx
	mov	eax,[esi].aput.xx	;abcisse point bas gauche
	mov	edx,[esi].aput.yy	;ordonnee point bas gauche
	mov	ecx,[esi].aput.mode	;mode traitement fond
	cmp	eax,swidth		;dans ecran ?
	jae	short ggput3		;non, traitement complet (test non signe, nombre negatif > SWIDTH)
	cmp	edx,sheight		;dans ecran ?
	jae	short ggput3		;non, traitement complet (test non signe, nombre negatif > SHEIGHT)
	test	ecx,ecx			;traitement fond ?
	jnz	short ggput3		;oui, traitement complet
	add	eax,[ebx].bmph.bmph_width ;a droite bitmap
	add	edx,[ebx].bmph.bmph_height ;au dessus bitmap
	cmp	eax,swidth		;dans ecran ?
	ja	short ggput3		;non, traitement complet
	cmp	edx,sheight		;dans ecran ?
	ja	short ggput3		;non, traitement complet
	mov	eax,sheight
	dec	eax
	sub	eax,[esi].aput.yy
	mul	swidth
	pop	edx
	add	eax,[esi].aput.xx	;offset point bas gauche
	mov	edi,graphbase		;adresse memoire graphique
	add	edi,eax			;adresse point bas gauche
	mov	esi,ebx
	add	esi,[ebx].bmph.bmph_ioffset ;debut image
	mov	ecx,[ebx].bmph.bmph_height ;hauteur image
ggput1:
	push	ecx
	push	esi
	push	edi
	mov	ecx,[ebx].bmph.bmph_width ;largeur image
	rep	movsb			;recopie ligne
	pop	edi
	pop	esi
	pop	ecx
	add	esi,edx			;ligne suivante image
	sub	edi,swidth		;debut ligne precedente
	loop	ggput1
	mov	refreshflag,1
ggput2:
	ret
ggput3:
	pop	edx
	xor	eax,eax
	mov	[esi].aput.xleft,eax	;point bas gauche bitmap
	mov	[esi].aput.ydown,eax
	dec	eax
	mov	[esi].aput.xright,eax	;point haut droit relatif
	mov	[esi].aput.yup,eax
	jmp	short ggputw1		;traitement complet

; Restauration bitmap graphique avec fenetre
; Entree: [esi]   : abscisse point bas gauche
;	  [esi+4] : ordonnee point bas gauche
;	  [esi+8] : adresse bitmap
;	  [esi+12] : longueur bitmap
;	  [esi+16] : mode traitement couleur
;	  [esi+20] : abscisse point bas gauche dans bitmap
;	  [esi+24] : ordonnee point bas gauche dans bitmap
;	  [esi+28] : abscisse point haut droite dans bitmap
;	  [esi+32] : ordonnee point haut droite dans bitmap
ggputw:
	cmp	graphmode,m_text	;mode graphique defini ?
	je	ggputw10		;non, ignore
	call	chkbmp			;verification image bitmap
ggputw1:
	push	ebp
	sub	esp,bmloc		;allocation variables locales
	mov	ebp,esp			;pointeur variables locales
	mov	ecx,[esi].aput.xright
	test	ecx,ecx			;X droit negatif ?
	jns	short ggputw2		;non
	add	ecx,[ebx].bmph.bmph_width ;relatif largeur
ggputw2:
	cmp	ecx,[ebx].bmph.bmph_width ;X droit dans bitmap ?
	jae	ggputw11		;non, erreur (test non signe, nombre negatif > BMPH_WIDTH)
	mov	eax,[esi].aput.xleft
	test	eax,eax			;X gauche dans bitmap ?
	js	ggputw11		;non, erreur
	sub	ecx,eax
	jc	ggputw11		;erreur
	inc	ecx			;largeur image
	mov	bwidth,ecx		;largeur image restauree
	mov	ecx,[esi].aput.yup
	test	ecx,ecx			;Y haut negatif ?
	jns	short ggputw3		;non
	add	ecx,[ebx].bmph.bmph_height ;relatif hauteur
ggputw3:
	cmp	ecx,[ebx].bmph.bmph_height ;Y haut dans bitmap ?
	jae	ggputw11		;non, erreur
	mov	eax,[esi].aput.ydown
	test	eax,eax			;Y bas dans bitmap ?
	js	ggputw11		;non, erreur
	sub	ecx,eax
	jc	ggputw11		;erreur
	inc	ecx			;hauteur image
	mov	bheight,ecx		;hauteur image restauree
	mov	eax,[esi].aput.xx	;abcisse point bas gauche
	cmp	eax,xminw		;dans fenetre ?
	jge	short ggputw4
	sub	eax,xminw		;non, -distance hors fenetre
	sub	[esi].aput.xleft,eax	;ajuste abcisse droite bitmap
	add	bwidth,eax		;ajuste largeur
	jle	ggputw9			;hors bitmap, ignore
	mov	eax,xminw
	mov	[esi].aput.xx,eax	;abcisse point bit bas gauche fenetre
ggputw4:
	mov	ecx,xmaxw
	inc	ecx
	sub	ecx,eax			;espace restant a droite
	jbe	ggputw9			;hors ecran, ignore
	cmp	ecx,bwidth		;coupure droite ?
	jge	short ggputw5		;non
	mov	bwidth,ecx		;ajuste largeur
ggputw5:
	mov	eax,[esi].aput.yy	;ordonnee point bas gauche
	cmp	eax,yminw		;dans fenetre ?
	jge	short ggputw6
	sub	eax,yminw		;non, -distance hors fenetre
	sub	[esi].aput.ydown,eax	;non, ajuste ordonnee basse bitmap
	add	bheight,eax		;ajuste hauteur
	jle	ggputw9			;hors bitmap, ignore
	mov	eax,yminw
	mov	[esi].aput.yy,eax	;ordonne point bit bas gauche fenetre
ggputw6:
	mov	ecx,ymaxw
	inc	ecx
	sub	ecx,eax			;espace restant en bas
	jbe	short ggputw9		;hors ecran, ignore
	cmp	ecx,bheight		;coupure haute ?
	jge	short ggputw7		;non
	mov	bheight,ecx		;ajuste hauteur
ggputw7:
	mov	eax,sheight
	dec	eax
	sub	eax,[esi].aput.yy
	push	edx
	mul	swidth
	pop	edx
	add	eax,[esi].aput.xx	;offset point bas gauche
	mov	edi,graphbase		;adresse memoire graphique
	add	edi,eax			;adresse point bas gauche
	mov	eax,[esi].aput.ydown
	push	edx
	mul	edx
	pop	edx
	add	eax,[esi].aput.xleft	;offset point bas gauche dans bitmap
	mov	ecx,[esi].aput.mode	;mode traitement fond
	mov	esi,ebx
	add	esi,[ebx].bmph.bmph_ioffset ;debut image
	add	esi,eax			;adresse point bas gauche bitmap
	test	ecx,ecx			;traitement fond ?
	mov	eax,ecx
	mov	ecx,bheight		;hauteur image
	jnz	short ggputw12		;oui
ggputw8:
	push	ecx
	push	esi
	push	edi
	mov	ecx,bwidth		;largeur image
	rep	movsb			;recopie ligne
	pop	edi
	pop	esi
	pop	ecx
	add	esi,edx			;ligne suivante image
	sub	edi,swidth		;debut ligne precedente
	loop	ggputw8
	mov	refreshflag,1
ggputw9:
	add	esp,bmloc		;liberation variables locales
	pop	ebp
ggputw10:
	ret
ggputw11:
	mov	al,err_bad_arg		;argument invalide
	jmp	rpter
ggputw12:
	dec	eax			;ignore couleur de fond ?
	jnz	short ggputw16		;non
ggputw13:
	push	ecx
	push	esi
	push	edi
	mov	ecx,bwidth		;largeur image
ggputw14:
	mov	al,[esi]		;couleur BMP
	and	al,al			;couleur de fond ?
	jz	short ggputw15		;oui, ignore
	mov	[edi],al		;copie dans fenetre graphique
ggputw15:
	inc	esi
	inc	edi
	loop	ggputw14			;pour toute la ligne
	pop	edi
	pop	esi
	pop	ecx
	add	esi,edx			;ligne suivante image
	sub	edi,swidth		;debut ligne precedente
	loop	ggputw13
	mov	refreshflag,1
	add	esp,bmloc		;liberation variables locales
	pop	ebp
	ret
ggputw16:
	dec	eax			;inversion couleur ?
	jnz	ggput1			;non, pas de traitement
ggputw17:
	push	ecx
	push	esi
	push	edi
	mov	ecx,bwidth		;largeur image
ggputw18:
	mov	al,[esi]		;couleur BMP
	xor	[edi],al		;operation dans fenetre graphique
	inc	esi
	inc	edi
	loop	ggputw18			;pour toute la ligne
	pop	edi
	pop	esi
	pop	ecx
	add	esi,edx			;ligne suivante image
	sub	edi,swidth		;debut ligne precedente
	loop	ggputw17
	mov	refreshflag,1
	add	esp,bmloc		;liberation variables locales
	pop	ebp
	ret

; Lecture position manette
; Entree: DL=numero manette
; Retour: EAX=position
	align	16
gpdl:
	xor	eax,eax			;non supporte
	ret

; Adresse point en memoire graphique
; Entree: ECX=X
;	  EDX=Y
; Retour: AH=couleur masquee
;	  AL=masque
	align	16
getloc:
	mov	eax,sheight		;hauteur ecran
	dec	eax
	sub	eax,edx			;0 en bas a gauche
	mul	linesize
	add	eax,ecx
	mov	esi,eax			;offset memoire graphique
	mov	ax,colmask		;AH=couleur, AL=masque
	and	ah,al			;masque couleur
	add	esi,graphbase		;adresse memoire graphique
	ret

; Affichage point
; Entree: ECX=X
;	  EDX=Y
	align	16
putpixel:
	push	esi
	push	eax
	push	ecx
	push	edx
	call	getloc			;adresse point en memoire graphique
	not	al
	and	al,[esi]		;masque couleur courante
	or	al,ah			;nouvelle couleur
	mov	[esi],al		;maj
ret_pixel:
	pop	edx
	pop	ecx
	pop	eax
	pop	esi
	ret

; Inversion point
	align	16
inv_pixel:
	push	esi
	push	eax
	push	ecx
	push	edx
	call	getloc			;adresse point en memoire graphique
	mov	al,ah			;couleur masquee
	and	al,[esi]
	not	al
	and	al,ah
	not	ah
	and	ah,[esi]
	or	al,ah
	mov	[esi],al		;maj
	jmp	ret_pixel

; Dessin point
	align	16
dashpixel:
	ror	reverse,1		;decalage masque inversion
	jc	inv_pixel		;inversion point
	ror	dashmask,1		;decalage masque pointille
	jc	putpixel		;affichage point
	ret

; Couleur point
; Entree: ECX=X
;	  EDX=Y
	align	16
getpixel:
	push	esi
	push	eax
	push	ecx
	push	edx
	call	getloc			;adresse point en memoire graphique
	mov	al,[esi]		;couleur point
	pop	edx
	pop	ecx
	pop	esi
	pop	esi
	ret

; Trace segment horizontal
; Entree: EBX=ordonnee
;	  ECX=gauche
;	  EDX=droite
	align	16
plotseg:
	push	ecx
	push	edx
	push	esi
	mov	eax,edx
	inc	eax
	sub	eax,ecx			;nombre de points
	mov	edx,ebx			;Y
	push	eax
	call	getloc			;adresse point en memoire graphique
	pop	ecx
	xchg	esi,edi
	mov	al,ah			;couleur
	rep	stosb			;trace
	mov	edi,esi
	pop	esi
	pop	edx
	pop	ecx
	ret

; Fonte caracteres
	align	16
chset	label	byte
	include chset.inc

; Dessin caractere
; Entree: AL=code caratere
;	  ECX=X
;	  EDX=Y
;	  EBP->variables locales affichage texte
	align	16
paintchar:
	movzx	eax,al
	lea	ebx,chset[eax*8+7]	;derniere rangee fonte caractere
	mov	eax,8			;compteur rangee
paintchar1:
	push	eax
	mov	eax,repy		;repetition en Y caractere
paintchar2:
	push	eax
	push	ecx
	push	edx
	mov	al,[ebx]		;motif rangee
	mov	pattern,al		;range
	mov	eax,8			;compteur point
paintchar3:
	push	eax
	sal	pattern,1		;sortie point
	setc	plotflg			;0:point eteint, 1:point allume
	mov	eax,repx		;repetition en X caractere
paintchar4:
	test	plotflg,0FFh		;point allume
	jz	short paintchar5	;non, ignore
	cmp	ecx,swidth		;dans l'ecran ?
	jae	short paintchar5	;non (test non signe, nombre negatif > SWIDTH)
	cmp	edx,sheight
	jae	short paintchar5	;non (test non signe, nombre negatif > SHEIGHT)
	call	putpixel		;affichage point
paintchar5:
	add	ecx,incdotx		;avance point
	add	edx,incdoty
	dec	eax
	jne	paintchar4		;repetition point
	pop	eax
	dec	eax
	jne	paintchar3		;point suivant
	pop	edx
	pop	ecx
	pop	eax
	add	ecx,incrowx		;avance rangee
	add	edx,incrowy
	dec	eax
	jne	paintchar2		;repetition rangee
	pop	eax
	dec	ebx			;motif rangee precedente
	dec	eax
	jne	paintchar1		;rangee suivante
	ret

; Constante dessin motif
	align	16
sqr2	dd	1518500250		;(2**32)*sqr(2)/4

; Table ajustement deplacemet motif
adjust	dd	offset adj0		;0 degre
	dd	offset adj1		;45 degres
	dd	offset adj2		;90 degres
	dd	offset adj3		;135 degres
adj1:
	add	yold,eax
adj0:
	add	xold,eax
	ret
adj3:
	sub	xold,eax
adj2:
	add	yold,eax
	ret

; Ajuste en Y suivant direction motif
; Entree: EAX=deplacement en Y
;	  EBX=direction deplacement
	align	16
yadjust:
	add	ebx,2			;ajoute 90 degres
	and	bl,00000111b		;modulo 8
;;;	jmp	short xadjust

; Ajuste en X suivant direction motif
; Entree: EAX=deplacement en X
;	  EBX=direction deplacement
;	  EBP->variables locales DRAW
xadjust:
	test	bl,0000001b		;incline ?
	jz	short xadjust1		;non
	push	edx
	imul	sqr2			;(2**32)*sqr(2)/4
	shl	eax,1			;*2
	rcl	edx,1
	mov	eax,edx			;*sqr(2)/2
	pop	edx
xadjust1:
	test	bl,00000100b		;cadran negatif ?
	jz	short xadjust2		;non
	and	bl,00000011b		;vers cadran positif
	neg	eax			;negation deplacement
xadjust2:
	jmp	adjust[ebx*4]		;ajustement

; EAX=(EAX/32+EBX)/16
	align	16
deltap:
	mov	edx,eax
	sar	eax,14
	add	eax,edx			;pour arrondi
	sar	eax,5			;/32
	add	eax,ebx
	sar	eax,4			;/16
	ret

; EAX=(EAX/32-EBX)/16
	align	16
deltam:
	mov	edx,eax
	sar	eax,14
	add	eax,edx			;pour arrondi
	sar	eax,5			;/32
	sub	eax,ebx
	sar	eax,4			;/16
	ret

; Test point dans fenetre
; Entree: [esi]   : abscisse point
;	  [esi+4] : ordonnee point
; Retour: ECX=X
;	  EDX=Y
;	  CF si hors fenetre
	align	16
checkfill:
	mov	ecx,[esi]		;X
	mov	edx,[esi+4]		;Y
	cmp	ecx,xminw
	jl	short checkfill1	;X < Xmin
	cmp	ecx,xmaxw
	jg	short checkfill1	;X > Xmax
	cmp	edx,yminw
	jl	short checkfill1	;Y < Ymin
	cmp	edx,ymaxw
	jg	short checkfill1	;Y > Ymax
	clc				;retour dans fenetre
	ret
checkfill1:
	stc				;retour hors fenetre
	ret

; Test si point libre
; Entree: ECX=X
;	  EDX=Y
; Retour: NC si libre
	align	16
freepoint:
	call	getpixel		;couleur point
freepoint1:
	cmp	al,gtrcl		;couleur trace ?
	je	short freepoint2	;oui, occupe
	test	filltype,0FFh		;remplissage contour ?
	jz	short freepoint3	;non
	cmp	al,fillcolor		;couleur contour ?
	jne	short freepoint4	;non, retour libre
freepoint2:
	stc				;retour occupe
	ret
freepoint3:
	cmp	al,fillcolor		;couleur zone ?
	jne	freepoint2		;non, occupe
freepoint4:
	clc				;retour libre
	ret

; Empile remplissage
; Entree: ECX=gauche
;	  EDX=droite
;	  EBX=ordonnee
;	  EAX=signe
; Retour: CF si debordement
	align	16
pushfill:
	mov	edi,stackptr		;pointeur pile remplissage
	cmp	edi,fillloc-4*4		;assez de place ?
	ja	short pushfill1		;non, erreur
	mov	[ebp+edi],ecx		;gauche
	mov	[ebp+edi+4],edx		;droite
	mov	[ebp+edi+8],ebx		;ordonnee
	mov	[ebp+edi+12],eax	;signe
	add	edi,4*4			;avance pointeur
	mov	stackptr,edi		;maj
	clc				;retour OK
	ret
pushfill1:
	stc				;retour debordement pile
	ret

; Depile remplissage
; Retour: ECX=gauche
;	  EDX=droite
;	  EBX=ordonnee
;	  EAX=signe
;	  CF si pile vide
	align	16
popfill:
	mov	edi,stackptr		;pointeur pile remplissage
	cmp	edi,fillstack+4*4	;donnees disponibles ?
	jb	short popfill1		;non, fin
	sub	edi,4*4			;recule pointeur
	mov	ecx,[ebp+edi]		;gauche
	mov	edx,[ebp+edi+4]		;droite
	mov	ebx,[ebp+edi+8]		;ordonnee
	mov	eax,[ebp+edi+12]	;signe
	mov	stackptr,edi		;maj
	clc
	ret
popfill1:
	stc
	ret

; Deplacement maximum libre a gauche
; Entree: ECX=abscisse
;	  EBX=limite gauche
; Retour: ECX=abscisse maximale a gauche
	align	16
goleft:
	mov	edi,ecx
	push	edx
	call	getloc			;adresse point en memoire graphique
	inc	edi
go_left1:
	dec	edi
	cmp	edi,ebx
	je	short go_left2
	mov	al,[esi]		;couleur point
	dec	esi
	call	freepoint1		;point libre ?
	jnc	go_left1		;oui
	inc	edi
go_left2:
	pop	edx
	mov	ecx,edi
	ret

; Deplacement maximum libre a droite
; Entree: ECX=abscisse
;	  EBX=limite droite
; Retour: ECX=abscisse maximale a droite
	align	16
goright:
	mov	edi,ecx
	push	edx
	call	getloc			;adresse point en memoire graphique
	dec	edi
go_right1:
	inc	edi
	cmp	edi,ebx
	jae	short go_right2
	mov	al,[esi]
	inc	esi
	call	freepoint1
	jnc	go_right1
	dec	edi
go_right2:
	pop	edx
	mov	ecx,edi
	ret

; Trace d'un segment a l'interieur de la fenetre
; Entree: X1TEMP,Y1TEMP=debut
;	  X2TEMP,Y2TEMP=fin
	align	16
gtrace:
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi
	push	ebp
	mov	ebx,x1temp
	mov	ecx,x2temp
	mov	esi,y1temp
	mov	edi,y2temp
	mov	eax,xminw		;gauche fenetre
	call	clipleft		;coupure par rapport a la gauche de la fenetre
	jc	short gtrace4		;hors fenetre
	mov	eax,xmaxw		;droite fenetre
	call	clipright		;coupure par rapport a la droite de la fenetre
	jc	short gtrace4		;hors fenetre
	xchg	ebx,esi			;echange abscisses et ordonnees
	xchg	ecx,edi
	mov	eax,yminw		;bas fenetre
	call	clipleft		;coupure par rapport au bas de la fenetre
	jc	short gtrace4		;hors fenetre
	mov	eax,ymaxw		;haut fenetre
	call	clipright		;coupure par rapport au haut de la fenetre
	jc	short gtrace4		;hors fenetre
	mov	edx,ebx			;Y1
	mov	ebx,ecx			;Y2
	mov	ecx,esi			;X1
	mov	eax,edi			;X2
	mov	esi,1			;pas en X par defaut
	mov	edi,1			;pas en Y par defaut
	mov	x2temp,eax		;range fin trace en X
	mov	y2temp,ebx		;range fin trace en Y
	xor	ebp,ebp
	sub	eax,ecx			;dX
	jg	short gtrace1
	neg	esi			;inverse pas en X
	neg	eax			;abs(dX)
gtrace1:
	sub	ebx,edx			;dY
	jg	short gtrace2
	neg	edi			;inverse pas en Y
	neg	ebx			;abs(dY)
gtrace2:
	cmp	eax,ebx			;abs(dX) >= abs(dY) ?
	jl	short gtrace5		;non, trace suivant Y
	sub	ebp,eax
	sar	ebp,1			;EBP=-abs(dX)/2
gtrace3:
	call	dashpixel		;dessin point
	cmp	ecx,x2temp		;fin trace en X ?
	je	short gtrace4		;oui
	add	ecx,esi			;avance ou recule X
	add	ebp,ebx			;EBP=EBP+abs(dY)
	js	gtrace3			;EBP<0
	add	edx,edi			;avance ou recule Y
	sub	ebp,eax			;EBP=EBP-abs(dX)
	jmp	short gtrace3		;jusqu'a fin de trace en X
gtrace4:
	pop	ebp
	pop	esi
	pop	edi
	pop	edx
	pop	ecx
	pop	ebx
	ret
gtrace5:
	sub	ebp,ebx
	sar	ebp,1			;EBP=-abs(dY)/2
gtrace6:
	call	dashpixel		;dessin point
	cmp	edx,y2temp		;fin de trace en Y ?
	je	gtrace4			;oui
	add	edx,edi			;avance ou recule en Y
	add	ebp,eax			;EBP=EBP+abs(dX)
	js	gtrace6			;EBP<0
	add	ecx,esi			;avance ou recule Y
	sub	ebp,ebx			;EBP=EBP-abs(dY)
	jmp	gtrace6			;jusqu'a fin de trace en Y

; Coupure a gauche ou en bas
; Entree: EAX=limite
;	  EBX=debut
;	  ECX=fin
;	  ESI=autre coordonnee debut
;	  EDI=autre coordonnee fin
; Retour: CF si segment hors limite
;	  EAX, EBX, ESI et EDI maj si coupure necessaire
	align	16
clipleft:
	xor	ebp,ebp			;segment entrant par defaut
	cmp	ebx,eax			;debut avant limite ?
	jl	short clipleft3		;oui
	cmp	ecx,eax			;fin avant limite ?
	jl	short clipleft0		;oui
	clc				;debut et fin apres limite
	ret
clipleft3:
	cmp	ecx,eax			;fin apres limite ?
	jg	short clipping		;oui, coupure
	stc				;hors limite
	ret
clipleft0:
	dec	ebp			;segment sortant
clipleft1:
	jmp	short clipping		;coupure sur limite

; Coupure a droite ou en haut
; Entree: EAX=limite
;	  EBX=debut
;	  ECX=fin
;	  ESI=autre coordonnee debut
;	  EDI=autre coordonnee fin
; Retour: CF si segment hors limite
;	  EAX, EBX, ESI et EDI maj si coupure necessaire
	align	16
clipright:
	xor	ebp,ebp			;segment entrant par defaut
	cmp	ebx,eax			;debut apres limite ?
	jg	short clipright3	;oui
	cmp	ecx,eax			;fin apres limite ?
	jg	short clipright0	;oui
	clc				;debut et fin avant limite
	ret
clipright3:
	cmp	ecx,eax			;fin avant limite ?
	jl	short clipping		;oui, coupure
	stc				;hors limite
	ret
clipright0:
	dec	ebp			;segment sortant
clipright1:
;;;	jmp	short clipping		;coupure sur limite

; Coupure sur limite
; Entree: EAX=limite
;	  EBX=debut
;	  ECX=fin
;	  ESI=autre coordonnee debut
;	  EDI=autre coordonnee fin
;	  EBP=0 si segment entrant
; Retour: CF=0
;	  EAX, EBX, ESI et EDI maj
	align	16
clipping:
	push	eax
	push	ebx
	mov	edx,ebx
	sub	edx,eax			;debut-limite
	jge	short clipping1
	neg	edx			;valeur absolue
clipping1:
	xor	eax,eax
	sub	ebx,ecx			;debut-fin
	jge	short clipping2
	neg	ebx			;valeur absolue
clipping2:
	div	ebx			;abs(debut-limite)*2**32/abs(debut-fin)
	mov	ebx,edi
	sub	ebx,esi			;debut-fin autres coordonnees
	test	ebx,ebx
	pushfd
	jns	short clipping3
	neg	ebx
clipping3:
	mul	ebx			;EDX=(debut-fin autres coordonnees)*(abs(debut-limite)*2**32/abs(debut-fin))/2**32
	popfd
	jns	short clipping4
	neg	edx			;restaure signe
clipping4:
	add	edx,esi			;autre coordonnee coupure
	pop	ebx
	pop	eax
clipping5:
	test	ebp,ebp			;segment entrant ? (CF=0)
	jnz	short clipping6		;non
	mov	ebx,eax			;debut sur coupure
	mov	esi,edx
	ret				;retour CF=0
clipping6:
	mov	ecx,eax			;fin sur coupure
	mov	edi,edx
	ret				;retour CF=0

; Preparation image bitmap
; Entree: EBX=largeur image
;	  ECX=hauteur image
; Retour: EBX->image bitmap
;	  EDI->debut image
;	  EDX=decalage
prepbmp:
	push	ebx
	push	ecx
	add	ebx,3
	and	ebx,0FFFFFFFCh		;largeur image alignee sur 32 bits
	mov	eax,ebx
	mul	ecx			;EAX=dimension image
	test	edx,edx			;debordement ?
	jnz	short prepbmp1		;oui, erreur
	add	eax,((size bmph+3)/4)*4	;ajout taille entete
	jc	short prepbmp1		;oui, erreur
	mov	ecx,eax
	push	ebx
	call	allocds			;allocation memoire
	pop	edx
	mov	[esi].aget.adr,ebx	;adresse image
	mov	[esi].aget.len,ecx	;retour longueur image
	push	ecx
	mov	edi,ebx
	shr	ecx,2			;nombre de doubles mots
	xor	eax,eax
	rep	stosd			;raz image
	pop	ecx
	mov	eax,((size bmph+3)/4)*4	;taille entete
	mov	[ebx].bmph.bmph_sign,'MB' ;signature
	mov	[ebx].bmph.bmph_fsize,ecx ;taille fichier
	sub	ecx,eax
	mov	[ebx].bmph.bmph_ioffset,eax ;debut d'image
	mov	[ebx].bmph.bmph_desclen,40 ;taille entete
	pop	[ebx].bmph.bmph_height	;hauteur image en pixels
	pop	[ebx].bmph.bmph_width	;largueur image en pixels
	mov	[ebx].bmph.bmph_planes,1 ;nombre de plans
	mov	[ebx].bmph.bmph_deep,8	;bits couleur
	mov	[ebx].bmph.bmph_psize,ecx ;taille image
	mov	[ebx].bmph.bmph_colcount,256 ;nombre de couleurs
	mov	[ebx].bmph.bmph_maincols,0 ;nombre de couleurs principales
	push	esi
	mov	esi,offset Color32	;palette courante
	lea	edi,[ebx].bmph.bmph_rgb	;palette image
	mov	ecx,256			;nombre de couleurs
	rep	movsd			;recopie palette
	pop	esi
	add	edi,3
	and	edi,0FFFFFFFCh		;alignement 32 bits
	ret
prepbmp1:
	mov	al,err_bad_arg		;argument invalide
	jmp	rpter

; Verification image bitmap
; Entree: ESI->parametres commande
; Retour: EBX->image bitmap
;	  EDX=decalage
chkbmp:
	mov	ebx,[esi].aput.adr	;adresse image
	mov	eax,[esi].aput.len	;longueur image
	test	ebx,ebx			;bit map vide ?
	jz	short chkbmp1		;oui, erreur format
	cmp	eax,size bmph		;longueur suffisante ?
	jb	short chkbmp1		;non, erreur format
	cmp	[ebx].bmph.bmph_sign,'MB' ;signature OK ?
	jne	short chkbmp1		;non, erreur format
	cmp	[ebx].bmph.bmph_fsize,eax ;taille fichier OK ?
	jne	short chkbmp1		;non, erreur format
	cmp	[ebx].bmph.bmph_desclen,40 ;taille entete OK ?
	jb	short chkbmp1		;non, erreur format
	cmp	[ebx].bmph.bmph_planes,1 ;nombre de plans OK ?
	jne	short chkbmp1		;non, erreur format
	cmp	[ebx].bmph.bmph_deep,8	;bits couleur OK ?
	jne	short chkbmp1		;non, erreur format
	mov	eax,[ebx].bmph.bmph_width ;largueur image en pixels
	add	eax,3
	and	eax,0FFFFFFFCh		;alignement 32 bits
	push	eax
	mul	[ebx].bmph.bmph_height	;taille image
	pop	edx
	cmp	eax,[ebx].bmph.bmph_psize ;taille image OK ?
	jne	short chkbmp1		;non, erreur format
	add	eax,[ebx].bmph.bmph_ioffset ;ajout debut d'image
	cmp	[ebx].bmph.bmph_fsize,eax ;taille fichier OK ?
	jne	short chkbmp1		;non, erreur format
	ret
chkbmp1:
	mov	al,err_bad_bmp		;format image invalide
	jmp	rpter

	end