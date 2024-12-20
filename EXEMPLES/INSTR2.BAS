   10 I% = 1 : N% = 0 : C$ = "IL ETAIT UNE FOIS DANS L'OUEST"
   20 A% = INSTR (I%,C$,"E")
   30 IF A%>0 THEN N% = N% + 1 : I% = A% + 1 : GOTO 20
   40 PRINT " LA LETTRE 'E' APPARAIT " ; N% ; " FOIS"
