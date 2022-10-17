# EXPRESSIONS

An expression consists of a series of values and operators.  Operators may be single-ended,
such as `ABS` in `ABS V%`; or double-ended, such as `+` in `V% + 1`.  A value may consist of
a bracketed expression.

There are just two simple rules for expressions:
+ A double-ended operator needs a value before and after it.
+ A value may always be preceded by a single-ended operator.

The use of a Stack means we can easily deal with expression priorities, by interrupting any
calculation to perform a higher-priority operation.  For instance, when we encounter an
expression such as `A + B * C` we start with A, get ready to add, get B, notice that * has
a higher priority than +, multiply B by C, and this product is the thing we have to add to A.

If the operation stack is empty, or the top of the operation stack is `(`, we always push
the operation onto the operation stack.

If the new operation has equal or lower priority than the operation on top of the
operation stack, then that operation is added to the program and the new operation is
placed on top of the operation stack.

If the new operation has a higher priority than the operation on top of the operation stack,
then the new operation is pushed onto the operation stack.


`A + B * C`
+ Value A: get on top of value stack
+ Double-ended operator + : push on operation stack
+ Value B: get on top of value stack
+ Double-ended operator * : * has a higher priority than +
+ Value C: multiply by B
+ End of expression.
+ We still have + on operation stack: add two values on stack
+ End of operation stack.



## VALUES

A value may be consist of:
+ A single-ended operator followed by a value
+ A numeric constant, such as `27`
+ A simple variable, such as `V%`
+ A memory access, such as `P%?3`
+ An array access, such as `S%(160-I%)`

In the simplest cases, a `USE constant` or `USE (location)` instruction is added to the program.
Array and memory accesses might well result in a series of instructions being added; but in any
case, the program will be extended so as to push the desired value onto the top of the Stack.

After parsing a value, we expect either a double-ended operator or the end of the expression.

_Possible extension: if a value is followed by a value, a multiply sign * will be inserted
between the two values._

### NUMERIC CONSTANTS

A numeric constant may consist of:
+ An `&` sign followed by up to 4 hex digits 0-9 and A-F
+ A `%` sign followed by up to 16 binary digits 0-1
+ Up to 5 decimal digits 0-9

### VARIABLES

A variable name consists of:
+ A letter `A-Z`, `a-z`, at sign `@`, underscore `_` or pound sign `£`
+ Optional further letters `A-Z`, `a-z`, underscores `_` digits `0-9`
+ An optional % sign

The variable name should exist in the symbol table.

### MEMORY ACCESSES

A memory access may consist of any of:
+ `<variable> ? <variable|numeric constant>`
+ `<variable> ! <variable|numeric constant>`
+ `? <expression>`
+ `! <expression`>

The latter cases may be thought of as single-ended operations, and are treated
as such in practice.

**Difference from BBC BASIC:** The ! operator uses 16-bit values, not 8-bit.

The ? operator refers to a single byte in memory.  The ! operator refers to a
16-bit value spanning two bytes.  The given address holds the low byte and the
following address holds the high byte.

The double-ended forms of ? and ! can be thought of as `base?offset` being
equivalent to `?(base + offset)` and similarly for `base!offset`.  

### ARRAY ACCESSES

An array access consists of an array variable name; followed by a bracketed group
of as many expressions as the array has dimensions, separated by commas.  These must
be evaluated in turn to find the location of the desired element.

The Symbol Table entry for an array contains its number of dimensions, the size of
each dimension in turn and its base address.

An **array access error** is generated if the array is not present in the symbol
table, or the number of subscripts doeas not match the number of dimensions.
A **syntax error** may be generated if any of the subscripts is faulty.

**Differences from BBC BASIC:** There is no **subscript out of range** error.
Subscripts will always be brought into range by adding or subtracting the size of
the relevant dimension as required, so `H%(-1)` is the last element of the array
`H()`.  Also, when an array is dimensioned with e.g. `DIM H%(10)`, `H%(10)` and `H%(0)`
actually refer to the _same_ element.  _You may need to modify BASIC programs which
make use of zero subscripts, by increasing the size of each dimension._

## SINGLE-ENDED OPERATORS

Any value may be preceded by a single-ended operator.  These include logic `NOT`, unary
`-` and `+`, `ABS`, `SGN` and `INKEY`.

Single-ended operators encountered while parsing are always stored on the operation
stack.

After parsing a single-ended operator, we expect another single-ended operator or a
value.




# PARSING AN EXPRESSION



The BASIC pointer `basic_ptr` always points to the beginning of the item being
parsed.  If a match is found, the Y register will contain the offset to the
first byte after the matched item, which may be the beginning of the next item
or the end of a line.

