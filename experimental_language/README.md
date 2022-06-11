# AN EXPERIMENTAL PROGRAMMING LANGUAGE RUNTIME

Just trying to see whether I can do enough with bits of YSON and BCP to
create a runtime library capable of supporting a cut-down BBC BASIC.

# THE VIRTUAL MACHINE

The virtual machine is primarily stack-based.  A few registers are used
internally.

The virtual machine is based primarily around a stack, which is implemented
in software independently of the 6502 stack.  (_A hypothetical J-code virtual
machine running on the Z-80 probably would use the SP' alternative stack
pointer._)

The virtual machine is based primarily around a stack, which is implemented
in software independently of the 6502 stack.  Program instructions can place
data on the stack and manipulate data already on the stack.


The general principle is to have a virtual machine executing instructions
in an intermediate language, with operands being supplied and results
returned via a stack.  All values are 16-bit signed integers.

An expression such as `2+3` could be represented as follows:
```
use 2
use 3
add
```
**use** is an instruction which places a value on the Stack.  So after
`use 2` the Stack contains the value 2.  After `use 3` the Stack contains
the values 3 and 2.  **add** adds two numbers from the Stack and places
their sum on the Stack.  After `add` the Stack contains the value 5.

We can also read values from memory by placing addresses on the Stack and
executing a **get** instruction, which replaces the value on the Stack by
the contents of that address in memory.  An expression such as
`I% * 100 + V%`
could be represented as follows:
```
use &0414
get
use 100
mul
use &0454
get
add
```

We can do better than this, though, by combining some of the most frequently
occurring operations with a **use** instruction; effectively creating
addressing modes.  This will consume space among the possible instructions,
but if necessary we can limit everything to a subset of the most common ones.

### IMMMEDIATE MODE

Immediate mode takes a value specified in the instruction, pushes it onto the
Stack and performs the specified operation.

Immediate mode is indicated by the presence of an operand: `add 3`

### INDIRECT MODE

Indirect mode takes a value specified in the instruction, pushes it onto
the stack, performs a **get** instruction to get the value stored in that
address and finally performs the specified operation.

Indirect mode is indicated by round brackets: `add (&0454)`

### STACK MODE

This is the normal working mode, which expects any input value(s) on the Stack 
and leaves any result(s) there.

Stack mode instructions do not include an operand: `mul`

## INSTRUCTIONS AND DATA
.........!.........!.........!.........!.........!.........!.........!.........!



The program will include both data to be processed and instructions for how
to process it, and it is important to be able to distinguish which is which.
It was not thought realistic to dedicate a bit out of every byte for this, so
instead an instruction must be used to indicate "place value on Stack".

It was not thought realistic to dedicate a bit out of every byte to indicate
whether it contained instructions or data. 

The simplest instruction is "Place literal value on Stack".  


## THE W REGISTER

**W** is the Working register.

## THE X REGISTER

**X** is the eXtension register.

## THE O REGISTER

**O** is the Operand register, and is used for the right-hand operand in
dyadic  (double-ended)  operations. 
.........!.........!.........!.........!.........!.........!.........!.........!


# CALCULATION STACK

The calculation Stack is independent of the 6502 stack.  The right-hand
operand is read from the Stack or supplied in immediate mode.  The left-hand
operand (if any) is read from the Stack.  On completion of an operation,
the answer is always left on the top of the Stack.

Unless explicitly stated otherwise, all values are signed two-byte numbers,
presented units-first.

# INTERMEDIATE CODE

An intermediate code or **J_CODE** is used to express operations.

# INSTRUCTIONS

Instructions are read and parsed by a despatcher.

.........!.........!.........!.........!.........!.........!.........!.........!

## ADDRESSING MODES

J-code instructions, like 6502 instructions, may exist in several different
addressing modes.  Not all instructions may be sensible in all addressing
modes!

Instructions may pull data from the Stack and/or leave results on the Stack.

