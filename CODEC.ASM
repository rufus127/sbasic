	page	,132
	name	codec

	public	decode
	public	encode
	public	encode1
	public	getok
	public	synerr
	public	skipsps
	public	clsch
	public	searchk
	public	putsym
	public	variab

	.model	flat,c

	include sbasic.inc

	.data
;Variables codage/decodage
inst		dd	?		;pointeur debut ligne analyse
inls		dd	?		;pointeur dernier caractere analyse
token		db	?		;sauvegarde token
stlen		db	?		;longueur chaine
listcol		db	?		;couleur affichage

	.code
	extrn	outch:near
	extrn	intger:near
	extrn	atof:near
	extrn	atoii:near
	extrn	outdc:near
	extrn	pcrlf:near
	extrn	rpter:near
	extrn	TextCols:dword

; Chaines
s_bad		db	'???',eot
s_goto		db	'GOTO',eot
s_gosub		db	'GOSUB',eot
s_resume	db	'RESUME',eot
s_digits	db	'DIGITS',eot
s_rem		db	'REM',eot
s_let		db	'LET',eot
s_print		db	'PRINT',eot
s_input		db	'INPUT',eot
s_execute	db	'EXECUTE',eot
s_swpap		db	'SWAP',eot
s_for		db	'FOR',eot
s_poke		db	'POKE',eot
s_lprint	db	'LPRINT',eot
s_next		db	'NEXT',eot
s_read		db	'READ',eot
s_return	db	'RETURN',eot
s_if		db	'IF',eot
s_dim		db	'DIM',eot
s_on		db	'ON',eot
s_set		db	'SET',eot
s_end		db	'END',eot
s_stop		db	'STOP',eot
s_data		db	'DATA',eot
s_restore	db	'RESTORE',eot
s_call		db	'CALL',eot
s_open		db	'OPEN',eot
s_close		db	'CLOSE',eot
s_chain		db	'CHAIN',eot
s_kill		db	'KILL',eot
s_rename	db	'RENAME',eot
s_get		db	'GET',eot
s_put		db	'PUT',eot
s_field		db	'FIELD',eot
s_lset		db	'LSET',eot
s_rset		db	'RSET',eot
s_exec		db	'EXEC',eot
s_dpoke		db	'DPOKE',eot
s_sub		db	'SUB',eot
s_label		db	'LABEL',eot
s_recore	db	'RECORD',eot
s_old		db	'OLD',eot
s_new		db	'NEW',eot
s_as		db	'AS',eot
s_using		db	'USING',eot
s_error		db	'ERROR',eot
s_line		db	'LINE',eot
s_then		db	'THEN',eot
s_else		db	'ELSE',eot
s_to		db	'TO',eot
s_step		db	'STEP',eot
s_point		db	'POINT',eot
s_abs		db	'ABS',eot
s_atn		db	'ATN',eot
s_cos		db	'COS',eot
s_exp		db	'EXP',eot
s_int		db	'INT',eot
s_log		db	'LOG',eot
s_rnd		db	'RND',eot
s_sgn		db	'SGN',eot
s_sin		db	'SIN',eot
s_sqr		db	'SQR',eot
s_tan		db	'TAN',eot
s_pos		db	'POS',eot
s_peek		db	'PEEK',eot
s_usr		db	'USR',eot
s_fre		db	'FRE',eot
s_dpeek		db	'DPEEK',eot
s_pdl		db	'PDL',eot
s_ptr		db	'PTR',eot
s_spc		db	'SPC',eot
s_tab		db	'TAB',eot
s_xpen		db	'XPEN',eot
s_ypen		db	'YPEN',eot
s_pi		db	'PI',eot
s_err		db	'ERR',eot
s_erl		db	'ERL',eot
s_asc		db	'ASC',eot
s_len		db	'LEN',eot
s_val		db	'VAL',eot
s_hex		db	'HEX',eot
s_instr		db	'INSTR',eot
s_cvt$p		db	'CVT$%',eot
s_cvt$f		db	'CVT$F',eot
s_date$		db	'DATE$',eot
s_chr$		db	'CHR$',eot
s_left$		db	'LEFT$',eot
s_right$	db	'RIGHT$',eot
s_mid$		db	'MID$',eot
s_str$		db	'STR$',eot
s_inch$		db	'INCH$',eot
s_cvtp$		db	'CVT%$',eot
s_cvtf$		db	'CVTF$',eot
s_ltrim$	db	'LTRIM$',eot
s_rtrim$	db	'RTRIM$',eot
s_string$	db	'STRING$',eot
s_not		db	'NOT',eot
s_and		db	'AND',eot
s_or		db	'OR',eot
s_le		db	'<=',eot
s_ge		db	'>=',eot
s_dif		db	'<>',eot
s_lt		db	'<',eot
s_gt		db	'>',eot
s_eq		db	'=',eot
s_power		db	'^',eot
s_div		db	'/',eot
s_mul		db	'*',eot
s_plus		db	'+',eot
s_minus		db	'-',eot
s_exclamation	db	'!',eot
s_ampersand	db	'&',eot
s_comma		db	',',eot
s_semicolon	db	';',eot
s_lbracket	db	'(',eot
s_rbracket	db	')',eot
s_hashtag	db	'#',eot
s_mod		db	'MOD',eot
s_append	db	'APPEND',eot
s_library	db	'LIBRARY',eot
s_colon		db	':',eot
s_gr		db	'GR',eot
s_text		db	'TEXT',eot
s_color		db	'COLOR',eot
s_hgr		db	'HGR',eot
s_play		db	'PLAY',eot
s_setcolor	db	'SETCOLOR',eot
s_setblink	db	'SETBLINK',eot
s_plot		db	'PLOT',eot
s_port		db	'PORT',eot
s_clear		db	'CLEAR',eot
s_tron		db	'TRON',eot
s_troff		db	'TROFF',eot
s_cursor	db	'CURSOR',eot
s_delete	db	'DELETE',eot
s_overlay	db	'OVERLAY',eot
s_load		db	'LOAD',eot
s_bload		db	'BLOAD',eot
s_local		db	'LOCAL',eot
s_clrg		db	'CLRG',eot
s_move		db	'MOVE',eot
s_dash		db	'DASH',eot
s_symbol	db	'SYMBOL',eot
s_arc		db	'ARC',eot
s_fill		db	'FILL',eot
s_draw		db	'DRAW',eot
s_mask		db	'MASK',eot
s_window	db	'WINDOW',eot
s_pen		db	'PEN',eot
s_compile	db	'COMPILE',eot
s_bron		db	'BRON',eot
s_broff		db	'BROFF',eot
s_cls		db	'CLS',eot
s_edit		db	'EDIT',eot
s_reset		db	'RESET',eot
s_exit		db	'EXIT',eot
s_zoom		db	'ZOOM',eot
s_gget		db	'GGET',eot
s_gput		db	'GPUT',eot
s_list		db	'LIST',eot
s_unlock	db	'UNLOCK',eot
s_lock		db	'LOCK',eot
s_time		db	'TIME',eot
s_chd		db	'CHD',eot
s_bsave		db	'BSAVE',eot
s_argc		db	'ARGC',eot
s_argv$		db	'ARGV$',eot

