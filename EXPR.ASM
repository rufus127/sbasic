	page	,132
	name	expr

	public	comtok
	public	lepar
	public	ripar
	public	eval
	public	esitor0
	public	exp
	public	subexp
	public	pushi
	public	pshpara
	public	popr0
	public	sstmp
	public	stexp
	public	pshstr
	public	strcnt
	public	strtox
	public	strtobuf
	public	nxtsc
	public	chrd1
	public	evlbyt
	public	pulbyt
	public	evlint
	public	pulint
	public	pulins
	public	evluint
	public	pulfp
	public	settime
	public	setdate

	.model	flat,c

	include sbasic.inc

	.data
;Variables evaluation
temp		dd	?		;pointeur temporaire

	.code
	extrn	getok:near
	extrn	avar:near
	extrn	allocds:near
	extrn	dpmod:near,imod:near
	extrn	iadd:near,isub:near
	extrn	intmul:near,intdiv:near
	extrn	rintgr:near,uintgr:near
	extrn	dpadd:near,dpsub:near,dpmul:near,dpdiv:near
	extrn	floatr0:near,float:near
	extrn	dsignum:near
	extrn	dintf:near,drnd:near,dpabs:near
	extrn	ftoa:near,itoa:near,atof:near
	extrn	dsqrt:near,dtan:near,dpowri:near
	extrn	r0tor1:near
	extrn	dlog:near,dexp:near,dsine:near,dcosine:near
	extrn	datan:near,dpower:near
	extrn	icmp:near,dcmp:near
	extrn	rpter:near,synerr:near
	extrn	pdl:near,pointx:near
	extrn	exec:near
	extrn	fdate:near
	extrn	ftime:near
	extrn	selchn:near
	extrn	inch:near,status:near
	extrn	dppi:byte

; Evaluation expression
; RETOUR: si entier ou flottant: resultat dans R0 et AL=type (TOK_MARK non positionne)
;	  si chaine: pile sous-chaine et STRFL positionne
	align	16
eval:
	initexp				;initialise piles evaluation expression
	call	exp			;evaluation expression, erreur
	jz	short popr04		;pas d'expression
	test	strflg,0FFh		;expression chaine ?
	jnz	short popr01		;oui
;;;	jmp	short popr0

; POP sommet de pile dans R0 ou R0I
; Retour: AL=type R0 (TOK_MARK non positionne)
popr0:
	mov	ebx,atos		;sommet de pile arithmetique
	sub	ebx,size opnd		;POP
	cmp	ebx,offset astack	;vide ?
	jb	short popr03		;oui, erreur
	mov	atos,ebx
	test	strflg,0FFh		;expression chaine ?
	jnz	short popr02		;oui, erreur
	mov	al,[ebx].opnd.o_type	;type operande
	test	al,intbit		;entier ?
	jz	short popr05		;non
	mov	ebx,dword ptr [ebx].opnd.o_value ;valeur entiere
	mov	r0i,ebx			;dans R0I
popr01:
	ret
popr02:
	mov	al,err_arg_type		;erreur type argumant
	jmp	rpter
popr03:
	mov	al,err_exp		;erreur expression
	jmp	rpter
popr04:
	jmp	synerr			;erreur de syntaxe
popr05:
	lea	esi,[ebx].opnd.o_value	;pointeur valeur flottante
;;;	jmp	short esitor0

; Copie [ESI] dans R0
esitor0:
	mov	edi,offset r0
	movsd
	movsd
	ret

; POP avec convertion en flottant si necessaire
	align	16
pulfp:
	call	popr0			;POP
	test	al,intbit		;entier ?
	jnz	floatr0			;non, conversion flottant
	ret

; Pointeur vers operande flottant
; Retour: ESI->operande flottant
ptropnd:
	mov	ebx,atos		;sommet de pile arithmetique
	sub	ebx,size opnd		;POP
	cmp	ebx,offset astack	;vide ?
	jb	short popr03		;oui, erreur
	test	strflg,0FFh		;expression chaine ?
	jnz	popr02			;oui, erreur
	test	[ebx].opnd.o_type,intbit ;type entier
	lea	esi,[ebx].opnd.o_value	;adresse operande
	jz	short ptropnd1		;non
	call	float			;conversion flottant
	mov	[ebx].opnd.o_type,fltbit ;type flottant
ptropnd1:
	ret

; Pointeurs vers deux operandes
; Retour: ESI->premier operande
;         EBX->second operande
;         NZ si deux operandes entiers
; Si les operandes ne sont pas de meme type, l'entier est convertit en flottant
	align	16
ptr2ops:
	mov	ebx,atos		;sommet de pile arithmetique
	sub	ebx,2*size opnd		;2 operandes
	cmp	ebx,offset astack	;vide ?
	jb	pulops6			;oui, erreur
	sub	atos,size opnd		;garde resultat operation
	test	strflg,0FFh		;expression chaine ?
	jnz	popr02			;oui, erreur
	mov	ah,[ebx].opnd.o_type	;type premier operande
	mov	al,[ebx+size opnd].opnd.o_type ;type second operande
	cmp	al,ah			;comparaison types
	jbe	short pulops1		;identiques ou premier operande entier
	lea	esi,[ebx+size opnd].opnd.o_value ;adresse second operande
	call	float			;conversion flottant second operande
	mov	[ebx+size opnd].opnd.o_type,fltbit ;indique second operande flottant
	lea	esi,[ebx].opnd.o_value	;adresse premier operande
	jmp	short pulops4
pulops1:
	cmp	ah,al			;meme type ?
	lea	esi,[ebx].opnd.o_value	;adresse premier operande
	je	short pulops4		;oui
	call	float			;conversion flottant premier operande
	mov	[ebx].opnd.o_type,fltbit ;indique premier operande flottant
pulops4:
	test	[ebx].opnd.o_type,intbit ;operandes entiers ?
	lea	ebx,[ebx+size opnd].opnd.o_value ;adresse second operande
	ret
pulops6:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Evaluation expression
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
exp:
; Priorite 8 (OR)
	call	pr7
	jz	short exp2		;pas d'expression
exp1:
	cmp	al,k_or			;OR ?
	je	short exp3		;oui
exp2:
	ret				;retour NZ
exp3:
	inc	ebp			;mange OR
	call	pr7
	jz	short exp4		;erreur
	call	pulint			;POP entier
	mov	ecx,r0i			;sauve
	call	pulint			;POP entier
	or	r0i,ecx			;execution OR
	mov	al,intbit		;type entier
	call	pushr0			;PUSH RESULT
	mov	al,[ebp]		;token courant
	jmp	exp1			;continue
exp4:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 7 (AND)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr7:
	call	pr6
	jz	short pr72		;pas d'expression
pr71:
	cmp	al,k_and		;AND ?
	je	short pr73		;oui
pr72:
	ret				;retour NZ
pr73: 
	inc	ebp			;mange AND
	call	pr6
	jz	short pr74		;erreur
	call	pulint			;POP entier
	mov	ecx,r0i			;sauve
	call	pulint			;pop entier
	and	r0i,ecx			;execution AND
	mov	al,intbit		;type entier
	call	pushr0			;PUSH RESULT
	mov	al,[ebp]		;token courant
	jmp	pr71			;continue
pr74:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 6 (comparaison)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr6:
	call	pr5
	jz	short pr62		;pas d'expression
pr61:
	cmp	al,k_le			;comparaison ?
	jb	short pr62		;non, fin niveau (NZ)
	cmp	al,k_eq
	jbe	short pr63
pr62:
	ret				;retour NZ
pr63:
	test	strflg,0FFh		;expression chaine ?
	jnz	stexp4			;oui, comparaison chaines
	inc	ebp			;mange token comparaison
	movzx	eax,al			;token
	push	eax			;sauve token
	call	pr5
	pop	eax
	jz	short pr64		;erreur
	call	relop			;execution
	mov	al,[ebp]		;token courant
	jmp	pr61			;continue
pr64:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 5 (+,-)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr5:
	call	pr4
	jz	short pr52		;pas d'expression
pr51:
	cmp	al,k_plus		;+ ?
	je	short pr53
	cmp	al,k_minus		;- ?
	je	short pr55		;oui
pr52:
	ret				;retour NZ
pr53:
	inc	ebp			;mange +
	call	pr4
	jz	short pr57		;erreur
	call	ptr2ops			;pointeurs vers operandes
	jnz	short pr54		;operandes entiers
	call	dpadd			;execution addition
	mov	al,[ebp]		;token courant
	jmp	pr51
pr54:
	call	iadd			;execution addition entiere
	mov	al,[ebp]		;token courant
	jmp	pr51
pr55:
	inc	ebp			;mange -
	call	pr4
	jz	short pr57		;erreur
	call	ptr2ops			;pointeurs vers operandes
	jnz	short pr56		;operandes entiers
	call	dpsub			;execution soustraction
	mov	al,[ebp]		;token courant
	jmp	pr51			;continue
pr56:
	call	isub			;execution soustraction entiere
	mov	al,[ebp]		;token courant
	jmp	pr51			;continue
pr57:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 4 (MOD)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr4:
	call	pr3
	jz	short pr42		;pas d'expression
pr41:
	cmp	al,k_mod		;MOD ?
	je	short pr43		;oui
pr42:
	ret				;retour NZ
pr43:
	inc	ebp			;mange MOD
	call	pr3
	jz	short pr45		;erreur
	call	ptr2ops			;pointeurs vers operandes
	jnz	short pr44		;operandes entiers
	call	dpmod			;execution modulo
	mov	al,[ebp]		;token courant
	jmp	pr41			;continue
pr44:
	call	imod			;execution modulo entier
	mov	al,[ebp]		;token courant
	jmp	pr41			;continue
pr45:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 3 (*,/)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr3:
	call	pr2
	jz	short pr33		;pas d'expression
pr31:
	cmp	al,k_mul		;* ?
	je	short pr34		;oui
pr32:
	cmp	al,k_div		;/ ?
	je	short pr36		;oui
pr33:
	ret				;retour NZ
pr34:
	inc	ebp			;mange *
	call	pr2
	jz	short pr38		;erreur
	call	ptr2ops			;pointeurs vers operandes
	jnz	short pr35		;operandes entiers
	call	dpmul			;execution multiplication
	mov	al,[ebp]		;token courant
	jmp	pr31			;continue
pr35:
	call	intmul			;execution multiplication entiere
	mov	al,[ebp]		;token courant
	jmp	pr31			;continue
pr36:
	inc	ebp			;mange /
	call	pr2
	jz	short pr38		;erreur
	call	ptr2ops			;pointeurs vers operandes
	jnz	short pr37		;operandes entiers
	call	dpdiv			;execution division
	mov	al,[ebp]		;token courant
	jmp	pr31			;continue
pr37:
	call	intdiv			;execution division entiere
	mov	al,[ebp]		;token courant
	jmp	pr31			;continue
pr38:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 2 (^)
; Retour: ZF si pas d'expression
;	  AL=token courant
	align	16
pr2:
	call	pr1
	jz	short pr22		;pas d'expression
pr21:
	skipst				;saut espace et token
	cmp	al,k_power		;^ ?
	je	short pr23		;oui
pr22:
	ret				;retour NZ
