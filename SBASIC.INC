;Constantes et structures
defrec		equ	252		;longueur enregistrement par default
defstr		equ	18		;longueur chaine par defaut dans tableau virtuel
numfil		equ	33		;nombre maximal de fichiers
buflen		equ	32		;len of buffer in seq I/O
foblen		equ	34		;FTOA output buffer len (DE: 24->34)
maxpath		equ	120		;taille tampon chemin de fichier
maxbuf		equ	1024		;taille tampons
maxlin		equ	254		;taille tampon codage ligne
maxtmp		equ	512		;taille tampon allocations temporaires
maxstk		equ	64		;nombre d'entrees pile arithmetique
maxstr		equ	32		;nombre d'entrees pile chaines
maxline		equ	7FFFFFFFh	;numero maximum ligne
maxlen		equ	16		;longeur maximale dans tampon allocations temporaires
maxinput	equ	100		;nombre d'entree historique de commandes
maxcmd		equ	125		;longueur maximale chaine commande systeme
maxport		equ	20		;nombre de ports
maxsymb		equ	15		;maximum caracteres affichage symbole
maxlabl		equ	9		;maximum caracteres affichage etiquette
minlnum		equ	5		;minimum caracteres affichage numero de ligne

text_cols	equ	80		;largeur ecran texte
text_lines	equ	25		;hauteur ecran texte
max_cols	equ	255		;maximum largeur ecran texte
max_lines	equ	255		;maximum hauteur ecran texte
print_room	equ	16		;reserve ligne PRINT
gr_width	equ	320		;largeur ecran graphique
gr_height	equ	200		;hauteur ecran graphique
gr_para		equ	4000		;320*200*1/16
hgr_width	equ	800		;largeur ecran graphique haute resolution
hgr_height	equ	600		;hauteur ecran graphique haute resolution
hgr_pages	equ	8		;taille memoire graphique haute resolution en pages de 64Ko
first_code	equ	20h		;offset codes points d'entree graphique

;Caracteres
inrt		equ	02h		;caractere insertion
ctrlc		equ	03h		;Ctrl-C
eot		equ	04h		;caractere fin de texte
del		equ	05h		;caractere effacement
bell		equ	07h		;caractere sonore
bs		equ	08h		;caractere recul
tab		equ	09h		;caractere tabulation
lf		equ	0Ah		;caractere saut de ligne
up		equ	0Bh		;caractere deplacement vers le haut
ff		equ	0Ch		;caractere saut de page
cr		equ	0Dh		;caractere fin de ligne
rpt		equ	12h		;caractere repetition
ctrlx		equ	18h		;Ctrl-X
ctrlz		equ	1Ah		;Ctrl-Z
escape		equ	1Bh		;caractere d'echapement
lef		equ	1Dh		;caractere de deplacement vers la gauche
quote		equ	27h		;caractere apostrophe
back		equ	7Fh		;caractere effacement caractere

;Couleurs affichage
col_none	equ	'8'		;couleur texte par defaut
col_key		equ	'4'		;couleur mot cle (bleu)
col_var		equ	'2'		;couleur variable (vert)
col_str		equ	'3'		;couleur chaine (jaune)
col_rem		equ	'1'		;couleur commentaire (rouge)

;Indicateurs variable
fltbit		equ	00000000b	;flottant
strbit		equ	00000001b	;chaine
linbit		equ	00000010b	;ligne
intbit		equ	00000100b	;entier
unused		equ	00001000b	;non utilise
arrbit		equ	00010000b	;tableau
conbit		equ	00100000b	;constante
labbit		equ	01000000b	;label

;Interruptions
trace_int	equ	0
break_int	equ	7
trace_mask	equ	00000001b
break_mask	equ	10000000b
int_flag	equ	11111111b

;Extenxions nom de fichier par defaut
ext_none	equ	-1
ext_bas		equ	0
ext_dat		equ	1
ext_bac		equ	2
ext_wav		equ	3
ext_dll		equ	4

;Classes caractere
clsch_sepa	equ	0
clsch_alpha	equ	1
clsch_num	equ	2

;Taille constantes
size_i		equ	4		;entier
size_o		equ	4		;offset
size_a		equ	4		;adresse
size_f		equ	8		;flottant
size_v		equ	8		;variable en memoire donnees

