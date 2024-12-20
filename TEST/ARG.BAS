   10 PRINT "Nombre d'arguments ="; ARGC
   20 IF ARGC = 0 THEN 60
   30 FOR I=0 TO ARGC-1
   40 PRINT "Argument";I;" : ";ARGV$(I)
   50 NEXT I
   60 PRINT "Pressez une touche pour continuer"
   70 C$ = INCH$(0)
   80 END