pr23:
	inc	ebp			;mange ^
	call	pr1
	jz	short pr26		;erreur
	call	popr0			;POP POWER depuis sommet pile
	push	eax			;type
	call	ptropnd			;pointeur parametre flottant
	pop	eax
	mov	ebx,offset r0		;POWER
	test	al,intbit		;entier ?
	jnz	short pr25		;oui
	call	dpower			;BASE^POWER
	jmp	pr21
pr25:
	call	dpowri			;BASE^POWERpercent
	jmp	pr21
pr26:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Priorite 1 (operande, fonction, NOT, PTR, POINT, LINE, !, & , -, +)
; Retour: ZF si pas d'expression
; Attention: SKIPST doit suivre
	align	16
pr1:
	movzx	eax,byte ptr [ebp]	;token
	jmp	pr1_table[eax*4]	;aiguillage
pr1_ext:
	inc	ebp			;mange token indirection
	movzx	eax,byte ptr [ebp]	;token
	jmp	ext_table[eax*4]	;aiguillage

; Constante numerique
	align	16
pr1_con:
	inc	ebp			;mange token constante
	and	al,unused+intbit+linbit+strbit ;garde bits utiles
	mov	esi,ebp			;adresse valeur
	test	al,intbit		;entier ?
	mov	ecx,size_f		;taille flottant
	jz	short pr1_con1		;oui
	mov	ecx,size_i		;taille entier
pr1_con1:
	add	ebp,ecx			;saute valeur
	movzx	ecx,byte ptr [ebp]	;longueur representation
	inc	ebp			;saute longueur
	add	ebp,ecx			;saute representation
	jmp	pshopnd			;PUSH constante

; Variable
	align	16
pr1_var:
	call	avar			;adresse variable
	test	al,arrbit		;tableau ?
	jnz	short pr1_var1		;oui, erreur
	and	al,unused+intbit+linbit+strbit ;garde bits utiles
	jmp	pshopnd			;PUSH variable
pr1_var1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Espace(s)
	align	16
pr1_mspace:
	inc	ebp			;espaces multiples
pr1_space:
	inc	ebp			;mange token ou compte
	jmp	pr1

; LINE
	align	16
pr1_line:
	inc	ebp			;mange LINE
	skipst				;saut espace et token
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	jne	short pr1_line1		;non
	mov	ebx,[ebp+1]		;numero de ligne
	add	ebp,1+size_i+size_a	;mange token, numero de ligne et adresse ligne
	jmp	pushi			;PUSH
pr1_line1:
	mov	ebx,curpc		;debut ligne courante
	mov	ebx,[ebx].line.l_number	;numero de ligne
	jmp	pushi			;PUSH

; -
	align	16
pr1_minus:
	inc	ebp			;mange -
	call	pr2
	jz	short pr1_minus3	;erreur
	call	popr0			;POP operande
	test	al,intbit		;entier ?
	jnz	short pr1_minus1	;oui
	xor	r0+7,10000000b		;inversion signe
	jmp	short pr1_minus2
pr1_minus1:
	neg	r0i			;negation
pr1_minus2:
	jmp	pushr0			;PUSH resultat et retour
pr1_minus3:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; NOT
	align	16
pr1_not:
	inc	ebp			;mange NOT
	call	pr6
	jz	short pr1_not1		;erreur
	call	pulint			;operande entier
	not	r0i			;complement a 1
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
pr1_not1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Non expression
	align	16
no_exp:
	cmp	al,al			;retour ZF
	ret

; Table aiguillage expression niveau 1
	align	16
pr1_table label	dword
	dd	offset no_exp		;0
	dd	offset no_exp		;1 k_goto
	dd	offset no_exp		;2 k_gosub
	dd	offset no_exp		;3 k_resume
	dd	offset no_exp		;4 k_digits
	dd	offset no_exp		;5 k_rem
	dd	offset no_exp		;6 k_let
	dd	offset no_exp		;7 k_print
	dd	offset no_exp		;8 k_input
	dd	offset no_exp		;9 k_execute
	dd	offset no_exp		;10 k_swap
	dd	offset no_exp		;11 k_for
	dd	offset no_exp		;12 k_poke
	dd	offset no_exp		;13 k_lprint
	dd	offset no_exp		;14 k_next
	dd	offset no_exp		;15 k_read
	dd	offset no_exp		;16 k_return
	dd	offset no_exp		;17 k_if
	dd	offset no_exp		;18 k_dim
	dd	offset no_exp		;19 k_on
	dd	offset no_exp		;20 k_set
	dd	offset no_exp		;21 k_end
	dd	offset no_exp		;22 k_stop
	dd	offset no_exp		;23 k_data
	dd	offset no_exp		;24 k_restore
	dd	offset no_exp		;25 k_call
	dd	offset no_exp		;26 k_open
	dd	offset no_exp		;27 k_close
	dd	offset no_exp		;28 k_chain
	dd	offset no_exp		;29 k_kill
	dd	offset no_exp		;30 k_rename
	dd	offset no_exp		;31 k_get
	dd	offset no_exp		;32 k_put
	dd	offset no_exp		;33 k_field
	dd	offset no_exp		;34 k_lset
	dd	offset no_exp		;35 k_rset
	dd	offset no_exp		;36 k_exec
	dd	offset no_exp		;37 k_dpoke
	dd	offset pr1_ext		;38 k_indirect
	dd	offset no_exp		;39 k_sub
	dd	offset no_exp		;40 k_label
	dd	offset no_exp		;41 k_record
	dd	offset no_exp		;42 k_old
	dd	offset no_exp		;43 k_new
	dd	offset no_exp		;44 k_as
	dd	offset no_exp		;45 k_using
	dd	offset no_exp		;46 k_error
	dd	offset pr1_line		;47 k_line
	dd	offset no_exp		;48 k_then
	dd	offset no_exp		;49 k_else
	dd	offset no_exp		;50 k_to
	dd	offset no_exp		;51 k_step
	dd	offset pointx		;52 k_point
	dd	offset xabs		;53 k_abs
	dd	offset xatn		;54 k_atn
	dd	offset xcos		;55 k_cos
	dd	offset xexp		;56 k_exp
	dd	offset xint		;57 k_int
	dd	offset xlog		;58 k_log
	dd	offset xrnd		;59 k_rnd
	dd	offset xsgn		;60 k_sgn
	dd	offset xsin		;61 k_sin
	dd	offset xsqr		;62 k_sqr
	dd	offset xtan		;63 k_tan
	dd	offset xpos		;64 k_pos
	dd	offset xpeek		;65 k_peek
	dd	offset xusr		;66 k_usr
	dd	offset xfre		;67 k_fre
	dd	offset dpeek		;68 k_dpeek
	dd	offset xpdl		;69 k_pdl
	dd	offset xptr		;70 k_ptr
	dd	offset ilil		;71 k_spc
	dd	offset ilil		;72 k_tab
	dd	offset xpen		;73 k_xpen
	dd	offset ypen		;74 k_ypen
	dd	offset dpi		;75 k_pi
	dd	offset derr		;76 k_err
	dd	offset derl		;77 k_erl
	dd	offset asc		;78 k_asc
	dd	offset lenf		;79 k_len
	dd	offset val		;80 k_val
	dd	offset hexf		;81 k_hex
	dd	offset xinstr		;82 k_instr
	dd	offset cvtsi		;83 k_cvt$p
	dd	offset cvtsf		;84 k_cvt$f
	dd	offset stexp		;85 k_date$
	dd	offset stexp		;86 k_chr$
	dd	offset stexp		;87 k_left$
	dd	offset stexp		;88 k_right$
	dd	offset stexp		;89 k_mid$
	dd	offset stexp		;90 k_str$
	dd	offset stexp		;91 k_inch$
	dd	offset stexp		;92 k_cvtp$
	dd	offset stexp		;93 k_cvtf$
	dd	offset stexp		;94 k_ltrm$
	dd	offset stexp		;95 k_rtrm$
	dd	offset stexp		;96 k_string$
	dd	offset pr1_not		;97 k_not
	dd	offset no_exp		;98 k_and
	dd	offset no_exp		;99 k_or
	dd	offset no_exp		;100 k_le
	dd	offset no_exp		;101 k_ge
	dd	offset no_exp		;102 k_dif
	dd	offset no_exp		;103 k_lt
	dd	offset no_exp		;104 k_gt
	dd	offset no_exp		;105 k_eq
	dd	offset no_exp		;106
	dd	offset no_exp		;107 k_power
	dd	offset no_exp		;108 k_div
	dd	offset no_exp		;109 k_mul
	dd	offset pr1_space	;110 k_plus
	dd	offset pr1_minus	;111 k_minus
	dd	offset gettyp		;112 k_exclamation
	dd	offset stexp		;113 k_ampersand
	dd	offset no_exp		;114 k_comma
	dd	offset no_exp		;115 k_semicolon
	dd	offset subexp1		;116 k_lbracket
	dd	offset no_exp		;117 k_rbracket
	dd	offset no_exp		;118 k_hashtag
	dd	offset no_exp		;119 k_mod
	dd	offset no_exp		;120 k_append
	dd	offset no_exp		;121 k_library
	dd	offset no_exp		;122
	dd	offset no_exp		;123 k_colon
	dd	offset no_exp		;124
	dd	offset no_exp		;125 k_cr
	dd	offset pr1_space	;126 k_space
	dd	offset pr1_mspace	;127 k_mspace
