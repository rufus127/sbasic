   98 REM *** Ouverture du fichier et d‚finition des variables ***
  100 OPEN "PERSON" AS 1 LEN 50
  120 FIELD #1, 30 AS NOM$, 12 AS PRE$, 8 AS SAL$
  125 FIELD #1, 42 AS NNN$
  198 REM *** Saisie du num‚ro d'enregistrement … modifier ***
  199 ON ERROR GOTO 250
  200 INPUT "NUMERO DE L'EMPLOYE"; I%
  210 IF I%=0 THEN 500
  220 GET #1 RECORD I%
  230 PRINT "Employ‚ :"; NNN$
  240 PRINT "Salaire : "; CVT$F(SAL$) : GOTO 300
  248 REM *** Gestion de l'erreur "Enregistrement non trouv‚"***
  250 PRINT "Enregistrement inexistant"
  260 RESUME 200
  298 REM *** Mise … jour du contenu de la m‚moire tampon (buffer)***
  300 PRINT "Nom " ; : INPUT LINE R$
  305 IF R$ <> "" THEN LSET NOM$=R$
  320 PRINT "Pr‚nom " ; : INPUT LINE R$
  325 IF R$<>"" THEN LSET PRE$=R$
  330 PRINT "Salaire " ; : INPUT LINE R$
  335 IF R$<>"" THEN LSET SAL$=CVTF$(VAL(R$))
  398 REM *** Ecriture de l'enregistrement ***
  400 PUT #1 RECORD I%: GOTO 200
  498 REM *** Fin de programme
  500 CLOSE 1
  510 END
