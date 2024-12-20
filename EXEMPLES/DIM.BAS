   10 DIM I(100)
   20 FOR N%=1 TO 100
   30 I(N%)=N%
   40 NEXT N%
   50 FOR N=1 TO 100
   60 IF I(N) <> N PRINT N,I(N)
   70 NEXT N
