# DIFFERENCES FROM BBC BASIC



## GENERAL

All mathematical operations are done in 16-bit integer mode.  No error is generated
if a value goes out of range.  The built-in multiplication / division engine is
actually capable of giving a 32-bit product and accepting a 32-bit dividend; so it
is possible, with due care, to multiply two numbers giving an out-of-range product
and immediately divide this by something that will bring it into range.

## THE ! OPERATOR

The ! operator works with 16-bit values, not 32-bit.

## USR

The USR function returns only the processor status register and accumulator contents.

## STRINGS

Only strings in memory using the `$` operator are supported.

## DIVISION

The `DIV` operator performs the usual integer division.  The `/` operator does
not zero the high bits of the 32-bit dividend before performing the division;
this way, it can handle a product which has exceeded the 16 bit limit.

BBC BASIC already uses 32-bit integers, and DIV and / are functionally identical
when using % integer variables, so writing a program taking this altered
behaviour into account should not affect its running in BBC BASIC.

## COLOUR

`COLOUR` in MODEs 0-6 generates the usual `VDU 17,X` sequence.

`COLOUR` in MODE 7 generates Teletext control codes and sequences.  `COLOUR 0-31`
generate the Teletext control code equal to the argument + 128; so for instance,
`COLOUR 1-7` generate codes 129 to 135 respectively for coloured text; `COLOUR 8`
turns on flashing; and `COLOUR 17-23` produce coloured graphics characters).
`COLOUR 128` generates character code 156 for a black background.
`COLOUR 129-135` generate the appropriate code for the same coloured text,
followed by 157 for "change background". You will need to change the foreground
colour afterwards to produce legible text!

This extension will be interpreted incorrectly by BBC BASIC, but it will not cause
a program to crash.

## PRINT +

In a `PRINT` statement, the `+` modifier causes the next value to be printed as an
unsigned value.  For instance, `PRINT +(30000+10000)` prints `40000` whereas
`PRINT 30000+10000` prints `-23256`.

This modifier is valid syntax as far as BBC BASIC is concerned; it is treated as
unary + and effectively ignored.

## ARRAYS

`DIM A(10)` creates an array with 10 elements `A(0)` to `A(9)`; there is no `A(10)`.
However, array bounds are enforced using modulo arithmetic, so `A(10)` refers to
the _same_ element as `A(0)`, and `A(-1)` refers to `A(9)`.  If you only use array
subscripts starting from 1, this will not make any difference.  But if you ever use
the zero subscript of an array, you may need to increase its size.


# INTENDED EXTENSIONS

It is intended to provide some extensions which will be incompatible with BBC BASIC
(although the program can still be edited, `SAVE`d and compiled).

## BIT ARRAYS

`DIM A(-64)` creates an array of 64 single-bit elements; `DIM S(10,-16)` creates an
array of 10 * 16 single-bit elements.  Storing 0 in an element causes it to read back
as 0.  Storing any non-zero value in an element causes it to read back as -1.

## EXTENDED ARRAYS

`DIM A(4;32)` creates an array where `A(0)`, `A(1)`, `A(2)` and `A(3)` are normal
array elements; and `A(4)` returns the location of a 32-byte block which can be used
to hold any arbitrary data.  `DIM S(10,2;64)` creates an array of ten structures with
two 16-bit values  (accessed as `S(A,B)`)  and a 64-byte block whose address can be
read from `S(A,2)`.  This might be useful for exchanging data with machine code
routines, e.g. sprites having a pair of co-ordinates and a block of pixel data.
Alternatively, something like `DIM R(100;2048)` can be used to hold the starting
addresses of up to 100 variable-length records within a 2048 byte space as `R(0)`
to `R(99)`, with `R(100)` giving the starting address of the 2048 byte block.

`DIM N(20,0;40)` creates a read-only array `N(0)` to `N(19)` which each give the
address of a 40-byte block of memory.  This can be used to emulate (fixed size)
string arrays.

Multiple blocks may be specified using additional semicolons.  For example,
`DIM E(10,1;20;20)` creates an array where `E(A,0)` is a normal numeric element,
`E(A,1)` is the (read-only) address of a 20 byte block and `E(A,2)` is the read-only
address of another, separate 20-byte block.

## COLOUR

`COLOUR` can accept more than one parameter; so `COLOUR 135,4,8` would give flashing
blue text on a white background
