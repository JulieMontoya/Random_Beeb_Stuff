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




## PARSING AN EXPRESSION

The string pointer `str_ptr` always points to the beginning of the item being
parsed.  If a match is found, the Y register will contain the offset to the
first byte after the matched item, which may be the beginning of the next item
or the end of a line.


