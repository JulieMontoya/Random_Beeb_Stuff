

```
               *       *                
               **     **                
               ***   ***                
               **** ****                
           *****************            
            ***************             
             *************              
              ***********               
               *********                
              ***********               
             *************              
            ***************             
           *****************            
               **** ****                
               ***   ***                
               **     **                
               *       *
```               

```
```

+ The pattern can be drawn using groups of stars and spaces in strict alternation.
+ The pattern is exactly symmetrical about the middle row.
+ No group is of size zero or larger than 255.

These properties are ruthlessly exploited.  The alternation means we need
only store the size of each group, since whether we are printing spaces or
stars is determined externally.  And the symmetry means we can reverse at
the halfway point, and start redrawing the same groups backwards.


```
.begin
    LDY#6
```

We begin by loading the Y register with 6, which is the length of the
preamble we are about to print.

```
.init1
    LDA preamble-1, Y
    JSR &FFEE
    DEY
    BNE init1
```

We load A with the Y-th value from the preamble sequence and print
it to the screen.  Then we decrease Y; and if it is not zero, we branch
back and print another value.

This sequence selects Teletext mode, which supports 25 rows of 40
characters; and moves the cursor down 4 lines to centre the 17-row high
design vertically on the screen.

At this point, Y=0.


```
.main_star
    LDA #&20
```

We load the accumulator with &20, which is the ASCII code for a space.

```
.draw_group
    LDX pattern,Y    
```

This is the outer loop, which draws a group of either spaces or stars,
depending on the contents of the accumulator.

The size of the group -- as pointed to in the table by Y -- is first
loaded into the X register.


```
.draw1
    JSR &FFEE
    DEX
    BNE draw1
```    

This is the inner loop.  It prints a character whose ASCII code is in the
accumulator, the number of times in the X register.  We decrease X and if
it is not zero, go around the loop again.  (This means we will always
print at least one character.  This is not a problem in practice, as the
smallest groups consist of a single star or space.

```
    EOR #&0A
```

Here we toggle between printing stars and spaces, by Exclusive-ORing the
value in the accumulator with &0A.  The first time through, &20 will be
changed to &2A; the next time through, &2A will change back to &20, and
so forth.


```
.next_group
    INY
```

Here we move on to the next group.  This INY instruction will actually be
changed to DEY later on.


```
    BEQ finished
```

The preceding INY or DEY instruction will have set the Z flag if the new
value in the Y register is zero.  This won't happen with Y increasing,
because we will break the loop long before Y gets to 255.  If we see Y=0
then it means we have drawn the last group of stars and are ready to
exit.


```
    CPY #middle-pattern
    BCC draw_group
    
```

If Y contains any value less than the offset of the middle group in the
design  (which will always be true if we are decreasing Y),  we branch
back and draw the next group.  Otherwise, we must have reached the middle
of the design.


```
    LDX #&88
    STX next_group
    BNE draw_group
```

Here we store a DEY instruction at the address `next_group`, overwriting
the INY that was there before; and we branch to `draw_group`.  Remember
at this point, A contains &2A for a group of stars, and Y points to the
value 9 in the table.  Afterwards, we will decrease Y and it will point
to the value 30, with the code for a space in A; effectively repeating
the groups of stars and spaces in reverse order.

We use the X register to hold the value being
written to memory, so as to preserve the contents of the accumulator and
Y register.


``` 
.finished
    JMP &FFE7
```

At this point, we have printed the last "group" of one star, and the
cursor will be immediately after it, somewhere on the right side of the
screen.  To avoid spoiling the design with the BASIC prompt, we call an
OS routine to start a new line on screen.  We use JMP as opposed to JSR
so the JSR at the end of the OS routine will return directly to BASIC.

```
.preamble
    EQUB 10
    EQUB 10
    EQUB 10
    EQUB 10
    EQUB 7
    EQUB 22
```

This is the ASCII codes 22, 7, 10, 10, 10, 10 in reverse order.  These
are printed to the screen during the initialisation.

22 = select screen MODE; expects another character indicating the mode
7  = desired mode number  (Teletext, 40 columns, 25 rows)
10 = cursor down; repeated 4 times to move cursor to fifth line.


```    
.pattern
    EQUB 15:EQUB 1:EQUB 7:EQUB 1
    EQUB 31:EQUB 2:EQUB 5:EQUB 2
    EQUB 31:EQUB 3:EQUB 3:EQUB 3
    EQUB 31:EQUB 4:EQUB 1:EQUB 4
    EQUB 27:EQUB 17
    EQUB 24:EQUB 15
    EQUB 26:EQUB 13
    EQUB 28:EQUB 11
    EQUB 30
.middle
    EQUB 9
.end
```

This is the actual pattern data, describing the number of stars or
spaces in each group as far as the middle row of stars:

+ 15 spaces, 1 star, 7 spaces, 1 star
+ 31 spaces, 2 stars, 5 spaces, 2 stars
+ 31 spaces, 3 stars, 3 spaces, 3 stars
+ 31 spaces, 4 stars, 1 space, 4 stars
+ 27 spaces, 17 stars
+ 24 spaces, 15 stars
+ 26 spaces, 13 stars
+ 28 spaces, 11 stars
+ 30 spaces
+ 9 stars
+ ..... and so on again in reverse, but this is generated automatically by re-reading the data again backwards.

