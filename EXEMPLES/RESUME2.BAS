   10 ON ERROR GOTO 100
   20 INPUT A
   30 INPUT B
   40 PRINT A; "divis‚ par "; B; "est ‚gal … "; A/B
   50 PRINT
   60 GOTO 20
   99 REM *** GESTION D'ERREUR ***
  100 PRINT "erreur ";ERR
  110 RESUME 20
