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

### RUNNING MODE

In this mode, the modificand is always in the accumulator; and the
modifier is either embedded into the actual instruction, or passed in the X
register to a subroutine which exits with the result in the accumulator.

### STACK MODE

In this mode, the modificand is always on top of the stack, and the modifier
is always in the accumulator.  Multiplication additionally returns the overflow
in the X register, and division additionally returns the remainder in the X
register.

In our pseudocode, we will represent a stack push by an increase in indentation,
and a stack mode operation by restoring the indentation and not writing an
operand  (think of "the above indented stuff" as being the operand).  For example;
```
    GET A
        GET B
        MUL C
    ADD
```
This incidentally is an example of how the stack automatically allows a
low-priority operation to be interrupted by a higher-priority one.

Note also we could have written
```
    GET C
    MUL B
    ADD A
```
in pure running mode.

_This probably could be built into the compiler easily enough.  If an easy GET
is followed by an ADD or SUB of a product, we can safely reverse the order
of the operands, so the multiplication will occur before the addition, and we
may even be able to bypass stack mode._

It would have been possible to combine an addition and multiplication into
one operation by using a preload.  Where we perform `LDA #0` followed by
`STA prod_hi`, we could have placed any other value in `prod_hi` and it would
end up added to the product, in its correct place.  (This was heavily used in
the original 16-bit maths code from which this is adapted; a 16-bit address
corresponding to the beginning of a table was placed in the preload, the length
of each record in the multiplier, the index of a record in the multiplicand,
and the answer gave the address of the selected record.)  This might be
considered as a future optimisation.  Experiment with it, if you get bored.
The saving might ultimately be minimal if the construct is rare in practice.


.........|.........|.........|.........|.........|.........|.........|.........|

### ADDITION AND SUBTRACTION

Addition and subtraction are compiled directly to native 6502 instructions,
as `CLC` followed by `ADC` and `SEC` followed by `SBC` respectively.
Along with these are `CMP`, `CPX` and `CPY` instructions, which are used by
the relation operators  (which return a Boolean value based on some numeric
test).

### MULTIPLICATION AND DIVISION

Multiplication is performed by a subroutine which has multiple entry points
depending on the initial disposition of the operands.  The entry point
`mult8_AX` multplies A by X.  The entry point `mult8_A` multiplies A by some
value already in the zero page location `multiplier`.  On return, the low
byte of the 16-bit product is in the accumulator, and the high byte of the
product is in the X register.  

Multiplication and division use subroutines which generally expect the
multiplicand or dividend in one zero-page location, the multiplier or divisor
in another, and return the product or quotient in the accumulator and the
high byte of the 16-bit product or remainder in the X register.  

The product of two 8-bit numbers may be up to 16 bits long, so the high
byte of the product is returned in the X register for possible future use.

Multiplication begins by setting the high byte of the product to zero; then
begins the main loop.  The multiplicand is rolled right, importing the
previous carry into the high bit; and if the bit that falls out of the end
is a one, adding the multiplier to the product high byte.  Whether or not an
addition was performed, the product high byte is rolled right, importing a
zero; the bit that falls out of the end is caught in the carry flag, and
gets rolled into the multiplicand the next time around. 

After eight cycles of shifting and maybe adding, the product is given one
final roll right.  Now the original multiplicand has been completely replaced
by bits shifting down from where the multiplier was added to the high byte of
the product.  The copy of the multiplier that was added if the units bit of
the multiplicand was one has been shifted right eight times, the copy that was
added if the twos bit was one has been shifted right seven times, and so
forth, all properly aligned in place.

It's basically the technique you learned in primary school; except, instead
of shifting the digits being added at each stage left under the total so far,
we are shifting the total right over the digits being added.  This minimises
the number of columns needing active addition.

### DIVISION

Division is performed by a subroutine which has multiple entry points
depending on the initial disposition of the operands.  The entry point
`div8_AX` divides A by X.  The entry point `div8_A` divides A by some
value already in the zero page location `divisor`  (which, funnily enough,
happens to be the same as `multiplier`).  On return, the quotient is in
the accumulator, and the remainder is in the X register; the modulus
operator actually compiles to a division followed by TXA.

_If the operation following a % operation is a PUT, we could get rid of the
TXA and replace the STA with STX -- the opposite of what currently happens
with GET operations._

Multiplication and division use subroutines which generally expect the
multiplicand or dividend in one zero-page location, the multiplier or divisor
in another, and return the product or quotient in the accumulator and the
high byte of the 16-bit product or remainder in the X register.  

Division is the opposite of multiplication, and almost exactly reverses the
above process.  Here we attempt to subtract the divisor from a working total
at each stage; updating the remainder in place if the carry was set  (meaning
that the result was positive, i.e. the subtraction succeeded and a 1 belongs
in the quotient)  or rolling it leftwards unaltered if the carry was clear.




.........|.........|.........|.........|.........|.........|.........|.........|

There is a slight twist, in that the roll right of the multiplicand is actually
placed at the _bottom_ of the loop; the first one described above is performed
by jumping in early.


```
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\
\  MULTIPLICATION

.mult8_AX   \ MULTIPLY A BY X
.q_mul
    STX multiplier
.mult8_A    \ MULTIPLY A BY multiplier
    STA multiplicand
.mult8_main
    LDA #0
    STA prod_hi
    LDY #9 \ one more than we need
    BNE _mult8_3 \ always branches
._mult8_1
    BCC _mult8_2 \ skip if zero
    \ add multiplier to prod_hi
    CLC
    LDA prod_hi
    ADC multiplier
    STA prod_hi
._mult8_2
    ROR prod_hi
._mult8_3
    ROR product
    DEY
    BNE _mult8_1
    LDA product
    LDX prod_hi \ RETURN HIGH BYTE IN X
    RTS

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\
\  DIVISION


.div8_AX    \ DIVIDE A BY X; REMAINDER IN X
.q_div
    STX divisor
.div8_A     \ DIVIDE A BY divisor
    STA dividend
.div8_main
    LDA #0
    STA remainder
    LDY #9 \ one more than we need
    BNE _div8_3 \ always branches
._div8_1
    ROL remainder
._div8_2
    \ attempt to subtract divisor from working total
    SEC
    LDA remainder
    SBC divisor
    BCC _div8_3
    \ update dividend if we had room to subtract
    STA remainder
._div8_3
    ROL quotient    \ C shifts into quotient
    DEY
    BNE _div8_1
    LDA quotient
    LDX remainder   \ RETURN REMAINDER IN X
    RTS
```

## PSEUDOCODE

A pseudocode has been used to represent the complex objects within the
instruction tree in a human-readable fashion.  This is based on 6502
instruction syntax, with each operation optionally taking one operand in the
accumulator and one from the instruction itself  (all four combinations exist
in practice) and gets transliterated directly into 6502 assembly language
when the program is compiled.

Stack pushes are indicated by an increase in indentation level, and stack mode
operations by restoring the indentation and not specifying an operand  (think
of the second operand as being "the thing indented above here".)

**BTR** = Branch if TRue.  **BFA** = Branch if FAlse.
**PHA** and **PLA** refer to the calculation stack.

.........|.........|.........|.........|.........|.........|.........|.........|




