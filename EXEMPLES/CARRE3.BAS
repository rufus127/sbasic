20 on error goto 250
100 OPEN OLD "CARRE" AS 2
110 INPUT #2, A$
120 DIM NOMBRE(6): FOR I%=1 TO 6: INPUT #2, NOMBRE(I%): NEXT I%
130 INPUT #2, B$
140 DIM CARRE(6): FOR I%=1 TO 6: INPUT #2, CARRE(I%): NEXT I%
150 input #2, c$
200 CLOSE 2
210 stop
250 print "erreur ";ERR;" ligne ";erl
