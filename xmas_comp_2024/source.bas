   10MODE7
   20VDU14
   30DIMcode% 1024
   40oswrch=&FFEE
   50osasci=&FFE3
   60osnewl=&FFE7
   70FORJ%=4TO7STEP3
   80O%=code%
   90P%=&40
  100[OPTJ%:._begin
  110.present
  120LDX #7
  130.draw_bow
  140LDA bow_chars, X
  150JSR oswrch
  160DEX
  170BPL draw_bow
  180JSR osnewl
  190LDY #0
  200.draw_row
  210LDX #10
  220LDA #32
  230.rept_chr
  240JSR oswrch
  250DEX
  260BNE rept_chr
  270.draw_col
  280LDA pattern, X
  290STA pattern+9, X
  300ASL A
  310ADC pattern, Y
  320STY retr_Y+1
  330TAY
  340LDA chars, Y
  350JSR oswrch
  360.retr_Y
  370LDY #0
  380INX
  390CPX #19
  400BCC draw_col
  410INY
  420JSR osnewl
  430CPY #19
  440BCC draw_row
  450RTS
  460.bow_chars
  470EQUB47
  480EQUB79
  490EQUB92
  500EQUB5
  510EQUB18
  520EQUB31
  530EQUB4
  540EQUB22
  550.chars
  560EQUB32
  570EQUB45
  580EQUB33
  590EQUB43
  600.pattern
  610EQUB1
  620EQUD0
  630EQUD0
  640._end
  650]
  660NEXT
  670PRINT;_end-_begin;" = &";~_end-_begin;" bytes"
  680OSCLI"SAVE PRESENT "+STR$~code%+" "+STR$~O%+" "+STR$~present+" 40"
