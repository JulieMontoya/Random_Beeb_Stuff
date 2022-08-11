# THE VIRTUAL MACHINE

The virtual machine executes J-CODE instructions.  A J-CODE instruction consists of an opcode, possibly
followed by some data specifying an operand.

_All mentions of details of implementation in the following is based on the 6502 implementation; which
is the first to be written, but it is fully intended for the J-CODE interpreter to be implemented on
other processor architectures, which may require different implementation than described here._

## THE STACK

Instructions generally operate on a Stack.  Any operands associated with an instruction are placed on
the Stack, which is pushed down.

## ADDRESSING MODES

There are three addressing modes, as follows.

### STACK MODE

The operand(s)  is  (are)  already on top of the Stack.  If an operation returns a result, it will be
placed on top of the Stack.

### IMMEDIATE MODE

The instruction includes an operand.  If a result is returned, it will be on top of the Stack.

An immediate mode instruction such as `MUL &0A` is functionally equivalent to `USE &0A` followed by `MUL`,
but is optimised in the internal implementation.  **Dyadic  (double-ended)** operations copy the right-hand
operand directly from code space into the O register without touching the Stack, and the left-hand operand
never leaves the W register where it has been all along.

### INDIRECT MODE

The instruction includes an address, where the operand is found.

An indirect mode instruction such as `ADD (&0424)` is functionally equivalent to `USE &0424` `RDW` and
`ADD`, but is optimised in the internal implementation.