;Codes operation
oc_and		equ	0
oc_or		equ	1
oc_add		equ	0
oc_sub		equ	1
oc_mul		equ	2
oc_div		equ	3
oc_mod		equ	4
oc_power	equ	5

;Type fichier binaire
compressed	equ	00000001b	;compresse
nosymb		equ	00000010b	;sans symboles
protected	equ	00000100b	;protege
librairy	equ	00001000b	;librairie
overlay		equ	00010000b	;idem librairie

;Signatures
interrupt_mark	equ	0F0h
execute_mark	equ	0F4h
for_mark	equ	0F8h
gosub_mark	equ	0FCh
call_mark	equ	0FEh

;Modes affichage
m_text		equ	0
m_gr		equ	1
m_hgr		equ	2

;Mots cles
tok_mark	equ	10000000b	;bit7
k_goto		equ	1
k_gosub		equ	2
k_resume	equ	3
k_digits	equ	4
k_rem		equ	5
k_let		equ	6
k_print		equ	7
k_input		equ	8
k_execute	equ	9
k_swap		equ	10
k_for		equ	11
k_poke		equ	12
k_lprint	equ	13
k_next		equ	14
k_read		equ	15
k_return	equ	16
k_if		equ	17
k_dim		equ	18
k_on		equ	19
k_set		equ	20
k_end		equ	21
k_stop		equ	22
k_data		equ	23
k_restore	equ	24
k_call		equ	25
k_open		equ	26
k_close		equ	27
k_chain		equ	28
k_kill		equ	29
k_rename	equ	30
k_get		equ	31
k_put		equ	32
k_field		equ	33
k_lset		equ	34
k_rset		equ	35
k_exec		equ	36
k_dpoke		equ	37
k_indirect	equ	38
k_sub		equ	39
k_label		equ	40
k_record	equ	41
k_old		equ	42
k_new		equ	43
k_as		equ	44
k_using		equ	45
k_error		equ	46
k_line		equ	47
k_then		equ	48
k_else		equ	49
k_to		equ	50
k_step		equ	51
k_point		equ	52
k_abs		equ	53
k_atn		equ	54
k_cos		equ	55
k_exp		equ	56
k_int		equ	57
k_log		equ	58
k_rnd		equ	59
k_sgn		equ	60
k_sin		equ	61
k_sqr		equ	62
k_tan		equ	63
k_pos		equ	64
k_peek		equ	65
k_usr		equ	66
k_fre		equ	67
k_dpeek		equ	68
k_pdl		equ	69
k_ptr		equ	70
k_spc		equ	71
k_tab		equ	72
k_xpen		equ	73
k_ypen		equ	74
k_pi		equ	75
k_err		equ	76
k_erl		equ	77
k_asc		equ	78
k_len		equ	79
k_val		equ	80
k_hex		equ	81
k_instr		equ	82
k_cvt$p		equ	83
k_cvt$f		equ	84
k_date$		equ	85
k_chr$		equ	86
k_left$		equ	87
k_right$	equ	88
k_mid$		equ	89
k_str$		equ	90
k_inch$		equ	91
k_cvtp$		equ	92
k_cvtf$		equ	93
k_rtrim$	equ	94
k_rtrm$		equ	94
k_ltrim$	equ	95
k_ltrm$		equ	95
k_string$	equ	96
k_not		equ	97
k_and		equ	98
k_or		equ	99
k_le		equ	100
k_ge		equ	101
k_dif		equ	102
k_lt		equ	103
k_gt		equ	104
k_eq		equ	105
k_power		equ	107
k_div		equ	108
k_mul		equ	109
k_plus		equ	110
k_minus		equ	111
k_exclamation	equ	112
k_ampersand	equ	113
k_comma		equ	114
k_semicolon	equ	115
k_lbracket	equ	116
k_rbracket	equ	117
k_hashtag	equ	118
k_mod		equ	119
k_append	equ	120
k_library	equ	121
k_colon		equ	123
k_cr		equ	125
k_space		equ	126
k_mspace	equ	127
;Mots cles etendus
k_gr		equ	1
k_text		equ	2
k_color		equ	3
k_hgr		equ	4
k_play		equ	5
k_setcolor	equ	6
k_setblink	equ	7
k_plot		equ	8
k_port		equ	9
k_clear		equ	10
k_tron		equ	11
k_troff		equ	12
k_cursor	equ	13
k_delete	equ	14
k_overlay	equ	15
k_load		equ	16
k_bload		equ	17
k_local		equ	18
k_clrg		equ	19
k_move		equ	20
k_dash		equ	21
k_symbol	equ	22
k_arc		equ	23
k_fill		equ	24
k_draw		equ	25
k_mask		equ	26
k_window	equ	27
k_pen		equ	28
k_compile	equ	29
k_bron		equ	30
k_broff		equ	31
k_cls		equ	32
k_edit		equ	33
k_reset		equ	34
k_exit		equ	35
k_zoom		equ	36
k_gget		equ	37
k_gput		equ	38
k_list		equ	39
k_unlock	equ	40
k_lock		equ	41
k_time		equ	42
k_chd		equ	43
k_bsave		equ	44
k_argc		equ	45
k_argv$		equ	46
;Mots cles commandes
c_save		equ	1
c_exit		equ	2
c_list		equ	3
c_new		equ	4
c_run		equ	5
c_goto		equ	6
c_cont		equ	7
c_step		equ	8
c_clear		equ	9
c_edit		equ	10
c_plist		equ	11
c_trace		equ	12
c_break		equ	13
c_renum		equ	14
c_trivar	equ	15
c_tasvar	equ	16
c_refsub	equ	17
c_stack		equ	18
;Mots cles BREAK
c_on		equ	1
c_off		equ	2

