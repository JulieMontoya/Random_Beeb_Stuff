# THE CALCULATION ENGINE

## MONADIC (SINGLE-ENDED) OPERATIONS

A monadic operation takes a single operand and returns a result.

## DYADIC (DOUBLE-ENDED) OPERATIONS

The dyadic operations +, -, *, / and % have a _modificand_ and a _modifier_.

Consider the statement `score := score + 10`, which compiles to something like this:
```
    LDA var_score      \ copy modificand to accumulator
    CLC                \ clear processor carry
    ADC #&0A           \ add ten to contents of accumulator
    STA var_score      \ copy result over modificand
```
.........|.........|.........|.........|.........|.........|.........|.........|

The modificand is placed in the accumulator, the carry flag is cleared, the
modifier is added to it and the result is copied from the accumulator to the
location in memory from which the modificand was fetched.

We can write this in pseudo-code:
```
    GET score
    ADD 10
    PUT score
```

Note that the 6502 has no built-in instructions for multiplication or
division/modulus, so these operations must be performed in software.  Also,
the 6502's single-operand instruction format means we can't simply embed
the multiplier/divisor into the instruction as we could with addition and
subtraction.



The calculation engine has its own dedicated stack which is handled purely in
software, and completely separate from the processor's own stack.

-- is used in order to keep everything flexible
with respect to subroutine calls.

allows for subroutine calls without affecting the
calculation stack


have a higher priority than addition and
subtraction

Each operation has two modes.

.........|.........|.........|.........|.........|.........|.........|.........|

In the first mode, the modificand is always in the accumulator; and the
modifier is either embedded into the actual instruction, or passed in the X
register to a subroutine which exits with the result in the accumulator.

### STACK MODE

In this mode, the modificand is always on top of the stack, and the modifier
is always in the accumulator.  Multiplication additionally returns the overflow
in the X register, and division additionally returns the remainder in the X
register.

### MULTIPLICATION AND DIVISION

Multiplication and division use subroutines which generally expect the
multiplicand or dividend in one zero-page location, the multiplier or divisor
in another, and return the product or quotient in the accumulator and the
overflow or remainder in the X register.  