;
	dd	offset pr1_var		;128
	dd	offset stexp		;129
	dd	offset pr1_var		;130
	dd	offset stexp		;131
	dd	offset pr1_var		;132
	dd	offset stexp		;133
	dd	offset pr1_var		;134
	dd	offset stexp		;135
	dd	offset pr1_var		;136
	dd	offset stexp		;137
	dd	offset pr1_var		;138
	dd	offset stexp		;139
	dd	offset pr1_var		;140
	dd	offset stexp		;141
	dd	offset pr1_var		;142
	dd	offset stexp		;143
	dd	offset pr1_var		;144
	dd	offset stexp		;145
	dd	offset pr1_var		;146
	dd	offset stexp		;147
	dd	offset pr1_var		;148
	dd	offset stexp		;149
	dd	offset pr1_var		;150
	dd	offset stexp		;151
	dd	offset pr1_var		;152
	dd	offset stexp		;153
	dd	offset pr1_var		;154
	dd	offset stexp		;155
	dd	offset pr1_var		;156
	dd	offset stexp		;157
	dd	offset pr1_var		;158
	dd	offset stexp		;159
	dd	offset pr1_con		;160
	dd	offset stexp		;161
	dd	offset pr1_con		;162
	dd	offset stexp		;163
	dd	offset pr1_con		;164
	dd	offset stexp		;165
	dd	offset pr1_con		;166
	dd	offset stexp		;167
	dd	offset pr1_con		;168
	dd	offset stexp		;169
	dd	offset pr1_con		;170
	dd	offset stexp		;171
	dd	offset pr1_con		;172
	dd	offset stexp		;173
	dd	offset pr1_con		;174
	dd	offset stexp		;175
	dd	offset pr1_con		;176
	dd	offset stexp		;177
	dd	offset pr1_con		;178
	dd	offset stexp		;179
	dd	offset pr1_con		;180
	dd	offset stexp		;181
	dd	offset pr1_con		;182
	dd	offset stexp		;183
	dd	offset pr1_con		;184
	dd	offset stexp		;185
	dd	offset pr1_con		;186
	dd	offset stexp		;187
	dd	offset pr1_con		;188
	dd	offset stexp		;189
	dd	offset pr1_con		;190
	dd	offset stexp		;191
	dd	offset pr1_var		;192
	dd	offset stexp		;193
	dd	offset pr1_var		;194
	dd	offset stexp		;195
	dd	offset pr1_var		;196
	dd	offset stexp		;197
	dd	offset pr1_var		;198
	dd	offset stexp		;199
	dd	offset pr1_var		;200
	dd	offset stexp		;201
	dd	offset pr1_var		;202
	dd	offset stexp		;203
	dd	offset pr1_var		;204
	dd	offset stexp		;205
	dd	offset pr1_var		;206
	dd	offset stexp		;207
	dd	offset pr1_var		;208
	dd	offset stexp		;209
	dd	offset pr1_var		;210
	dd	offset stexp		;211
	dd	offset pr1_var		;212
	dd	offset stexp		;213
	dd	offset pr1_var		;214
	dd	offset stexp		;215
	dd	offset pr1_var		;216
	dd	offset stexp		;217
	dd	offset pr1_var		;218
	dd	offset stexp		;219
	dd	offset pr1_var		;220
	dd	offset stexp		;221
	dd	offset pr1_var		;222
	dd	offset stexp		;223
	dd	offset pr1_con		;224
	dd	offset stexp		;225
	dd	offset pr1_con		;226
	dd	offset stexp		;227
	dd	offset pr1_con		;228
	dd	offset stexp		;229
	dd	offset pr1_con		;230
	dd	offset stexp		;231
	dd	offset pr1_con		;232
	dd	offset stexp		;233
	dd	offset pr1_con		;234
	dd	offset stexp		;235
	dd	offset pr1_con		;236
	dd	offset stexp		;237
	dd	offset pr1_con		;238
	dd	offset stexp		;239
	dd	offset pr1_con		;240
	dd	offset stexp		;241
	dd	offset pr1_con		;242
	dd	offset stexp		;243
	dd	offset pr1_con		;244
	dd	offset stexp		;245
	dd	offset pr1_con		;246
	dd	offset stexp		;247
	dd	offset pr1_con		;248
	dd	offset stexp		;249
	dd	offset pr1_con		;250
	dd	offset stexp		;251
	dd	offset pr1_con		;252
	dd	offset stexp		;253
	dd	offset pr1_con		;254
	dd	offset stexp		;255

; Table extension aiguillage expression niveau 1
ext_table label	dword
	dd	offset no_exp		;0
	dd	offset no_exp		;1 k_gr
	dd	offset no_exp		;2 k_text
	dd	offset no_exp		;3 k_color
	dd	offset no_exp		;4 k_hgr
	dd	offset no_exp		;5 k_play
	dd	offset no_exp		;6 k_setcolor
	dd	offset no_exp		;7 k_setblink
	dd	offset no_exp		;8 k_plot
	dd	offset no_exp		;9 k_port
	dd	offset no_exp		;10 k_clear
	dd	offset no_exp		;11 k_tron
	dd	offset no_exp		;12 k_troff
	dd	offset no_exp		;13 k_cursor
	dd	offset no_exp		;14 k_delete
	dd	offset no_exp		;15 k_overlay
	dd	offset no_exp		;16 k_load
	dd	offset no_exp		;17 k_bload
	dd	offset no_exp		;18 k_local
	dd	offset no_exp		;19 k_clrg
	dd	offset no_exp		;20 k_move
	dd	offset no_exp		;21 k_dash
	dd	offset no_exp		;22 k_symbol
	dd	offset no_exp		;23 k_arc
	dd	offset no_exp		;24 k_fill
	dd	offset no_exp		;25 k_draw
	dd	offset no_exp		;26 k_mask
	dd	offset no_exp		;27 k_window
	dd	offset no_exp		;28 k_pen
	dd	offset no_exp		;29 k_compile
	dd	offset no_exp		;30 k_bron
	dd	offset no_exp		;31 k_broff
	dd	offset no_exp		;32 k_cls
	dd	offset no_exp		;33 k_edit
	dd	offset no_exp		;34 k_reset
	dd	offset no_exp		;35 k_exit
	dd	offset no_exp		;36 k_zoom
	dd	offset no_exp		;37 k_gget
	dd	offset no_exp		;38 k_gput
	dd	offset no_exp		;39 k_list
	dd	offset no_exp		;40 k_unlock
	dd	offset no_exp		;41 k_lock
	dd	offset no_exp		;42 k_time
	dd	offset no_exp		;43 k_chd
	dd	offset no_exp		;44 k_bsave
	dd	offset xargc		;45 k_argc
	dd	offset stexp		;46 k_argv$ (46 doit etre NO_EXP dans PR1_TABLE)
	dd	offset no_exp		;47
	dd	offset no_exp		;48
	dd	offset no_exp		;49
	dd	offset no_exp		;50
	dd	offset no_exp		;51
	dd	offset no_exp		;52
	dd	offset no_exp		;53
	dd	offset no_exp		;54
	dd	offset no_exp		;55
	dd	offset no_exp		;56
	dd	offset no_exp		;57
	dd	offset no_exp		;58
	dd	offset no_exp		;59
	dd	offset no_exp		;60
	dd	offset no_exp		;61
	dd	offset no_exp		;62
	dd	offset no_exp		;63
	dd	offset no_exp		;64
	dd	offset no_exp		;65
	dd	offset no_exp		;66
	dd	offset no_exp		;67
	dd	offset no_exp		;68
	dd	offset no_exp		;69
	dd	offset no_exp		;70
	dd	offset no_exp		;71
	dd	offset no_exp		;72
	dd	offset no_exp		;73
	dd	offset no_exp		;74
	dd	offset no_exp		;75
	dd	offset no_exp		;76
	dd	offset no_exp		;77
	dd	offset no_exp		;78
	dd	offset no_exp		;79
	dd	offset no_exp		;80
	dd	offset no_exp		;81
	dd	offset no_exp		;82
	dd	offset no_exp		;83
	dd	offset no_exp		;84
	dd	offset no_exp		;85
	dd	offset no_exp		;86
	dd	offset no_exp		;87
	dd	offset no_exp		;88
	dd	offset no_exp		;89
	dd	offset no_exp		;90
	dd	offset no_exp		;91
	dd	offset no_exp		;92
	dd	offset no_exp		;93
	dd	offset no_exp		;94
	dd	offset no_exp		;95
	dd	offset no_exp		;96
	dd	offset no_exp		;97
	dd	offset no_exp		;98
	dd	offset no_exp		;99
	dd	offset no_exp		;100
	dd	offset no_exp		;101
	dd	offset no_exp		;102
	dd	offset no_exp		;103
	dd	offset no_exp		;104
	dd	offset no_exp		;105
	dd	offset no_exp		;106
	dd	offset no_exp		;107
	dd	offset no_exp		;108
	dd	offset no_exp		;109
	dd	offset no_exp		;110
	dd	offset no_exp		;111
	dd	offset no_exp		;112
	dd	offset no_exp		;113
	dd	offset no_exp		;114
	dd	offset no_exp		;115
	dd	offset no_exp		;116
	dd	offset no_exp		;116
	dd	offset no_exp		;118
	dd	offset no_exp		;119
	dd	offset no_exp		;120
	dd	offset no_exp		;121
	dd	offset no_exp		;122
	dd	offset no_exp		;123
	dd	offset no_exp		;124
	dd	offset no_exp		;125
	dd	offset no_exp		;126
	dd	offset no_exp		;127
;
	dd	offset no_exp		;128
	dd	offset no_exp		;129
	dd	offset no_exp		;130
	dd	offset no_exp		;131
	dd	offset no_exp		;132
	dd	offset no_exp		;133
	dd	offset no_exp		;134
	dd	offset no_exp		;135
	dd	offset no_exp		;136
	dd	offset no_exp		;137
	dd	offset no_exp		;138
	dd	offset no_exp		;139
	dd	offset no_exp		;140
	dd	offset no_exp		;141
	dd	offset no_exp		;142
	dd	offset no_exp		;143
	dd	offset no_exp		;144
	dd	offset no_exp		;145
	dd	offset no_exp		;146
	dd	offset no_exp		;147
	dd	offset no_exp		;148
	dd	offset no_exp		;149
	dd	offset no_exp		;150
	dd	offset no_exp		;151
	dd	offset no_exp		;152
	dd	offset no_exp		;153
	dd	offset no_exp		;154
	dd	offset no_exp		;155
	dd	offset no_exp		;156
	dd	offset no_exp		;157
	dd	offset no_exp		;158
	dd	offset no_exp		;159
	dd	offset no_exp		;160
	dd	offset no_exp		;161
	dd	offset no_exp		;162
	dd	offset no_exp		;163
	dd	offset no_exp		;164
	dd	offset no_exp		;165
	dd	offset no_exp		;166
	dd	offset no_exp		;167
	dd	offset no_exp		;168
	dd	offset no_exp		;169
	dd	offset no_exp		;170
	dd	offset no_exp		;171
	dd	offset no_exp		;172
	dd	offset no_exp		;173
	dd	offset no_exp		;174
	dd	offset no_exp		;175
	dd	offset no_exp		;176
	dd	offset no_exp		;177
	dd	offset no_exp		;178
	dd	offset no_exp		;179
	dd	offset no_exp		;180
	dd	offset no_exp		;181
	dd	offset no_exp		;182
	dd	offset no_exp		;183
	dd	offset no_exp		;184
	dd	offset no_exp		;185
	dd	offset no_exp		;186
	dd	offset no_exp		;187
	dd	offset no_exp		;188
	dd	offset no_exp		;189
	dd	offset no_exp		;190
	dd	offset no_exp		;191
	dd	offset no_exp		;192
	dd	offset no_exp		;193
	dd	offset no_exp		;194
	dd	offset no_exp		;195
	dd	offset no_exp		;196
	dd	offset no_exp		;197
	dd	offset no_exp		;198
	dd	offset no_exp		;199
	dd	offset no_exp		;200
	dd	offset no_exp		;201
	dd	offset no_exp		;202
	dd	offset no_exp		;203
	dd	offset no_exp		;204
	dd	offset no_exp		;205
	dd	offset no_exp		;206
	dd	offset no_exp		;207
	dd	offset no_exp		;208
	dd	offset no_exp		;209
	dd	offset no_exp		;210
	dd	offset no_exp		;211
	dd	offset no_exp		;212
	dd	offset no_exp		;213
	dd	offset no_exp		;214
	dd	offset no_exp		;215
	dd	offset no_exp		;216
	dd	offset no_exp		;217
	dd	offset no_exp		;218
	dd	offset no_exp		;219
	dd	offset no_exp		;220
	dd	offset no_exp		;221
	dd	offset no_exp		;222
	dd	offset no_exp		;223
	dd	offset no_exp		;224
	dd	offset no_exp		;225
	dd	offset no_exp		;226
	dd	offset no_exp		;227
	dd	offset no_exp		;228
	dd	offset no_exp		;229
	dd	offset no_exp		;230
	dd	offset no_exp		;231
	dd	offset no_exp		;232
	dd	offset no_exp		;233
	dd	offset no_exp		;234
	dd	offset no_exp		;235
	dd	offset no_exp		;236
	dd	offset no_exp		;237
	dd	offset no_exp		;238
	dd	offset no_exp		;239
	dd	offset no_exp		;240
	dd	offset no_exp		;241
	dd	offset no_exp		;242
	dd	offset no_exp		;243
	dd	offset no_exp		;244
	dd	offset no_exp		;245
	dd	offset no_exp		;246
	dd	offset no_exp		;247
	dd	offset no_exp		;248
	dd	offset no_exp		;249
	dd	offset no_exp		;250
	dd	offset no_exp		;251
	dd	offset no_exp		;252
	dd	offset no_exp		;253
	dd	offset no_exp		;254
	dd	offset no_exp		;255

