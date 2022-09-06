## USE

Pushes a value onto the calculation stack.

## EOR

Logic Exclusive OR.

## ORI

Logic OR Inclusive.

## AND

Logic AND.

## ADD

Arithmetic add.

## SUB

Arithmetic subtract.

## MUL

Arithmetic multiply.

## DIV

Arithmetic divide.

## MOD

Arithmetic modulus.

## POW

Arithmetic raise to power.

## TEQ

Test Equal.

## TNE

Test Not Equal.

## TLT

Test Less Than.

## TGE

Test Greater or Equal.

## TGT

Test Greater Than.

## TLE

Test Less or Equal.

## CMP

Compare.

## BCP

Backward compare.

## BSU

Rackward subtract.

## MUF

Multiply Fractional.  This returns the _upper_ 16 bits of the 32-bit product.

## DIP

Divide Product.  This performs a division without clearing the upper 16 bits
of the dividend.  If the most recent arithmetic operation was a multiply, the
full 32-bit product will still be available to be divided by a 16-bit divisor.

## PUT

Put a value into memory.

## PAF

Put Address First.

## ARG

Array Get.  The subscripts are placed on the stack in order.  The base address of
the array may either be on top of the stack, or specified in immediate mode.
The number of dimensionss and size of each dimension are specified in the array
header, and subscript values will be forced into range by adding or subtracting
the relevant dimension as required.  The value will be returned on top of the
Stack.


## ARP

Array Put.  The value to be stored is placed on the stack, then the subscripts in
order.  The base address of the array may either be on top of the stack, or specified
in immediate mode.

## NCH

No Change.

## TWC

Twos Complement.

## ONC

Ones complement.

## SGN

Signum function.

## ABS

Absolute magnitude.

## RDW

Read Word.

## RDB

Read Byte.

## ARR

Array Access.

## OPB

Open Brackets.

## CLB

Close Brackets.