; Tables des mots cles
; Table premiere lettre
	align	16
keytab	dd	key_a
	dd	0			;B
	dd	key_c
	dd	key_d
	dd	key_e
	dd	key_f
	dd	key_g
	dd	key_h
	dd	key_i
	dd	0			;J
	dd	key_k
	dd	key_l
	dd	key_m
	dd	key_n
	dd	key_o
	dd	key_p
	dd	0			;Q
	dd	key_r
	dd	key_s
	dd	key_t
	dd	key_u
	dd	key_v
	dd	0			;W
	dd	key_x
	dd	key_y
	dd	0			;Z
key_a	label	byte
	db	'BS',k_abs+tok_mark
	db	'ND',k_and+tok_mark
	db	'PPEND',k_append+tok_mark
	db	'TN',k_atn+tok_mark
	db	'SC',k_asc+tok_mark	;K_ASC doit être avant K_AS !
	db	'S',k_as+tok_mark
	db	0
key_c	label	byte
	db	'ALL',k_call+tok_mark
	db	'HAIN',k_chain+tok_mark
	db	'HR$',k_chr$+tok_mark
	db	'LOSE',k_close+tok_mark
	db	'OS',k_cos+tok_mark
	db	'VT$%',k_cvt$p+tok_mark
	db	'VT$F',k_cvt$f+tok_mark
	db	'VT%$',k_cvtp$+tok_mark
	db	'VTF$',k_cvtf$+tok_mark
	db	0
key_d	label	byte
	db	'ATA',k_data+tok_mark
	db	'ATE$',k_date$+tok_mark
	db	'IGITS',k_digits+tok_mark
	db	'IM',k_dim+tok_mark
	db	'PEEK',k_dpeek+tok_mark
	db	'POKE',k_dpoke+tok_mark
	db	0
key_e	label	byte
	db	'LSE',k_else+tok_mark
	db	'ND',k_end+tok_mark
	db	'RROR',k_error+tok_mark
	db	'RR',k_err+tok_mark
	db	'RL',k_erl+tok_mark
	db	'XECUTE',k_execute+tok_mark ;K_EXECUTE doit etre avant K_EXEC
	db	'XEC',k_exec+tok_mark
	db	'XP',k_exp+tok_mark
	db	0
key_f	label	byte
	db	'IELD',k_field+tok_mark
	db	'OR',k_for+tok_mark
	db	'RE',k_fre+tok_mark
	db	0
key_g	label	byte
	db	'ET',k_get+tok_mark
	db	'OSUB',k_gosub+tok_mark
	db	'OTO',k_goto+tok_mark
	db	0
key_h	label	byte
	db	'EX',k_hex+tok_mark
	db	0
key_i	label	byte
	db	'F',k_if+tok_mark
	db	'NPUT',k_input+tok_mark
	db	'NCH$',k_inch$+tok_mark
	db	'NSTR',k_instr+tok_mark
	db	'NT',k_int+tok_mark
	db	0
key_k	label	byte
	db	'ILL',k_kill+tok_mark
	db	0
key_l	label	byte
	db	'ABEL',k_label+tok_mark
	db	'EFT$',k_left$+tok_mark
	db	'EN',k_len+tok_mark
	db	'ET',k_let+tok_mark
	db	'IBRARY',k_library+tok_mark
	db	'INE',k_line+tok_mark
	db	'OG',k_log+tok_mark
	db	'PRINT',k_lprint+tok_mark
	db	'SET',k_lset+tok_mark
	db	'TRIM$',k_ltrim$+tok_mark
	db	'TRM$',k_ltrm$+tok_mark
	db	0
key_m	label	byte
	db	'ID$',k_mid$+tok_mark
	db	'OD',k_mod+tok_mark
	db	0
key_n	label	byte
	db	'EXT',k_next+tok_mark
	db	'EW',k_new+tok_mark
	db	'OT',k_not+tok_mark
	db	0
key_o	label	byte
	db	'LD',k_old+tok_mark
	db	'N',k_on+tok_mark
	db	'PEN',k_open+tok_mark
	db	'R',k_or+tok_mark
	db	0
key_p	label	byte
	db	'DL',k_pdl+tok_mark
	db	'EEK',k_peek+tok_mark
	db	'I',k_pi+tok_mark
	db	'OINT',k_point+tok_mark
	db	'OKE',k_poke+tok_mark
	db	'OS',k_pos+tok_mark
	db	'RINT',k_print+tok_mark
	db	'TR',k_ptr+tok_mark
	db	'UT',k_put+tok_mark
	db	0
key_r	label	byte
	db	'EAD',k_read+tok_mark
	db	'ECORD',k_record+tok_mark
	db	'EM',k_rem+tok_mark
	db	'ENAME',k_rename+tok_mark
	db	'ESTORE',k_restore+tok_mark
	db	'ESUME',k_resume+tok_mark
	db	'ETURN',k_return+tok_mark
	db	'IGHT$',k_right$+tok_mark
	db	'ND',k_rnd+tok_mark
	db	'SET',k_rset+tok_mark
	db	'TRIM$',k_rtrim$+tok_mark
	db	'TRM$',k_rtrm$+tok_mark
	db	0
key_s	label	byte
	db	'ET',k_set+tok_mark
	db	'GN',k_sgn+tok_mark
	db	'IN',k_sin+tok_mark
	db	'PC',k_spc+tok_mark
	db	'QR',k_sqr+tok_mark
	db	'TEP',k_step+tok_mark
	db	'TOP',k_stop+tok_mark
	db	'TR$',k_str$+tok_mark
	db	'TRING$',k_string$+tok_mark
	db	'UB',k_sub+tok_mark
	db	'WAP',k_swap+tok_mark
	db	0
key_t	label	byte
	db	'AB',k_tab+tok_mark
	db	'AN',k_tan+tok_mark
	db	'HEN',k_then+tok_mark
	db	'O',k_to+tok_mark
	db	0
key_u	label	byte
	db	'SING',k_using+tok_mark
	db	'SR',k_usr+tok_mark
	db	0
key_v	label	byte
	db	'AL',k_val+tok_mark
	db	0
key_x	label	byte
	db	'PEN',k_xpen+tok_mark
	db	0
key_y	label	byte
	db	'PEN',k_ypen+tok_mark
	db	0

; Table des mots cles etendus
; Table premiere lettre
	align	16