; Erreur interne 
ilil:
	mov	al,255
	jmp	rpter

; Fonctions arithmetiques
; ABS
	align	16
xabs:
	inc	ebp			;mange ABS
	call	subexp			;argument
	jz	short xabs1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dpabs			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xabs1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; ATN
	align	16
xatn:
	inc	ebp			;mange ATN
	call	subexp			;argument
	jz	short xatn1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	datan			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xatn1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; COS
	align	16
xcos:
	inc	ebp			;mange COS
	call	subexp			;argument
	jz	short xcos1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dcosine			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xcos1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; EXP
	align	16
xexp:
	inc	ebp			;mange EXP
	call	subexp			;argument
	jz	short xexp1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dexp			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xexp1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; INT
	align	16
xint:
	inc	ebp			;mange INT
	call	subexp			;argument
	jz	short xint1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dintf			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xint1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; LOG
	align	16
xlog:
	inc	ebp			;mange LOG
	call	subexp			;argument
	jz	short xlog1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dlog			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xlog1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; RND
	align	16
xrnd:
	inc	ebp			;mange RND
	call	subexp			;argument
	jz	short xrnd1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	drnd			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xrnd1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; SGN
	align	16
xsgn:
	inc	ebp			;mange SGN
	call	subexp			;argument
	jz	short xsgn1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dsignum			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xsgn1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; SIN
	align	16
xsin:
	inc	ebp			;mange SIN
	call	subexp			;argument
	jz	short xsin1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dsine			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xsin1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; SQR
	align	16
xsqr:
	inc	ebp			;mange SQR
	call	subexp			;argument
	jz	short xsqr1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dsqrt			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xsqr1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; TAN
	align	16
xtan:
	inc	ebp			;mange TAN
	call	subexp			;argument
	jz	short xtan1		;erreur
	call	ptropnd			;pointeur parametre flottant
	call	dtan			;execution fonction arithmetique
	test	ebp,ebp			;retour NZ
	ret
xtan1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; POS
	align	16
xpos:
	inc	ebp			;mange POS
	call	subexp			;argument
	jz	short xpos5		;erreur
	call	pulint			;POP entier
	mov	eax,r0i
	test	eax,eax			;canal 0 ?
	jnz	short xpos1		;non
	mov	ebx,oport		;port de sortie
	movzx	eax,colm[ebx]		;colonne
	jmp	short xpos2		;retour octet
xpos1:
	cmp	eax,numfil-1		;valide ?
	ja	short xpos3		;non, erreur
	mov	ebx,filtab[eax*4]	;pointeur FCB
	test	ebx,ebx			;fichier ouvert ?
	je	short xpos4		;non, erreur
	movzx	eax,[ebx].fcb.fcb_fcolm	;colonne
xpos2:
	mov	r0i,eax			;range octet
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
xpos3:
	mov	al,err_channel		;numero canal invalide
	jmp	rpter
xpos4:
	mov	al,err_not_opened	;canal non ouvert
	jmp	rpter
xpos5:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; PEEK
	align	16
xpeek:
	inc	ebp			;mange PEEK
	call	subexp			;argument
	jz	short xpeek3		;erreur
	call	pulins			;POP entier non signe
	mov	ebx,r0i			;adresse memoire
	cmp	ebx,data_base		;dans segment donnees ?
	jb	short xpeek2		;non
	cmp	ebx,data_end
	jae	short xpeek2		;non
	movzx	eax,byte ptr [ebx]	;octet
xpeek1:
	mov	r0i,eax			;range octet
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
xpeek2:
	xor	eax,eax			;hors donnees, retour zero
	jmp	xpeek1
xpeek3:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; USR
	align	16
xusr:
	inc	ebp			;mange USR
	call	subexp			;argument
	jz	short xusr1		;erreur
	call	pulint			;POP entier
; Fonction USR non implementee
	mov	r0i,0			;valeur retournee
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
xusr1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; FRE
	align	16
xfre:
	inc	ebp			;mange FRE
	call	subexp			;argument
	jz	short xfre6		;erreur
	call	pulint			;POP entier
	mov	eax,r0i
	test	eax,eax			;nul ?
	jz	short xref1		;oui, memoire donnees
	dec	eax			;1 ?
	jz	short xref5		;oui, memoire symboles
	mov	ebx,prog_base		;debut memoire programme
	mov	eax,prog_size		;taille memoire programme
	sub	eax,[ebx].prog.prog_len	;retranche taille programme
	jmp	short xref4		;retour taille libre 
xref1:
	xor	eax,eax
	mov	ebx,fstavl		;pointeur chaine memoire libre
xref2:
	test	ebx,ebx			;nul ?
	jz	short xref4		;oui, fin chaine
	add	eax,[ebx].free_mem.len	;ajout taille segment memoire libre
	mov	ebx,[ebx].free_mem.link	;segment suivanr
	jmp	xref2
xref4:
	mov	r0i,eax			;retour taille libre
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
xref5:
	mov	ebx,prog_base		;debut memoire programme
	mov	eax,symb_size		;taille memoire symboles
	sub	eax,[ebx].prog.sym_len	;retranche taille symboles
	jmp	xref4			;retour taille libre 
xfre6:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; DPEEK
	align	16
dpeek:
	inc	ebp			;mange DPEEK
	call	subexp			;argument
	jz	short dpeek3		;erreur
	call	pulins			;POP entier non signe
	mov	eax,r0i			;adresse memoire
	cmp	eax,data_base		;dans segment de donnees ?
	mov	ebx,eax
	jb	short dpeek2		;non
	add	eax,size_i-1		;adresse fin donnee
	cmp	eax,data_end		;dans segment donnees ?
	jae	short dpeek2		;non
	mov	eax,[ebx]		;double mot
dpeek1:
	mov	r0i,eax			;retour double mot
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
dpeek2:
	xor	eax,eax			;hors donnees, retour zero
	jmp	dpeek1
dpeek3:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; PDL
	align	16
xpdl:
	inc	ebp			;mange PDL
	call	subexp			;argument
	jz	short xpdl1		;erreur
	call	pulint			;POP entier
	call	pdl			;execution fonction paddle
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH donne paddle
xpdl1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Fonction PTR
; Retourne offset variable
	align	16
xptr:
	inc	bp			;mange PTR
	call	lepar			;mange (
	skipst				;saut espace et token
	test	al,al			;mot cle ?
	jns	short xptr1		;oui, erreur
	test	al,conbit+linbit+labbit	;variable ?
	jnz	short xptr1		;non, erreur
	call	avar			;adresse variable
	test	vrtflg,0FFh		;tableau virtuel ?
	mov	r0i,esi
	jnz	short xptr2		;oui
	call	ripar			;mange )
	mov	al,intbit		;valeur entiere
	jmp	pushr0			;PUSH offset variable
xptr1:
	jmp	synerr			;erreur de syntaxe
xptr2:
	mov	al,err_arg_type		;erreur type argument
	jmp	rpter

; Variable XPEN
	align	16
xpen:
	inc	ebp			;mange XPEN
	mov	ebx,penx		;variable
	jmp	pushi

; Variable YPEN
	align	16
ypen:
	inc	ebp			;mange YPEN
	mov	ebx,peny		;variable
	jmp	pushi

; Variable ARGC
xargc:
	inc	ebp			;mange ARGC
	mov	ebx,arg_c		;variable
	jmp	pushi

; Constante PI
	align	16
dpi:
	inc	ebp			;mange PI
	mov	esi,offset dppi		;PI
	mov	al,fltbit		;type flottant
	jmp	short pshopnd		;PUSH PI

; Code erreur
	align	16
derr:
	inc	ebp			;mange ERR
	mov	ebx,errs
;;;	jmp	short pushi

; PUSH entier
; Entree: EBX=valeur entiere
; Retour: EBX->nouveau sommet pile
;	  NZ
pushi:
	mov	r0i,ebx
	mov	al,intbit		;type entier
;;;	jmp	pushr0			;PUSH

; PUSH pile arithmetique
; Entree: R0=donnee
;	  AL=type
; Retour: EBX->nouveau sommet pile
;	  NZ
pushr0:
	mov	esi,offset r0
;;;	jmp	short pshopnd		;PUSH R0

; PUSH operande
; Entree: ESI=adresse
;	  AL=type (TOK_MARK non positionne)
; Retour: EBX->nouveau sommet pile
;	  NZ
	align	16
pshopnd:
	mov	ebx,atos		;sommet de pile arithmetique
	cmp	ebx,offset astack+maxstk*size opnd ;debordement ?
	jae	short pshopnd2		;oui, erreur
	mov	[ebx].opnd.o_type,al	;range type variable
	test	al,intbit		;entier ?
	jz	short pshopnd1		;non
	mov	eax,[esi]		;valeur entiere
	mov	dword ptr [ebx].opnd.o_value,eax ;range valeur
	add	ebx,size opnd		;PUSH (NZ)
	mov	atos,ebx
	ret				;retour NZ
pshopnd1:
	lea	edi,[ebx].opnd.o_value	;pointeur valeur flottante
	add	ebx,size opnd		;PUSH (NZ)
	movsd				;range valeur
	movsd
	mov	atos,ebx
	ret				;retour NZ
pshopnd2:
	mov	al,err_too_complex
	jmp	rpter

; PUSH parametre
; Entree: ESI=adresse parametre (variable ou valeur)
;	  AL=type parametre (TOK_MARK positionne si variable)
	align	16
pshpara:
	mov	ebx,atos		;sommet de pile arithmetique
	cmp	ebx,offset astack+maxstk*size para ;debordement ?
	jae	pshopnd2		;oui, erreur
	mov	[ebx].para.p_type,al	;type parametre
	mov	[ebx].para.p_addr,esi	;adresse variable ou valeur
	mov	[ebx].para.p_symb,0	;raz adresse symbole
	add	ebx,size para		;PUSH
	mov	atos,ebx
	ret

; Ligne erreur
	align	16