;Codes d'erreur
err_file_used	equ	2
err_file_exist	equ	3
err_no_file	equ	4
err_file_open	equ	5
err_file_create	equ	6
err_disk_full	equ	7
err_eof		equ	8
err_read	equ	9
err_write	equ	10
err_write_prot	equ	11
err_too_big	equ	12
err_bad_fcb	equ	13
err_disk_num	equ	15
err_not_ready	equ	16
err_access_prot	equ	17
err_bac_format	equ	18
err_no_type	equ	20
err_bad_name	equ	21
err_close	equ	22
err_fat		equ	23
err_record_num	equ	24
err_no_sector	equ	25
err_locked	equ	29
err_no_fit	equ	30
err_read_data	equ	31
err_on_arg	equ	32
err_channel	equ	40
err_alrdy_open	equ	41
err_open_mode	equ	42
err_not_opened	equ	43
err_file_state	equ	44
err_field_size	equ	45
err_no_dir	equ	49
err_bad_inst	equ	50
err_illegal_chr	equ	51
err_syntax	equ	52
err_line_end	equ	53
err_line_num	equ	54
err_bracket_bal	equ	55
err_func_ref	equ	56
err_then_no_if	equ	58
err_no_line	equ	60
err_return	equ	61
err_for_next	equ	62
err_continue	equ	63
err_no_source	equ	64
err_bad_file	equ	65
err_resume	equ	66
err_digits_arg	equ	67
err_bad_arg	equ	68
err_bad_bmp	equ	69
err_pu_type	equ	70
err_pu_format	equ	71
err_arg_type	equ	72
err_exp		equ	73
err_ubyte_out	equ	74
err_neg_arg	equ	75
err_var_type	equ	76
err_dim_out	equ	77
err_no_dim	equ	78
err_swap_arg	equ	79
err_memory_ovf	equ	80
err_dim_ovf	equ	81
err_prog_ovf	equ	82
err_str_len	equ	83
err_too_arg	equ	84
err_exec_empty	equ	85
err_exec_str	equ	86
err_dim_resize	equ	88
err_del_ref_lin	equ	89
err_usr_no_def	equ	90
err_not_virtual	equ	92
err_sub		equ	93
err_bad_len	equ	94
err_local	equ	95
err_virtual_clr	equ	96
err_seek	equ	97
err_clr_arg	equ	98
err_call_type	equ	99
err_too_complex	equ	100
err_float_ovf	equ	101
err_arg_ovf	equ	102
err_zero_div	equ	103
err_int_conv	equ	104
err_log_arg	equ	105
err_input_int	equ	106
err_sqrt_arg	equ	107
err_conv	equ	108
err_int_ovf	equ	109
err_color_num	equ	110
err_port_num	equ	111
err_paddle	equ	112
err_edit_empty	equ	114
err_edit_line	equ	115
err_rdef_label	equ	116
err_fatal	equ	128

