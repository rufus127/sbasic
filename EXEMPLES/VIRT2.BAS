100 OPEN "VIRT" AS 1
110 DIM #1 NO%(10)
120 INPUT "Rang de la valeur à modifier"; I%
130 IF I%=0 THEN 200
140 PRINT "Valeur courante :"; NO%(I%)
150 INPUT "Nouvelle valeur :"; NO%(I%)
160 GOTO 120
200 CLOSE 1: END