derl:
	inc	ebp			;mange ERL
	mov	ebx,erls
	mov	al,intbit		;valeur entiere
	mov	r0i,ebx
	call	pushr0			;PUSH
	skipst				;saut espace et token
	cmp	al,k_le			;comparaison ?
	jb	short derlr		;non, pas de traitement special
	cmp	al,k_eq
	ja	short derlr		;non
	movzx	eax,al			;token
	push	eax			;sauve token
	push	ebp			;sauve pointeur token
	inc	ebp			;mange token comparaison
	skipst				;saut espace et token
	cmp	al,tok_mark+conbit+linbit ;numero de ligne ?
	jne	short derl1		;non
	mov	ebx,[ebp+1]		;numero de ligne
	add	ebp,1+size_i+size_a	;saute token, numero de ligne et adresse ligne
	call	pushi
	pop	eax			;ignore sauvegarde pointeur token
	pop	eax			;token comparaison
	call	relop			;execution comparaison
	and	ebp,ebp			;retour NZ
	ret
derl1:
	pop	ebp			;restaure pointeur token
	pop	eax
derlr:
	and	ebp,ebp			;retour NZ
	ret

; Fonctions arithmetiques sur chaine
; ASC
	align	16
asc:
	call	stafun			;debut execution fonction sur chaine
	call	nxtsc			;premier charactere chaine
	movzx	eax,al
	mov	r0i,eax
asc1:
	mov	strsptr,ebx		;restaure pointeur de pile chaine
asc2:
	mov	al,intbit		;resultat entier
asc3:
	mov	ebx,strsptr		;pointeur pile chaine
	mov	[ebx].strg.str_addr,0	;marque fin de chaine
	mov	strtos,ebx		;recule sommet pile chaine
	jmp	pushr0			;PUSH

; LEN
	align	16
lenf:
	call	stafun			;debut execution fonction sur chaine
	call	strcnt1			;longueur chaine
	jmp	short asc2

; VAL
	align	16
val:
	call	stafun			;debut execution fonction sur chaine
	push	ebx
	mov	ecx,foblen-1		;longueur tampon
	mov	ebx,offset outbuf	;tampon chaine
	mov	inptr,ebx		;range pointeur caractere entree sur debut chaine
val4:
	call	nxtsc			;caractere chaine
	jz	short val5		;fin de chaine
	cmp	al,' '			;espace ?
	je	val4			;ignore
	mov	[ebx],al		;copie
	inc	ebx
	loop	val4			;boucle avec compteur
val5:
	mov	byte ptr [ebx],cr	;fin de chaine
	pop	strsptr			;restaure pointeur de pile chaine
	call	atof			;conversion chaine en flottant
	mov	al,fltbit		;valeur flottante
	jmp	asc3			;PUSH

; HEX
	align	16
hexf:
	call	stafun			;debut execution fonction sur chaine
	mov	strtos,ebx		;sommet pile chaine
hex2:
	call	nxtsc			;caractere chaine
	jz	asc1			;fin chaine
	sub	al,'G'			;caractere hexadecimal ?
	jns	asc1			;non
	add	al,6			;entre A et F ?
	jns	short hex3		;oui
	add	al,7			;entre 0 et 9 ?
	jns	asc1			;non
hex3:
	add	al,10			;ajuste entre 00h et 0Fh
	js	asc1			;non
	sal	r0i,4			;x16
	movzx	eax,al
	add	r0i,eax			;ajoute digit
	jmp	hex2			;continue

; INSTR
	align	16
xinstr:
	inc	ebp			;mange INSTR
	call	lepar			;mange (
	push	strtos			;sommet pile chaine
	push	1			;debut de chaine par defaut
	call	exp			;evaluation expression
	jz	instr4			;pas d'expression, erreur
	test	strflg,0FFh		;expression chaine ?
	jnz	short instr1		;oui
	call	pulint			;POP entier
	pop	eax			;ignore valeur par defaut
	mov	eax,r0i			;rang debut recherche
	push	eax
	call	comtok			;mange ,
	skipst				;saut espace et token
	call	stexp			;chaine destination recherche
	jz	short instr4		;pas de chaine, erreur
instr1:
	push	strsptr			;pointeur pile chaine
	add	strtos,size strg	;nouvelle chaine
	call	comtok			;mange ,
	skipst				;saut espace et token
	call	stexp			;chaine a rechercher
	jz	short instr4		;pas de chaine, erreur
	call	ripar			;mange )
	pop	strtos			;sommet pile chaine
	pop	eax			;rang debut
	test	eax,eax			;<=0 ?
	jle	short instr4		;oui, erreur
	push	esi
	push	edi
	push	ebp
	dec	eax			;base 0
	mov	r0i,eax			;position de depart
	mov	ecx,eax
	mov	esi,strtos		;chaine destination
	mov	ebp,strsptr		;chaine a rechercher
instr2:
	mov	ebx,esi			;sauve
	lodsd				;adresse sous-chaine
	test	eax,eax			;fin de chaine ?
	jz	instr17			;oui, rang hors chaine destination
	lodsd				;longueur sous-chaine
	sub	ecx,eax			;rang dans sous-chaine ?
	jae	instr2			;non		
	add	ecx,eax			;restaure
	add	[ebx].strg.str_addr,ecx	;ajuste adresse debut sous-chaine
	sub	[ebx].strg.str_len,ecx	;et longueur
instr3:
	mov	esi,[ebp].strg.str_addr	;adresse sous chaine recherche
	mov	edx,[ebp].strg.str_len	;et longueur
	test	esi,esi
	jz	short instr16		;chaine vide, chaine trouvee
	test	edx,edx			;longueur sous-chaine nulle ?
	jnz	short instr5		;non
	add	ebp,size strg		;ignore sous-chaine
	jmp	instr3
instr4:
	jmp	synerr			;erreur de syntaxe
instr5:
	lodsb				;premier caractere recherche
	dec	edx
instr6:
	mov	edi,[ebx].strg.str_addr	;sous-chaine destination
	mov	ecx,[ebx].strg.str_len
	test	edi,edi			;fin de chaine ?
	jz	instr17			;oui, chaine non trouvee
	jecxz	short instr8		;sous-chaine vide
	repne	scasb			;recherche premier caractere
	je	short instr9		;trouve
instr7:
	mov	ecx,[ebx].strg.str_len	;longueur sous-chaine
	add	r0i,ecx			;ajuste position
instr8:
	add	ebx,size strg		;saut sous-chaine
	jmp	instr6
instr9:
	mov	eax,ecx
	xchg	eax,[ebx].strg.str_len	;reste sous-chaine destination
	sub	eax,ecx			;longueur utilisee
	add	r0i,eax			;ajuste position
	mov	[ebx].strg.str_addr,edi	;ajuste pointeur sous-chaine destination
	push	ebx			;sauve pointeur chaine destination
	push	ebp			;sauve pointeur chaine recherchee
instr10:
	dec	edx			;prise en compte caractere identique
	js	short instr14		;fin sous-chaine recherchee
instr11:
	dec	ecx			;fin sous-chaine destination
	js	short instr13
instr12:
	cmpsb				;comparaison caractere suivant
	je	instr10			;identique
	pop	ebp			;restaure pointeur chaine recherchee
	pop	ebx			;restaure pointeur chaine destination
	mov	esi,[ebp].strg.str_addr	;debut sous-chaine recherche
	mov	edx,[ebp].strg.str_len	;et longueur
	jmp	instr5			;retour au premier caractere
instr13:
	add	ebx,size strg		;sous-chaine destination suivante
	mov	edi,[ebx].strg.str_addr	;adresse
	mov	ecx,[ebx].strg.str_len	;longueur
	test	edi,edi			;fin de chaine ?
	jnz	instr11			;non
	mov	r0i,0			;chaine non trouvee
	jmp	instr15
instr14:
	add	ebp,size strg		;sous-chaine recherchee suivante
	mov	esi,[ebp].strg.str_addr	;adresse
	mov	edx,[ebp].strg.str_len	;longueur
	test	esi,esi			;fin de chaine ?
	jnz	instr10			;non
instr15:
	add	esp,2*4			;mange sauvegarde pointeurs chaines
instr16:
	pop	ebp
	pop	edi
	pop	esi
	pop	ebx			;pointeur pile chaine
	mov	strtos,ebx		;restaure
	mov	[ebx].strg.str_addr,0	;marque fin de chaine
	skipst				;saut espace et token
	mov	strflg,0		;raz indicateur expression chaine
	mov	al,intbit		;resultat entier
	jmp	pushr0			;push result
instr17:
	mov	r0i,0
	jmp	instr16

; Fonctions converstion chaine
; CVT$%
	align	16
cvtsi:
	call	stafun			;debut execution fonction sur chaine
	push	ebx			;pointeur pile chaines
	mov	al,intbit		;valeur entiere
	mov	ecx,size_i		;taille entier
	mov	ebx,offset r0i
	jmp	short cvtsf1

; CVT$F
	align	16
cvtsf:
	call	stafun			;debut execution fonction sur chaine
	push	ebx			;pointeur pile chaines
	mov	al,fltbit		;valeur flottante
	mov	ecx,size_f		;taille flottant
	mov	ebx,offset r0
cvtsf1:
	push	eax
cvtsf2:
	call	nxtsc			;caractere chaine suivant
	jz	short cvtsf3		;fin de chaine
	mov	[ebx],al
	inc	ebx
	loop	cvtsf2
	jmp	short cvtsf4		;fin copie
cvtsf3:
	mov	byte ptr [ebx],0	;complete avec des zeros
	inc	ebx
	loop	cvtsf3
cvtsf4:
	pop	eax			;type resultat
	pop	strsptr			;restaure pointeur pile chaines
	jmp	asc3			;PUSH RESULT

; Evaluation expression chaine
; Retour: NZ si chaine ou comparaison chaine
;	  AL=token courant
	align	16
stexp:
	push	strtos			;sommet pile chaine
	call	spr3
	pop	strsptr			;dans pointeur pile chaine
	jz	short stexp1		;pas de chaine
	test	strflg,0FFh		;expression chaine ?
	jz	short stexp2		;non
	cmp	al,k_le			;operateur comparaison ?
	jb	short stexp1		;non
	cmp	al,k_eq
	jbe	short stexp4		;non
stexp1:
	ret				;retour NZ
stexp2:
	test	al,al			;NZ
	ret				;retour
stexp3:
	mov	al,err_exp		;erreur expression
	jmp	rpter
stexp4:
	movzx	eax,al			;token comparaison
	inc	ebp			;mange token
	add	strtos,size strg	;nouvelle chaine
	push	eax
	push	strsptr			;sauve pointeur chaine
	push	strtos			;sauve sommet pile chaine
	skipst				;saut espace et token
	call	spr3			;chaine ?
	pop	strsptr			;pointeur sur seconde chaine
	pop	strtos			;sommet pile sur premiere chaine
	jz	stexp3			;non, erreur
	mov	strflg,0		;raz indicateur expression chaine
	push	ebp
	mov	ebx,strtos		;premiere chaine
	mov	ebp,strsptr		;seconde chaine
cmpst1:
	call	getcmp1			;pointeur premiere sous-chaine
	jz	short cmpst3		;fin de chaine
	call	getcmp2			;pointeur seconde sous-chaine
	jz	short cmpst4		;fin de chaine
	cmp	ecx,edx			;comparaison longueur sous-chaines
	ja	short cmpst2		;premiere sous-chaine plus longue
	sub	edx,ecx			;excedent seconde sous-chaine
	mov	[ebx].strg.str_len,0	;prise en compte premiere sous-chaine
	add	[ebp].strg.str_addr,ecx	;debut excedent
	mov	[ebp].strg.str_len,edx
	repz	cmpsb			;comparaison
	je	cmpst1			;egalite, continue
	jmp	short cmpst5		;resultat comparaison dans les flags
