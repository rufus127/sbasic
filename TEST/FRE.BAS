   10 N%=(FRE(0)-100)/4
   20 PRINT N%
   30 DIM I%(N%)
   40 FOR J%=0 TO N%
   50 I%(J%)=J%
   60 NEXT J%
   70 FOR J%=N% TO 0 STEP -1
   80 IF I%(J%) <> J% THEN PRINT "Erreur!": STOP
   90 NEXT J%
  100 PRINT FRE(0)
