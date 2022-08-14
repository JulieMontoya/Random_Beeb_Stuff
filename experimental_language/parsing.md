# EXPRESSIONS

An expression consists of a series of values and operators.  Operators may be single-ended,
such as `ABS` in `ABS V%`; or double-ended, such as `+` in `V% + 1`.  A value may consist of
a bracketed expression.

There are just two simple rules for expressions:
+ A double-ended operator needs a value before and after it.
+ A value may always be preceded by a single-ended operator.

The use of a Stack means we can easily deal with expression priorities, by interrupting any
calculation to perform a higher-priority operation.

## VALUES

A value may be consist of:
+ A single-ended operator followed by a value
+ A numeric constant, such as `27`
+ A simple variable, such as `V%`
+ A memory access, such as `P%?3`
+ An array access, such as `S%(160-I%)`

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

### ARRAY ACCESSES

An array access consists of an array variable name, followed by a bracketed group
of as many expressions as the array has dimensions separated by commas.  These must
be evaluated in turn to find the location of the desired element.

An array access error is generated if the array is not present in the symbol table,
or the number of subscripts doeas not match the number of dimensions.
A syntax error may be generated if any of the subscripts is faulty.
Subscripts will be reduced modulo the corresponding dimension and so can never be
out-of-range.

## PARSING AN EXPRESSION



