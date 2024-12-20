  110 INPUT "Nombre d'‚l‚ments ";NE%
  120 DIM BB(NE%)
  130 FOR X% = 1 TO NE%
  140 PRINT "‚l‚ment ";X%;
  150 INPUT BB(X%)
  160 NEXT X%
  170 CALL SOMME (BB(*),NE%,SOM)
  180 PRINT "La somme des ";NE%;" ‚l‚ments introduits est ‚gale … : ";SOM
  190 END
  210 SUB SOMME (A(*),N%,S)
  220 S = 0
  230 FOR X% = 1 TO N%
  240 S = S + A(X%)
  250 NEXT X%
  260 RETURN