extkey	dd	ext_a
	dd	ext_b
	dd	ext_c
	dd	ext_d
	dd	ext_e
	dd	ext_f
	dd	ext_g
	dd	ext_h
	dd	0
	dd	0
	dd	0
	dd	ext_l
	dd	ext_m
	dd	0
	dd	ext_o
	dd	ext_p
	dd	0
	dd	ext_r
	dd	ext_s
	dd	ext_t
	dd	ext_u
	dd	0
	dd	ext_w
	dd	0
	dd	0
	dd	ext_z
ext_a	label	byte
	db	'RC',k_arc+tok_mark
	db	'RGC',k_argc+tok_mark
	db	'RGV$',k_argv$+tok_mark
	db	0
ext_b	label	byte
	db	'LOAD',k_bload+tok_mark
	db	'ROFF',k_broff+tok_mark
	db	'RON',k_bron+tok_mark
	db	'SAVE',k_bsave+tok_mark
	db	0
ext_c	label	byte
	db	'HD',k_chd+tok_mark
	db	'LEAR',k_clear+tok_mark
	db	'LRG',k_clrg+tok_mark
	db	'LS',k_cls+tok_mark
	db	'OLOR',k_color+tok_mark
	db	'OMPILE',k_compile+tok_mark
	db	'URSOR',k_cursor+tok_mark
	db	0
ext_d	label	byte
	db	'ASH',k_dash+tok_mark
	db	'ELETE',k_delete+tok_mark
	db	'RAW',k_draw+tok_mark
	db	0
ext_e	label	byte
	db	'DIT',k_edit+tok_mark
	db	'XIT',k_exit+tok_mark
	db	0
ext_f	label	byte
	db	'ILL',k_fill+tok_mark
	db	0
ext_g	label	byte
	db	'GET',k_gget+tok_mark
	db	'PUT',k_gput+tok_mark
	db	'R',k_gr+tok_mark
	db	0
ext_h	label	byte
	db	'GR',k_hgr+tok_mark
	db	0
ext_l	label	byte
	db	'IST',k_list+tok_mark
	db	'OAD',k_load+tok_mark
	db	'OCAL',k_local+tok_mark
	db	'OCK',k_lock+tok_mark
	db	0
ext_m	label	byte
	db	'ASK',k_mask+tok_mark
	db	'OVE',k_move+tok_mark
	db	0
ext_o	label	byte
	db	'VERLAY',k_overlay+tok_mark
	db	0
ext_p	label	byte
	db	'EN',k_pen+tok_mark
	db	'LAY',k_play+tok_mark
	db	'LOT',k_plot+tok_mark
	db	'ORT',k_port+tok_mark
	db	0
ext_r	label	byte
	db	'ESET',k_reset+tok_mark
	db	0
ext_s	label	byte
	db	'ETBLINK',k_setblink+tok_mark
	db	'ETCOLOR',k_setcolor+tok_mark
	db	'YMBOL',k_symbol+tok_mark
	db	0
ext_t	label	byte
	db	'EXT',k_text+tok_mark
	db	'IME',k_time+tok_mark
	db	'ROFF',k_troff+tok_mark
	db	'RON',k_tron+tok_mark
	db	0
ext_u	label	byte
	db	'NLOCK',k_unlock+tok_mark
	db	0
ext_w	label	byte
	db	'INDOW',k_window+tok_mark
	db	0
ext_z	label	byte
	db	'OOM',k_zoom+tok_mark
	db	0

; Table des caracteres operateurs
chrtab	label	byte
	db	':',k_colon+tok_mark
	db	cr,k_cr+tok_mark
	db	' ',k_space+tok_mark
	db	'^',k_power+tok_mark
	db	'/',k_div+tok_mark
	db	'**',k_power+tok_mark
	db	'*',k_mul+tok_mark
	db	'+',k_plus+tok_mark
	db	'-',k_minus+tok_mark
	db	'!',k_exclamation+tok_mark
	db	'&',k_ampersand+tok_mark
	db	',',k_comma+tok_mark
	db	';',k_semicolon+tok_mark
	db	'(',k_lbracket+tok_mark
	db	')',k_rbracket+tok_mark
	db	'#',k_hashtag+tok_mark
	db	'?',k_print+tok_mark
eqctab	label	byte
	db	'=',k_eq+tok_mark
	db	'<>',k_dif+tok_mark
	db	'<=',k_le+tok_mark
	db	'<',k_lt+tok_mark
	db	'>=',k_ge+tok_mark
	db	'>',k_gt+tok_mark
	db	0

; Table des chaines mots cles
	align	16
keystr	dd	s_bad			;0
	dd	s_goto			;1
	dd	s_gosub			;2
	dd	s_resume		;3
	dd	s_digits		;4
	dd	s_rem			;5
	dd	s_let			;6
	dd	s_print			;7
	dd	s_input			;8
	dd	s_execute		;9
	dd	s_swpap			;10
	dd	s_for			;11
	dd	s_poke			;12
	dd	s_lprint		;13
	dd	s_next			;14
	dd	s_read			;15
	dd	s_return		;16
	dd	s_if			;17
	dd	s_dim			;18
	dd	s_on			;19
	dd	s_set			;20
	dd	s_end			;21
	dd	s_stop			;22
	dd	s_data			;23
	dd	s_restore		;24
	dd	s_call			;25
	dd	s_open			;26
	dd	s_close			;27
	dd	s_chain			;28
	dd	s_kill			;29
	dd	s_rename		;30
	dd	s_get			;31
	dd	s_put			;32
	dd	s_field			;33
	dd	s_lset			;34
	dd	s_rset			;35
	dd	s_exec			;36
	dd	s_dpoke			;37
	dd	s_bad			;38
	dd	s_sub			;39
	dd	s_label			;40
	dd	s_recore		;41
	dd	s_old			;42
	dd	s_new			;43
	dd	s_as			;44
	dd	s_using			;45
	dd	s_error			;46
	dd	s_line			;47
	dd	s_then			;48
	dd	s_else			;49
	dd	s_to			;50
	dd	s_step			;51
	dd	s_point			;52
	dd	s_abs			;53
	dd	s_atn			;54
	dd	s_cos			;55
	dd	s_exp			;56
	dd	s_int			;57
	dd	s_log			;58
	dd	s_rnd			;59
	dd	s_sgn			;60
	dd	s_sin			;61
	dd	s_sqr			;62
	dd	s_tan			;63
	dd	s_pos			;64
	dd	s_peek			;65
	dd	s_usr			;66
	dd	s_fre			;67
	dd	s_dpeek			;68
	dd	s_pdl			;69
	dd	s_ptr			;70
	dd	s_spc			;71
	dd	s_tab			;72
	dd	s_xpen			;73
	dd	s_ypen			;74
	dd	s_pi			;75
	dd	s_err			;76
	dd	s_erl			;77
	dd	s_asc			;78
	dd	s_len			;79
	dd	s_val			;80
	dd	s_hex			;81
	dd	s_instr			;82
	dd	s_cvt$p			;83
	dd	s_cvt$f			;84
	dd	s_date$			;85
	dd	s_chr$			;86
	dd	s_left$			;87
	dd	s_right$		;88
	dd	s_mid$			;89
	dd	s_str$			;90
	dd	s_inch$			;91
	dd	s_cvtp$			;92
	dd	s_cvtf$			;93
	dd	s_rtrim$		;94
	dd	s_ltrim$		;95
	dd	s_string$		;96
	dd	s_not			;97
	dd	s_and			;98
	dd	s_or			;99
	dd	s_le			;100
	dd	s_ge			;101
	dd	s_dif			;102
	dd	s_lt			;103
	dd	s_gt			;104
	dd	s_eq			;105
	dd	s_bad			;106
	dd	s_power			;107
	dd	s_div			;108
	dd	s_mul			;109
	dd	s_plus			;110
	dd	s_minus			;111
	dd	s_exclamation		;112
	dd	s_ampersand		;113
	dd	s_comma			;114
	dd	s_semicolon		;115
	dd	s_lbracket		;116
	dd	s_rbracket		;117
	dd	s_hashtag		;118
	dd	s_mod			;119
	dd	s_append		;120
	dd	s_library		;121
	dd	s_bad			;122
	dd	s_colon			;123
	dd	s_bad			;124

