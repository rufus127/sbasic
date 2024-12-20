  100 OPEN NEW "CARRE" AS 1
  110 PRINT #1,"Liste des 5 premiers entiers"
  120 FOR I%=1 TO 6: PRINT #1, I%: NEXT I%
  130 PRINT #1, "leurs carr‚s"
  140 FOR I%=1TO 6: PRINT #1,I%*I%: NEXT I%
  200 CLOSE 1
