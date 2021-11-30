# LANGUAGE REFERENCE

Very much a work in progress .....

Requirements:

+ Complete enough to implement typical business logic for an adventure.
+ Should be obvious to anyone familiar with BASIC on the BBC Micro.
+ But not a slavish reimplementation, if there is a better way.
+ And not too fancy; there is always still BASIC if really needed.
+ Generate bare-metal 6502 code  (no intermediate step).

The output is BeebAsm source code which performs the actual operations directly,
with no intermdiate, interpreted step; i.e. a statement such as 
```
MESSAGE 13
````
will produce code such as
```
LDA #13
JSR real_select_mesg
```

## 6502 HARDWARE LIMITATION

Conditional branch instructions on the 6502  (BEQ, BNE, BCS, BCC, BVS, BVC,
BMI and BPL) use a short address in the form of an offset from the current
program counter position, and are therefore limited to a range of -128 ..
+127 bytes  (actually -129 .. +126 bytes from the first byte of the branch
instruction, or -127 to +128 from the first byte of the next instruction,
since the program counter gets increased just _before_ reading each byte
of an instruction).

This is by no means insurmountable, since one can always rewrite the code
so as to perform the opposite test and either branch forward past an
unconditional `JMP` instruction  (which uses a long address)  to the code
that would have followed the original conditional branch, or fall through
to the JMP.  This comes at a cost of requiring five bytes rather than the
usual two.

It is possible  (though unlikely)  for a very long series of tests in an
`IF` statement to produce unassemblable code.  

To avoid this, the BeebAsm output will incorporate macro definitions
for `FAR_BNE`, `FAR_BEQ` and so forth, which implement the technique
described above to allow for greater distances.  Wherever BeebAsm
complains of `Branch out of range` errors, edit the source and prepend
FAR_ to the offending instruction.

# THE LANGUAGE

Influenced by BBC BASIC  (Boolean expressions should be similar enough to be
transliterated almost directly)  and 6502 assembler  (not surprising, as this
is the final target).

The major improvement over BBC BASIC is the ability to use nested, multi-line
IF statements, as illustrated in the following example:

```
IF VERB GE 1 AND VERB LT 12 AND (DEST IS 2 OR _ IS 4 OR _ IS 9 OR _ IS 11) THEN
    IF knocked THEN
        IF UNVISITED DEST THEN
            MESSAGE 56
            NEWLINE
        FI
    ELSE
        MESSAGE 68
        ROOM := EXIT 11
        SHOW_DESC := 1
    FI
FI
```

This is the "door knocked" logic from _Bobajob Street_.  We are checking for
a direction verb and the destination room to be 2, 4, 9 or 11  (the houses).
If the game state indicates that the player has previously tried knocking on
a door and received no answer, and the destination room has not been
visited before, they are told that the door is not locked and they enter.
(Nothing happens if the player has already been inside the house and thus
can be expected to remember the door is unlocked.)  But if the player has
_not_ yet knocked on a door, a message is displayed, the player is returned
whence they came and the flag is set to force the room description to be
displayed.

## IF STATEMENT

The IF statement has the following syntax:

IF boolean_expression [ THEN statements ] [ ELSE statements ] FI

The syntax of the IF statement in BBC BASIC is extended to support multi-line
statements with proper nesting.  To mark the end of an IF statement, therefore,
a new keyword FI is required.  Another added keyword is ELIF, which allows
one IF to be executed if another IF tests false without increasing the nesting
level.

```
IF ROOM IS RM_STUDY AND bookcase_moved THEN
    NORTH := RM_PASSAGE
FI
```

In its simplest form, the IF statement looks like this:

```
IF test THEN statement FI
```

Then the statement will be executed if the test is TRUE.  It is also
possible to have multiple conditional statements like this:

```
IF test THEN
    statement
    another statement
    and so on
FI
```

An ELSE clause may be added between THEN and FI, providing a list of
statements which are to be executed if the test is FALSE:

```
IF test THEN
    statement
    another statement
ELSE
    different statement
    more statements
FI
```

Note that every IF requires its own FI.  To avoid this sort of ugliness when
chaining one IF statement onto the ELSE clause of another:

```
IF ROOM IS RM_STUDY AND bookcase_moved THEN
    NORTH := RM_PASSAGE