; Table des chaines mots cles etendus
extstr	dd	s_bad			;0
	dd	s_gr			;1
	dd	s_text			;2
	dd	s_color			;3
	dd	s_hgr			;4
	dd	s_play			;5
	dd	s_setcolor		;6
	dd	s_setblink		;7
	dd	s_plot			;8
	dd	s_port			;9
	dd	s_clear			;10
	dd	s_tron			;11
	dd	s_troff			;12
	dd	s_cursor		;13
	dd	s_delete		;14
	dd	s_overlay		;15
	dd	s_load			;16
	dd	s_bload			;17
	dd	s_local			;18
	dd	s_clrg			;19
	dd	s_move			;20
	dd	s_dash			;21
	dd	s_symbol		;22
	dd	s_arc			;23
	dd	s_fill			;24
	dd	s_draw			;25
	dd	s_mask			;26
	dd	s_window		;27
	dd	s_pen			;28
	dd	s_compile		;29
	dd	s_bron			;30
	dd	s_broff			;31
	dd	s_cls			;32
	dd	s_edit			;33
	dd	s_reset			;34
	dd	s_exit			;35
	dd	s_zoom			;36
	dd	s_gget			;37
	dd	s_gput			;38
	dd	s_list			;39
	dd	s_unlock		;40
	dd	s_lock			;41
	dd	s_time			;42
	dd	s_chd			;43
	dd	s_bsave			;44
	dd	s_argc			;45
	dd	s_argv$			;46

; Decodage ligne
; Entree: EBX->ligne en token a decoder
;	  EAX=numero de ligne
;	  ECX=nombre minimum de caracteres pour affichage numero de ligne
;	  LISTCOLFLG=indicateur affichage couleur
;	  ligne decodee dans BUFFER 
	align	16
decode:
	mov	edi,offset buffer	;tampon de sortie
	push	eax
	mov	listcol,0		;raz couleur affichage
	mov	al,col_none		;pas de couleur
	call	setlistcol		;positionnement couleur
	pop	eax
	test	eax,eax			;numero de ligne a zero ?
	jz	short decode1		;oui, pas d'affichage
	mov	linum,eax		;range
	call	outdc			;affichage numero de ligne
	mov	al,' '
	stosb				;affiche espace
decode1:
	mov	ah,[ebx]		;token
	inc	ebx
	cmp	ah,k_cr			;fin de ligne ?
	je	short decode35		;oui
	ja	decode9			;constante, variable ou espace(s)
; Mot cle
	cmp	ah,k_indirect		;mot cle etendu ?
	je	short decode6
	cmp	ah,k_le			;symbole ?
	mov	al,col_key		;couleur mot cle
	jb	short decode2		;oui
	cmp	ah,k_mod
	jb	short decode25		;non
	cmp	ah,k_colon
	jne	short decode2		;oui
decode25:
	mov	al,col_none		;pas de couleur
decode2:
	call	setlistcol		;positionnement couleur
	movzx	eax,ah
	mov	esi,keystr[eax*4]	;pointeur chaine mot cle
	mov	ah,al
decode3:
	lodsb				;caractere
	cmp	al,eot			;fin de chaine ?
	je	short decode4		;oui
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	short decode35		;oui
	stosb				;copie
	jmp	decode3			;tant que necessaire
decode35:
	jmp	decodeot		;fin decodage
decode4:
	cmp	ah,k_rem		;REM ?
	mov	al,col_rem		;couleur commentaire
	je	short decode5		;oui
	cmp	ah,k_data		;DATA ?
	mov	al,col_none		;pas de couleur
	jne	decode1			;non, token suivant
decode5:
	jmp	decodest		;affichage fin de ligne
decode6:
	mov	ah,[ebx]		;token suivant
	inc	ebx
	cmp	ah,k_argv$		;valide ?
	ja	short decode8		;non
	mov	al,col_key		;couleur mot cle
	call	setlistcol		;positionnement couleur
	movzx	eax,ah
	mov	esi,extstr[eax*4]	;pointeur chaine mot cle etendu
decode7:
	lodsb				;caractere
	cmp	al,eot			;fin de chaine ?
	je	decode1			;oui, token suivant
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	decode35		;oui
	stosb				;copie
	jmp	decode7			;tant que necessaire
decode8:
	mov	esi,offset s_bad	;invalide
	jmp	decode7
decode9:
	test	ah,ah			;constante ou variable ?
	js	short decodevar		;oui
; Espace(s)
	cmp	ah,k_mspace		;espaces multiples ?
	mov	al,' '			;espace
	je	short decode11		;oui
	mov	ecx,1
decode10:
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	decode35		;oui
	stosb				;affiche caractere
	loop	decode10
	jmp	decode1			;token suivant
decode11:
	movzx	ecx,byte ptr [ebx]	;compte espaces
	inc	ebx
	jmp	decode10
decodevar:
	test	ah,conbit		;constante ?
	jnz	short decodecn		;oui
; Variable
	mov	al,col_var		;couleur variable
	call	setlistcol		;positionnement couleur
	push	eax
	mov	esi,symb_base		;table symboles
	add	esi,dword ptr [ebx]	;ajout offset symbole
	add	ebx,size_o		;saut offset symbole
	add	esi,size_a		;saut adresse
decodevar1:
	lodsb				;caractere nom
	test	al,al			;type symbole suivant ?
	js	short decodevar2	;oui
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	short decodevar5	;oui
	stosb				;affiche caractere
	jmp	decodevar1		;continue pour tout le nom