The expression parser always begins in the state "expecting a value", and with
the "last instruction was USE" flag clear.


_Parsing an expression must be re-entrant!  In the course of parsing an expression,
we may encounter a function call or array access which requires further expressions
to be parsed.  It will be necessary to push the parser state on the 6502 stack at
the beginning of an expression, and restore it afterwards._


The expression parser is designed to be re-entrant.  If it is necessary to parse an
expression within an expression, it is possible to save the parser state on the 6502
stack and call the expression parser to treat this as an expression in its own right
and with the existing operation stack isolated.


## SEARCHING FOR A VALUE

Any spaces are skipped, until `basic_ptr` points to a non-space character in the
expression buffer.  The 6502 Y register is initialised with 0.

### SINGLE-ENDED OPERATOR

If the item matched a single-ended operator  (including an opening bracket; which
is permitted as the first character of a value, since a bracketed expression is
itself a value),  it is processed as follows:
+ If the item is an opening bracket, ( is pushed on the operation stack with priority &01.
+ If the item is any other single-ended operator, it is pushed on the operation stack with priority &0E.
The parser state remains "expecting a value".  The "last instruction was USE" flag
is cleared.

`basic_ptr` is adjusted to point to the first character after the item matched.

### NUMERIC CONSTANT

If no single-ended operator was matched, the item is checked to see it it is a
numeric constant; either decimal  (beginning with a digit 0-9),  hexadecimal
(an & sign followed by digits 0-9 and A-F)  or binary  (a % sign followed by
digits 0 and 1).  _Binary constants are an extension over BBC BASIC._

If a numeric constant is matched, a `USE` instruction is appended to the program
and the "last instruction was USE" flag is set.

If the operation on top of the operation stack is single-ended with priority &0E,
and "last was USE" is set, the last instruction of the program is changed from `USE`
to the appropriate addressing mode version  (immediate for a constant, or indirect
for a variable)  of the instruction popped from the stack, and the "last instruction
was USE" flag is cleared.  If the operation on top of the operation stack has 
priority &0E but "last was use" is not set, the instruction popped from the stack
is appended to the program as a stack mode instruction.

This is repeated until either the operation stack is empty, or the top operation is
a double-ended one or an opening bracket.

After parsing a numeric constant, the parser state is changed to "expecting an
operator".  The state of the "last instruction was USE" flag will be dependent upon
whether there were any single-ended operators before the value.  `basic_ptr` is
updated to point to the first character after the value.

### VARIABLE

If the item does not match a numeric constant, it is matched against variables in
the symbol table.  If the item matches a known variable, a `USE (indirect)` instruction
is appended to the program and the "last instruction was USE" flag is set.

If the operation on top of the operation stack is single-ended with priority &0E,
and "last was USE" is set, the last instruction of the program is changed from `USE`
to the appropriate addressing mode version  (immediate for a constant, or indirect
for a variable)  of the instruction popped from the stack, and the "last instruction
was USE" flag is cleared.  If the operation on top of the operation stack has 
priority &0E but "last was use" is not set, the instruction popped from the stack
is appended to the program as a stack mode instruction.

This is repeated until either the operation stack is empty, or the top operation is
a double-ended one or an opening bracket.

After parsing a variable, the parser state is changed to "expecting an operator".
The state of the "last instruction was USE" flag will be dependent upon whether there
were any single-ended operators before the value.  `basic_ptr` is updated to point to
the first character after the variable name.

### ARRAY ELEMENT

Accessing an array element requires evaluating an expression for each subscript.

First, the base address of the array is found.  This points to the array's
header record, which contains the number of dimensions  (1 byte)  followed
by the size of each one  (2 bytes each).  The base address is pushed onto
the operation stack with an "array access" instruction.  This has priority
&0C, with the number of subscripts remaining in the place where its opcode
would go.

The current parser state is then pushed onto the 6502 stack, and a new
parser state set up to expect a value and not stop on an = sign, with a
stack depth of 0.  This places the array access operation out of sight of
the parser.

.........!.........!.........!.........!.........!.........!.........!.........!

### END OF EXPRESSION (BAD)

If the item does not match an opening bracket, single-ended operator, numeric constant
or existing variable, a syntax error is generated.

## SEARCHING FOR AN OPERATOR

Any spaces are skipped, until `basic_ptr` points to a non-space character in the
expression buffer.  The 6502 Y register is initialised with 0.

If the item matched a double-ended operator  (including a closing bracket; which may be
permitted as an end-of-value marker)  then it is processed as follows:

### CLOSING BRACKET

If a closing bracket is encountered, this marks the end of a value.

If the operation stack is not empty and the operation on top of the stack is
not an opening bracket, the program is grown.  If the "last instruction was USE"
flag is set, the last instruction of the program is changed from `USE` to the
appropriate addressing mode version  (immediate for a constant, or indirect
for a variable)  of the operation popped from the stack, and the "last instruction
was USE" flag is cleared.  Otherwise, the new operation is appended to the program
as a stack mode instruction.

This is repeated until the operation on top of the stack is an opening bracket
(or the stack is empty, which creates a syntax error).  The opening bracket is
popped from the stack.  The parser state is set to "expecting an operator" without
affecting the "last was use" flag  (which thus remains set if the only thing inside
the brackets was a constant or variable, even through multiple nested brackets).
`basic_ptr` is adjusted to point to the first character after the item matched.

### HIGH-PRIORITY OPERATION

If the operation stack is empty, or the new operation priority is higher than
the priority of the operation on top of the stack, the new operation is pushed
onto the operator stack.  (The low priority &01 of an opening bracket ensures
the next operation will always be pushed onto the stack.)  The "last instruction
was USE" flag is cleared.  `basic_ptr` is updated to point to the first character
after the operator matched.

### LOW-PRIORITY OPERATION

If the new operation priority is the same as or lower than the priority of the
operation on top of the stack, the operation on top of the stack is used to grow
the program.  If the "last instruction was USE" flag is set, the last instruction
of the program is changed from `USE` to the appropriate addressing mode version
(immediate for a constant, or indirect for a variable)  of the operation popped
from the stack, and the "last instruction was USE" flag is cleared.  Otherwise,
the new operation is appended to the program as a stack mode instruction. 

If we popped an operation from the stack, we test the new operation against the
new top-of-stack.

`basic_ptr` is updated to point to the first character after the operator matched.

### END OF EXPRESSION (GOOD)

If the item being parsed did not match a valid double-ended operator, this is
considered to be the end of the expression.

If the operation stack is not empty, the program is grown.  If the "last instruction
was USE" flag is set, the last instruction of the program is changed from `USE` to
the appropriate addressing mode version  (immediate for a constant, or indirect
for a variable)  of the operation popped from the stack, and the "last instruction
was USE" flag is cleared.  Otherwise, the new operation is appended to the program
as a stack mode instruction.

This is repeated until the operation stack is empty.  The parser state is set to
"success".

By this point, the program has grown to evaluate the expression and leave the value
in the virtual machine's W register.

## GROWING THE PROGRAM

The program is built up as a representation of the expression being parsed, with
variable values fetched from their locations in memory and operations applied as
necessary.  When the complete expression has been parsed, the program generated
will be such as to leave the result in the W register with the Stack beneath it
unaltered.

A constant such as `&1900` is represented in the program correcponding to the
expression by an immediate-mode `USE` instruction.  A variable access such as `W%`
is represented by an indirect-mode `USE(addr)` instruction.

The parser state includes a flag indicating that the last instruction appended to
the program was `USE`.

Instead of appending a stack-mode instruction with immediate and indirect mode
equivalents after a `USE` instruction, the `USE` is altered in place to be the
new instruction, in the same addressing mode as the original `USE`.

# WORKED EXAMPLE

Consider the expression `V% - P% * M% / D%`.  This is parsed as follows:

```
Parser state : 00000000  Operation stack : empty
Program:    empty
```

`V%` -- the operation stack is empty, so the program is grown with
`USE (&0458)`, which will read the value in the memory location used for
the variable V%  (it's one of the so-called static variables, and has a
fixed location in memory)  and push it onto the Stack.

```
Parser state : 11000000  Operation stack : empty
Program:    USE (&0458)
```

`-` -- the operation stack is empty, so `-` is pushed onto the operation
stack together with its priority.

```
Parser state : 01000001  Operation stack : -
```

`P%` -- the program is grown with `USE (&0440)`, which will read the value
in the memory location used for P% and push it onto the Stack.

```
Parser state : 11000001  Operation stack : -
Program:    USE (&0458)
            USE (&0440)
```

`*` -- this has a higher priority than the operation on top of the
operation stack, so we push it and its priority onto the operation stack.

```
Parser state : 01000010  Operation stack : - *
Program:    USE (&0458)
            USE (&0440)
```

`M%` -- the program is grown with `USE (&0434)`, which will read the value
in the memory location used for M% and push it onto the Stack.

```
Parser state : 11000010  Operation stack : - *
Program:    USE (&0458)
            USE (&0440)
            USE (&0434)
```

`/` -- this has the same priority as the operation on top of the operation
stack, so we use that instruction to grow the program.  We could grow the
program with a `MUL` instruction, which will multiply the numbers on top of
the Stack and replace them with the product.  But we know the last
instruction was `USE`, so we alter that _in situ_ to `MUL (&0434)`, which
combines the two instructions into one.  (This saves a byte in the program
and also several ticks of the CPU clock at runtime, since we never have to
touch the Stack: we can poke the right-hand operand straight into the
multiplier.)  After this, the operation stack is empty, so we push the `/`
instruction and its priority onto it.

```
Parser state : 00000010  Operation stack : - /
Program:    USE (&0458)
            USE (&0440)
            MUL (&0434)
```

`D%` -- the program is grown with `USE (&0410)`, which will read the value
in the memory location used for D% and push it onto the Stack.

```
Parser state : 11000010  Operation stack : - /
Program:    USE (&0458)
            USE (&0440)
            MUL (&0434)
            USE (&0410)
```

`(the end)` -- the operation stack is not empty, so it needs to be purged.
The top operation is `/` and the last instruction was `USE`, so it gets
altered to `DIP (&410)`.

```
Parser state : 10000001  Operation stack : -
Program:    USE (&0458)
            USE (&0440)
            MUL (&0434)
            DIP (&0410)
```

The operation stack is still not empty.  The top operation is `-` and the
last instruction was _not_ `USE`; so we grow the program with a stack-mode
`SUB` instruction, which will pull the subtrahend and minuend from the
Stack and push the difference.

```
Parser state : 10000000  Operation stack : empty
                            \  STACK CONTENTS WHEN RUN
Program:    USE (&0458)     \  V%
            USE (&0440)     \  V%  P%
            MUL (&0434)     \  V%  product
            DIP (&0410)     \  V%  quotient
            SUB             \  difference
```

By the time the end of the expression has been reached, the program will
have grown to evaluate the expression, leaving only the result on top of
the calculation Stack.



.........!.........!.........!.........!.........!.........!.........!.........!

# PARSER STATE

The "parser state" is a single byte used to keep track of the program item
being parsed.  The meaning of bit 6 is fixed: it always represents "the last
instruction added to the program was `USE`".  (Bit 6 was chosen for the ease
of testing it in 4 bytes with a `BIT` and a `BVS`.)  Bit 7, which can be
tested in two bytes with a `BMI` instruction, usually represents something
that needs checking often, such as "whether to expect a value or an operator"
or "is this an `INPUT` or a `PRINT` statement?".  The lowest bits are usually
used for some sort of counter.

