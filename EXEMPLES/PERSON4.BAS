   10 OPEN "PERSON" AS 1, LEN 50
   20 FIELD #1, 30 AS NOM$, 12 AS PRE$, 8 AS SAL$
   30 INPUT "Num‚ro (0=fin) "; N%
   40 IF N% = 0 THEN 100
   50 INPUT "Nom : "; N$
   60 INPUT "Pr‚nom: "; P$
   70 INPUT "Salaire: "; S
   75 LSET NOM$ = N$ : LSET PRE$ = P$ : LSET SAL$ = CVTF$(S)
   80 PUT #1 RECORD N%
   90 GOTO 30
  100 CLOSE 1