cmpst2:
	xchg	ecx,edx
	sub	edx,ecx			;excedent premier sous-chaine
	mov	[ebp].strg.str_len,0	;prise en compte seconde sous-chaine
	add	[ebx].strg.str_addr,ecx	;debut excedent
	mov	[ebx].strg.str_len,edx
	repz	cmpsb			;comparaison
	je	cmpst1			;egalite, continue
	jmp	short cmpst5		;resultat comparaison dans les flags
cmpst3:
	call	getcmp2			;pointeur seconde sous-chaine
cmpst4:
	cmp	ah,al			;comparaison longueurs
cmpst5:
	mov	ebx,strtos
	mov	[ebx].strg.str_addr,0	;marque fin de chaine
	pop	ebp
	pop	eax
	pushfd
	push	eax
	mov	al,intbit		;type entier
	call	pushr0			;PUSH pour place en sommet de pile
	pop	eax			;token comparaison
	popfd
	lea	esi,[ebx-size opnd].opnd.o_value ;adresse resultat
	call	relop3			;traitement operation relation
	test	ebp,ebp			;retour NZ
	ret

; Priorite 3 (+)
; Retour: ZF si pas de chaine
;	  AL=token courant
	align	16
spr3:
	call	spr1
	jz	short spr32		;pas de chaine, retour ZF
spr31:
	cmp	al,k_plus		;+ ?
	je	short spr33		;oui
spr32:
	ret				;retour NZ
spr33:
	inc	ebp			;mange +
	skipst				;saut espace et token
	cmp	al,k_indirect		;indirection ?
	je	short spr35		;oui
spr34:
	call	spr1
	jnz	spr31
	mov	al,err_exp		;erreur expression
	jmp	rpter
spr35:
	inc	ebp			;mange indirection
	mov	al,[ebp]		;token extension
	jmp	spr34

; Priorite 1 (operande chaine)
; Retour: ZF si pas de chaine
;	  AL=token courant
	align	16
spr1:
	test	al,al			;mot cle ?
	js	short strop		;non
	cmp	al,k_date$		;fonction chaine ?
	jb	short spr11		;non
	cmp	al,k_string$
	ja	short spr12		;non
	movzx	ebx,al
	inc	ebp			;mange token fonction
	skipst				;saut espace et token
	jmp	strfnc[ebx*4-k_date$*4]	;branchement fonction
spr11:
	cmp	al,k_argv$		;ARGV$ ?
	je	xargv			;oui
	cmp	al,al			;pas une chaine, retour ZF
	ret
spr12:
	cmp	al,k_ampersand		;& ?
	je	getex			;chaine hexadecimale
subsex:
; Evalutation sous-chaine
	call	lepar			;mange (
	skipst				;saut espace et token
	call	stexp			;evaluation expression chaine
	jz	short subsex2		;pas de chaine, erreur
	cmp	al,k_rbracket		;) ?
	jne	short subsex1		;non
	inc	ebp			;mange )
	skipst				;saut espace et token
	test	al,al			;retour NZ
	ret
subsex1:
	mov	al,err_bracket_bal	;erreur balance parentheses
	jmp	rpter
subsex2:
	jmp	synerr
strop:
; Operande chaine
	test	al,strbit		;chaine ?
	jz	short strop1		;non, retour ZF
	cmp	al,tok_mark+conbit+strbit ;constante chaine ?
	jb	short stvar		;non, variable chaine
	jne	short strop2		;erreur
; Constante chaine
	movzx	eax,byte ptr [ebp+1]	;longueur chaine
	movzx	ecx,byte ptr [ebp+2]	;longueur representation
	add	ebp,4			;saute token, longueur chaine, longueur representation, quote ou double-quote
	mov	ssptr,ebp		;pointeur sous-chaine pour PSHST
	dec	ebp			;debut representation
	add	ebp,ecx			;pointeur token apres representation
	jmp	short pshstr		;PUSH operande chaine
strop1:
	ret
strop2:
	mov	al,err_exp		;erreur expression
	jmp	rpter
stvar:
; Variable chaine
	call	avar			;adresse variable
	test	al,arrbit		;tableau ?
	jnz	strop2			;oui, erreur
	mov	ebx,[esi].strg.str_addr	;addresse chaine
	test	ebx,ebx			;chaine nulle ?
	jz	short pshst6		;oui
	mov	ssptr,ebx		;adresse chaine pour PSHST
	mov	eax,[esi].strg.str_len	;longueur chaine
	and	eax,07FFFFFFFh		;raz indicateur FIELD
;;;	jmp	short pshstr		;PUSH operande chaine

; PUSH operande chaine
; Entree: EAX=longueur chaine
;	  SSPTR=adresse chaine
pshstr:
	test	eax,eax			;longueur nulle ?
	mov	ebx,strtos		;pointeur pile chaines
	jz	short pshst4		;oui
	cmp	ebx,offset strstk+maxstr*size strg ;debordement pile?
	ja	short pshst7		;oui
	mov	[ebx].strg.str_len,eax	;range longueur
pshst1:
	mov	eax,ssptr		;adresse sous-chaine
	mov	[ebx].strg.str_addr,eax	;range adresse
pshst2:
	add	ebx,size strg		;ajuste pointeur pile chaines
pshst3:
	mov	strtos,ebx		;nouveau sommet de pile
pshst4:
	mov	[ebx].strg.str_addr,0	;fin de chaine
pshst5:
	mov	strflg,0FFh		;indique expression chaine
	skipst				;saut espace et token
	ret
pshst6:
	mov	ebx,strtos		;pointeur pile chaine
	jmp	pshst4
pshst7:
	mov	al,err_too_complex
	jmp	rpter

; Chaine hexadecimale
getex:
	inc	ebp			;mange &
	mov	strflg,0		;raz indicateur expression chaine
	call	exp			;evaluation expression
	jz	short getex1		;pas d'expression
	call	pulint			;POP entier
	mov	edx,r0i			;resulat binaire
	rol	edx,8
	mov	al,dl
	call	getex2			;2 digits
	shl	eax,16
	rol	edx,8
	mov	al,dl
	call	getex2			;2 digits
	rol	eax,16
	mov	dword ptr outbuf,eax
	rol	edx,8
	mov	al,dl
	call	getex2			;2 digits
	shl	eax,16
	rol	edx,8
	mov	al,dl
	call	getex2			;2 digits
	rol	eax,16
	mov	dword ptr outbuf+4,eax
	mov	len,8			;8 digits
	jmp	strd2			;retourne chaine
getex1:
	jmp	synerr			;erreur de syntaxe

; Conversion octet en ASCII hexadecimal
; Entree: AL=octet
; Retour: AX=2 caractere ASCII
	align	16
getex2:
	mov	ah,al
	call	getex21			;1 caractere
	xchg	ah,al
	shr	al,4
getex21:
	and	al,0Fh
	add	al,'0'
	cmp	al,'9'
	jbe	short getex22
	add	al,7
getex22:
	ret

; Table aiguillage fonctions chaine
	align	16
strfnc:
	dd	offset date
	dd	offset chrd
	dd	offset left
	dd	offset right
	dd	offset mid
	dd	offset strd
	dd	offset inchs
	dd	offset cvtis
	dd	offset cvtfs
	dd	offset ltrm
	dd	offset rtrm
	dd	offset strng

; DATE$
	align	16
date:
	mov	eax,20			;longueur chaine 'JJ/MM/AA HH:MM:SS:CC'
	push	eax
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	edi,ebx
	call	fdate
	call	setdate
	call	ftime
	call	settime
	pop	eax			;longueur chaine
	jmp	pshstr			;PUSH operande chaine

; CHR$
	align	16
chrd:
	mov	strflg,0		;raz indicateur expression chaine
	call	subexp			;argument
	call	pulbyt			;resultat octet
chrd1:
	push	eax
	mov	eax,1			;chaine de longueur 1
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	pop	eax
	mov	[ebx],al		;range code caractere
	mov	eax,1			;1 caractere
	jmp	pshstr			;PUSH operande chaine

; LEFT$
	align	16
left:
	call	sfarg			;(chaine, entier)
left2:
	call	ithch			;position caractere par rapport au debut
	jz	short left3		;hors chaine, garde tout
	mov	[ebx].strg.str_len,eax	;ajuste longueur segment courant
	jmp	pshst2			;ignore les segments suivants
left3:
	jmp	pshst5			;retour chaine

; RIGHT$
	align	16
right:
	call	sfarg			;(chaine, entier)
	push	ebx
	call	strcnt			;longueur chaine
	pop	edx			;nombre de caracteres en fin de chaine
	cmp	eax,edx			;inferieur a la longueur de la chaine ?
	jle	left3			;non, garde toute la chaine
	sub	eax,edx			;nombre de caracteres a sauter
	mov	r0i,eax			;remplace expression
right1:
	call	ithch			;position caractere par rapport au debut
	jz	right2			;hors chaine, a priori impossible!
	add	[ebx].strg.str_addr,eax	;ajuste debut de chaine
	sub	[ebx].strg.str_len,eax	;ajuste longueur
right2:
	mov	ebx,strsptr		;pointeur pile chaine
right3:
	cmp	ebx,temp		;dernier segment ?
	je	left3			;oui, retour chaine
	mov	[ebx].strg.str_len,0	;segment de longueur nulle
	add	ebx,size strg		;entree pil chaines suivante
	jmp	right3			;continue

; MID$
	align	16
mid:
	call	sarg			;(chaine, entier
	jz	short mid2		;expression nulle, retour chaine vide
	dec	ebx			;caracteres a sauter
	mov	r0i,ebx
	call	right1			;saute caracteres
	skipst				;saut espace et token
mid1:
	inc	ebp			;mange MID$
	cmp	al,k_rbracket		;) ?
	je	left3			;oui, idem RIGHT$
	cmp	al,k_comma		;, ?
	jne	mid3			;non, erreur
	call	sarg1			;entier
	call	ripar			;mange )
	jmp	left2			;finit comme LEFT$
mid2:
	mov	ebx,strsptr		;pointeur pile chaines
	call	pshst4			;chaine vide
	jmp	short mid1
mid3:
	jmp	synerr			;erreur de syntaxe

; STR$
	align	16
strd:
	mov	strflg,0		;raz indicateur expression chaine
	call	subexp			;argument
	call	popr0			;POP argument
	test	al,intbit		;entier ?
	jz	short strd1		;non
	call	itoa			;conversion entier en chaine ASCII
	jmp	short strd2
strd1:
	call	ftoa			;convertion flottant en chaine ASCII
strd2:
	mov	eax,len			;longueur chaine
	test	eax,eax			;nulle ?
	jz	short strd3		;oui
	push	eax
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	edi,ebx
	mov	ecx,len
	mov	esi,offset outbuf
	rep	movsb			;recopie tampon de sortie
	pop	eax
strd3:
	jmp	pshstr			;PUSH operande chaine

; INCH$
	align	16