ELSE
    IF ROOM IS 17 AND door17_open THEN
        EAST := 18
    ELSE
        IF ROOM IS 19 AND door19_open THEN
            NORTH := 20
        FI
    FI
FI
```

another keyword ELIF  (short for ELSE-IF)  has been added.  Using ELIF instead
of ELSE IF makes the code look like this:

```
IF ROOM IS RM_STUDY AND bookcase_moved THEN
    NORTH := RM_PASSAGE
ELIF ROOM IS 17 AND door17_open THEN
    EAST := 18
ELIF ROOM IS 19 AND door19_open THEN
    NORTH := 20
FI
```

which is obviously more manageable if you need to add more tests and
conditional statements.  


The expression being tested is evaluated.  If it is TRUE then the
statement(s) between THEN and ELSE  (or FI, if there is no ELSE)  are
executed.  If the expression is FALSE then any statement(s) between
ELSE and FI are executed.  In any case, execution proceeds after FI.

## BOOLEAN EXPRESSIONS

Boolean expressions can use AND, OR and NOT.  NOT has the highest priority.
AND has a higher priority than OR.

Boolean expressions can use AND and OR.  (There is no NOT, but every test
has an opposite-sense form anyway.)  AND has a higher priority than OR.

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

### V1 - V255

Short form of `VISITED 1 .. VISITED 255`.

### C0 - C63

Short form of `CREG 0 .. CREG 63`.

### L1 - L127

Short form of `LOC 1 .. LOC 127`.

### UNDERSCORE

When testing a variable for one of several values, use _ as a shortcut:

```
IF ROOM IS 7 OR _ IS 8 OR _ IS 10 THEN
    MESSAGE 17
FI
```

This simply adds another `CMP` instruction to an AND / OR chain without
reloading the accumulator between successive comparisons.  Three bytes of
memory and four ticks of the clock in the hand 

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

## ASSIGNMENT

Variable are assigned using statements of the form

variable := value

### SPECIAL VARIABLES

**ROOM** is the current room.  (`R%` in BASIC)

**VERB MOD NOUN** are the indices of the parsed words from the command.

**DEST** is the destination room, if the command is a direction.

**C0-C63** are the character registers within the game state.

**L1-L127** are the locations of objects.

**NORTH NE EAST SE SOUTH SW WEST NW UP DOWN BACK** are the exits from the
current room in the corresponding directions.

.........!.........!.........!.........!.........!.........!.........!.........!

## MISCELLANEOUS

### DONE
```
DONE
```

Return directly to BASIC without executing any more code.  An implied DONE
is automatically appended to a program.


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


## SYMBOLIC CONSTANTS

Symbolic constants may behave differently in Boolean and Numeric context.  For
instance, if the symbol `umbrella_open` refers to the game status bit B1, it
will be interpreted when it appears in Boolean context as the present state of
B1.  However, in a Numeric context, it will be interpreted as the value 1.

Symbolic constants for status bits have an automatic inverse form specified
by including **un** in the name.  For instance, if **B8** is represented by
the symbol `gum_chewed`, then any time the symbol `gum_unchewed` is seen, it
will be read as `NOT gum_chewed`.

## OPERATION LISTS

An AND list consists of a series of Boolean tests, **all** of which must be
TRUE for the list to succeed.  Tests are performed in turn and as soon as the
first one returns FALSE, the program jumps to the list's FALSE address; or
if all tests returned TRUE, execution continues from the end of the list.

An OR list consists of a series of Boolean tests, **any** of which can be
TRUE for the list to succeed.  Tests are performed in turn and as soon as the
first one returns TRUE, the program jumps to the list's TRUE address; or
if all tests returned FALSE, execution continues from the end of the list.




# THE OUTPUT CODE

The output will be in the form of a BeebAsm source code file.


The code generation paradigm will be based on series of tests, falling
through if another test is required or branching away as soon as a definite
TRUE or FALSE is known.  The last test of an OR list, however, will be reversed
so as to jump away if FALSE or fall through if TRUE.  This keeps behaviour
consistent between AND and OR lists.

Operation lists are of type AND and OR.



# NOTE

YSON should have been called ABEL (for AdveBuilder Extension Language)  but that
acronym was already taken.  (cf. the manpage for the `dd` command).
