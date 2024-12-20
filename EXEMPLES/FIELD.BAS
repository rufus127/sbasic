   10 OPEN "PERSON" AS 1, LEN 50
   20 FIELD#1, 30 AS NOM$, 12 AS PRE$, 8 AS SAL$
   30 INPUT "Num‚ro (0=fin) ";N%
   40 IF N% = 0 THEN 100
   50 GET#1, RECORD N%
   60 PRINT "Nom: "; NOM$
   70 PRINT "Pr‚nom: "; PRE$
   80 PRINT "Salaire: "; CVT$F (SAL$) : PRINT
   90 GOTO 30
  100 CLOSE 1
