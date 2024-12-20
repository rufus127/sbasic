    1 """"
    2 " dessin : (x%(i%),y%(i%)) = factor * coordonn‚es r‚elles du point i%
    3 " L%(i%), l%(i%+1) : indice de la liste du contour (i%+1)/2
    4 " NBP% = discr‚tisation des courbes … tracer
    5 " eps = ‚cart du bord, Factor = grossissement
    6 " DX, DY = taille utile de l'‚cran
    7 " 
   10 DIM X%(3000), Y%(3000), L%(50)
   20 R = SQR(2): N% = 0 : NL% = 0 : NP% = N% : NBP% = 20
   21 EPS = 10 : FACTOR = 1000.  :  DX = 800: DY=600
   25 CALL GENARC(1, -1, R , PI/4, 3*PI/4)
   30 CALL GENARC(1, 0, R/5, 0, PI)
   35 CALL SYMX : CALL SYMY
   41 CALL MINMAX 
   50 CALL INIT(NAX-EPS, NBX+EPS, NAY-EPS, NBY+EPS)
   60 CLS: HGR : COLOR 0 : CLRG
   70 COLOR 7
   80 CALL DESSINE
   90 A$=INCH$(0): TEXT
  100 STOP
  990 """""
  991 " initialise les paramŠtres de conversion r‚el, fenˆtre
  992 " A, B = min, max du dessin en X
  993 " C, D = min, max du dessin en Y
  994 " calcule les Z** Xdess = ZAX*Xdata + ZBX, id en Y
  995 "
 1000 SUB INIT (A, B, C, D)
 1001 PRINT A,B,C,D
 1010 ZAX = DX/(B-A) : ZBX = -A*ZAX
 1020 ZAY = DY/(D-C) : ZBY =-C*ZAY
 1030 RETURN
 1990 """"
 1991 " Dessine les lignes d‚crites par L%(*), (X%(*),Y%(*))
 1992 " M‚thode lisible dans le code
 1993 "
 2000 SUB DESSINE : LOCAL I%,J%, LI%,LJ%,U1,V1,U2,V2
 2001 FOR I%=1 TO NL% STEP 2: LI% = L%(I%) : LJ% = L%(I%+1)
 2004 U1 = X%(LI%) * ZAX + ZBX : V1 = Y%(LI%) * ZAY + ZBY
 2010 FOR J%=LI%+1 TO LJ%
 2011 U2 = X%(J%) * ZAX + ZBX : V2 = Y%(J%) * ZAY + ZBY
 2012 PLOT U1,V1 TO U2,V2
 2013 U1 = U2 : V1 = V2
 2018 NEXT J% : NEXT I%
 2020 RETURN : END SUB
 2990 """"
 2991 " calcule le cadre du dessin pour le positionner
 2992 " sur l'‚cran (centrer le dessin et plein ‚cran.
 2993 " pas de contrainte d'‚chelle unique.
 2994 " le dessin remplit la fenˆtre.
 2995 "  
 3000 SUB MINMAX : LOCAL I%
 3010 NAX = X%(1) : NBX = NAX : NMAY = Y%(1) : NBY = NAY
 3020 FOR I%=2 TO N% : X = X%(I%) : Y = Y%(I%) 
 3030 IF X < NAX THEN NAX = X
 3031 IF X > NBX THEN NBX = X 
 3032 IF Y < NAY THEN NAY = Y
 3033 IF Y > NBY THEN NBY = Y
 3050 NEXT I%
 3060 RETURN : END SUB
 3990 """"
 3991 " g‚n‚re les segments d'un arc de cercle :
 3992 " X,Y   : centre
 3993 " R     : rayon
 3994 " T1,T2 : angle d‚but, fin en radian
 3995 "
 4000 SUB GENARC(X,Y,R,T1,T2) : LOCAL I, ND%, NF%
 4005 ND% = N% + 1
 4010 FOR I = T1 TO T2 STEP (T2-T1)/NBP% : N% = N% + 1
 4020 X%(N%) = 1000.*(X+R*COS(I))
 4030 Y%(N%) = 1000.*(Y+R*SIN(I))
 4040 NEXT I  : NF% = N% : Y%(ND%) = 0 : Y%(NF%) = 0
 4050 L%(NL%+1) = NP%+1 : L%(NL%+2) = N% : NP% = N% : NL% = NL% + 2
 4060 RETURN : END SUB
 4990 """"
 4991 " ajoute … L% son sym‚trique par rapport … OX
 4992 "
 5000 SUB SYMX : LOCAL I%,J%, LD%,LF%, ND%, NF%, NLL%
 5001 NLL% = NL%
 5010 FOR I% = 1 TO NLL% STEP 2 : LD% = L%(I%) : LF% = L%(I%+1)
 5015 ND% = N%+1: NF%=N%
 5020 FOR J% = LD% TO LF% : NF% = NF% + 1
 5030 X%(NF%) = X%(J%) : Y%(NF%) = -Y%(J%)
 5040 NEXT J% : N% = NF% : L%(NL%+1)=ND% : L%(NL%+2)=NF% : NL%=NL%+2
 5045 NEXT I%
 5050 RETURN : END SUB
 5990 """"
 5991 " ajoute … L% son sym‚trique par rapport … OY
 5992 "
 6000 SUB SYMY : LOCAL I%,J%, LD%,LF%, ND%, NF%, NLL%
 6001 NLL% = NL%
 6010 FOR I% = 1 TO NLL% STEP 2 : LD% = L%(I%) : LF% = L%(I%+1)
 6015 ND% = N%+1: NF%=N%
 6020 FOR J% = LD% TO LF% : NF% = NF% + 1
 6030 X%(NF%) = -X%(J%) : Y%(NF%) = Y%(J%)
 6040 NEXT J% : N% = NF% : L%(NL%+1)=ND% : L%(NL%+2)=NF% : NL%=NL%+2
 6045 NEXT I%
 6050 RETURN : END SUB
 6100 SUB ZFL(X,Y,C) : HGR : COLOR C : FILL X,Y
 6110 A$=INCH$(0) : TEXT : RETURN : END SUB
