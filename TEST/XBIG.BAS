   10 N%=5000
   20 OPEN "XBIG" AS 1
   30 DIM #1 TBL(N%,N%)
   40 FOR I%=0 TO N%
   50 FOR J%=0 TO N%
   60 TBL(I%,J%)=I%*J%
   70 NEXT J%:NEXT I%
   80 CLOSE 1
   90 OPEN "XBIG" AS 2
  100 DIM #2 TBL(N%,N%)
  110 FOR J%=N% TO 0 STEP -1
  120 FOR I%=N% TO 0 STEP -1
  130 IF TBL(I%,J%)<>I%*J% THEN PRINT "Erreur tableau virtuel!": STOP
  140 NEXT I%:NEXT J%
  150 CLOSE 2