decodevar2:
	pop	eax
	test	ah,strbit		;variable chaine ?
	mov	al,'$'
	jnz	decodevar4		;oui, affiche $
	test	ah,intbit		;variable entiere ?
	mov	al,'%'
	jnz	decodevar4		;oui, affiche %
	test	ah,labbit		;etiquette ?
	jz	short decodevar3	;non
	add	ebx,size_o		;saut offset
decodevar3:
	jmp	decode1			;token suivant
decodevar4:
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	decode35		;oui
	stosb				;affiche caractere
	jmp	decode1			;token suivant
decodevar5:
	jmp	short decodeot		;fin decodage
decodecn:
; Constante
	test	ah,strbit		;constante chaine ?
	mov	al,col_str		;couleur chaine
	jnz	short decodecn2		;oui
	test	ah,linbit		;numero de ligne ?
	mov	al,col_none		;pas de couleur
	jnz	short decodeln		;oui
	test	ah,intbit		;constante entiere ?
	jnz	short decodecn1
	add	ebx,size_f-size_i	;saute valeur flottante
decodecn1:
	add	ebx,size_i-1		;saute valeur entiere
decodecn2:
	inc	ebx			;saute longueur chaine
decodest:
	movzx	ecx,byte ptr [ebx]	;longueur representation
	inc	ebx
	jecxz	decodest3		;vide
	call	setlistcol		;positionnement couleur
decodest1:
	mov	al,[ebx]		;caractere representation
	inc	ebx
	cmp	al,' '			;affichable ?
	jb	short decodest2		;non
	cmp	edi,offset buffer+maxbuf-3 ;debordement tampon de sortie ?
	jae	short decodeot		;oui
	stosb				;affiche caractere
decodest2:
	loop	decodest1		;pour toute la longueur
decodest3:
	jmp	decode1			;token suivant
decodeln:
; Numero de ligne
	call	setlistcol		;positionnement couleur
	mov	eax,[ebx]		;numero de ligne
	add	ebx,size_i+size_a	;saute numero de ligne + adresse ligne
	cmp	edi,offset buffer+maxbuf-13 ;risque de debordement tampon de sortie ?
	jae	short decodeot		;oui
	xor	ecx,ecx			;pas de minimum caracteres
	call	outdc			;affichage numero de ligne
	jmp	decode1			;token suivant
decodeot:
; Fin de ligne
	mov	al,col_none		;pas de couleur
	call	setlistcol		;positionnement couleur
	mov	al,eot			;fin de chaine
	stosb				;range
	ret

; Codage ligne
; Entree: INPTR->ligne en ASCII a coder
; Sortie: LINBUF=ligne codee
;	  CHRCNT=longueur ligne codee
;	  B si avant intervalle, A si apres intervalle, Z si dans intervalle
	align	16
encode:
	xor	eax,eax
	mov	linum,eax		;raz numero de ligne
	mov	linlen,al		;raz longueur ligne codee
	mov	labflg,al		;raz indicateur etiquette
	mov	lineflg,al		;raz indicateur numero de ligne
	mov	bckcnt,al		;raz compte parentheses
	mov	eax,inptr		;pointeur caractere tampon entree
	mov	linptr,offset linbuf	;pointeur sortie ligne codee
	mov	inst,eax		;debut de ligne
	mov	inls,eax		;pointeur analyse
	call	getchr			;AH=caractere courant, AL=type
	test	al,al			;separateur ?			
	jz	short encode1		;oui
	dec	al			;lettre ?
	jz	short encode1		;oui
	call	atoii			;conversion entier
	mov	eax,r0i
	cmp	eax,first		;valide ?
	jb	short encode2		;non
	cmp	eax,lastx
	ja	short encode2		;non
	add	eax,offst		;ajout deplacement
	js	short encode5		;debordement numero de ligne
	mov	linum,eax		;range
	jz	short encode5		;nul
	call	getchr			;AH=caractere courant, AL=type
	cmp	ah,' '			;espace ?
	jne	short encode1		;non
	inc	inptr			;mange caractere
encode1:
	mov	tokflg,0		;raz indicateur rangement token
	call	getok			;encode token
	cmp	al,k_colon		;separateur instructions ?
	je	short encode3		;oui
	cmp	al,k_cr			;fin de ligne ?
	jne	encode1			;non
	test	bckcnt,0FFh		;parentheses balancees
	jnz	short encode4		;non, erreur
encode2:
	ret
encode3:
	test	bckcnt,0FFh		;parentheses balancees
	jz	encode1			;oui
encode4:
	mov	al,err_bracket_bal	;parentheses non balancees
	jmp	short encodere
encode5:
	mov	al,err_line_num		;numero de ligne illegal
	jmp	short encodere
encode6:
	mov	al,err_illegal_chr	;caractere illegal
encodere:
	mov	ecx,inls		;pointeur dernier caractere analyse
	sub	ecx,inst		;position erreur
	cmp	ecx,maxbuf		;valide ?
	jae	short encodere8		;non, ignore
	push	eax
	mov	ebx,inst		;debut ligne
encodere1:
	mov	al,[ebx]
	cmp	al,cr			;fin de ligne ?
	je	short encodere3		;oui
	cmp	al,' '			;caractere affichable ?
	jae	short encodere2
	mov	al,' '			;remplace par espace
encodere2:
	call	outch			;affichage caractere
	inc	ebx
	jmp	encodere1
encodere3:
	call	pcrlf			;affichage fin de ligne
encodere4:
	cmp	ecx,TextCols		;plus d'une ligne ecran ?
	jb	encodere5
	sub	ecx,TextCols		;oui, ignore une ligne
	jmp	encodere4
encodere5:
	jecxz	encodere7		;debut de ligne
	mov	al,' '			;positonnement curseur
encodere6:
	call	outch			;affichage espace
	loop	encodere6
encodere7:
	mov	al,'^'			;repere
	call	outch			;affichage caractere
	pop	eax
encodere8:
	jmp	rpter

; Erreur de syntaxe
	align	16
synerr:
	mov	al,err_syntax
	jmp	rpter

; Encode token
; Retour: AL=token
	align	16
getok:
	call	getchr			;AH=caractere courant, AL=type
	inc	inptr			;mange caractere
	test	al,al			;separateur ?
	jz	dosepa			;oui
	dec	al			;lettre ?
	jz	donam			;oui
docon:
; Constante
	dec	inptr			;retour sur premier caractere
	test	lineflg,0FFh		;indicateur numero de ligne ?
	jnz	short docon3		;oui
	call	atof			;encode nombre flottant dans R0
	test	intflg,0FFh		;valeur entiere ?
	mov	ax,(tok_mark+conbit+fltbit)*256+size_f ;flottant par defaut
	jnz	short docon1		;non
	call	intger			;convertion R0 en entier
	mov	ax,(tok_mark+conbit+intbit)*256+size_i ;entier
docon1:
	call	stout			;range token
	mov	ebx,offset r0		;pointeur valeur