;Descripteur fichier
fcb		struc
fcb_handle	dd	?		;handle systeme
fcb_opntyp	db	?		;type ouverture
fcb_fcolm	db	?		;compteur colonnes
fcb_fill	db	2 dup (?)
fcb_posrec	dd	?		;position tampon/numero enregistrement
fcb_cntlen	dd	?		;reste tampon/longueur enregistrement
fcb_bufadr	dd	?		;adresse tampon
fcb_locklow	dd	?		;debut verou bas
fcb_lockhigh	dd	?		;debut verou haut
fcb		ends
;Type ouverture fichier
opn_apd		equ	0		;ouvert en append
opn_r		equ	1		;ouvert en lecture
opn_w		equ	2		;ouvert en ecriture
opn_rw		equ	3		;ouvert en lecture/ecriture
opn_lib		equ	4		;ouvert en librairie
opn_fld		equ	10000000b	;indicateur FIELD

;Chaine memoire libre
free_mem	struc
link		dd	?		;chainage entete
len		dd	?		;taille bloc memoire
free_mem	ends

;Entete symbole
symb		struc
s_type		db	?		;type symbole (bit 7 a 1)
s_addr		dd	?		;adresse symbole
symb		ends
;le symbole suit en ascii jusqu'au type suivant

;Operande
opnd		struc
o_type		db	?		;type operande
o_fill		db	3 dup (?)
o_value		db	8 dup (?)	;valeur entiere ou flottante
opnd		ends

;Chaine
strg		struc
str_addr	dd	?		;adresse chaine
str_len		dd	?		;longueur chaine
strg		ends

;Tableau
array		struc
a_addr		dd	?		;adresse donnees
a_dim		db	?		;nombre dimensions
a_virt		db	?		;tableau virtuel
a_fill		db	2 dup (?)
array		ends

;Tableau virtuel
vrta		struc
va_type		db	?		;type
va_chan		db	?		;canal
va_fill		db	2 dup (?)
va_size		dd	?		;taille element
vrta		ends

;Espace execution
exc		struc
ex_addr		dd	?		;addresse donnee
ex_len		dd	?		;longueur donnee
exc		ends

;Entete ligne
line		struc
l_len		db	?
l_number	dd	?
line		ends

;Entree RETURN
rete		struc
r_mark		db	?		;marque RETURN
r_count		db	?		;compteur
r_flags		db	?		;indicateurs
r_fill		db	?
r_curpc		dd	?		;pointeur ligne courante
r_nextpc	dd	?		;pointeur ligne suivante
r_ebp		dd	?		;pointeur code retour
rete		ends

;Entree parametre
para		struc
p_type		db	?		;type parametre
p_fill		db	3 dup (?)
p_addr		dd	?		;adresse parametre
p_symb		dd	?		;adresse symbole
para		ends

;Entree FOR
fore		struc
f_mark		db	?		;marque FOR
f_type		db	?		;type variable
f_fill		db	2 dup (?)
f_var		dd	?		;offset variable
f_curpc		dd	?		;pointeur ligne courante
f_nextpc	dd	?		;pointeur ligne suivante
f_ebp		dd	?		;pointeur code
f_step		db	8 dup (?)	;pas
f_value		db	8 dup (?)	;valeur courante
fore		ends

;CALL argument
calla		struc
ca_type		db	?		;type argument
ca_fill		db	3 dup (?)
ca_addr		dd	?		;adresse argument
ca_symb		dd	?		;adresse symbole
calla		ends

;Arguments fonctions graphique
axy		struc
xx		dd	?		;abscisse
yy		dd	?		;ordonnee
axy		ends

aplot		struc
xx1		dd	?		;abscisse debut
yy1		dd	?		;ordonnee debut
xx2		dd	?		;abscisse fin
yy2		dd	?		;ordonnee fin
aplot		ends

