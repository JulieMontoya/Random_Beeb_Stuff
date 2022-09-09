# J-CODE MNEMONICS AND OPCODES

Unless otherwise indicated, instructions exist in the following addressing
modes:

## STACK MODE

The operand is  (operands are)  on top of the calculation Stack.  The
result, if any, is returned on the top of the calculation Stack.

## IMMEDIATE MODE

The  (right-hand)  operand is specified in the instruction  (if there is
a left-hand operand, it is on top of the Stack).  The result, if any, is
returned on the top of the calculation Stack.

Immediate mode opcodes have bit 7 set.

## INDIRECT MODE

The  (right-hand)  operand is to be found in an address specified in the
instruction  (if there is a left-hand operand, it is on top of the Stack).
The result, if any, is returned on the top of the calculation Stack.

Indirect mode opcodes have bits 7 and 6 set.

## DUP

DUPlicate the value on top of the calculation Stack.

_Available in stack mode only._

## USE

Pushes a value onto the calculation Stack.

_Available in immediate and indirect modes only._

## DOUBLE-ENDED OPERATIONS

In Stack mode, the right-hand operand is pulled from the Stack first, then
the left-hand operand.  The result is returned on top of the Stack.

### EOR

Logic Exclusive OR.

### ORI

Logic OR Inclusive.

### AND

Logic AND.

### ADD

Arithmetic add.

### SUB

Arithmetic subtract.  The subtrahend is pulled from the Stack or indicated
in the instruction.  The minuend is pulled from the Stack.  The difference
is returned to the Stack.

### MUL

Arithmetic multiply.

### DIV

Arithmetic divide.  The divisor is pulled from the Stack or indicated in
the instruction.  The dividend is pulled from the Stack.  The quotient is
returned to the Stack.

### MOD

Arithmetic modulus.  Performs a division, but discards the quotient and
returns the remainder instead.

Note that -37 divided by 7 gives -5, remainder -2; not -6, remainder 5.

### POW

Arithmetic raise to power.  Note bits 4 and higher of the index are
ignored  (but anything bigger than 2 ** 15 can never be represented in 16
bits anyway).  The upper 16 bits of the 32-bit product will be available
to an immediately-following `DIP` instruction.

## TESTS

Tests behave similarly to double-ended operators.  They return a value
depending on the relationship between the operands.  If the condition
being tested for is satisfied, the result is -1  (= %1111111111111111, all
bits set)  meaning TRUE.  If the condition is not satisfied, the result is
0  (all bits cleared)  meaning FALSE.  `IF` and `UNTIL` conditions
in BASIC will treat any non-zero value  (i.e., with any bit set)  as TRUE.

### TEQ

Test Equal.

### TNE

Test Not Equal.

### TLT

Test Less Than.  TRUE if the left-hand operand is strictly less than the
right-hand operand.

### TGE

Test Greater or Equal.

### TGT

Test Greater Than.

### TLE

Test Less or Equal.

### CMP

Compare.  Returns -1 if the left-hand operand is less than the right-hand
operand, 0 if they are equal, or +1 if the left-hand operand is greater
than the right-hand operand.

### BCP

Backward compare.  Was worth including, in case it saves an operation.

### BSU

Backward subtract.

### MUF

Multiply Fractional.  This returns the _upper_ 16 bits of the 32-bit
product.

### DIP

Divide Product.  This performs a division without clearing the upper 16
bits of the dividend.  If the immediately-preceding instruction was `MUL`
or `POW` then the upper 16 bits of the product will be intact in the
virtual machine's extension register.

### PUT

Put a value into memory.  The right-hand operand is the address where the
left-hand operand will be stored.

### PAF

Put Address First:  the left-hand operand is the address and the right-
hand operand is the value to be stored there.

### ARG

Array Get. The base address of the array may either be on top of the
Stack, or given as an immediate operand.  The subscripts are pulled from
the Stack in reverse order.

The number of dimensions and size of each dimension are specified in the
array's header, and subscript values will be forced into range by adding
or subtracting the relevant dimension as required.  The value will be
returned on top of the Stack.

_Available in stack and immediate modes only._

### ARP

Array Put.  The base address of the array may either be on top of the
Stack, or given as an immediate operand.  The subscripts are pulled from
the Stack in reverse order  (so the subscript most recently pushed onto
the Stack is the one processed last).  The value to be stored is pulled
from the Stack last of all.

_Available in stack and immediate modes only._
_Not available in indirect mode._

Array Put.  The value to be stored is placed on the Stack, then the subscripts in
order.  The base address of the array may either be on top of the Stack, or specified
in immediate mode.

## SINGLE-ENDED OPERATORS

Single-ended operators take the operand either from the top of the Stack
or specified in the instruction, and return the result on top of the
Stack.

### NCH

No Change.

### TWC

Twos Complement.

### ONC

Ones complement.

### SGN

Signum function.

### ABS

Absolute magnitude.

### RDW

Read Word.

### RDB

Read Byte.

### ARR

Array Access.

### OPB

Open Brackets.

### CLB

Close Brackets.
