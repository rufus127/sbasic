	page	,132
	name	math

	public	dpten
	public	dpund
	public	dpone
	public	dppi
	public	dwordten
	public	fltinit
	public	iadd
	public	isub
	public	icmp
	public	imod
	public	intmul
	public	intdiv
	public	dpadd
	public	dpsub
	public	dpmul
	public	dpdiv
	public	dcmp
	public	dpmod
	public	dsignum
	public	dintf
	public	drnd
	public	dpabs
	public	dsqrt
	public	dpowri
	public	dlog
	public	dexp
	public	dsine
	public	dcosine
	public	dtan
	public	datan
	public	dpower
	public	ifadd
	public	ifmul
	public	floatr0
	public	float
	public	intger
	public	uintgr
	public	rintgr
	public	ftoa
	public	r0tor1
	public	itoa
	public	atof
	public	atoii

	.model	flat,c

	include sbasic.inc

	.data
;Variables calcul
rndm		dw	1234,5678	;semence generateur aleatoire
rndsav		dd	?		;sauvegarde semence precedente
obufptr		dd	?		;pointeur tampon de sortie
temp32		dd	?		;variable temporaire 32 bits
temp16		dw	?		;variable temporaire 16 bits
rsign		db	?		;signe resultat
eflag		db	?		;indicateur notation scientifique
zerobc		db	?		;indicateur 0 avant la virgule
digcnt		db	?		;nombre de chiffres lus
esign		db	?		;signe exposant
ebyte		db	?		;exposant
ldigit		db	?		;chiffres a gauche de la virgule
rdigit		db	?		;chiffres a droite de la virgule 

	.code
	extrn	rpter:near
	extrn	skipsps:near

; Constantes flottantes
dphalf	db	000h,000h,000h,000h,000h,000h,0E0h,03Fh ;0.5
dpten	db	000h,000h,000h,000h,000h,000h,024h,040h ;1E+01
dpund	db	000h,000h,000h,000h,000h,000h,059h,040h ;1E+02
	db	000h,000h,000h,000h,000h,040h,08Fh,040h ;1E+03
	db	000h,000h,000h,000h,000h,088h,0C3h,040h ;1E+04
	db	000h,000h,000h,000h,000h,06Ah,0F8h,040h ;1E+05
	db	000h,000h,000h,000h,080h,084h,02Eh,041h ;1E+06
	db	000h,000h,000h,000h,0D0h,012h,063h,041h ;1E+07
	db	000h,000h,000h,000h,084h,0D7h,097h,041h ;1E+08
	db	000h,000h,000h,000h,065h,0CDh,0CDh,041h ;1E+09
	db	000h,000h,000h,020h,05Fh,0A0h,002h,042h ;1E+10
	db	040h,08Ch,0B5h,078h,01Dh,0AFh,015h,044h ;1E+20
	db	0EAh,08Ch,0A0h,039h,059h,03Eh,029h,046h ;1E+30
	db	0A5h,05Ch,0C3h,0F1h,029h,063h,03Dh,048h ;1E+40
	db	09Ah,064h,07Eh,0C5h,00Eh,01Bh,051h,04Ah ;1E+50
	db	044h,0F3h,0C2h,0E4h,0E4h,0E9h,063h,04Ch ;1E+60
	db	03Eh,0C7h,0DDh,0D6h,0BAh,02Eh,077h,04Eh ;1E+70
	db	04Fh,0FBh,0F0h,051h,0EFh,0FCh,08Ah,050h ;1E+80
	db	0AAh,059h,029h,009h,00Fh,06Bh,09Fh,052h ;1E+90
dpone	db	000h,000h,000h,000h,000h,000h,0F0h,03Fh ;1E+00
deci	db	099h,099h,099h,099h,099h,099h,0B9h,03Fh ;1E-01
dppi	db	018h,02Dh,044h,054h,0FBh,021h,009h,040h ;= 3.14159265358979324

; Constante division par 10
dwordten	dd	10
byteten		equ	byte ptr dwordten

; Initialisation operations flottantes
fltinit:
	finit				;initialisation processeur flotant
	ret

; Addition entiers
; [ESI] = [ESI] + [EBX]
	align	16
iadd:
	mov	eax,[esi]
	add	eax,[ebx]		;addition entiere
	jo	short iadd1		;debordement
	mov	[esi],eax
	ret
iadd1:
	call	iconv			;conversion operandes en flottant
;;;	jmp	dpadd			;addition flottante

; Addition flottante
; [ESI] = [ESI] + [EBX]
dpadd:
	fld	qword ptr [esi]
	fadd	qword ptr [ebx]
;;;	jmp	short fpfinish

; Test execption apres operation flottante
fpfinish:
	fstp	qword ptr [esi]		;range resultat
	fstsw	ax			;indicateurs flottants
	test	al,00011101b		;exception ?
	jnz	short fpexcep		;oui
	ret
fpexcep:
	fclex				;raz indicateurs exception
	test	al,00000100b		;division par zero ?
	jnz	short divby0
	test	al,00000001b		;operation invalide ?
	jnz	short invoflo
	test	al,00001000b		;debordement superieure ?
	jnz	short fovrflo
;;;	jmp	dret0			;R0=zero

; Zero R0
dret0:
	xor	eax,eax
	mov	[esi].large.l_low,eax
	mov	[esi].large.l_high,eax
	ret

;Exceptions flotantes
divby0:
	mov	al,err_zero_div
	jmp	rpter
invoflo:
	mov	al,err_arg_ovf
	jmp	rpter
fovrflo:
	mov	al,err_float_ovf
	jmp	rpter

; Soustraction entiere
; [ESI] = [ESI] - [EBX]
	align	16
isub:
	mov	eax,[esi]
	sub	eax,[ebx]		;soustraction entiere
	jo	isub1			;debordement
	mov	[esi],eax
	ret
isub1:
	call	iconv			;conversion operandes en flottant
;;;	jmp	dpsub			;soustraction flottante