awin		struc
xleft		dd	?		;abscisse bas gauche
ydown		dd	?		;ordonnee bas gauche
xright		dd	?		;abscisse haut droit
yup		dd	?		;ordonnee haut droit
typ		dd	?		;type affichage
awin		ends

atxt		struc
lup		dd	?		;ligne superieure
cleft		dd	?		;colonne gauche
ldown		dd	?		;ligne inferieure
cright		dd	?		;colonne droite
atxt		ends

afill		struc
xx		dd	?		;abscisse
yy		dd	?		;ordonnee
col		db	?		;couleur remplissage
afill		ends

amask		struc
r		db	?		;composante rouge
g		db	?		;composante verte
b		db	?		;composante bleue
amask		ends

acol		struc
col		db	?		;couleur
r		db	?		;composante rouge
g		db	?		;composante verte
b		db	?		;composante bleue
acol		ends

asymb		struc
xx		dd	?		;abscisse origine
yy		dd	?		;ordonnee origine
w		db	?		;largeur caractere
h		db	?		;hauteur caractere
dir		db	?		;direction
fill		db	?
adr		dd	?		;adresse chaine
len		dd	?		;longueur chaine
asymb		ends

acirc		struc
xxc		dd	?		;abscisse centre
yyc		dd	?		;ordonnee centre
angle		dd	?		;angle
xxs		dd	?		;abscisse depart
yys		dd	?		;ordonnee depart
factor		dd	?		;facteur de forme
acirc		ends

adraw		struc
xx		dd	?		;abscisse origine
yy		dd	?		;ordonnee origine
adr		dd	?		;adresse chaine
len		dd	?		;longueur chaine
dir		db	?		;direction
adraw		ends

aget		struc
xleft		dd	?		;abscisse bas gauche
ydown		dd	?		;ordonnee bas gauche
xright		dd	?		;abscisse haut droit
yup		dd	?		;ordonnee haut droit
adr		dd	?		;adresse chaine
len		dd	?		;longueur chaine
aget		ends

aput		struc
xx		dd	?		;abscisse haut gauche
yy		dd	?		;ordonnee haut gauche
adr		dd	?		;adresse chaine
len		dd	?		;longueur chaine
mode		dd	?		;mode traitement fond
xleft		dd	?		;abscisse bas gauche dans bitmap
ydown		dd	?		;ordonnee bas gauche dans bitmap
xright		dd	?		;abscisse haut droit dans bitmap
yup		dd	?		;ordonnee haut droit dans bitmap
aput		ends

;Entier (32 bits)
long		struc
l_b0		db	?		;octet poids faible
l_b1		db	?
l_b2		db	?
l_b3		db	?		;octet poids fort
long		ends

;Nombre double precision (64 bits)
large		struc
l_low		dd	?		;dword bas
l_high		dd	?		;dword haut
large		ends

;Nombre flottant (64 bits)
flt		struc
f_low		db	6 dup (?)	;6 octets (48 bits de poids faible mantisse)
f_high		dw	?		;2 octets (1 bit signe, 11 bits exposant, 4 bits de poids fort mantisse)
flt		ends

;Programme vide
prog		struc
;Premiere ligne
line_zero	db	?		;longueur entete programme (ligne zero)
		dd	?		;zero (numero de ligne)
return_code	db	?		;token RETURN
end_of_line	db	?		;token fin de ligne
seg_name	db	8 dup(?)	;nom segment
prog_type	db	?		;type binaire
prog_len	dd	?		;longueur code
prog_line	dd	?		;nombre de lignes
sym_len		dd	?		;taille table des symboles
sym_count	dd	?		;nombre de symboles
first_line	dd	?		;numero premiere ligne
last_line	dd	?		;numero derniere ligne
;Dernier ligne (et debut programme)
begin_prog	db	?		;longueur derniere ligne
		dd	?		;numero derniere ligne
		db	?		;bcode of END statement
prog		ends
prog_head	equ	prog.begin_prog-prog.line_zero
last_len	equ	size prog-prog_head


;Macro saut espace(s) et token
skipst	macro
	local	l1,l2,l3,l4
l1:
	jmp	short l4
l2:
	je	short l3		;espace simple
	inc	ebp			;saut compte espaces
l3:
	inc	ebp			;saut token espace