docon2:
	mov	ah,[ebx]		;octet valeur
	inc	ebx
	push	ebx
	call	tout			;range octet
	pop	ebx
	dec	al			;tout copie ?
	jnz	docon2			;non, continue
	jmp	copasc			;copie representation
docon3:
	call	atoii			;encode entier
	mov	ah,tok_mark+conbit+linbit ;token numero de ligne
	call	stout			;range token
	mov	eax,r0i			;valeur
	test	eax,eax			;negative ?
	js	encode5			;oui, erreur
	jz	short docon4		;nul, pas d'offset (RESUME 0)
	add	eax,offst		;ajout offset
	test	eax,eax			;debordement ?
	js	encode5			;oui, erreur
	mov	ecx,size_i		;taille entier
	rol	eax,8			;octet dans AH
docon4:
	call	tout			;range octet
	ror	eax,8			;octet suivant
	loop	docon4			;pour un entier
docon5:
	mov	ecx,size_o		;taille offset
	xor	ah,ah			;octet a zero
docon6:
	call	tout			;range octet
	loop	docon6
	mov	al,token		;retour token
	ret
dosepa:
	cmp	ah,','			;, ?
	je	short dochar		;oui
	cmp	ah,' '			;espace ?
	je	short dochar		;oui
	mov	lineflg,0		;raz indicateur numero de ligne
	mov	labflg,0		;raz indicateur etiquette
	cmp	ah,'.'			;virgule de nombre flottant ?
	je	docon			;oui, constante
	cmp	ah,'"'			;" ?
	je	string			;oui, chaine
	cmp	ah,quote		;' ?
	je	string			;oui, chaine
dochar:
	mov	ebx,inptr		;pointeur caractere tampon entree
	dec	ebx
	mov	nxtnam,ebx		;pointe premier caractere
	mov	ebx,offset chrtab	;table de caracteres operateurs 
	call	searchk			;recherche dans table
	jnc	encode6			;non trouve, caractere illegal
	mov	inptr,ebx		;pointeur caractere apres mot cle
	cmp	ah,k_space		;espace ?
	je	short dospace		;oui
dotoken:
	call	stout			;range token
	mov	al,token		;retour token
	ret
dospace:
	mov	stlen,0			;raz compteur
dospace1:
	call	getchr			;AH=caractere courant, AL=type
	cmp	ah,' '			;nouvel espace ?
	jne	short dospace2		;non
	inc	inptr			;mange caractere
	inc	stlen			;un espace de plus
	jmp	dospace1		;continue
dospace2:
	test	stlen,0FFh		;espaces suplementaires ?
	jnz	short dospace3		;oui
	mov	ah,k_space		;token espace
	jmp	dotoken			;range token et retour
dospace3:
	mov	ah,k_mspace		;token espaces multiples
	call	stout			;range token
	mov	ah,stlen
	inc	ah			;nombre d'espaces
dobyte:
	call	tout			;range octet
	mov	al,token		;retour token
	ret
donam:
; Lettre
	mov	ebx,inptr		;pointeur caractere suivant
	mov	nxtnam,ebx		;debut chaine + 1
	mov	cl,ah
	mov	ebx,offset extkey	;recherche mot cle etendue
	call	qsearchk
	jc	doextkey		;mot cle trouve
	mov	ah,cl			;premier caractere
	mov	ebx,offset keytab	;recherche mot cle
	call	qsearchk
	jnc	dovar			;mot cle non trouve, variable
	mov	lineflg,0		;raz indicateur numero de ligne
	mov	labflg,0		;raz indicateur etiquette
	mov	inptr,ebx		;pointeur caractere apres mot cle
	cmp	ah,k_sub		;SUB ?
	je	short setdeflab		;oui
	cmp	ah,k_label		;LABEL ?
	je	short setdeflab		;oui
	cmp	ah,k_call		;CALL ?
	je	short setlablin		;oui
	cmp	ah,k_restore		;RESTORE ?
	je	short setlablin		;oui
	cmp	ah,k_line		;LINE ?
	je	short setlin		;oui
	cmp	ah,k_resume		;GOTO, GOSUB ou RESUME ?
	jbe	short setlablin		;oui
	cmp	ah,k_then		;THEN ?
	je	short setlin		;oui
	cmp	ah,k_else		;ELSE ?
	je	short setlin		;oui
	cmp	ah,k_erl		;ERL ?
	je	short doerl		;oui
	cmp	ah,k_rem		;REM ?
	je	coment			;oui
	cmp	ah,k_data		;DATA ?
	je	coment			;oui
	jmp	dotoken			;range token et retour
setdeflab:
	mov	labflg,-1		;indique definition etiquette
	jmp	dotoken			;range token et retour
setlablin:
	mov	labflg,1		;indique reference etiquette
setlin:
	mov	lineflg,0FFh		;indique ligne
	jmp	dotoken			;range token et retour
doerl:
	call	stout			;range token
	mov	ebx,inptr		;pointeur caractere tampon entree
	call	skipsps			;saut espaces et caractere
	mov	nxtnam,ebx
	mov	ebx,offset eqctab	;caracteres de comparaison ?
	call	searchk			;dans la table ?
	jnc	tout2			;non, retour
	mov	inptr,ebx		;prend en compte les caracteres de comparaison
	jmp	setlin			;indique numero de ligne
doextkey:
; Mot cle etendu
	mov	lineflg,0		;raz indicateur numero de ligne
	mov	labflg,0		;raz indicateur sous programme
	mov	inptr,ebx		;pointeur caractere apres mot cle
	push	eax
	mov	ah,k_indirect		;token extension
	call	stout			;range token
	pop	eax
	jmp	dobyte
dovar:
; Variable
	dec	nxtnam			;pointeur sur premier caractere chaine
variab:
	mov	eax,nxtnam		;premier caractere chaine
	mov	inptr,eax		;maj pointeur caractere
	mov	count,0			;raz compteur caracteres
var1:
	call	getchr			;AH=caractere courant, AL=type
	test	al,al			;separateur ?
	jz	short var3		;ni lettre ni chiffre
	cmp	al,clsch_num		;chiffre ?
	je	short var2		;oui
	and	byte ptr [ebx],11011111b ;force majuscule
var2:
	inc	inptr			;mange caractere
	inc	count			;un caractere de plus
	jmp	var1			;continue
var3:
	cmp	ah,'_'			;_ ?
	je	var2			;oui
	mov	edx,ebx
	dec	edx
	mov	stend,edx		;fin de symbole
	mov	edx,nxtnam
	mov	stbeg,edx		;debut de symbole
	cmp	ah,'$'			;variable chaine ?
	mov	al,tok_mark		;token variable
	jne	short var4		;non
	or	al,strbit		;indique chaine
	jmp	short var5
var4:
	cmp	ah,'%'			;variable entiere ?
	jne	short var6		;non
	or	al,intbit		;indique entier
var5:
	inc	ebx			;mange caractere
	mov	inptr,ebx		;maj pointeur caractere
