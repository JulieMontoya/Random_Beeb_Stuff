   10MODE7
   20HIMEM=&6000
   30*L.M.SUDOKU0
  100*K.1G.1000|M
  110PRINT''CHR$129"f1"CHR$135"Edit puzzle"
  120*K.2G.2000|M
  130PRINT''CHR$129"f2"CHR$135"Read puzzle from program"
  140*K.3G.3000|M
  150PRINT''CHR$129"f3"CHR$135"Solve puzzle"
  160PRINT
  170scr_ptr=&70:see_ptr=&72:text_ptr=&74:set_ptr=&76:alt_ptr=&78
  180solved=&8C
