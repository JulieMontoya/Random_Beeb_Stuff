# LANGUAGE REFERENCE

Very much a work in progress .....

## IF STATEMENT

The IF statement has the following syntax:

IF boolean_expression [ THEN statements ] [ ELSE statements ] FI

The expression is evaluated.  If it is TRUE then the statements between THEN
and ELSE are executed.  If the expression is FALSE then the statements between
ELSE and FI are executed.  In any case, execution proceeds after FI.

## BOOLEAN EXPRESSIONS

Boolean expressions can use AND, OR and NOT.  NOT has the highest priority.
AND has a higher priority than OR.

Boolean expressions can use AND, OR and NOT.  NOT has the highest priority.
AND has a higher priority than OR.

A list of terms separated by OR is evaluated only as far as the first TRUE
test  (at which point we know the answer is TRUE).  A list of terms separated
by AND is evaluated only as far as the first FALSE test  (at which point we
know the answer to be FALSE).

## RELATIONS

The following relations can be tested:

## MONADIC RELATIONS

A monadic relation involves one given term and one implied term.

A monadic relation involves only one term.

### POS : Positive  (including zero)

```
POS C3          \  TRUE if C3 is positive or zero
```

This relation is TRUE if the value given is positive  (including zero).

### NEG : Negative

```
NEG C3          \  TRUE if C3 is negative
```

### ZERO

```
ZERO C4         \  TRUE if C4 is zero
```

### NONZERO, NZ

```
NONZERO C4      \  TRUE if C4 is not zero
```

### VISITED, UNVISITED : Whether or not room has been visited

```
VISITED DEST    \  TRUE if destination room has been visited
UNVISITED 12    \  TRUE if room 12 has not yet been visited
```

### BITSET, BITUNSET : Whether or not a status bit is set

```
BITSET 6        \  TRUE if B6 is set
BITUNSET C4     \  TRUE if the status bit pointed to by C4 is unset
```

### VISITED : Room has been visited

```
VISITED DEST    \  TRUE if destination room has been visited
```

### UNVISITED : Room has not been visited

```
UNVISITED 12    \  TRUE if room 12 has not yet been visited
```


###

## DYADIC RELATIONS

### IS, EQ : Equal

```
A IS B
A EQ B
```

This relation is TRUE if the values of A and B are equal.

### ISNT, NE : Not Equal

```
A ISNT B
A NE B
```

This relation is TRUE if the values of A and B are not equal.

### LT : Less Than

```
A LT B
```

This relation is TRUE if the value of A is strictly smaller than the value of B.

### GE : Greater than or Equal to

```
A GE B
```

This relation is TRUE if the value of A is greater than or equal to the value of B.

(There is no LE or GT, due to the 6502 internal architecture.  If this really nags
at me, I'll add them by reversing the order of the terms in the GE / LT test.)

## TERMS WITHIN RELATIONS

Terms within relations may be literal values, symbolic constants or variables.



## NUMERIC OPERATORS

### LOC : Location of object

```
LOC glowstick   \ returns location of the glowstick
```


## SHORTCUTS

### B0 - B255

Short form of `BITSET 0 .. BITSET 255`.  

### UNDERSCORE

When testing a variable for one of several values, use _ as a shortcut:

```
IF ROOM IS 7 OR _ IS 8 OR _ IS 10 THEN
    MESSAGE 17
FI
```

Be very careful with _ elsewhere!

## NUMERIC OPERATIONS

```
INCREASE C3     \  add one to C3
INCREASE C4 6   \  add one to C4 and take the remainder modulo 6
DECREASE C9     \  subtract one from C9
```

An example to handle a light source with limited energy:

```
IF C9 GE 1 THEN
    DECREASE C9
ELSE
    UNSET B9
    LIGHT := 0
FI
```




## MISCELLANEOUS

### DONE
```
DONE
```

Return to BASIC.

### ERROR
```
ERROR SM_CANT_DO
```

Set `E%` to the given value and return to BASIC.

### LIVE, DIE

```
LIVE 56
DIE 11
```

Set `V%` to `VB_LIVE` or `VB_DIE` as applicable and `M%` to the given value,
and return to BASIC.



# CONCEPTS

Requirements:

+ Complete enough to implement typical business logic for an adventure.
+ Should be obvious to anyone familiar with BASIC on the BBC Micro.
+ But not a slavish reimplementation, if there is a better way.
+ Generate bare-metal 6502 code  (no intermediate step).


## SYMBOLIC CONSTANTS

Symbolic constants may behave differently in Boolean and Numeric context.  For
instance, if the symbol `umbrella_open` refers to the game status bit B1, it
will be interpreted when it appears in Boolean context as the present state of
B1.  However, in a Numeric context, it will be interpreted as the value 1.





# NOTE

YSON should have been called ABEL (for AdveBuilder Extension Language)  but that
acronym was already taken.  (cf. the manpage for the `dd` command).
