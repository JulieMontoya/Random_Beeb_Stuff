# THE GRAPHICS LIBRARY

## SYMBOL OUTLINES

Symbol outlines are drawn from a series of instructions.

### MOVE

**MOVE** moves the cursor on screen to the given point and also sets this as the destination for **CLOSE**.

### DRAW

**DRAW** draws a line on screen to the given point.

### TRIANGLE

**TRIANGLE** draws a triangle on screen from the last-but-one point, to the previous point, to the given
point  (the famous `PLOT 85`).

### CLOSE

**CLOSE** draws a line on screen to the given point, then to the last point mentioned in a **MOVE** instruction
to close an outline.

**CLOSE** immediately after **MOVE** draws an outline rectangle using the previous and given points as
opposite corners.

### CIRCLE_CTR

**CIRCLE_CTR** specifies the centre point for a **CIRCLE_NJ** or **CIRCLE_J** command.  The cursor on screen
will not be moved and the **CLOSE** destination will not be affected.

### CIRCLE_NJ

**CIRCLE_NJ** draws a circle  (or, strictly speaking, a hexadecagon),  or part of a circle, centred on the
previous point; starting from the first point plotted.  The X co-ordinate given specifies the radius.  The
Y co-ordinate given specifies the starting and finishing points as follows:  Bits 4-7 are the most
anticlockwise position  (0 = 3 o'clock).  Bits 0-3 are the most clockwise position.  Drawing proceeds in an
anticlockwise direction if the radius given is positive, or clockwise if the radius given is negative.

### CIRCLE_J

**CIRCLE_J** draws a circle, or part of a circle, centred on the previous point, joined from the last point
visited before the **CIRCLE_CTR** command.  Other details are as above.

### TEXT

_Provisional: **TEXT** writes text to the screen.  Bits 0-7 of the X co-ordinate specify the low byte of
the address of the text to be printed.  Bits 0-8 of the Y co-ordinate specify the high byte.  At the address
are two bytes giving the text size and angle and the length of the text + 2, followed by the text itself._

_The text will have to be able to contain placeholders._


# COMPONENT DEFINITIONS

A component may be split into one or more _systems_, each represented by a _symbol_.  For instance, a
relay with double-pole changeover contacts might have one system for the coil, and another system for
each switched pole.  A simple component such as a resistor, capacitor, diode or transistor probably
will have just one system.


## 2904

An LM2904 dual op-amp is split into three systems, representing the two separate amplifiers and the
power connections.

+ System 0 has the symbol OPA1 connected to physical terminals 1, 2 and 3 respectively.
+ System 1 has the symbol OPA1 connected to physical terminals 7, 6 and 5 respectively.
+ System 2 has the symbol POW2 connected to physical terminals 8 and 4 respectively.


When an instance of a multi-system component is imported into a design, each system within it is
automatically assigned an extended designator.  For instance, if IC1 is a 2904 then the amplifier
systems will be designated IC1A  (pins 1-3)  and IC1B  (pins 5-7)  and the power connections will
be designated IC1C.  It is important to specify a full extended designator in a move command.
However, for the purposes of wiring, these extensions _do not_ form part of the designator;
thus, amplifier 2 output is `IC1 7`, _not_ `IC1B 7`.


# SYMBOL DEFINITIONS

A symbol represents a _system_.  A system may be a complete component, a relay coil, a set of contacts, an
individual op-amp or logic gate within an IC, the power connections for an IC, a single pin of a multi-way
connector or even literally an individual electrode system in a valve such as an ECC83 dual triode.

A system has at least one _terminal_.  A terminal is simply a connection to something.


## OPA1

The symbol OPA1 represents an operational amplifier.  It has three terminals, corresponding to the output,
inverting input and non-inverting input respectively.

## POW2

The symbol POW2 represents a power connection with two terminals.






