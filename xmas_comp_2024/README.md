# VINTAGE COMPUTING CHRISTMAS CHALLENGE 2024

The challenge is to draw this shape

        \O/
+--------+--------+
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
+--------+--------+
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
!        !        !
+--------+--------+

The BBC Micro's default screen mode, MODE 7 cannot display a backslash
character  (ASCII 92)  as this uses the Mullard SAA5050 Teletext
character generator IC, and this code point displays as "1/2";  so this
program selects MODE 4 which generates standard ASCII characters.  (The
text rows are also thinner and more squashed-up against one another, so
I think this looks prettier.)  I also took the opportunity to centre
the display  (at least, as nearly as possible considering parity)  on
the screen.

## BUILDING THE PROGRAM

Load the disc image into a BBC Micro emulator

Type `CHAIN "SOURCE"

The code being assembled will be displayed on screen.  When the screen
is full, the CAPS LOCK and SHIFT LOCK LEDs will light together.  Press
SHIFT to scroll the screen.

When the code finishes assembling, it will be saved to disc.

## RUNNING THE PROGRAM

Load the disc image into a BBC Micro emulator

Type `*PRESENT`

# ANNOTATED SOURCE

```
.present
    LDX #9
.draw_bow
    LDA bow_chars, X
    JSR oswrch
    DEX
    BPL draw_bow
```
We step backwards through memory from bow_chars + 9 to bow_chars,
sending character codes to the VDU driver:

22, 4 -- selects MODE 4

31, 18 5 -- positions the cursor at column 18, row 5

92, 79, 47 -- the bow on the present

13, 10 -- positions cursor at beginning of next row

```
LDY #0
```
Y will count the rows.
```
.draw_row
    LDX #10
    LDA #32
.rept_chr
    JSR oswrch
    DEX
    BNE rept_chr
```
Each row begins with a tight little loop, which prints ten spaces and
leaves 0 in the X register.
```
.draw_col
    LDA pattern, X
    STA pattern+9, X
```
This is the "cartoon railroad" algorithm.  The table of data repeats
exactly 9 bytes later on in memory; so we only store the first 9 bytes
in our program, and copy each byte we read 9 places forward.  It's just
like laying down fresh track in front of a moving train.
```
    ASL A
    ADC pattern, Y
    STY retr_Y+1
```
Here we need to borrow a register.  So we store Y straight into an LDY
instruction later in the program.
```
    TAY
    LDA chars, Y
    JSR oswrch
.retr_Y
    LDY #0
    INX
    CPX #19
    BCC draw_col
```
That's the whole of the row drawn.
```
    INY
    JSR osnewl
    CPY #19
    BCC draw_row
    RTS
```
And that's all the code!  The rest is data.
```
.bow_chars
    EQUB 10
    EQUB 13
    EQUB 47
    EQUB 79
    EQUB 92
    EQUB 5
    EQUB 18
    EQUB 31
    EQUB 4
    EQUB 22
.chars
    EQUB 32
    EQUB 45
    EQUB 33
    EQUB 43
.pattern
    EQUB 1
    EQUD 0
    EQUD 0