; Soustraction flottante
; [ESI] = [ESI] - [EBX]
dpsub:
	fld	qword ptr [esi]
	fsub	qword ptr [ebx]
	jmp	fpfinish

; Multiplication entiere
; [ESI] = [ESI] * [EBX]
	align	16
intmul:
	mov	eax,[ebx]
	imul	dword ptr [esi]
	jo	short intmul1		;debordement
	mov	[esi],eax
	ret
intmul1:
	call	iconv			;conversion operandes en flottant
;;;	jmp	dpmul			;multiplication flottante

; Multiplication flottante
; [ESI] = [ESI] * [EBX]
dpmul:
	fld	qword ptr [esi]
	fmul	qword ptr [ebx]
	jmp	fpfinish

; Division entiere
; [ESI] = [ESI] / [EBX]
	align	16
intdiv:
	mov	ecx,[ebx]
	test	ecx,ecx			;nul ?
	jecxz	short divby0		;oui, erreur
	mov	eax,[esi]		;diviseur negatif ?
	jns	short intdiv1		;non
	neg	ecx			;diviseur positif
	neg	eax			;compense
intdiv1:
	cdq
	idiv	ecx			;division entiere
	mov	[esi],eax		;resultat
	ret

; Division flottante
; [ESI] = [ESI] / [EBX]
	align	16
dpdiv:
	fld	qword ptr [esi]
	fdiv	qword ptr [ebx]
	jmp	fpfinish

; Partie entiere
; INT[ESI]
	align	16
dintf:
	fstcw	temp16
	or	byte ptr temp16+1,00001100b ;arrondi vers zero
	fldcw	temp16
	fld	qword ptr [esi]
	frndint
	and	byte ptr temp16+1,not 00001100b ;arrondi vers plus pres
	fldcw	temp16
	jmp	fpfinish

; Modulo entier
; [ESI]=[ESI] MOD [EBX]
	align	16
imod:
	call	intdiv			;division
	test	eax,eax			;resultat positif ?
	jns	short imod1		;oui
	add	edx,ecx			;ajout diviseur positif, reste positif
imod1:
	mov	[esi],edx		;retour reste
	ret

; Modulo
; [ESI] = [ESI] - [EBX] * INT([ESI]/[EBX])
	align	16
dpmod:
	fld	qword ptr [ebx]
	fld	qword ptr [esi]
	fprem				;MOD(R0, [EBX])
	fstp	st(1)			;mange ST(1)
	jmp	fpfinish

; Compare [ESI] avec [EBX]
; Retour comparaison entier NON signes (ZF et CF)
	align	16
dcmp:
	fld	qword ptr [esi]
	fcomp	qword ptr [ebx]		;comparaison et POP
	fstsw	ax
	and	ah,01000101b
	jz	short dcmp1		;C3, C2, C0 = 000 : R0 > [EBX]
	cmp	ah,00000001b
	je	short dcmp2		;C3, C2, C0 = 001 : R0 < [EBX]
	xor	eax,eax			;0 (ZF, NC)
	ret
dcmp1:
	xor	eax,eax
	add	eax,1			;1 (NZ, NC)
	ret
dcmp2:
	xor	eax,eax
	sub	eax,1			;-1 (NZ, CF) 
	ret

; Comparaison entiers signes
; retour flags comparaison NON signes (ZF et CF)
	align	16
icmp:
	mov	eax,[esi]
	sub	eax,[ebx]
	jl	icmp2
	jg	icmp1
	ret
icmp1:
	clc
	ret
icmp2:
	stc
	ret

; Puissance
; [ESI]**[EBX]
; X**Y = 2**(Y*LOG2(X))
	align	16