var6:
	call	skipsps			;saut espaces et caractere
	cmp	ah,'('			;tableau ?
	jne	short var7		;non
	or	al,arrbit		;indique tableau
var7:
	test	labflg,0FFh		;etiquette ?
	jz	short var9		;non
	test	al,intbit+strbit	;entier ou chaine ?
	jnz	short var8		;oui
	or	al,labbit		;indique etiquette
var8:
	and	al,not arrbit		;cela ne peut pas etre un tableau
var9:
	mov	vartyp,al		;sauve type symbole
	test	tokflg,0FFh		;rangement token ?
	mov	ah,al			;pour PUTSYM ou GETSYM
	jnz	short var11		;non
	call	putsym			;recherche ou creation symbole
	mov	ah,vartyp		;token variable
	call	stout			;range token
	mov	eax,symoff		;offset symbole
	mov	ecx,size_o		;taille offset
	rol	eax,8			;octet dans AH
var10:
	call	tout			;range octet
	ror	eax,8			;octet suivant
	loop	var10			;pour un pointeur
	test	vartyp,labbit		;etiquette ?
	jnz	docon5			;oui, ajout offset a zero
	mov	al,token		;retour token
	ret
var11:
	call	getsym			;recherche symbole
	jnc	var13			;non trouve
	mov	al,vartyp		;preset
var12:
	ret
var13:
	xor	al,al			;token nul
	jmp	var12
coment:
; Commentaire
	call	stout			;range token
	mov	ebx,inptr		;pointeur caractere tampon entree
	mov	stbeg,ebx		;debut chaine donnee ou commentaire
comen1:
	mov	ah,[ebx]		;caractere
	inc	ebx			;avance pointeur
	cmp	ah,cr			;fin de ligne ?
	jne	comen1			;non, continue
comen2:
	dec	ebx			;retour sur fin de ligne
	mov	inptr,ebx		;maj pointeur caractere
	mov	stend,ebx		;fin de chaine
	jmp	short copasc		;copie representation
strin1:
	dec	ebx			;pointe fin de ligne
	jmp	short strin3
