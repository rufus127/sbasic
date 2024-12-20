   10 M%=3 : N% = 2
   20 OPEN LIBRARY "farey.dll" AS 1
   40 CALL#1 "__fareymn_MOD_farey"(M%,N%)
   41 A$=INCH$(0)
   50 CLOSE 1