Most instructions are available in **Stack mode**, where all operands to be
processed are already on the Stack.

The most common form of instruction takes one operand and acts upon the value
on top of the Stack, placing the result on the Stack.  **Immediate mode** and
**indirect mode** instructions specify the operand itself, or the location
where it is to be found, respectively, within the instruction.

### IMMEDIATE MODE

Instructions in immediate mode include the operand directly within the
instruction.

### INDIRECT MODE

Instructions in indirect mode include an address within the instruction,
where the actual operand may be found.

### STACK MODE

Instructions in Stack mode work on data already on the Stack.


### IMMEDIATE MODE

Instructions in immediate mode include some data.  Some instructions have
the ability to work in a "true" immediate mode using the data from the
instruction directly without storing it on the Stack.  Other instructions
work by copying the data from the instruction to the Stack.

### INDIRECT MODE

Instructions in indirect mode include an address where the actual data
may be found.


.........!.........!.........!.........!.........!.........!.........!.........!

A `SOUND` command takes four parameters: channel, loudness, pitch and length.
These are pushed onto the Stack in order.  The command reads the parameters
in the same order as they were written, rather than pulling them individually
and reversing the order; stores them in a parameter block; and calls `OSWORD`
to play the sound.

# SUBROUTINES

### init_calc_stk

Initialise the calculation Stack.

### pushAX

Push a 16-bit value from A (low byte) and X (high byte) to the calculation
Stack.

### push16

Push a 16-bit value from a zero-page location specified in X to the
calculation Stack.

### pull16

Pull a 16-bit value from the calculation Stack to a zero-page location
specified in X.

### get_both

Pull both left-hand and right-hand operands from the calculation Stack to
their usual zero-page locations.

.get_lho

### .mult_stk

Multiply two numbers at the top of the Stack and place the product on the
Stack.

### disp_dec_stk

Pull a value from the top of the Stack and display it as a decimal number.

### conv_str_stk

Pull an address from the top of the Stack.  Pull a value from the top of
the Stack, and store its decimal representation as an ASCII string, ending
with CR, at the supplied address.

### decode_dec_stk

Pull a value from the top of the Stack.  If it is negative, set bit 7 of
`neg_flag` and twos-complement it.  Repeatedly divide by ten and store the
ASCII value of the digit representing the remainder in a scratch space at
the far end of the calculation Stack, units-first.  On exit, X points to
the location _after_ the last (= first!) digit.

### parse_num_stk

Pull an address from the top of the Stack, move it to `str_ptr` and proceed
to `parse_num_at_ptr`.

### parse_num_at_ptr

Search forwards in memory from `str_ptr` for a decimal number, stopping at
the first non-digit, non-space character.  Return the number read on top
of the Stack.

### store_word

Pull an address from the Stack.  Pull a value from the Stack and store it
in the given address.

### twc16

Replace the value on top of the Stack by its twos complement.

## INTERNAL OPERATIONS

The multiply and divide subroutines are very similar; effectively mutual
inverses.  For speed, they operate on fixed zero-page locations.

Since a 16-bit number multiplied by a 16-bit number gives a 32-bit number,
the product and dividend can actually be 32 bits long.  The locations used
for the high bits serve double duty as a preload register when multiplying
and a remainder when dividing, so there are entry points which bypass the
initial zeroing of these locations when desired.

Location | Meaning (multiplying)     | Meaning (dividing)
---------|---------------------------|----------------------------
&70-&71  | (before) Multiplier (LHO) | (before) Dividend (LHO)
&72-&73  | (before) Preload          | (before) Dividend Extension
&74-&75  | Multiplicand (RHO)        | Divisor (RHO)
&70-&71  | (after) Product           | (after) Quotient
&72-&73  | (after) Product Extension | (after) Remainder

Multiplication is inherently signed-friendly.  Division will need to be
fixed to work with signed values.

