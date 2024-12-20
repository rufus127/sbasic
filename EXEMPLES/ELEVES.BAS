   10 N%=5
   20 DIM NOM$(N%)
   30 DIM NNOTE(N%)
  100 FOR I%=1 TO N%
  110 REM
  120 REM Affectation d'un contenu Ö la variable NOM$(l%)
  130 PRINT "Nom de l'Çläve ";I% ;
  140 INPUT NOM$(I%)
  150 REM Affectation d'une NOTE Ö l'Çläve de rang I%
  170 PRINT "NOTE de l'Çläve ";NOM$(I%);
  180 INPUT NNOTE(I%)
  190 NEXT I%
  200 FOR I%=1 TO N%
  210 PRINT NOM$(I%); " a pour NOTE "; NNOTE(I%)
  220 NEXT I%