If we need to parse a different kind of item  (for example, a numeric value
referred to in a `PRINT` statement), the current parser state can be saved
on the 6502 stack and restored afterwards.  

## WHILE PARSING AN EXPRESSION

Bit | Meaning
---:|------------------------------
7   | Expect double-ended operator
6   | Last instruction was `USE`
5   | Stop on =
4-0 | Operation stack depth

## WHILE PARSING A PRINT OR INPUT STATEMENT

`PRINT` and `INPUT` statements are parsed by the same subroutine; which
detects items as string constants to be printed, variables or memory
accesses to be printed or input, or delimiters which affect the cursor
position  (e.g. `'` starts a new line).  

Bit | Meaning
---:|------------------------------
7   | 1 = INPUT, 0 = PRINT
6   | Last instruction was `USE`
5   | 
4   | 
3   | 
2   | 
1   | 
0   | 

## WHILE PARSING A LIST OF VALUES

Bit | Meaning
---:|------------------------------
7   | 1 = any size, 0 = fixed size
6   | Last instruction was `USE`
5   | 
4-0 | Count of values

Note that the count holds the number of values _remaining_ in the case of a
fixed-size list; or the number of values _processed_ in the case of a
variable-size list.




# OPERATOR PRIORITIES

Priority | Operation
--------:|--------------------------
&01      | Open bracket
&02      | Logic `EOR`, `OR`
&03      | Logic `AND`
&04      | Addition and subtraction
&05      | Multiplication, division and modulus
&06      | Powers
&08      | Comparisons `<`, `=`, `>`, `<=`, `<>`, `>=`
&0E      | Single-ended operations
&0F      | Close bracket

A higher number means a higher priority: an operation in progress may be suspended
temporarily in order to perform a higher-priority operation.

An opening bracket is treated as an operator with priority 1; any higher-priority
operation will always be placed on top of it on the operation stack.  When the
corresponding closing bracket is encountered, operations are popped from the
operation stack until the ( returns to the top of the stack, whence it is popped.  

# ARRAY ACCESS INSTRUCTION

Byte | Meaning
----:|--------------------------------
0    | Number of subscripts remaining
1    | Priority = &0C
2    | Low byte of base address
3    | High byte of base address


