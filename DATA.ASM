	page	,132
	name	data

	public	pathbuf
	public	widthx
	public	maxnref
	public	maxlref
	public	sigcnt
	public	sigcn2
	public	sigcnx
	public	r0
	public	r0h
	public	r0i
	public	r1
	public	intflg
	public	format
	public	ftoaerr
	public	puleft
	public	puright
	public	len
	public	inptr
	public	outbuf
	public	stbeg
	public	stend
	public	tmpptr
	public	arg_c
	public	arg_v
	public	prog_base
	public	data_base
	public	symb_base
	public	lcode
	public	lsymb
	public	penx
	public	peny
	public	colm
	public	oport
	public	iport
	public	tcx
	public	tdx
	public	initsp
	public	execsp
	public	count
	public	clrflg
	public	labflg
	public	lineflg
	public	contflg
	public	pbinflg
	public	inflg
	public	first
	public	lastx
	public	fstavl
	public	vartyp
	public	nxtnam
	public	linptr
	public	prvlin
	public	symoff
	public	nextpc
	public	curpc
	public	savebp
	public	prog_size
	public	symb_size
	public	atos
	public	asnadr
	public	asntype
	public	dirflg
	public	runline
	public	arayptr
	public	bckcnt
	public	strtos
	public	strflg
	public	ssptr
	public	strsptr
	public	oldstr
	public	excchn
	public	offst
	public	datapt
	public	dataln
	public	contcur
	public	contnxt
	public	contebp
	public	ergol
	public	errs
	public	erls
	public	onerflg
	public	fcbin
	public	fcbout
	public	fcbdir
	public	fldptr
	public	fldend
	public	sschn
	public	virtchn
	public	vrtasn
	public	vrtrec
	public	vrtflg
	public	prtflg
	public	asnflg
	public	filswo
	public	filswi
	public	data_end
	public	incnum
	public	startnum
	public	cmpopt
	public	sortflg
	public	tokflg
	public	noedf
	public	stepflg
	public	trcflg
	public	breakflg
	public	listcolflg
	public	intmask
	public	intflags
	public	inttbl
	public	filtab
	public	vatab
	public	buffer
	public	linlen
	public	linum
	public	linbuf
	public	tmps
	public	astack
	public	strstk

	.model	flat,c

;Constantes (copie SBASIC.INC)
numfil		equ	33		;nombre maximum de fichiers
buflen		equ	32		;longueur tampon acces fichier
foblen		equ	34		;longueur tampon sortie FTOA
maxpath		equ	120		;taille tampon chemin fichier
maxbuf		equ	1024		;taille tampon de travail
maxlin		equ	254		;taille tampon codage ligne
maxtmp		equ	512		;taille tampon allocations temporaires
maxstk		equ	64		;nombre d'entrees pile arithmetique
maxstr		equ	32		;nombre d'entrees pile chaines
prog_head	equ	50		;a verifier!
text_cols	equ	80		;largeur ecran texte
maxsymb		equ	15		;maximum caracteres affichage symbole
maxlabl		equ	9		;maximum caracteres affichage etiquette
minlnum		equ	5		;minimum caracteres affichage numero de ligne

	.data
;Donnees communes BASIC
		db	16 dup(?)	;zone de travail avant R0 (2 octets utilises dans ATOF) et alignement paragraphe