inchs:
	mov	strflg,0		;raz indicateur expression chaine
	call	lepar			;mange (
	call	exp			;evaluation expression
	jz	inchs9			;non, erreur
	call	pulint			;entier
	mov	eax,r0i			;parametre
	test	eax,eax			;negatif
	js	short inchs5		;oui, test caractere en attente
	push	eax			;numero de canal
	skipst				;saut espace et token
	mov	ecx,1			;1 caractere par defaut
	cmp	al,k_comma		;, ?
	jne	short inchs1		;non
	inc	ebp			;mange ,
	call	exp			;evaluation expression
	jz	short inchs9		;non, expression
	call	pulint			;entier
	mov	eax,r0i			;nombre de caracteres
	test	eax,eax			;strictement positif ?
	jle	short inchs7		;non
	mov	ecx,eax			;nombre de caracteres
inchs1:
	call	ripar			;mange )
	pop	eax			;numero de cannal
	push	ecx
	call	selchn			;selection canal
	pop	eax			;nombre de caracteres
inchs2:
	push	eax
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	ecx,eax			;compteur caracteres
	call	inch			;lecture premier caractere
	jc	short inchs8		;erreur
inchs3:
	mov	[ebx],al		;range caractere
	inc	ebx			;avance pointeur
	dec	ecx			;decremente compteur
	jz	short inchs4		;fin de lecture
	call	inch			;lecture caractere suivant
	jnc	inchs3			;pas d'erreur, continue
	cmp	al,err_eof		;fin de fichier ?
	jne	short inchs8		;non, erreur
inchs4:
	pop	eax
	sub	eax,ecx			;longueur effective
	mov	filswi,0		;pas de fichier d'entree
	jmp	pshstr			;PUSH operande chaine
inchs5:
	call	ripar			;mange )
	call	status			;caractere en attente ?
	jz	short inchs6		;non, retourne chaine vide
	mov	eax,1			;1 caractere
	jmp	inchs2			;lecture
inchs6:
	xor	eax,eax
	jmp	pshstr			;PUSH operande chaine
inchs7:
	mov	al,err_neg_arg		;argument negatif
inchs8:
	jmp	rpter
inchs9:
	jmp	synerr			;erreur de syntaxe

; CVT%$
	align	16
cvtis:
	mov	strflg,0		;raz indicateur expression chaine
	call	subexp			;argument
	call	pulint			;entier
	mov	eax,size_i		;taille entier
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	eax,r0i			;valeur
	mov	[ebx],eax		;dans chaine
	mov	eax,size_i		;taille entier
	jmp	pshstr			;PUSH operande chaine

; CVTF$
	align	16
cvtfs:
	mov	strflg,0		;raz indicateur expression chaine
	call	subexp			;argument
	call	pulfp			;flottant
	mov	eax,size_f		;taille flottant
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	mov	eax,dword ptr r0	;valeur
	mov	[ebx],eax		;dans chaine
	mov	eax,dword ptr r0+4
	mov	[ebx+4],eax
	mov	eax,size_f		;taille flottant
	jmp	pshstr			;PUSH operande chaine

; LTRM$
	align	16
ltrm:
	call	subsex			;argument chaine
	push	strsptr			;sauve pointeur pile chaine
	xor	ebx,ebx			;position
	mov	r0i,ebx			;defaut
	mov	first,ebx		;pour NXTSC
ltrm1:
	call	nxtsc			;caractere chaine suivant
	jz	short ltrm2		;fin de chaine
	inc	ebx			;position suivante
	cmp	al,' '			;espace ?
	je	ltrm1			;oui
	mov	r0i,ebx			;sauve position dernier caractere non espace
	jmp	ltrm1
ltrm2:
	pop	strsptr			;restaure pointeur pile chaine
	jmp	left2			;continue avec LEFT$

; RTRM$
	align	16
rtrm:
	call	subsex			;argument chaine
	push	strsptr			;sauve pointeur pile chaine
	xor	ebx,ebx			;position
	mov	first,ebx		;pour NXTSC
rtrm1:
	call	nxtsc			;caractere chaine suivant
	jz	short rtrm2		;fin de chaine
	cmp	al,' '			;espace ?
	jne	short rtrm2		;non
	inc	ebx			;position suivante
	jmp	rtrm1
rtrm2:
	mov	r0i,ebx			;premier caractere non espace
	pop	strsptr			;restaure pointeur pile chaine
	jmp	right1			;continue avec RIGHT$

; STRING$
	align	16
strng:
	call	sfarg			;(chaine, entier)
	mov	eax,r0i			;nombre de repetitions
	test	eax,eax			;nul ?
	jz	short strng2		;oui
	dec	eax			;une fois ?
	jz	short strng3		;oui
	push	eax
	call	strcnt			;longueur chaine
	test	eax,eax			;vide ?
	pop	ecx
	jz	short strng3		;oui, retourne
	push	eax
	mul	ecx			;longueur x repetitions
	test	edx,edx			;debordement ?
	jnz	short strng4		;oui
	test	eax,eax
	js	short strng4		;oui
	push	eax
	call	sstmp			;allocation memoire temporaire pour sous-chaine
	push	strsptr			;sauve pointeur pile chaine
	call	strtox			;copie chaine dans debut memoire temporaire
	pop	strsptr			;restaure pointeur pile chaine
	pop	ecx			;longueur chaine resultante
	pop	eax			;longueur chaine initiale
	sub	ecx,eax			;reste a copier
	jz	short strng1		;rien
	mov	edx,ecx
	push	esi
	mov	esi,ssptr		;pointeur sous-chaine
	mov	edi,ebx			;apres la premiere copie
	rep	movsb			;recopie cyclique
	pop	esi
	add	eax,edx			;longueur chaine resultante
strng1:
	jmp	pshstr			;PUSH operande chaine
strng2:
	mov	ebx,strsptr		;pointeur pile chaines
	jmp	pshst3			;retourne chaine vide
strng3:
	jmp	pshst5			;retour chaine
strng4:
	mov	al,err_memory_ovf	;debordement memoire
	jmp	rpter

; ARGV$
xargv:
	inc	ebp			;mange extension ARGV$
	skipst				;saut espace et token
	mov	strflg,0		;raz indicateur expression chaine
	call	subexp			;argument
	call	pulint			;entier
	mov	eax,r0i			;valeur
	cmp	eax,arg_c		;index argument valide ?
	jae	short xargv3		;non, erreur
	mov	esi,arg_v		;adresse table des pointeurs argument
	mov	esi,[esi+eax*4]		;pointeur chaine argument
	mov	ssptr,esi		;adresse chaine pour PSHST
	xor	ecx,ecx			;compteur caracteres
xargv1:
	lodsb
	and	al,al			;fin chaine argument ?
	jz	short xargv2		;oui
	inc	ecx			;un caractere de plus
	jmp	xargv1			;jusqu'a fin de chaine
xargv2:
	mov	eax,ecx			;longueur chaine
	jmp	pshstr			;PUSH operande chaine
xargv3:
	mov	al,err_dim_out		;hors dimension tableau
	jmp	rpter

; Operateur ! "chaine"
; retourne code mot-cle "chaine" * 256 + longueur
	align	16
gettyp:
	inc	ebp			;mange !
	skipst				;saut espace et token
	call	stexp			;evaluation chaine
	jz	short gettyp1		;erreur
	call	strtobuf		;copie dans tampon de travail
	mov	tokflg,0FFh		;pas de rangement token
	mov	inptr,offset buffer	;point caratere entree sur debut chaine
	call	getok
	mov	ebx,inptr		;pointeur caractere tampon entree
	sub	ebx,offset buffer	;taille token
	mov	bh,al
	mov	r0i,ebx			;resultat
	mov	strflg,0		;raz indicateur expression chaine
	mov	al,intbit		;type entier
	jmp	pushr0			;PUSH
gettyp1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Routines
; Sous expression
	align	16
subexp:
	skipst				;saut espace et token
	cmp	al,k_lbracket		;( ?
	jne	short subexp2		;non, pas de sous expression
subexp1:
	inc	ebp			;mange (
	call	exp			;evaluation expression
	jz	short subexp4		;pas d'expression, erreur
	cmp	al,k_rbracket		;)?
	jne	short subexp3		;non
	inc	ebp			;mange )
	test	al,al			;retour NZ
	ret
subexp2:
	cmp	al,al			;retour ZF
	ret
subexp3:
	mov	al,err_bracket_bal	;erreur balance parentheses
	jmp	rpter
subexp4:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Evaluation octet
	align	16
evlbyt:
	call	eval			;evalue expression dans R0
	test	strflg,0FFh		;expression chaine ?
	jz	short pulbyt1		;non
evlbyt1:
	mov	al,err_arg_type		;erreur type argument
	jmp	rpter

; POP octet
	align	16
pulbyt:
	call	popr0			;POP dans R0
pulbyt1:
	test	al,intbit		;entier ?
	jnz	short pulbyt2		;oui
	call	rintgr			;convertion R0 en entier avec arrondi
pulbyt2:
	mov	eax,r0i
	test	eax,0FFFFFF00h		;<=255 ?
	jnz	short pulbyt3		;non, debordement
	ret
pulbyt3:
	mov	al,err_ubyte_out	;debordement octet
	jmp	rpter

;POP entier
	align	16
pulint:
	call	popr0			;POP dans R0
	jmp	short evlint1		;continue

; Evaluation entier
	align	16
evlint:
	call	eval			;evalue expression dans R0
	test	strflg,0FFh		;expression chaine ?
	jnz	evlbyt1			;oui, erreur
evlint1:
	test	al,intbit		;entier ?
	jnz	short evlint2		;oui
	jmp	rintgr			;convertion R0 en entier avec arrondi
evlint2:
	ret

;POP entier non signe
	align	16
pulins:
	call	popr0			;POP dans R0
	jmp	short evluint1		;continue

; Evaluation entier non signe
	align	16
evluint:
	call	eval			;evalue expression dans R0
	test	strflg,0FFh		;expression chaine ?
	jnz	evlbyt1			;oui, erreur
evluint1:
	test	al,intbit		;entier ?
	jz	short evluint2		;non
	test	r0+3,0FFh		;signe ?
	js	short evluint3		;oui, erreur
	ret
evluint2:
	jmp	uintgr			;convertion entier non signe et retour
evluint3:
	mov	al,err_neg_arg		;argument negatif
	jmp	rpter

; Execution comparaison
; Entree: AL=token comparaison (k_le...k_eq)
	align	16
relop:
	push	eax
	call	ptr2ops			;pointeurs vers operandes
	jnz	short relop1		;operandes entiers
	call	dcmp			;comparaison flottante
	jmp	short relop2
relop1:
	call	icmp			;comparaison entiere
relop2:
	pop	eax			;token
relop3:
	jmp	rlpp[eax*4-4*k_le]
	align	16
rlpp	dd	offset rlpp_le
	dd	offset rlpp_ge
	dd	offset rlpp_dif
	dd	offset rlpp_lt
	dd	offset rlpp_gt
	dd	offset rlpp_eq
rlpp_le:
	jbe	short reltru		;'<='?
	jmp	short relfls
rlpp_ge:
	jae	short reltru		;'>='?
	jmp	short relfls
rlpp_dif:
	jne	short reltru		;'<>'?
	jmp	short relfls
