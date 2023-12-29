# VINTAGE COMPUTING CHRISTMAS CHALLENGE 2023

The challenge is to generate this pattern:

```
   *     *     *
  * *   * *   * *
 *   * *   * *   *
*     *     *     *
 *   * *   * *   *
  * *   * *   * *
   *     *     *
  * *   * *   * *
 *   * *   * *   *
*     *     *     *
 *   * *   * *   *
  * *   * *   * *
   *     *     *
  * *   * *   * *
 *   * *   * *   *
*     *     *     *
 *   * *   * *   *
  * *   * *   * *
   *     *     *
```

The pattern is highly symmetrical, including about the diagonals: any
row is identical to the corresponding column.

If we consider the first four rows, we have this pattern:

```
   *     *     *
  * *   * *   * *
 *   * *   * *   *
*     *     *     *
```

And note this is made from just four distinct patterns in the columns.
So if we can generate just this pattern:

```
   *
  *
 *
*
```

then we ought to be able to extend it somehow from four columns to
nineteen.

First, let us assign values to each row and column and see if we can
spot anything special about the positions where stars appear:

```
ROW  COLUMN
       0   1   2   3
   0 |   |   |   | * |
   1 |   |   | * |   |
   2 |   | * |   |   |
   3 | * |   |   |   |
```

Notice that the stars appear where the row and column numbers add to
exactly 3.  The pattern then repeats column 2, 1, 0, and so forth:

0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0

It soon became clear that the shortest way to generate this pattern is
just to look the values up in a table. 

A naïve implementation of this method using the X and Y index registers
to count from 0 to 18 ends up occupying 39 bytes, plus 19 for the table
giving 58 bytes -- or 56 bytes if we put everything in zero page and use
short operands.

```
.draw
    LDY #0          \  Counts rows
.row
    LDX #0          \  Counts columns
.col
    CLC
    LDA pattern, X  \  Column value 0-3
    ADC pattern, Y  \  Add row value 0-3
    CMP #3          \  Did they add to 3?
    BNE prt_sp
    LDA #42         \  Load A with ASCII code for a star
    BNE prt1        \  Will always branch
.prt_sp
    LDA #&20        \  Load A with ASCII code for space
.prt1
    JSR &FFEE       \  Print character in A
    INX
    CPX #19         \  Number of columns
    BCC col         \  Do another column if X < 19
    JSR &FFE7       \  Start a new line
    INY
    CPY #19         \  Number of rows in pattern
    BCC row         \  Do another row if Y < 19
    RTS             \  The end.
```

We can reduce this to just 52 bytes by counting the rows and columns
downwards, starting from 18 and working down to 0, which allows us to omit
a comparison operation: after the nineteenth DEX or DEY, we can just test
using BPL, which will branch as long as X or Y >= 0 but fall through when
the value turns negative.

```
.draw
    LDY #18         \  Number of rows - 1
.row
    LDX #18         \  Number of columns - 1
.col
    CLC
    LDA pattern, X  \  Column value 0-3
    ADC pattern, Y  \  Add row value 0-3
    CMP #3          \  Did they add to 3?
    BNE prt_sp
    LDA #42         \  Load A with ASCII code for a star
    BNE prt1        \  Will always branch
.prt_sp
    LDA #&20        \  Load A with ASCII code for space
.prt1
    JSR &FFEE       \  Print character in A
    DEX
    BPL col         \  Do another column if X >= 0
    JSR &FFE7       \  Start a new line
    DEY
    BPL row         \  Do another row if Y >= 0
    RTS             \  The end.
```

But there is still a further economy to be had!

Notice how we print a star when the sum of the values from the table is
exactly equal to 3.  If we can arrange instead for the values to add to
exactly 42 when a star is to be printed, then we will already have the
correct ASCII code in the accumulator ready for printing.

Using the values 19, 20, 21, 22, 21, 20, 19 and so forth in the table
gives us 41 when we need a star; but adding 1 to a total is effectively
"free" on the 6502, since we can easily replace the customary CLC which
usually precedes an addition  (unless the carry state is known) with SEC.

This saves another four bytes, bringing the total down to 48 bytes.

```
.col
    SEC             \  Add an extra 1
    LDA pattern, X  \  Column value 19, 20, 21, 22
    ADC pattern, Y  \  Add row value 19, 20, 21, 22
    CMP #42         \  Did they add to 42?  (= ASCII code for star)
    BEQ prt1        \  Skip if so
.prt_sp
    LDA #&20        \  Load A with ASCII code for space
.prt1
```

# FULL BEEBASM SOURCE

```
.draw
    LDY #18         \  Number of rows - 1
.row
    LDX #18         \  Number of columns - 1
.col
    SEC             \  Add an extra 1
    LDA pattern, X  \  Column value 19, 20, 21, 22
    ADC pattern, Y  \  Add row value 19, 20, 21, 22
    CMP #42         \  Did they add to 42?  (= ASCII code for star)
    BEQ prt1        \  Skip if so
.prt_sp
    LDA #&20        \  Load A with ASCII code for space
.prt1
    JSR &FFEE       \  Print character in A
    DEX
    BPL col         \  Do another column if X >= 0
    JSR &FFE7       \  Start a new line
    DEY
    BPL row         \  Do another row if Y >= 0
    RTS             \  The end.
.pattern
    EQUB 19         \  Table of row/column weightings to produce pattern
    EQUB 20
    EQUB 21         \  A star is printed only in rows and columns whose
    EQUB 22         \  weightings add to 41.
    EQUB 21
    EQUB 20         \  Since pattern is symmetrical about diagonal, we can
    EQUB 19         \  use the same weightings for the rows and columns.
    EQUB 20         \  Since pattern is symmetrical about X and Y axes, we
    EQUB 21         \  can read it either forwards or (as here) backwards.
    EQUB 22
    EQUB 21
    EQUB 20
    EQUB 19
    EQUB 20
    EQUB 21
    EQUB 22
    EQUB 21
    EQUB 20
    EQUB 19
```
