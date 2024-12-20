   10 F$ = "code.txt"
   15 OPEN NEW F$ AS 1
   16 PRINT#1,"\begin{tikzpicture}[scale=5]"
   20 DX = 0 : CALL INIT
   25 CALL DESFAREY(2,2,"m=2,n=2")
   26 A$ = INCH$(0)
   30 DX = 1.8 : CALL INIT
   35 CALL DESFAREY(4,3,"m=4,n=3")
   40 PRINT#1,"\end{tikzpicture}" : CLOSE 1
   50 A$ = INCH$(0) : TEXT : STOP
 1000 " 
 1010 "  calcul du PGCD de UU%, VV% résultat dans D%
 1020 " 
 1030 SUB GCD(UU%,VV%,D%) : LOCAL A%, U%, V%
 1040 U% = ABS(UU%) : V% = ABS(VV%) : D% = 0
 1050 IF V% = 0 THEN D% = U% : RETURN
 1060 IF U%<V% THEN A% = U% : U% = V% : V% = A%
 1070 D% = U%/V% : A% = U% - V% * D%
 1080 IF A% = 0 THEN D% = V% : RETURN
 1090 U% = V% : V% = A% : GOTO 1070
 1100 " 
 1110 "  dessiner le segment (x1,y1),(x2,y2)
 1120 " 
 1130 SUB SEG(X1,Y1,X2,Y2)
 1140 PLOT OX%+X1*DX%, OY%+Y1*DY% TO OX%+X2*DX%, OY%+Y2*DY%
 1150 PRINT#1,"\draw (";STR$(DX + X1);",";STR$(Y1);") -- (";STR$(DX + X2);",";STR$(Y2);") ;"
 1160 RETURN
 1170 " 
 1180 "  dessiner le texte A$ en position x,y
 1190 "  position B$ pour tikz
 1195 " 
 1200 SUB TXT(X,Y,A$,B$)
 1210 SYMBOL OX% + DX%*X,OY%+DY%*Y,A$
 1220 PRINT#1,"\draw (";STR$(DX + X);",";STR$(Y);") ";B$;"{$";A$;"$} ;"
 1230 RETURN
 1240 " 
 1250 "  init des données
 1260 " 
 1270 SUB INIT : OX% = 100 : OY% = 100 : DX% = 400 : DY% =400 
 1280 FX% = OX% + DX% :FY% = OY% + DY%
 1290 HGR : COLOR 0 : CLRG : COLOR 7
 1300 CALL SEG(-0.1,0,1.1,0) : CALL TXT(1.+3./40,-1./40,"x","node[below]")
 1310 CALL SEG(1.06,0.01,1.1,0) : CALL SEG(1.06,-0.01,1.1,0)
 1320 CALL SEG(0,-0.1,0,1.1) : CALL TXT(-1./40,1+3./40,"y","node[left]")
 1330 CALL SEG(0.01,1.06,0,1.1) : CALL SEG(-0.01,1.06,0,1.1)
 1340 CALL SEG(0.,1.,1.,1.) : CALL SEG(1.,0.,1.,1.)
 1350 CALL TXT(-1./40,-1./40,"O","node[below left]")
 1360 CALL TXT(-1./40,1.,"1","node[left]")
 1370 CALL TXT(1.,-1./40,"1","node[below]")
 1380 RETURN
 3990 " 
 3991 "  dessiner la droite verticale (u%,v%,w%)
 3992 " 
 4000 SUB DESSINEV(U%,V%,W%) :  LOCAL A,B,C, X1, Y1,X2,Y2
 4010 HGR
 4020 A = U% : B = V% : C = W%
 4030 X1 = C/A : Y1 = 0 : X2 = X1 : Y2 = 1
 4040 CALL SEG(X1,Y1,X2,Y2)
 4050 RETURN
 4990 " 
 4991 "  dessiner la droite horizontale (u%,v%,w%)
 4992 " 
 5000 SUB DESSINEH(U%,V%,W%) :  LOCAL A,B,C, X1, Y1,X2,Y2
 5010 HGR
 5020 A = U% : B = V% : C = W%
 5030 X1 = 0 : Y1 = C/B : X2 = 1 : Y2 = Y1
 5040 CALL SEG(X1,Y1,X2,Y2)
 5050 RETURN
 5990 " 
 5991 "  dessiner la droite n‚gative (u%,v%,w%)
 5992 " 
 6000 SUB DESSINEN(U%,V%,W%) : LOCAL A,B,C, X1, Y1,X2,Y2
 6010 HGR
 6020 A = U% : B = V% : C = W%
 6030 X1 = 0 : Y1 = C/B : IF Y1<1 GOTO 6050
 6040 X1 = (C-B)/A : Y1 = 1
 6050 X2 = 1 : Y2 = (C-A)/B : IF Y2>0 GOTO 6070
 6060 X2 = C/A : Y2 = 0 
 6070 CALL SEG(X1,Y1,X2,Y2)
 6080 RETURN
 6990 " 
 6991 "  dessiner la droite positive (u%,v%,w%)
 6992 " 
 7000 SUB DESSINEP(U%,V%,W%) : LOCAL A,B,C, X1, Y1,X2,Y2
 7010 HGR
 7020 A = U% : B = -V% : C = W%
 7030 X1 = 0 : Y1 = C/B : IF Y1>0 GOTO 7050
 7040 X1 = C/A : Y1 = 0
 7050 X2 = 1 : Y2 = (C-A)/B : IF Y2<1 GOTO 7070
 7060 X2 = (C-B)/A : Y2 = 1 
 7070 CALL SEG(X1,Y1,X2,Y2)
 7080 RETURN
 7990 """"
 7991 " dessin du complexe de Farey (m%,n%)
 7992 "
 8000 SUB DESFAREY(M%,N%,MN$) : LOCAL U%,V%,W%
 8010 "  dessiner les verticales
 8020 FOR U%= 1 TO M% : FOR W% = 1 TO U%-1
 8030 CALL DESSINEV (U%,0,W%)
 8040 NEXT W% : NEXT U%
 8050 "  dessiner les horizontales
 8060 FOR V%= 1 TO N% : FOR W% = 1 TO V%-1
 8070 CALL DESSINEH (0,V%,W%)
 8080 NEXT W% : NEXT V%
 8090 "  dessiner les negatives
 8100 FOR U%= 1 TO M% : FOR V% = 1 TO N%
 8110 FOR W% = 1 TO U% + V% -1 : CALL DESSINEN (U%,V%,W%) : NEXT W%
 8120 NEXT V% : NEXT U%
 8130 "  dessiner les positives
 8140 FOR U%= 1 TO M% : FOR V% = 1 TO N%
 8150 FOR W% = -V% + 1 TO U% -1 : CALL DESSINEP (U%,V%,W%) : NEXT W%
 8160 NEXT V% : NEXT U%
 8170 CALL TXT(0.5, -0.05,MN$,"node[below]")
 8180 RETURN