l4:
	mov	al,[ebp]		;token courant
	cmp	al,k_space		;espace ou espaces multiples ?
	jge	l2			;oui
	endm

;Macro initialisation evaluation expression
initexp	macro
	mov	tmpptr,offset tmps	;initialise pointeur temporaires
	mov	atos,offset astack	;sommet pile arithmetique
	mov	strtos,offset strstk	;sommet pile chaines
	mov	strstk.strg.str_addr,0 ;marque fin de chaine
	mov	strflg,0		;raz indicateur expression chaine
	mov	vrtflg,0		;raz indicateur tableau virtuel
	endm

	.data
	extrn	pathbuf:byte
	extrn	widthx:dword
	extrn	maxnref:dword
	extrn	maxlref:dword
	extrn	sigcnt:byte
	extrn	sigcn2:byte
	extrn	sigcnx:byte
	extrn	r0:byte
	extrn	r0h:word
	extrn	r0i:dword
	extrn	r1:byte
	extrn	intflg:byte
	extrn	format:byte
	extrn	ftoaerr:byte
	extrn	puleft:byte
	extrn	puright:byte
	extrn	len:dword
	extrn	inptr:dword
	extrn	outbuf:byte
	extrn	stbeg:dword
	extrn	stend:dword
	extrn	tmpptr:dword
	extrn	arg_c:dword
	extrn	arg_v:dword
	extrn	prog_base:dword
	extrn	data_base:dword
	extrn	symb_base:dword
	extrn	lcode:dword
	extrn	lsymb:dword
	extrn	penx:dword
	extrn	peny:dword
	extrn	colm:byte
	extrn	oport:dword
	extrn	iport:dword
	extrn	initsp:dword
	extrn	execsp:dword
	extrn	tcx:word
	extrn	tdx:word
	extrn	count:byte
	extrn	clrflg:byte
	extrn	labflg:byte
	extrn	lineflg:byte
	extrn	contflg:byte
	extrn	pbinflg:byte
	extrn	inflg:byte
	extrn	first:dword
	extrn	lastx:dword
	extrn	fstavl:dword
	extrn	vartyp:byte
	extrn	nxtnam:dword
	extrn	linptr:dword
	extrn	prvlin:dword
	extrn	symoff:dword
	extrn	nextpc:dword
	extrn	curpc:dword
	extrn	savebp:dword
	extrn	prog_size:dword
	extrn	atos:dword
	extrn	asnadr:dword
	extrn	asntype:byte
	extrn	dirflg:byte
	extrn	runline:dword
	extrn	arayptr:dword
	extrn	bckcnt:byte
	extrn	strtos:dword
	extrn	strflg:byte
	extrn	ssptr:dword
	extrn	strsptr:dword
	extrn	oldstr:word
	extrn	excchn:dword
	extrn	offst:dword
	extrn	datapt:dword
	extrn	dataln:dword
	extrn	contcur:dword
	extrn	contnxt:dword
	extrn	contebp:dword
	extrn	ergol:dword
	extrn	errs:dword
	extrn	erls:dword
	extrn	onerflg:byte
	extrn	fcbin:dword
	extrn	fcbout:dword
	extrn	fcbdir:dword
	extrn	fldptr:dword
	extrn	fldend:dword
	extrn	sschn:dword
	extrn	virtchn:byte
	extrn	vrtasn:byte
	extrn	vrtrec:dword
	extrn	vrtflg:byte
	extrn	prtflg:byte
	extrn	asnflg:byte
	extrn	filswo:byte
	extrn	filswi:byte
	extrn	data_end:dword
	extrn	symb_size:dword
	extrn	incnum:dword
	extrn	startnum:dword
	extrn	cmpopt:byte
	extrn	sortflg:byte
	extrn	tokflg:byte
	extrn	noedf:byte
	extrn	stepflg:byte
	extrn	trcflg:byte
	extrn	breakflg:byte
	extrn	listcolflg:byte
	extrn	intmask:byte
	extrn	intflags:byte
	extrn	inttbl:dword
	extrn	filtab:dword
	extrn	vatab:dword
	extrn	buffer:byte
	extrn	linlen:byte
	extrn	linum:dword
	extrn	linbuf:byte
	extrn	tmps:byte
	extrn	astack:byte
	extrn	strstk:dword