Other arithmetic operations can usefully use the same locations for
analogous purposes.

### mult16

Multiply the left-hand operand by the right-hand operand.

### mult16_preload

Multiply the left-hand operand by the right-hand operand and add the value
in the preload to the product.

### set_divisor / set_multiplicand

Store an 8-bit value in the right-hand operand, padding with zeros.

### div16 / divide_no_rem

Divides the left-hand operand by the right-hand operand.

### divide_signed

Divides the 32-bit value in the left-hand operand and extension by the
right-hand operand.  Both operands are first positivified and `neg_flag`
bits are set as follows: Bit 7 indicates that the quotient is really
negative, and bit 6 indicates that the remainder is negative.

# ZERO PAGE WORKSPACE

Location | Name       | Meaning
--------:|------------|-------------------------------------------------
&70-&71  | lh_operand | Left-hand operand / result
&72-&73  | remainder  | Preload / remainder /result extension
&74-&75  | rh_operand | Right-hand operand
&7E      | calc_sp    | Calculation Stack pointer
&7F      | neg_flag   | Negative flag
&80-&81  | code_ptr   | Pointer to instruction being executed
&82-&83  | str_ptr    | String pointer
&84-&85  | loop_ptr   | Pointer to FOR / REPEAT structure in loop stack

# INTERNAL OPCODES

Hex | Opcode | Hex | Opcode | Meaning
----|--------|-----|--------|--------------------------------------
&00 | RTS    | &80 | RTS    | RTS
&01 | DUP    | &81 | USE    | Duplicate TOS or use immediate value
&02 | RDW    | &82 | RDW    | Read word = BASIC ! operator
&03 | WRW    | &83 | WRW    | Write word = BASIC ! operator
&04 | PRN    | &84 | PRN    | Print Number
&05 | VDU    | &85 | VDU    | Display char = VDU
&06 | VDW    | &86 | VDW    | Display 2 chars = VDU Z%;
&07 | MUL    | &87 | MUL    | Multiply = * operator
&08 | DIV    | &88 | DIV    | Divide = / and DIV operators
&09 | MOD    | &89 | MOD    | Modulus = MOD operator
&0A | ADD    | &8A | ADD    | Add = + operator
&0B | SUB    | &8B | SUB    | Subtract = - operator
& |     | & |     | 

# NUMERIC VARIABLES

Numeric variables are 16-bit signed integers.

# ARRAYS

Arrays can have as many dimensions as space permits.

.........!.........!.........!.........!.........!.........!.........!.........!
`DIM S(320)` -- creates a one-dimensional array with 320 entries, accessed
as `S(0)` to `S(319)`.

`DIM B(8,8)` -- creates a two-dimensional array with 64 entries, accessed as
`B(0,0)` to `B(7,7)`.

Subscripts start from 0 and wrap around, so in the above example `S(320)` is
an alias for `S(0)`; `S{318)`and `S(-2)` refer to the same  (last but one)
element, and so on.   **This behaviour differs from BBC BASIC.**  You will
have to increase your dimensions by one if you want to use element 0.

Each array has a header record as follows:

BYTES    | MEANING
---------|----------------------
0        | Number of dimensions
1..2     | First dimension
...      | ...
2n-1..2n | Last dimension

This is followed by the actual data, 2 bytes per element.

## ARRAY BOUNDS ENFORCEMENT

Array bounds are enforced in the most primitive and brutal way possible, by
reducing each subscript modulo the size of its dimension.  If the remainder
is negative, then the size is added  (which is certain to give a positive
answer by the operation of the modulus function).


.........!.........!.........!.........!.........!.........!.........!.........!

# DIFFERENCES FROM BBC BASIC

+ All mathematics is 16-bit integer.
+ The `!` memory operator operates on 16-bit values.
+ After `DIM A(10)`, `A(0)` and `A(10)` refer to the _same_ array element!
+ Only strings using the `$` memory operator are supported.