rlpp_lt:
	jb	short reltru		;'<'?
	jmp	short relfls
rlpp_gt:
	ja	short reltru		;'>'?
	jmp	short relfls
rlpp_eq:
	je	short reltru		;'='?
relfls:
	xor	eax,eax			;faux
relret:
	mov	[esi],eax		;resultat
	push	ebx
	mov	ebx,atos		;sommet pile
	mov	[ebx-size opnd].opnd.o_type,intbit ;type resultat entier
	pop	ebx
	ret
reltru:
	mov	eax,-1			;vrai
	jmp	relret

; Arguments (chaine, entier)
	align	16
sfarg:
	call	sarg			;(chaine, entier
;;;	jmp	short ripar

; Attend parenthese fermante
ripar:
	skipst				;saut espace et token
	cmp	al,k_rbracket		;) ?
	jne	short toker		;non, erreur
	inc	ebp			;mange )
	ret
toker:
	jmp	synerr			;erreur de syntaxe

; Attend parenthese ouvrante
	align	16
lepar:
	skipst				;saut espace et token
	cmp	al,k_lbracket		;( ?
	jne	toker			;non, erreur
	inc	ebp			;mange (
	ret

; Attend virgule
	align	16
comtok:
	skipst				;saut espace et token
	cmp	al,k_comma		;, ?
	jne	toker			;non, erreur
	inc	ebp			;mange ,
	ret

; Arguments (chaine, entier
	align	16
sarg:
	call	lepar			;attend (
	skipst				;saut espace et token
	call	stexp			;argument chaine
	jz	short sarg2		;pas de chaine, erreur
	call	comtok			;attend ,
sarg1:
	skipst				;saut espace et token
	mov	strflg,0		;raz indicateur expression chaine
	push	strsptr			;sauve pointeur pile chaine
	call	exp			;evaluation expression
	jz	short sarg2		;pas d'expression
	pop	strsptr			;restaure pointeur pile chaine
	call	pulint			;entier
	mov	ebx,r0i			;CHECK RESULT
	test	ebx,ebx			;>=0 ?
	js	toker			;non, erreur
	ret
sarg2:
	jmp	synerr			;erreur de syntaxe

; Debut execution fonction sur chaine
; Retour: EBX=pointeur pile chaine
	align	16
stafun:
	inc	ebp			;mange token fonction
	call	subsex			;argument chaine
	mov	strflg,0		;retour fonction non chaine
	xor	eax,eax
	mov	first,eax		;raz longueur chaine
	mov	r0i,eax			;raz valeur retour par defaut
	mov	ebx,strsptr		;pointeur pile chaine
	ret

; Allocation memoire temporaire pour sous-chaine
; Entree: EAX=longueur chaine
; Retour: EBX->sous-chaine allouee
;	  SSPTR->sous-chaine allouee
	align	16
sstmp:
	cmp	eax,maxlen		;longeur maximale dans tampon allocations temporaires
	mov	ecx,eax
	ja	short sstmp1
	mov	ebx,tmpptr		;pointeur temporaires
	mov	edx,ebx
	add	edx,eax
	cmp	edx,offset tmps+maxtmp	;debordement tampon ?
	ja	short sstmp1		;oui
	mov	tmpptr,edx		;avance pointeur temporaires
	jmp	short sstmp4		;retour adresse
sstmp1:
	add	eax,size strg		;ajout taille entete
	call	allocds			;allocation memoire
	push	ebx
	mov	ebx,offset sschn	;chaine des sous-chaines temporaires
sstmp2:
	mov	eax,[ebx].strg.str_addr
	test	eax,eax			;fin de chaine ?
	je	short sstmp3		;oui
	mov	ebx,eax			;entree suivante
	jmp	sstmp2
sstmp3:
	pop	eax
	mov	[ebx].strg.str_addr,eax	;chainage
	mov	ebx,eax
	mov	[ebx].strg.str_addr,0	;marque fin de chaine
	mov	eax,ecx			;longueur sous-chaine
	add	eax,size strg		;ajout taille entete
	mov	[ebx].strg.str_len,eax	;longueur allocation
	add	ebx,size strg		;debut memoire temporaire sous-chaine
sstmp4:
	mov	ssptr,ebx		;sauve pointeur sous-chaine
	mov	eax,ecx			;restaure longueur
	ret

; Copie chaine dans tampon de travail
	align	16
strtobuf:
	call	strcnt			;longueur chaine
	cmp	eax,maxbuf		;rentre dans tampon ?
	jae	short strtobuf1		;non
	mov	ebx,offset buffer	;tampon
	call	strtox			;copie chaine
	mov	byte ptr [ebx],cr	;ajoute fin de chaine
	ret
strtobuf1:
	mov	al,err_exp		;erreur expression
	jmp	rpter

; Longueur chaine dans pile
; Entree: STRSPTR=pointeur pile chaine
; Retour: R0I=longueur
;	  EAX=longueur
;	  TEMP=pointeur pile fin de chaine
	align	16
strcnt:
	mov	ebx,strsptr		;pointeur pile chaine
strcnt1:
	xor	eax,eax			;compte caracteres
strcnt2:
	mov	edx,[ebx].strg.str_addr	;fin de chaine ?
	test	edx,edx
	jz	short strcnt3		;oui
	add	eax,[ebx].strg.str_len	;prise en compte sous-chaine
	js	short strcnt4		;debordement longueur
	add	ebx,size strg		;entree pile chaine suivante
	jmp	strcnt2			;continue
strcnt3:
	mov	temp,ebx		;sauve pointeur pile fin de chaine (voir RIGHT)
	mov	r0i,eax			;retour longueur
	ret
strcnt4:
	mov	al,err_str_len		;chaine trop longue
	jmp	rpter

; Transfert chaine de pile vers EBX
; Entree: EBX=pointeur tampon
; Retour: EBX=pointeur apres chaine
	align	16
strtox:
	push	esi
	mov	edi,ebx
	mov	ebx,strsptr		;pointeur pile chaines
strtox1:
	mov	esi,[ebx].strg.str_addr	;adresse segment chaine
	test	esi,esi			;fin de chaine ?
	jz	short strtox3		;oui
	mov	ecx,[ebx].strg.str_len	;longueur segment
	rep	movsb			;copie
strtox2:
	add	ebx,size strg		;entree pile chaine suivante
	jmp	strtox1
strtox3:
	mov	ebx,edi			;pointeur apres chaine
	pop	esi
	ret

; Pointeur premiere chaine
; Retour: ESI->sous-chaine
;	  ECX=longueur sous-chaine
;	  AH=0 et ZF si fin de chaine
	align	16
getcmp1:
	xor	ah,ah			;
getcmp11:
	mov	esi,[ebx].strg.str_addr
	test	esi,esi			;fin de chaine ?
	jz	short getcmp13		;oui
	mov	ecx,[ebx].strg.str_len
	test	ecx,ecx			;longueur nulle
	jnz	short getcmp12		;non
	add	ebx,size strg
	jmp	getcmp11
getcmp12:
	inc	ah			;AH=1
getcmp13:
	ret

; Pointeur seconde chaine
; Retour: EDI->sous-chaine
;	  EDX=longueur sous-chaine
;	  AL=0 et ZF si fin de chaine
	align	16
getcmp2:
	xor	al,al
getcmp21:
	mov	edi,[ebp].strg.str_addr
	test	edi,edi			;fin de chaine ?
	jz	short getcmp23		;oui
	mov	edx,[ebp].strg.str_len
	test	edx,edx			;longueur nulle ?
	jnz	short getcmp22		;non
	add	ebp,size strg
	jmp	getcmp21
getcmp22:
	inc	al			;AL=1
getcmp23:
	ret

; Caractere suivant chaine dans pile
; Entree: FIRST=caracteres restant dans segment
;	  LASTX=pointeur caractere suivant dans segment
;	  STRSPTR=pointeur pile chaines
; Retour: AL=caractere
;	  ZF si fin de chaine
	align	16
nxtsc:
	push	ebx
nxtsc1:
	mov	ebx,first		;caracteres restants dans segment
	test	ebx,ebx			;fin segment ?
	jz	short nxtsc3		;oui
	dec	ebx			;decompte
	mov	first,ebx		;range
	mov	ebx,lastx		;pointeur caractere
	mov	al,[ebx]		;caractere
	inc	ebx			;avance pointeur
	mov	lastx,ebx		;range
nxtsc2:
	pop	ebx
	ret
nxtsc3:
	mov	ebx,strsptr		;pointeur pile chaines
	mov	eax,[ebx].strg.str_len	;longueur segment
	mov	first,eax		;range
	mov	eax,[ebx].strg.str_addr	;adresse segment
	test	eax,eax			;fin de chaine ?
	jz	nxtsc2			;oui
	mov	lastx,eax		;range
	add	ebx,size strg		;entree pile chaines suivante
	mov	strsptr,ebx		;range
	jmp	nxtsc1

; Positionnement sur Nieme caractere chaine
; Entree: STRSPTR=pointeur pile chaines
;	  R0I=position demandee
; Retour: EAX et LEN=position dans segment chaine
;	  EBX et TEMP=pointeur pile chaine
;	  ZF si position hors chaine
	align	16
ithch:
	mov	ebx,strsptr		;pointeur pile chaines
	xor	eax,eax			;longueur
ithch1:
	mov	edx,[ebx].strg.str_addr	;adresse chaine
	test	edx,edx			;fin de chaine ?
	jz	short ithch3		;oui, position hors chaine
	add	eax,[ebx].strg.str_len	;ajout longueur segment
	cmp	eax,r0i			;position dans segment ?
	jae	short ithch2		;oui
	add	ebx,size strg		;segment chaine suivant
	jmp	ithch1			;continue
ithch2:
	sub	eax,r0i			;reste chaine
	mov	edx,eax			
	mov	eax,[ebx].strg.str_len	;longueur segemnt
	sub	eax,edx			;position dans segment
	mov	len,eax			;range
	inc	edx			;NZ
ithch3:
	mov	temp,ebx		;range pointeur pile chaine (voir RIGHT)
	ret

; Chaine date au format JJ/MM/AA
; Entree: DL=jour
;	  DH=mois
;	  CX=annee
	align	16
setdate:
	mov	al,dl
	call	setasci			;jour
	mov	al,dh
	mov	bl,'/'
	call	setascix		;/ mois
	mov	ax,cx
	xor	dx,dx
	mov	cx,100
	div	cx
	xchg	ax,dx			;/ annee
	jmp	short setascix

; Chaine heure au format JJ:MM:SS:CC
; Entree: CH=heure
;	  CL=minutes
;	  DH=secondes
;	  DL=100ieme de seconde
	align	16
settime:
	mov	al,ch
	mov	bl,' '
	call	setascix		;' ' heure
	mov	al,cl
	mov	bl,':'
	call	setascix		;: minutes
	mov	al,dh
	call	setascix		;: secondes
	mov	bl,'.'
	mov	al,dl
setascix:
	mov	[edi],bl
	inc	edi
setasci:
	xor	ah,ah
	mov	bh,10
	div	bh
	add	ah,'0'
	add	al,'0'
	mov	[edi],ax
	inc	edi
	inc	edi
	ret

	end