dpower:
	movsx	eax,[esi].flt.f_high
	and	eax,eax			;nul ?
	jz	short dpower1		;oui, rien a faire
	fstcw	temp16
	or	byte ptr temp16+1,00001100b ;arrondi vers zero
	fldcw	temp16
	fld	qword ptr [ebx]		;Y<-[EBX]
	fld	qword ptr [esi]		;X<-[ESI]
	fyl2x				;ST(0)=Y*LOG2(X) et POP
	fld	st(0)			;duplique
	frndint				;ROUND(Y*LOG2(X))
	fsub	st(1),st(0)		;ST(1)<-Y*LOG2(X)-ROUND(Y*LOG2(X))
	fxch	st(1)			;-1<ST(0)<+1, ST(1)=Y*LOG2(X)
	f2xm1				;ST(0)<-2**ST(0)-1
	fld1
	faddp	st(1),st(0)		;ST(0)<-2**(Y*LOG2(X)-ROUND(Y*LOG2(X))
	fscale				;ST(0)<-2**(Y*LOG2(X)-ROUND(Y*LOG2(X))*2**(ROUND(Y*LOG2(X))
	fstp	st(1)			;mange ST(1)
	and	byte ptr temp16+1,not 00001100b ;arrondi vers plus pres
	fldcw	temp16
	jmp	fpfinish
dpower1:
	ret

; Puissance entiere
	align	16
dpowri:
	movsx	eax,[esi].flt.f_high
	and	eax,eax			;nul ?
	jz	dpower1			;oui, rien a faire
	mov	eax,[ebx]		;puissance
	test	eax,eax			;nulle ?
	jz	short dretone		;oui, retour 1,0
	jns	short dpowri1		;positive
	neg	eax			;valeur absolue
	push	eax
	push	esi
	mov	edi,ebx
	movsd				;copie [ESI] dans [EBX]
	movsd
	pop	esi
	call	dretone			;1,0 dans [ESI]
	call	dpdiv			;1/[EBX]
	pop	eax			;-puissance
dpowri1:
	mov	temp32,eax
dpowri2:
	shr	temp32,1		;sortie bit de poids faible puissance
	jc	short dpowri3		;bit a 1
	push	ebx
	mov	ebx,esi
	call	dpmul			;[ESI]=[ESI]*[ESI]
	pop	ebx
	jmp	dpowri2			;jusqu'au premier bit a 1
dpowri3:
	cmp	temp32,0		;encore des bits a 1
	je	short dpowri5		;non
	push	esi
	mov	edi,ebx
	movsd				;copie [ESI] dans [EBX]
	movsd
	pop	esi
dpowri4:
	push	esi
	mov	esi,ebx
	call	dpmul			;[EBX]=[EBX]*[EBX]
	pop	esi
	shr	temp32,1		;sortie bit de poids faible puissance
	jnc	short dpowri4		;bit a zero
	call	dpmul			;[ESI]=[ESI]*[EBX]
	cmp	temp32,0		;encore des bits a 1
	jne	short dpowri4		;oui
dpowri5:
	ret

; [ESI]=1,0
	align	16
dretone:
	push	esi
	mov	edi,esi
	mov	esi,offset dpone
	movsd
	movsd
	pop	esi
	ret

; Signe
; Sortie: [ESI]>0  +1
;         [ESI]=0   0
;         [ESI]<0  -1
	align	16
dsignum:
	movsx	eax,[esi].flt.f_high
	test	eax,eax			;R0=0 ?
	jz	dret0
	and	ah,10000000b		;signe
	call	dretone			;1,0 dans [ESI]
	or	[esi+7],ah		;avec signe
	ret

; Valeur absolue
	align	16
dpabs:
	and	byte ptr [esi+7],01111111b		;signe a zero
	ret

; Nombre aleatoire dans l'interval [0,0-1,0[
; Entree:  [ESI]<0 utilise une nouvelle source
;          [ESI]=0 nouveau nombre aleatoire
;          [ESI]>0 nombre aleatoire precedent
	align	16
drnd:
	movsx	eax,[esi].flt.f_high	;partie haute parametre flottant
	test	eax,eax			;negative ?
	js	short drnd1		;oui, nouvelle source
	jz	short drnd2		;nulle, nouveau nombre aleatoire
	mov	eax,rndsav		;source precedente
	mov	dword ptr rndm,eax
	jmp	short drnd3
drnd1:
	mov	eax,[esi].large.l_low	;dword bas
	mov	dword ptr rndm,eax	;nouvelle source
drnd2:
	mov	eax,dword ptr rndm	;sauve source
	mov	rndsav,eax
drnd3:
	mov	ecx,eax
	shr	ecx,16
	sal	cl,1
	rcl	ax,1
	sal	cl,1
	rcl	ax,1
	sal	cl,1
	rcl	ax,1
	xor	ax,rndm
	xor	cl,byte ptr rndm+3
	sal	cl,1
	rcl	ax,1
	ror	eax,16
	mov	dword ptr rndm,eax
	and	eax,0FFFFFFFh
	or	eax,0E0000000h
	mov	[esi+3],eax
	mov	byte ptr [esi+7],3Fh	;exposant dans [0,5-1,0[
	mov	[esi+4],cl
	mov	dword ptr [esi],0
	mov	ebx,offset dphalf	;0,5
	call	dpsub			;resultat dans [0,0-0,5[
	jmp	dpdiv			;dans [0,0-1,0[

; Racine carree
	movsx	eax,[esi].flt.f_high
	align	16
dsqrt:
	movsx	eax,[esi].flt.f_high
	test	eax,eax			;negatif ?
	js	short dsqrt1		;oui, erreur
	fld	qword ptr [esi]
	fsqrt
	jmp	fpfinish
dsqrt1:
	mov	al,err_sqrt_arg
	jmp	rpter

;  Logarithme neperien
;  LN(X) = LOG2(X)*LN(2)
	align	16
dlog:
	movsx	eax,[esi].flt.f_high
	test	eax,eax			;strictement positif ?
	jle	short logerr		;non, erreur
	fldln2				;ST(1)<-LN(2)
	fld	qword ptr [esi]		;ST(0)<-R0
	fyl2x				;ST(0)=LOG2(ST(0))*ST(1) et POP
	jmp	fpfinish
logerr:
	mov	al,err_log_arg
	jmp	rpter

; Exponentielle
; EXP(X) = 2**(X*LOG2(e))
	align	16
dexp:
	fstcw	temp16
	or	byte ptr temp16+1,00001100b ;arrondi vers zero
	fldcw	temp16
	fldl2e				;charge LOG2(e)
	fmul	qword ptr [esi]		;ST(0)<-X*LOG2(e)
	fld	st(0)			;duplique
	frndint				;ROUND(X*LOG2(e))
	fsub	st(1),st(0)		;ST(1)<-X*LOG2(e)-ROUND(X*LOG2(e))
	fxch	st(1)			;-1<ST(0)<+1, ST(1)=X*LOG2(e)
	f2xm1				;ST(0)<-2**ST(0)-1
	fld1
	faddp	st(1),st(0)		;ST(0)<-2**(X*LOG2(e)-ROUND(X*LOG2(e))
	fscale				;ST(0)<-2**(X*LOG2(e)-ROUND(X*LOG2(e))*2**(ROUND(R0*LOG2(e))
	fstp	st(1)			;mange ST(1)
	and	byte ptr temp16+1,not 00001100b ;arrondi vers plus pres
	fldcw	temp16
	jmp	fpfinish

;  Sinus
	align	16
dsine:
	call	ranred			;reduction interval
	fsin
	jmp	fpfinish

; Cosinus
	align	16
dcosine:
	call	ranred			;reduction interval
	fcos
	jmp	fpfinish

; Tangent
	align	16
dtan:
	call	ranred			;reduction interval
	fptan
	fdecstp				;ignore le 1,0 empile par FPTAN
	jmp	fpfinish

; Arc tangente
	align	16
datan:
	fld	qword ptr [esi]
	fld1
	fpatan				;ATAN(R0/1)
	jmp	fpfinish

; Addition de l'entier EAX a flottant
	align	16
ifadd:
	mov	temp32,eax
	fld	qword ptr [esi]
	fiadd	temp32
	jmp	fpfinish

; Multiplication flottant par entier EAX
	align	16
ifmul:
	mov	temp32,eax
	fld	qword ptr [esi]
	fimul	temp32
	jmp	fpfinish

; Entier signe vers flottant
	align	16
floatr0:
	mov	esi,offset r0
float:
	fild	dword ptr [esi]
	fstp	qword ptr [esi]
	ret

; Flottant dans R0 vers entier signe
	align	16
intger:
	fstcw	temp16
	or	byte ptr temp16+1,00001100b ;arrondi vers zero
	fldcw	temp16
	fld	qword ptr r0
	fistp	r0i			;range en entier signe 32 bits and POP
	and	byte ptr temp16+1,not 00001100b ;arrondi vers plus pres
	fldcw	temp16
intger1:
	fstsw	ax
	test	al,00000001b		;operation invalide ?
	jnz	short intger2		;oui
	ret
intger2:
	fclex				;raz indicateurs exception
intger3:
	mov	al,err_int_conv		;erreur conversion entier
	jmp	rpter

; Flottant dans R0 vers entier non signe
	align	16
uintgr:
	test	r0+7,0FFh		;negatif ?
	js	intger3			;oui, erreur
;;;	jmp	short rintgr		;conversion entier avec arrondi

; Flottant dans R0 vers entier avec arrondi
rintgr:
	fld	qword ptr r0
	fistp	r0i			;range en entier signe 32 bits and POP
	jmp	intger1			;test erreur conversion

; Conversion entier dans R0 vers chaine ASCII
	align	16
itoa:
	mov	format,0
	call	floatr0			;convertion en nombre flottant
;;;	jmp	short ftoa

; Convertion flottant dans R0 vers chaine ASCII
; Entree: FORMAT <0 force format scientifique, =0 format automatique, >0 pas de format scientifique (PRINT USING)
;	  SIGCNT=nombre de chiffres total
;	  SIGCN2=nombre de chiffres apres la virgule
;	  PURIGHT=nombre de chiffres apres la virgule (PRINT USING)
;	  PULEFT=nombre de chiffres avant la virgule (PRINT USING)
ftoa:
	xor	eax,eax
	mov	eflag,al
	mov	ldigit,al
	mov	ftoaerr,al
	inc	eax
	mov	obufptr,offset outbuf	;pointeur tampon
	mov	len,eax			;longueur=1
;$$$	add	dword ptr r0,eax	;arrondi (???)
;$$$	adc	dword ptr r0+4,0
	mov	esi,offset r0		;pour le calcul flottant
; Mise dans l'interval [0,1-1,0[, X = F * 2^N, calcul X * 10^(INT(78*N/256)) avec 78=256*LOG(2)+1
	movsx	eax,r0h
	test	eax,eax			;nul ?
	jz	ftoa8			;oui
	call	getexp			;exposant (x16)
	push	eax
	jns	short ftoa1
	neg	eax			;valeur absolue
ftoa1:
	shr	eax,4			;N
	mov	ecx,78			;256*LOG(2)+1
	mul	ecx			;EAX=N*(256*LOG(2)+1)
	pop	ecx
	cmp	eax,128*256		;debordement ?
	jb	short ftoa3		;non
	test	ecx,ecx			;exposant negatif ?
	jns	atof12			;non
ftoa2:
; Affichage 0
	mov	al,' '
	mov	len,0			;raz longueur
	call	inschr			;espace
	mov	al,0
	call	insnum			;'0'
	jmp	ftoa82			;espace de fin
ftoa3:
	mov	al,ah			;exposant decimal
	neg	ecx			;inversion signe exposant ?
	jz	short ftoa4
	js	short ftoa4
	neg	al			;ajuste si negatif a l'origine
ftoa4:
	mov	esign,ch		;signe N inverse
	mov	ebyte,al		;valeur absolue exposant decimal
	call	scale			;R0 = R0 * 10^AH
	push	dword ptr r0h		;sauve signe X
	and	r0h,07FFFh		;masque signe
ftoa5:
; Ajustage final dans l'interval [0,1-1,0[
	movsx	eax,r0h
	call	getexp			;exposant * 16
	js	short ftoa6		;R0<1,0
	mov	ebx,offset deci		;0,1
	call	dpmul			;R0=R0*0,1
	inc	ebyte			;ajuste exposant affiche
	jmp	ftoa5			;tant que >=1,0
ftoa6:
	mov	ebx,offset deci		;0,1
	call	dcmp			;R0>=0,1 ?
	jae	short ftoa7		;oui
	mov	ebx,offset dpten
	call	dpmul			;R0=R0*10
	dec	ebyte			;ajuste exposant affiche
	jmp	ftoa6			;tant que <0,1
ftoa7:
	pop	eax
	and	ah,10000000b		;signe X
	or	r0+7,ah			;restaure
ftoa8:
; 0,1 <= R0 < 1,0, EBYTE=exposant decimal
	test	format,0FFh		;test format
	jg	short ftoa20		;pas de notation scientifique
	jns	ftoa40			;format automatique
; Format scientifique forcee
	mov	eflag,0FFh		;indique format scientifique
	mov	ah,puleft		;nombre de chiffres avant la virgule
	mov	al,r0+7
	test	al,al			;X negatif ?
	jns	short ftoa9		;non
	dec	ah			;place pour le signe - ?
	js	ftoa29			;non
	and	al,01111111b		;raz signe X
	mov	r0+7,al
	mov	al,'-'
	call	inschr			;affiche -
ftoa9:
	mov	ldigit,ah		;chiffres a gauche de la virgule
	mov	ah,puright
	mov	rdigit,ah		;chiffres a droite de la virgule
	movsx	eax,r0h
	test	eax,eax			;X=0 ?
	jz	short ftoa10		;oui
	mov	ah,ebyte
	sub	ah,ldigit		;ajuste exposant decimal
ftoa10:
	inc	ah
	mov	ebyte,ah		;exposant decimal + 1
	jmp	ftoa45
ftoa20:
; Pas de notation, scientifique
	mov	zerobc,0		;raz indicateur zero avant la virgule
	mov	al,puright
	mov	rdigit,al		;chiffres a droite de la virgule
	mov	ah,puleft		;nombre de chiffres avant la virgule
	test	r0+7,0FFh		;X negatif ?
	jns	short ftoa21		;non
	dec	ah			;place pour le signe - ?
	js	short ftoa29		;non, erreur
ftoa21:
	mov	al,ebyte		;exposant decimal
	mov	ldigit,al		;chiffres a gauche de la virgule ou zeros a droite de la virgule
	test	al,al			;X>=1 ?
	jg	short ftoa23		;oui
	add	al,rdigit		;assez de chiffres a droite pour les zeros
	jg	short ftoa22		;oui
	mov	al,rdigit
	neg	al
	mov	ldigit,al		;nombre de zeros a droite de la virgule
	xor	al,al			;pas de chiffres apres les zeros
ftoa22:
	mov	rdigit,al
	mov	zerobc,0FFh		;indicateur zero avant la virgule
	test	ah,ah			;place avant la virgule ?
	jz	short ftoa26		;non
	dec	ah			;prend la place pour le zero
	jmp	short ftoa24
ftoa23:
	sub	ah,al			;espaces avant les chiffres
	js	short ftoa29		;pas de place, erreur
ftoa24:
	jz	short ftoa26		;pas d'espace
	mov	al,' '
ftoa25:
	call	inschr			;affichage espace
	dec	ah
	jne	ftoa25			;tant que necessaire
ftoa26:
	mov	al,r0+7
	test	al,al			;X negatif ?
	jns	short ftoa27		;non
	and	al,07Fh			;raz signe X
	mov	r0+7,al
	mov	al,'-'
	call	inschr			;affichage -
ftoa27:
	test	zerobc,0FFh		;zero avant la virgule ?
	jz	short ftoa28		;non
	call	inschr			;affiche 0
ftoa28:
	jmp	ftoa45
ftoa29:
	xor	al,al
	mov	format,al		;raz format
	mov	eflag,al		;pas d'affichage scienfique
	mov	ftoaerr,0FFh		;indique erreur
ftoa40:
; Format automatique
	movsx	eax,r0h
	test	eax,eax			;X=0 ?
	jz	ftoa2			;oui, affichage 0
	mov	al,' '
	test	ah,ah			;X negatif ?
	jns	ftoa41			;non
	and	ah,01111111b		;raz signe X
	mov	r0+7,ah
	mov	al,'-'
ftoa41:
	call	inschr			;affiche espace ou -
	mov	ah,ebyte		;exposant decimal
	mov	al,sigcnt		;nombre total de chiffres
	test	sigcn2,0FFh		;test nombre de chiffres apres la virgule
	js	short ftoa42		;non specifie
	sub	al,sigcn2		;places restantes avant la virgule
ftoa42:
	cmp	ah,al			;assez de place devant la virgule ?
	jg	ftoa47			;non, erreur
	cmp	ah,sigcnx		;passage en mode scientifique ?
	jle	ftoa48			;oui
	mov	ldigit,ah		;chiffres a gauche de la virgule
	mov	al,sigcn2		;nombre de chiffres apres la virgule
	test	al,al			;specifie ?
	js	short ftoa43		;non
	test	ah,0FFh			;zeros apres la virgule ?
	jns	short ftoa44		;non
	add	al,ldigit		;chiffres restants
	jns	short ftoa44		;ok
	xor	al,al			;pas de place pour les chiffres
	jmp	short ftoa44
ftoa43:
	mov	al,sigcnt		;nombre de total chiffres
	test	ebyte,0FFh		;exposant negatif ?
	js	short ftoa44		;oui
	sub	al,ebyte
ftoa44:
	mov	rdigit,al		;nombre de chiffres a droite de la virgule
ftoa45:
	mov	ah,ldigit		;nombre de chiffres a gauche de la virgule
	test	ah,ah			;negatif (zeros apres la virgule) ?
	jg	short ftoa50		;non
	mov	al,'.'			;virgule anglaise !!!
	call	inschr			;affiche virgule
	test	ah,0FFh
	je	short ftoa50		;pas de zero apres la virgule
	mov	al,0
ftoa46:
	call	inschr			;affiche 0
	inc	ah
	jnz	ftoa46			;le nombre necessaire
	mov	al,ldigit		;-nombre de zeros apres la virgule
	mov	ldigit,ah		;raz
	test	format,0FFh		;PRINT USING ?
	jle	short ftoa50		;non
	test	rdigit,0FFh		;chiffre a droite de la virgule ?
	jne	short ftoa50		;oui, affiche chiffres
	cmp	al,ebyte		;egale exposant decimal ?
	je	short ftoa50		;oui, affiche chiffres
	xor	al,al
	call	inschr			;affiche 0
	jmp	ftoa60			;arrondi affichage
ftoa47:
	mov	ftoaerr,0FFh		;indique erreur
ftoa48:
	mov	eflag,0FFh		;indique affichage scientifique
	mov	ldigit,1		;1 chiffre a gauche de la virgule
	mov	ah,sigcn2		;nombre de chiffres apres la virgule
	test	ah,ah			;specifie ?
	jns	short ftoa49		;oui
	mov	ah,sigcnt		;nombre total de chiffres
	dec	ah			;-1
ftoa49:
	mov	rdigit,ah		;nombre de chiffre a droite de la virgule
ftoa50:
	movsx	eax,r0h			;exposant R0 (R0 dans [0,1-1,0[)
	push	eax
	and	ax,0000000000001111b	;masque exposant
	or	al,00010000b		;restaure bit 52
	mov	r0h,ax
	pop	eax
	call	getexp			;exposant * 16
	add	ax,4*16			;exposant+4 (-4 <= exposant < 0)
	je	short ftoa52		;exposant+4 = 0
ftoa51:
	sal	r0.large.l_low,1	;decalage a gauche
	rcl	r0.large.l_high,1
	sub	ax,1*16
	jne	ftoa51			;pour exposant+4 = 0
ftoa52:
	test	ldigit,0FFh		;chiffre a gauche virgule ?
	jz	short ftoa54		;non
ftoa53:
	call	outdig			;sortie chiffre de R0
	dec	ldigit
	jnz	ftoa53			;tant que necessaire
	mov	al,'.'			;virgule anglaise
	call	inschr			;affiche
ftoa54:
	mov	ah,rdigit		;chiffres a droite de la virgule
	push	eax
ftoa55:
	call	outdig			;sortie chiffre de R0
	dec	rdigit
	jns	ftoa55			;+1 pour l'arrondi affichage
	pop	eax
	mov	rdigit,ah		;restaure RDIGIT
ftoa60:
; Arrondi affichage
	mov	ebx,obufptr
	dec	ebx			;pointeur dernier chiffre
	dec	len			;ignore le dernier chiffre au final
	mov	obufptr,ebx
	mov	ah,[ebx]		;dernier chiffre
	mov	al,5			;arrondi sur dernier chiffre
ftoa61:
	add	al,ah			;ajout retenue ou arrondi
	daa				;decimal
	mov	ah,al
	and	al,00001111b		;digit unite
	add	al,'0'			;en ASCCI
	mov	[ebx],al		;range
	shr	ax,12			;retenu
ftoa62:
	dec	ebx
	cmp	ebx,offset outbuf-1	;avant tampon ?
	jbe	short ftoa63		;oui
	mov	ah,[ebx]		;chiffre suivant
	cmp	ah,'.'			;virgule ?
	je	ftoa62			;oui, saute
	cmp	ah,' '			;espace ou signe ?
	jb	ftoa61			;non, continue
ftoa63:
	test	al,al			;retenue ?
	jz	short ftoa67		;non
	add	al,'0'			;en ASCII
	test	format,0FFh		;PRINT USING ?
	jle	short ftoa65		;non
	cmp	outbuf,' '		;place disponible ?
	je	short ftoa64		;oui
	mov	ftoaerr,0FFh		;indique erreur
	jmp	short ftoa65
ftoa64:
	mov	ah,[ebx]		;decalage vers la gauche
	mov	[ebx],al		;pour faire une place
	mov	al,ah
	dec	ebx
	cmp	ebx,offset outbuf-1
	jne	ftoa64			;jusqu'au debut du tampon
	jmp	short ftoa67
ftoa65:
	inc	ebx
	mov	ah,[ebx]		;declage vers la droite
	mov	[ebx],al		;pour faire une place
	inc	ebx
	inc	ebyte			;ajuste exposant decimal
	test	eflag,0FFh		;affichage scientifique ?
	jnz	short ftoa67		;oui
	cmp	ebx,obufptr		;fin tampon ?
	je	short ftoa67		;oui
ftoa66:
	mov	al,[ebx]		;continue decalage vers la droite
	mov	[ebx],ah
	inc	ebx
	mov	ah,al
	cmp	ebx,obufptr
	jne	ftoa66			;jusqu'a la fin du tampon
	call	inschr			;ajoute le dernier chiffre au tampon
ftoa67:
	mov	ebx,obufptr
	test	format,0FFh		;format automatique ?
	jnz	short ftoa71		;non
	mov	al,'0'			;supprime les zeros de fin
ftoa68:
	dec	ebx			;recule
	dec	len
	cmp	al,[ebx]		;0 ?
	je	ftoa68			;oui, continue
	cmp	byte ptr [ebx],'.'	;virgule ?
	jne	short ftoa69		;non
	dec	len			;supprime la virgule
	dec	ebx
ftoa69:
	mov	al,[ebx]		;dernier caractere
	inc	ebx			;apres le dernier caractere
	mov	obufptr,ebx
	cmp	al,' '			;espace ?
	je	short ftoa70		;oui, tout les chiffres ont ete efface
	cmp	al,'-'			;- ?
	jne	short ftoa71		;non
	mov	al,' '			;efface le signe -
	dec	ebx
	mov	[ebx],al
ftoa70:
	mov	al,'0'			;affiche 0
	call	inschr
ftoa71:
	test	eflag,0FFh		;affichage scientifique ?
	jz	short ftoa82		;non
;Affichage scientifique
	mov	al,'E'
	call	inschr			;affiche E
	mov	ah,ebyte		;exposant decimal
	dec	ah			;ajuste
	mov	al,'+'
	test	ah,ah			;exposant decimal positif ?
	jns	short ftoa80		;oui
	neg	ah			;valeur absolue
	mov	al,'-'
ftoa80:
	call	inschr			;affiche signe exposant
	shr	ax,8			;AL=AH, AH=0
	div	byteten			;AL=AL/10, reste dans AH
	cmp	al,10			;exposant trois chiffres ?
	jb	short ftoa81		;non
	shl	eax,8			;sauve le reste, AH=quotient
	shr	ax,8			;AL=AH, AH=0
	div	byteten			;AL=AL/10, reste dans AH
	call	insnum			;affichage chiffre des centaines
	shr	eax,8			;AL=dixaines, AH=unites
ftoa81:
	call	insnum			;affichage chiffre des dixaines
	mov	al,ah
	call	insnum			;affichage chiffre des unites
ftoa82:
	test	format,0FFh		;format automatique ?
	jnz	short ftoa83		;non
	mov	al,' '
	call	inschr			;affiche espace de fin
ftoa83:
	mov	byte ptr [ebx],eot	;marque de fin de chaine
	mov	format,0		;selection format automatique
	ret

; Convertion chaine ASCII vers flottant dans R0
; Entree: INPT->chaine
; Sortie: R0
; Formats supportes:
; (+-)2
; (+-)2.
; (+-)2E(+-)XX
; (+-)2.E(+-)XX
; (+-).2
; (+-).2E(+-)XX
	align	16
atof:
	mov	ebx,inptr		;pointeur caractere tampon entree
	mov	stbeg,ebx		;debut chaine
	mov	intflg,0		;entier par defaut
	call	sign			;lecture signe
	mov	rsign,al		;range
	mov	inptr,ebx		;maj pointeur caractere
	call	skipsps			;saut espace
	call	number			;chiffre ?
	jc	atof10			;non
	call	getnum			;chaine decimale dans R0
	mov	digcnt,0		;raz compteur chiffres
	cmp	ah,'.'			;virgule ?
	jne	short atof2		;non
atof1:
	mov	digcnt,0		;raz compteur chiffres
	mov	intflg,0FFh		;indique non entier
	inc	ebx			;mange .
	call	getnum1			;continue la chaine decimale
atof2:
	mov	dx,(52+1023)*16		;exposant=52 (avec bias)
	mov	ecx,7
	mov	word ptr r0-2,0		;raz 2 octets avant R0
atof3:
	test	r0+6,0FFh		;decalage gauche octet necessaire ?
	jnz	short atof4		;non
	mov	eax,r0.large.l_high-2	;decalage gauche octet R0
	mov	r0.large.l_high-1,eax
	mov	eax,r0.large.l_low-2
	mov	r0.large.l_low-1,eax
	sub	dx,8*16			;ajuste exposant
	loop	atof3
	jmp	short atof8
atof4:
	mov	eax,r0.large.l_high-1
atof5:
	test	eax,0E0000000h		;decalage droite bit necessaire ?
	jz	short atof6		;non
	shr	eax,1			;decalage droite bit
	rcr	r0.large.l_low-1,1
	add	dx,1*16			;ajuste exposant
	jmp	atof5
atof6:
	test	eax,0F0000000h		;decalage gauche bit necessaire ?
	jne	short atof7		;non
	sal	r0.large.l_low-1,1	;decalage gauche bit
	rcl	eax,1
	sub	dx,1*16			;ajuste exposant
	jmp	atof6
atof7:
	mov	dword ptr r0+3,eax
	mov	al,r0+6
	mov	ah,rsign		;signe
	and	al,00001111b		;raz bit 52
	or	ax,dx			;exposant
	mov	r0h,ax
atof8:
	push	ebx
	call	skipsps			;saut espaces
	cmp	ah,'E'			;E ?
	je	short atof11		;oui
	cmp	ah,'e'			;e ?
	je	short atof11		;oui
atof9:
	pop	ebx
	mov	inptr,ebx		;maj pointeur caractere
	xor	ah,ah			;exposant chaine a zero
	mov	al,digcnt		;chiffres apres la virgule
	jmp	atof15
atof10:
	mov	r0.large.l_low,0	;R0=0
	mov	r0.large.l_high,0
	cmp	ah,'.'			;virgule ?
	je	atof1			;oui
	jmp	atof18			;retour 0
atof11:
	inc	ebx			;mange E ou e
	call	sign			;signe exposant
	mov	esign,al
	mov	inptr,ebx		;maj pointeur caractere
	call	skipsps			;saut espaces
	cmp	ah,'0'			;chiffre ?
	jb	atof9			;non
	cmp	ah,'9'
	ja	atof9			;non
	pop	eax			;ignore pointeur caractere
	call	r0tor1			;copie R0 dans R1
	mov	al,digcnt
	push	eax			;sauve nombre de chiffres apres la virgule
	call	getnum			;chaine decimale dans R0
	movzx	eax,word ptr r0+1	;debordement exposant ?
	or	eax,dword ptr r0+3
	jz	short atof13		;peut etre pas
atof12:
	jmp	fovrflo			;debordement flottant
atof13:
	mov	ah,r0			;exposant decimal
	test	ah,ah			;<= 127 ?
	js	atof12			;non
	test	esign,0FFh		;signe exposant decimal
	jns	short atof14		;non
	mov	intflg,0FFh		;indique non entier
	neg	ah
atof14:
	call	r1tor0			;recupere la mantisse
	pop	edx
	mov	al,dl			;chiffres apres la virgule
atof15:
	sub	ah,al			;ajuste exposant decimal
	jo	atof12			;debordement octet signe
	mov	esign,ah		;sauve
	jns	short atof16
	neg	ah			;valeur absolue
atof16:
	push	ebx
	mov	esi,offset r0		;pour calcul flottant
	call	scale			;prise en compte exposant decimal
	pop	ebx
	movsx	eax,r0h			;nul ?
	test	eax,eax
	jz	short atof17		;oui
	call	getexp
	cmp	eax,30*16		;exposant <= 30 ?
	jbe	short atof17		;oui
	mov	intflg,0FFh		;indique non entier
atof17:
	mov	al,rsign
	or	r0+7,al			;ajout signe
atof18:
	mov	ebx,inptr		;pointeur caractere tampon entree
	dec	ebx
	mov	stend,ebx		;fin chaine
	ret

; Convertion chaine ASCII vers entier dans R0I
; Entree: INPT->chaine
; Sortie: R0I
	align	16
atoii:
	mov	ebx,inptr		;pointeur caractere tampon entree
	mov	stbeg,ebx		;debut chaine
	call	sign			;signe
	mov	rsign,al		;range
	mov	inptr,ebx		;maj pointeur caractere
	call	skipsps			;saut espaces
	call	number			;chiffre ?
	jc	short atoii2		;non, erreur
	call	getnum			;chaine decimale dans R0
	mov	eax,dword ptr r0+4	;bits 32 a 63
	test	eax,eax			;a zero ?
	jnz	short atoii3		;non, debordement
	mov	eax,dword ptr r0
	test	eax,eax			;bit 31 a zero ?
	js	short atoii3		;non, debordement
	test	rsign,0FFh		;signe ?
	jns	short atoi1		;non
	neg	eax			;negation
atoi1:
	mov	r0i,eax			;range
	mov	ebx,inptr		;pointeur caractere tampon entree
	dec	ebx
	mov	stend,ebx		;fin chaine
	ret
atoii2:
	mov	al,err_conv		;pas un chaine numerique
	jmp	rpter
atoii3:
	mov	al,err_input_int	;erreur debordement
	jmp	rpter


; Retour exposant
	align	16
getexp:
	and	eax,00007FF0h		;raz bit de signe
	sub	eax,1023*16		;moins offset
	ret

; Insertion chiffre dans la tampon de sortie
; Entree: AL=chiffre entre 0 et 9
	align	16
insnum:
	add	al,'0'			;conversion ASCII
;;;	jmp	short inschr

; Insertion caractere dans la tampon de sortie
; Entree: AL=caractere
inschr:
	mov	ebx,obufptr
	mov	[ebx],al
	inc	ebx
	mov	obufptr,ebx
	inc	len
	ret

; Sortie chiffre decimal de R0
	align	16
outdig:
	xor	ah,ah
	call	mul10			;R0<-R0x10, sortie bits 56 a 63
	jmp	inschr			;insere chiffre decimal, conversion en ASCII lors de l'arrondi

; Test caractere decimal
; Entree: EBX->caractere
; Retour: AH=valeur decimale
;	  CF si non decimal
	align	16
number:
	mov	ah,[ebx]
	mov	inptr,ebx		;maj pointeur caractere
	cmp	ah,'0'			;chiffre ?
	jb	short number1		;non, retour CF
	cmp	ah,'9'
	ja	short number2		;non
	and	ah,00Fh			;valeur decimale (NC)
number1:
	ret
number2:
	stc				;pas un caractere decimal
	ret

; Test presence signe
; Entree: EBX->caractere
; Sortie: EBX apres le signe si present
;	  AL=00h si pas de signe ou +
;	  AL=80h si -
	align	16
sign:
	call	skipsps			;saut espaces
	xor	al,al			;positif par defaut
	cmp	ah,'+'			;+ ?
	je	short sign1		;oui, saute
	cmp	ah,'-'			;- ?
	jne	short sign2		;non, retour
	mov	al,10000000b		;negatif
sign1:
	inc	ebx			;saute caractere
sign2:
	ret

; Conversion chaine decimale en binaire
; Entree: EBX->chaine
; Sortie: EBX apres la chaine
;	  R0=valeur binaire bits 0 a 55
	align	16
getnum:
	xor	eax,eax
	mov	r0.large.l_low,eax
	mov	r0.large.l_high,eax
	call	number			;caractere decimal ?
	jc	short getnum2		;non, ce n'est pas une chaine decimale
	inc	ebx			;saute caractere
	mov	r0,ah			;R0=valeur decimale premier caractere
	inc	digcnt			;maj compteur
getnum1:
	call	number			;nouveau caractere decimal ?
	jc	short getnum2		;non
	inc	ebx			;saute caractere
	inc	digcnt			;maj compteur
	call	mul10			;insertion chiffre decimal moins significatif dans R0
	test	al,al			;debordement mantisse ?
	jz	getnum1			;non, continue
	jmp	atoii2			;erreur conversion
getnum2:
	ret

; R0<-R0x10 + AH
; Retour: AL=bits 56 a 63 sortis de R0
	align	16
mul10:
	movzx	ecx,ah
	mov	eax,r0.large.l_low
	mov	edx,r0.large.l_high
	shl	eax,1			;x2
	rcl	edx,1
	push	edx
	push	eax
	shl	eax,1			;x4
	rcl	edx,1
	shl	eax,1			;x8
	rcl	edx,1
	add	eax,ecx			;x8+AH
	adc	edx,0
	pop	ecx
	add	eax,ecx			;x8+AH+x2
	pop	ecx
	adc	edx,ecx
	mov	r0.large.l_low,eax
	mov	r0.large.l_high,edx
	xor	al,al
	xchg	al,r0+7			;retour bits 56 a 63 et raz dans R0
	ret

; [ESI] = [ESI] * 10^[SIGN]AH
	align	16
scale:
	cmp	ah,10			;AH <= 10 ?
	jbe	short scale3		;oui
	shr	ax,8			;AL=AH, AH=0
	div	byteten			;AL=AL/10, reste dans AH
	push	eax			;sauve reste
	add	al,9			;ajout offset table 10^N*10
	mov	ah,al
scale1:
	cmp	ah,9+9			;N<=9 ?
	jbe	short scale2		;oui
	push	eax
	mov	ah,9+9			;maximum table 10^N*10
	call	scale3			;R0 = R0 * 10^N*10
	pop	eax			;restaure
	sub	ah,9			;prise en compte 9
	jmp	scale1			;continue
scale2:
	call	scale3			;R0 = R0 * 10^N*10
	pop	eax			;reste <10
scale3:
	movzx	eax,ah
	test	eax,eax			;nul ?
	je	short scale5		;oui, c'est bon
	push	ebx
	test	esign,0FFh		;exposant negatif ?
	lea	ebx,dpten[eax*8-8]	;offset table
	jns	short scale4		;non
	call	dpdiv			;division
	pop	ebx
	ret
scale4:
	call	dpmul			;multiplication
	pop	ebx
scale5:
	ret

; Copie R0 dans R1
	align	16
r0tor1:
	mov	edi,offset r1
	mov	esi,offset r0
	movsd
	movsd
	ret


; Copie R1 dans R0
	align	16
r1tor0:
	mov	esi,offset r1
	mov	edi,offset r0
	movsd
	movsd
	ret

; Reduction angle dans interval [0,0-2*PI[
	align	16
ranred:
	fldpi				;PI
	fadd	st(0),st(0)		;2*PI
	fld	qword ptr [esi]
	fprem				;MOD(R0, 2*PI)
	fstp	st(1)			;mange ST(1)
	ret

; Conversion entiers [ESI] et [EBX] en flottant
	align	16
iconv:
	push	esi
	mov	esi,ebx
	call	float			;conversion flottante [EBX]
	mov	esi,atos		;sommet pile
	mov	[esi-size opnd].opnd.o_type,fltbit ;type resultat flottant
	pop	esi
	jmp	float			;conversion flottante [ESI]

	end