r0		db	6 dup(?)	;6 octets R0 (48 bits de poids faible mantisse)
r0h		dw	?		;2 octets R0 (1 bit signe, 11 bits exposant, 4 bits de poids fort mantisse)
r0i		equ	dword ptr r0	;R0 entier 32 bits
r1		db	8 dup(?)	;R1
arg_c		dd	?		;nombre d'arguments
arg_v		dd	?		;adresse table de pointeurs argument
prog_base	dd	?		;program segment base
prog_size	dd	?		;taille memoire programme
data_base	dd	?		;base memoire donnees
data_end	dd	?		;fin memoire donnees
symb_base	dd	?		;base memoire symboles
symb_size	dd	?		;taille table symboles
lcode		dd	?		;longueur code
lsymb		dd	?		;longueur table symboles
widthx		dd	text_cols	;largeur affichage
maxnref		dd	(text_cols-maxsymb-5)/(minlnum+1) ;nombre maximum de references numero affichees par ligne
maxlref		dd	(text_cols-1)/(maxlabl+minlnum+1) ;nombre maximum de references etiquette affichees par ligne
penx		dd	?		;position horizontalle
peny		dd	?		;position verticale
atos		dd	?		;sommet pile arithmetique
strtos		dd	?		;sommet pile chaines
initsp		dd	?		;pointeur pile initial
execsp		dd	?		;pointeur pile execution
strsptr		dd	?		;pointeur pile chaine
tmpptr		dd	?		;pointeur allocation memoire temporaire
fstavl		dd	2 dup (?)	;pointeur memoire libre et longueur bloc
sschn		dd	?		;chaine des sous-chaines temporaires
excchn		dd	?		;chaine des lignes EXECUTE
inptr		dd	?		;pointeur caractere tampon entree
first		dd	?		;variable de travail
lastx		dd	?		;variable de travail
startnum	dd	?		;numero ligne debut renumerotation
incnum		dd	?		;pas renumerotation
offst		dd	?		;deplacement
len		dd	?		;longueur
ssptr		dd	?		;pointeur sous-chaine
stbeg		dd	?		;pointeur debut chaine
stend		dd	?		;pointeur fin chaine
nxtnam		dd	?		;pointeur debut nom
linptr		dd	?		;pointeur ligne codee
prvlin		dd	?		;pointeur ligne precedente
curpc		dd	?		;pointeur ligne programme courante
nextpc		dd	?		;pointeur ligne programme suivante
savebp		dd	?		;sauvegarde pointeur execution
contcur		dd	?		;sauvegarde CURPC pour CONTINUE
contnxt		dd	?		;sauvegarde NEXTPC pour CONTINUE
contebp		dd	?		;sauvegarde pointeur programme pour CONTINUE
datapt		dd	?		;pointeur DATA
dataln		dd	?		;pointeur ligne DATA
ergol		dd	?		;numero de ligne branchement ON ERROR
errs		dd	?		;code erreur
erls		dd	?		;ligne erreur
symoff		dd	?		;offset symbole
runline		dd	?		;ligne debut execution
asnadr		dd	?		;adresse affectation
arayptr		dd	?		;pointeur descripteur tableau
oldstr		dd	2 dup (?)	;adresse et longueur ancienne chaine
fcbin		dd	?		;FCB fichier entree
fcbout		dd	?		;FCB fichier sortie
fcbdir		dd	?		;FCB fichier acces direct
fldptr		dd	?		;pointeur tampon FIELD
fldend		dd	?		;fin tampon field
vrtrec		dd	?		;numero element tableau virtuel
inttbl		dd	8 dup(?)	;vecteurs interruption
oport		dd	10 dup (?)	;table des ports de sortie
iport		dd	10 dup (?)	;table des ports d'entree
tcx		dw	0		;heure:minute
tdx		dw	0		;seconde:1/100eme seconde
intflg		db	?		;indicateur entier pour ATOF
format		db	?		;indicateur format <0 force format scientifique, =0 format automatique, >0 pas de format scientifique (PRINT USING)
ftoaerr		db	?		;indicateur erreur FTOA
sigcnt		db	13		;nombre de chiffres significatifs
sigcn2		db	-1		;nombre de chiffres apres la virgule
sigcnx		db	-2		;seuil basculement notation scientifique
puleft		db	?		;nombre de chiffres a gauche de la virgule
puright		db	?		;nombre de chiffres a droite de la virgule
dirflg		db	?		;indicateur mode direct
clrflg		db	?		;indicateur CLEAR
labflg		db	?		;indicateur etiquette (-1:definition, 1:reference)
lineflg		db	?		;indicateur numero de ligne
contflg		db	?		;indicateur CONTINUE possible
pbinflg		db	?		;indicateur preparation image binaire
inflg		db	?		;indicateur INPUT
onerflg		db	?		;indicateur traitement ON ERROR
strflg		db	?		;indicateur expression chaine
prtflg		db	?		;indicateur impression
asnflg		db	?		;indicateur affectation
vrtflg		db	?		;indicateur tableau virtuel
vrtasn		db	?		;indicateur affectation tableau virtuelle
filswo		db	?		;indicateur sortie sur fichier
filswi		db	?		;indicateur entree depuis fichier
sortflg		db	?		;indicateur tri
tokflg		db	?		;indicateur rangement TOKEN
noedf		db	?		;indicateur pas d'affichage source
stepflg		db	?		;indicateur pas a pas
trcflg		db	?		;indicateur trace
breakflg	db	?		;indicateur BREAK
listcolflg	db	?		;indicateur affichage avec couleur
intmask		db	?		;masque interruptions
intflags	db	?		;indicateurs interruptions
vartyp		db	?		;type variable
asntype		db	?		;type affectation
virtchn		db	?		;canal tableau virtuel
cmpopt		db	?		;options compilation
count		db	?		;compteur
bckcnt		db	?		;compteur parentheses
colm		db	10 dup (?)	;compteurs colonne des ports

;Tampons (attention a l'ordre)
		align	4
filtab		dd	numfil dup (?)	;table des FCB
vatab		dd	numfil dup (?)	;table des descripteurs tableau virtuel (doit suivre FILTAB)
buffer		db	maxbuf dup (?)	;tampon de travail
;Attention: LINLEN, LINO et LINBUF doivent se suivre
linlen		db	?		;longueur ligne
linum		dd	?		;numero de ligne
linbuf		db	maxlin dup(?)	;tampon codage ligne
tmps		db	maxtmp dup (?)	;allocations temporaires
		align	4
astack		db	maxstk*12 dup (?) ;pile arithmetique
strstk		db	(maxstr+1)*8 dup (?) ;pile chaines
outbuf		db	foblen dup (?)	;tampon conversion nombre en chaine et inversement
pathbuf		db	maxpath+5 dup (?) ;tampon de travail avec place pour extension fichier et marque de fin

	end