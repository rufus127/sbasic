    1 N%=0: DIM X%(100),Y%(100)
    2 PRINT "Voulez-vous cr‚er un nouveau contour O/N ?": A$=INCH$(0)
    3 IF A$ <>"O" GOTO 500
   10 HGR : DASH 4 : COLOR 0 : CLRG : COLOR 7
   20 PEN : X2 = XPEN : Y2 = YPEN : REM point de depart
   30 X1=X2: Y1=Y2
   31 N%=N%+1 : X%(N%)=X2:Y%(N%)=Y2
   40 PLOT X1,Y1 TO X2,Y2
   50 PEN 2,A$ : A% = ASC(A$)
   55 IF X2<>XPEN OR Y2 <>YPEN GOTO 100
   60 IF A%=0 GOTO 50
   70 PRINT XPEN,YPEN,ASC(A$)
   80 IF A% <>1 THEN 90 ELSE 30 : REM si clic gauche (A%=1) alors point courant
   90 IF A% <>2 GOTO 50 : REM si clic droit (A%=2) alors fermer la boucle
   95 N%=N%+1:X%(N%)=X%(1): Y%(N%)=Y%(1)
   96 GOTO 105
  100 PLOT X1,Y1 TO X2,Y2 : X2 = XPEN: Y2=YPEN : GOTO 40
  105 COLOR 0: CLRG: COLOR 7
  106 FOR I%=1 TO N%-1: PLOT X%(I%),Y%(I%) TO X%(I%+1),Y%(I%+1): NEXT I%
  110 PEN 2,A$: FILL XPEN,YPEN
  111 PRINT " Voulez-vous garder ce contour O/N ?":A$=INCH$(0)
  112 IF A$<>"O" THEN STOP
  115 EXECUTE STR$(1000)+" data "+STR$(N%)
  120 FOR I%=1 TO N%
  130 EXECUTE STR$(1000+I%)+" data "+STR$(X%(I%))+","+STR$(Y%(I%))
  140 NEXT I%
  145 EXECUTE STR$(1000+I%+1)+" data "+STR$(XPEN)+","+STR$(YPEN)
  150 STOP
  500 CLEAR:HGR:COLOR 0:CLRG:COLOR 7
  510 READ N% : READ A%,B%: PLOT A%,B%
  511 FOR I%=2 TO N%: READ A%,B%: PLOT TO A%,B%: NEXT I%
  512 PRINT "Taper sur une touche";:A$=INCH$(0): READ A%,B%: FILL A%,B%
  513 STOP
 1000  DATA  10 
 1001  DATA  209 , 148 
 1002  DATA  109 , 393 
 1003  DATA  297 , 502 
 1004  DATA  248 , 363 
 1005  DATA  486 , 357 
 1006  DATA  469 , 475 
 1007  DATA  617 , 241 
 1008  DATA  471 , 157 
 1009  DATA  322 , 254 
 1010  DATA  209 , 148 
 1011  DATA  323 , 254 
