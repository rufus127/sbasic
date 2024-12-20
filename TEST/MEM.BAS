   10 N%=INT(LOG((FRE(0)-100)/4)/LOG(10))
   20 FOR I%=1 TO N%
   30 IF(I%=1)THEN D$="1000 DIM A%(9" ELSE D$=D$+",9"
   40 EXECUTE STR$(1010+10*I%)+"FOR I"+LTRIM$(RTRIM$(STR$(I%)))+"% = 0 to 9"
   50 EXECUTE STR$(1050+10*(N%*2+I%))+"FOR I"+LTRIM$(RTRIM$(STR$(I%)))+"% = 0 to 9"
   60 IF(I%=1)THEN E$="A%(I1%" ELSE E$=E$+",I"+LTRIM$(RTRIM$(STR$(I%)))+"%"
   70 EXECUTE STR$(1030+10*(N%+I%))+"NEXT I"+LTRIM$(RTRIM$(STR$(N%-I%+1)))+"%"
   80 EXECUTE STR$(1070+10*(N%*3+I%))+"NEXT I"+LTRIM$(RTRIM$(STR$(N%-I%+1)))+"%"
   90 NEXT I%
  100 EXECUTE D$+")"
  110 EXECUTE "1010 PRINT "+CHR$(34)+"Cr‚ation tableau de"+CHR$(34)+";10**N%;"+CHR$(34)+"entiers..."+CHR$(34)
  120 EXECUTE STR$(1040+20*N%)+"PRINT "+CHR$(34)+"V‚rification tableau..."+CHR$(34)
  130 EXECUTE STR$(1020+10*N%)+E$+")=j%"
  140 EXECUTE STR$(1030+10*N%)+"J%=J%+1"
  150 EXECUTE STR$(1050+20*N%)+"J%=0
  160 EXECUTE STR$(1060+30*N%)+"IF("+E$+")<>J%)THEN STOP"
  170 EXECUTE STR$(1070+30*N%)+"J%=J%+1"
