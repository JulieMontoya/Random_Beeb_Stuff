# TABLES

### BIT tables

Each record in the table is a single bit, and eight such bits are packed into a single byte.

### NYBBLE tables

Each record in the table is a 4-bit number between 0 and 15, and two such values are packed into a single byte.

### BYTE tables

Each record in the table is a single byte, a number between 0 and 255.

### STREAM tables

Each record in the table is a fixed-length stream of bits, beginning on a byte boundary.

```
TABLE moves STREAM
    11 21/5
    0
    10 11
    10 10
    0
    11 7/5
    ...
ELBAT
```
Each line corresponds to a record within the table.  Strings of ones and zeros are interpreted as bits.  Decimal or hexadecimal values
must be followed by a slash and a number of bits to be used to store the value; for example, &14/6 will store the bits 010100. Such
entries must be separated by spaces.

### VLR tables

Each record in the table is a variable-length stream of bits, beginning on a byte boundary, with its 2-byte starting address in a table.

```
TABLE search VLR
    REM 0 => MATCH OBJECT AND ROOM
    REM   7 BITS => NOUN TO MATCH
    REM   7 BITS => ROOM TO MATCH
    REM 10 => MATCH OBJECT
    REM   7 BITS => NOUN TO MATCH
    REM 11 => NO NOUN, MATCH ROOM
    REM   7 BITS => ROOM TO MATCH
    REM
    REM 0 => CONTROLLING STATE BIT
    REM   6 BITS
    REM 10 => AUXILIARY STATE BIT
    REM   6 BITS
    REM 11 => ALWAYS ALLOWED
    REM
    REM 0 => NO MORE OBJECTS TO DROP
    REM 1 => DROP OBJECT
    REM   7 BITS
    REM
    REM 0 => STOCK MESSAGE
    REM 10 => GAME MESSAGE
    REM   7 BITS
    REM 11 => LITERAL TEXT
    REM   TEXT TO DISPLAY
    REM
    0 5/7 1/7 0 5/6 0 10 11/7
    0 5/7 2/7 0 4/6 1 3/7 1 4/7 10 11/7
    0 8/7 3/7 0 6/6 1 14/7 0 10 10/7
ELBAT
```

## STREAM statement

```
STREAM table_name num_expr
```
Selects a record within a stream or VLR table.  (This happens automatically whenever you use FOREACH to iterate over a stream table.)

## GET function

```
num_var := GET num_expr
```
Gets some bits from the selected record.

```
num_var := GET3
```
Gets a constant number of bits.

You can do things like
```
IF ZERO GET1 THEN
    REM first bit is 0 => do nothing
ELIF ZERO GET1 THEN
    REM first two bits are 10 => do something
ELSE
    REM first two bits are 11 => do something different
FI
```

If you ever get more than one bit from the stream in an `IF` statement, you need to use the special variable _ in its `ELIF`s to refer to the
original bits and not fetch a new set of bits from the stream.

## SAYSTRM command

```
SAYSTRM
```
Uncompresses and displays some text from the stream.