string:
; Chaine
	mov	ebx,inptr		;pointeur caractere tampon entree
	dec	ebx			;recule sur quote
	mov	stbeg,ebx		;debut de chaine avec quote
	mov	dh,ah			;sauve code quote (' ou ")
	xor	ecx,ecx			;raz compteur
strin2:
	inc	ecx			;un caractere de plus
	inc	ebx			;suivant
	mov	ah,[ebx]		;caractere
	cmp	ah,cr			;fin de ligne ?
	je	strin1			;oui
	cmp	ah,dh			;quote (' ou ") ?
	jne	strin2			;non, continue
strin3:
	mov	stend,ebx		;fin de chaine
	inc	ebx			;suivant
	mov	inptr,ebx		;maj pointeur caractere
	mov	ah,tok_mark+conbit+strbit
	call	stout			;range token
	mov	ah,cl
	dec	ah			;longueur chaine (<=254)
	call	tout			;range octet
copasc:
; Copie representation ASCII
	mov	ebx,stbeg		;debut chaine
	mov	eax,stend		;fin chaine
	sub	eax,ebx
	inc	eax			;longueur chaine
	mov	ecx,eax
	mov	ah,al			;dans AH
	inc	ecx			;plus octet longueur
copas1:
	push	ebx
	call	tout			;range octet/caracteres
	pop	ebx
	mov	ah,[ebx]		;caractere suivant
	inc	ebx
	loop	copas1			;pour toute la chaine
	mov	al,token		;retour token
	ret

; Rangement token
; Entree: AH=token
	align	16
stout:
	mov	token,ah		;sauve token
	test	tokflg,0FFh		;rangement token ?
	jnz	short tout2		;non
	test	ah,ah			;mot cle
	js	short tout1		;non
	cmp	ah,k_lbracket		;( ?
	je	short stout1		;oui
	cmp	ah,k_rbracket		;) ?
	jne	short tout1		;non
	dec	bckcnt			;decompte parenthese fermante
	jns	short tout1
	jmp	encode4			;erreur balance parentheses
stout1:
	inc	bckcnt			;compte parenthese ouvrante
	jmp	short tout1		;range

; Rangement octet
; Entree: AH=octet
	align	16
tout:
	test	tokflg,0FFh		;rangement token ?
	jnz	short tout2		;non
tout1:
	mov	ebx,linptr		;pointeur sortie
	cmp	ebx,offset linbuf+maxlin-size_i ;debordement tampon codage ?
	jae	short tout3		;oui, erreur
	mov	[ebx],ah		;range octet dans tampon codage
	inc	ebx			;avance
	mov	linptr,ebx
	inc	linlen			;un octet de plus dans la ligne codee
tout2:
	ret
tout3:
	mov	al,err_too_complex	;ligne trop longue
	jmp	encodere

; Recherche symbole dans table
; Entree: STBEG->nom
;	  COUNT=nombre de caracteres
; Sortie: CF si trouve
;	  SYMOFF=symbole offset
;	  EDI->valeur symbole
	align	16
getsym:
	cmp	count,0			;chaine vide ?
	je	short getsym7		;oui, symbole non trouve
	mov	edi,symb_base		;debut table symboles
	mov	esi,prog_base		;base memoire programme
	mov	edx,edi
	add	edx,[esi].prog.sym_len	;fin table symboles
getsym1:
	mov	esi,stbeg		;debut symbole
	movzx	ecx,count		;nombre de caracteres
	cmp	edi,edx			;fin table symboles atteinte ?
	jae	getsym7			;oui, symbole non trouve
	mov	al,vartyp		;type variable
	scasb				;identique ?
	je	short getsym4		;oui, continue
	add	edi,size_a-1		;saut adresse
getsym2:
	inc	edi			;caractere suivant
getsym3:
	test	byte ptr [edi],0FFh	;type symbole suivant ?
	jns	getsym2			;non, continue
	jmp	getsym1			;symbole suivant dans table
getsym4:
	mov	ebx,edi			;sauve position dans table
	add	edi,size_a		;saute adresse
	repz	cmpsb			;meme nom ?
	je	short getsym5		;oui
	dec	edi			;recule sur caractere different
	jmp	getsym3			;recherche debut symbole suivant
getsym5:
	test	byte ptr [edi],0FFh	;type symbole suivant ?
	jns	getsym2			;non, nom incomplet
	mov	edi,ebx			;debut symbole dans table
	sub	ebx,symb_base		;offset symbole
	mov	symoff,ebx
	test	labflg,0FFh		;definition etiquette ?
	jns	short getsym6		;non
	mov	eax,linum		;numero ligne
	mov	[edi],eax		;sauve dans table symbole
getsym6:
	stc				;indique symbole trouve
	ret
getsym7:
	clc
	ret				;finish

; Ajout symbole dans table si non trouve
; Entree: STBEG->nom
;	  COUNT=nombre de caracteres
; Sortie: SYMOFF=offset symbole
	align	16
putsym:
	call	getsym			;recherche symbole
	jc	short putsym2		;trouve
	mov	esi,prog_base		;base memoire programme
	movzx	ecx,count		;nombre de caracteres nom
	mov	edi,[esi].prog.sym_len	;taille table symboles
	lea	eax,[ecx+size symb+1]	;taille entree symbole
	inc	edi
	mov	symoff,edi		;offset apres type sur nouveau symbole dans table
	dec	edi
	add	eax,edi			;nouvelle taille table symboles
	cmp	eax,symb_size		;debordement table symboles ?
	jae	short putsym3		;oui, erreur
	add	edi,symb_base		;pointeur sur entree nouveau symbole
	mov	al,vartyp
	stosb				;range type
	xor	eax,eax			;raz adresse
	test	labflg,0FFh		;definition etiquette ?
	jns	short putsym1		;non ?
	mov	eax,linum		;numero de ligne
putsym1:
	push	esi
	stosd				;range valeur
	mov	esi,stbeg
	rep	movsb			;range nom
	mov	byte ptr [edi],0FFh	;marque de fin de table
	sub	edi,symb_base		;nouvelle taille table symboles
	pop	esi
	mov	[esi].prog.sym_len,edi	;maj
	inc	[esi].prog.sym_count	;un symbole de plus
putsym2:
	ret
putsym3:
	mov	al,err_prog_ovf
	jmp	rpter

; Saut espaces
; Entree: EBX->caractere courant dans ligne
; Sortie: AH=caractere
	align	16
skipsps:
	dec	ebx
skipsps1:
	inc	ebx
	mov	ah,[ebx]
	cmp	ah,' '			;espace ?
	je	skipsps1		;oui, saute
	ret

; Caractere courant dans le tampon d'entree
; Entree: INPT->caractere
; Sortie: AH=caractere
;	  AL=type (0:separateur, 1:lettre, 2:chiffre)
	align	16
getchr:
	mov	ebx,inptr		;pointeur caractere tampon entree
	mov	inls,ebx		;pointeur dernier caractere traite
	mov	ah,[ebx]		;caractere
;;;	jmp	short clsch

; Type caractere
; Sortie: AL=type (0:separateur, 1:lettre, 2:chiffre)
clsch:
	cmp	ah,'0'			;chiffre ?
	jb	short clsch1		;non
	cmp	ah,'9'
	jbe	short clsch3		;oui
	cmp	ah,'A'			;lettre majuscule ?
	jb	short clsch1		;non
	cmp	ah,'Z'
	jbe	short clsch2		;oui
	cmp	ah,'a'			;lettre minuscule ?
	jb	short clsch1		;non
	cmp	ah,'z'
	jbe	short clsch2		;oui
clsch1:
	mov	al,clsch_sepa		;0 (separateur)
	ret
clsch2:
	mov	al,clsch_alpha		;1 (lettre)
	ret
clsch3:
	mov	al,clsch_num		;2 (chiffre)
	ret

; Recherche mot cle dans table
; Entree: EBX->table
;	  NXTNAM->mot cle
; Sortie: CF si trouve
;	  AH=token
;	  EBX->apres le mot cle trouve
	align	16
searchk:
	mov	esi,nxtnam		;pointeur mot cle
searchk1:
	mov	ah,[ebx]		;caractere table
	inc	ebx
	test	ah,ah			;fin de mot cle ?
	js	short searchk5		;oui, c'est le token
searchk2:
	lodsb				;caractere mot cle
;$$$	cmp	al,' '			;espace ?
;$$$	je	searchk2		;oui, ignore
	cmp	al,'a'			;minuscule ?
	jb	short searchk3		;non
	cmp	al,'z'
	ja	short searchk3		;non
	and	al,11011111b		;majuscule
searchk3:
	cmp	ah,al			;caractere recherche ?
	je	searchk1		;oui, continue
searchk4:
	mov	ah,[ebx]		;caractere table
	inc	ebx
	test	ah,ah			;fin de mot cle
	jns	searchk4		;non, saute
	mov	ah,[ebx]		;caractere table
	test	ah,ah			;fin de table (NC)
	jnz	searchk			;non, entree suivante
	ret
searchk5:
	mov	ebx,esi			;EBX pointe apres le mot cle trouve
	and	ah,01111111b		;raz indicateur token
	stc				;mot cle trouve
	ret

; Recherche rapide mot cle dans table
; Entree: AH=premiere lettre
;	  EBX->table des tables
;	  NXTNAM->apres la premiere lettre
; Sortie: CF si trouve
;	  AH=token
;	  EBX->apres le mot cle trouve
	align	16
qsearchk:
	and	ah,11011111b		;majuscule
	sub	ah,'A'			;index
	movzx	eax,ah
	mov	ebx,[ebx+eax*4]		;table suivant premiere lettre
	test	ebx,ebx			;table presente (NC) ?
	jz	short qsearchk7		;non
qsearchk1:
	mov	esi,nxtnam		;pointeur apres la premiere lettre
qsearchk2:
	mov	ah,[ebx]		;caractere table
	inc	ebx
	test	ah,ah			;fin de mot cle ?
	js	short qsearchk6		;oui, c'est le token
qsearchk3:
	lodsb				;caractere mot cle
;$$$	cmp	al,' '			;espace ?
;$$$	je	qsearchk3		;oui, ignore
	cmp	al,'a'			;minuscule ?
	jb	short qsearchk4		;non
	cmp	al,'z'
	ja	short qsearchk4		;non
	and	al,11011111b		;majuscule
qsearchk4:
	cmp	ah,al			;caractere recherche ?
	je	qsearchk2		;oui, continue
qsearchk5:
	mov	ah,[ebx]		;caractere table
	inc	ebx
	test	ah,ah			;fin de mot cle
	jns	qsearchk5		;non, saute
	mov	ah,[ebx]		;caractere table
	test	ah,ah			;fin de table (NC)
	jnz	qsearchk1		;non, entree suivante
	ret
qsearchk6:
	mov	ebx,esi			;EBX pointe apres le mot cle trouve
	and	ah,01111111b		;raz indicateur token
	stc				;mot cle trouve
qsearchk7:
	ret

; Selection couleur affichage
; Entree: AL=couleur affichage
;	  EDI->tampon sortie
;	  LISTCOLFLG=indicateur affichage couleur
setlistcol:
	test	listcolflg,0FFh		;affichage couleur ?
	jz	short setlistcol9	;non, ignore
	cmp	al,listcol		;couleur courante ok ?
	je	short setlistcol9	;oui, ignore
	mov	listcol,al		;maj couleur courante
	mov	byte ptr [edi],escape	;caractere echapement
	inc	edi
	stosb				;caractere selection couleur texte
setlistcol9:
	ret

	end