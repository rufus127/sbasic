   10 OVERLAY 50
   99 REM *** saisie des ‚l‚ments ***
  100 INPUT "Nombre d'‚l‚ments "; NE% : DIM EL(NE%)
  110 FOR X% = 1 TO NE%
  120 PRINT "‚l‚ment "; X%;
  130 INPUT EL(X%)
  140 NEXT X%
  199 REM *** Choix de la fonction ***
  200 PRINT "0 - QUITTER  1 - Autre tableau"
  210 PRINT "2 - Somme    3 - Moyenne     4 - Ecart-type"
  220 I%=INSTR(1,"01234",INCH$(0))
  230 IF I% = 0 THEN PRINT CHR$(7);: GOTO 220
  250 ON I% GOTO 300, 310, 320, 330, 340
  300 END
  305 REM *** Traitement de la fonction demand‚e ***
  310 CLEAR EL(*): GOTO 100
  320 BLOAD "SOMME" : CALL SOMME(NE%,EL(*)) : GOTO 200
  330 BLOAD "MOYEN" : CALL MOYEN(NE%,EL(*)) : GOTO 200
  340 BLOAD "ECART" : CALL ECART(NE%,EL(*)) : GOTO 200
