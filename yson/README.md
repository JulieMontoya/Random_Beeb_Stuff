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

The program uses the game state for its variables.  These may be referred to
directly as **B0..255**, **C0..C63**, **V1..V255** and **L0..L63** and some
others such as **VERB**, or via _symbolic constants_ such as `coin_found`.

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

An example to implement a piece of logic where the player can only pick up
a rabbit if they are carrying a carrot is shown below:

```
IF VERB IS VB_TAKE AND NOUN IS rabbit THEN
    IF CARRYING carrot THEN
        TAKE NOUN
    ELSE
        MESSAGE MSG_runs_away
        VERB := 0
    FI
FI
```

Another piece of logic might involve a radio which, when listened to, plays
one of three different songs (which may be clues).  This is done using a
character register to hold the current song number, and displaying a message
accordingly:

```
IF VERB IS VB_LISTEN AND NOUN IS radio THEN
    IF AVAIL radio THEN
        MESSAGE radio_song + song_0
        INCREASE radio_song 3
    ELSE
        ERROR := SM_NOT_HERE
    FI
FI
```

If you can understand this, congratulations!

# NUMERIC EXPRESSIONS

Simple integer numeric expressions are possible, using values taken directly
from game state registers, symbolic constants and literal values.  Functions
are provided to access room and object properties in the game database.

All numeric operations are performed on 8-bit values.  If a number becomes
negative, it effectively gets 256 added to it.  Beware: comparison operations
always treat values as unsigned, so `-1 GE 1` is TRUE as it is treating the
comparison as `255 GE 1`.  If you really need to compare signed numbers, you
can use something like
`IF NEG (A - B) THEN statements FI` 
to force a signed comparison; but note, this is not taking into account the
possibility of a false change of sign caused by a carry from bit 6 overflowing
into the sign bit 7.  It is probably best to stick to using BASIC unless you
know _exactly_ what you are doing.


## MONADIC (SINGLE-ENDED) NUMERIC OPERATORS

### LOCOF : Location of object

```
LOCOF glowstick   \ returns location of the glowstick
```

### EXIT : Destination in a direction

```
EXIT 3   \ returns destination in direction 3 (= East)
```

### TWC : Twos Complement

```
TWC C6
```

Subtracts a number from 256 so that when added to another number, the carry
will be set and the sum will be the other number minus the first number.


## DYADIC (DOUBLE-ENDED) NUMERIC OPERATORS

### * / % + -

The `*` (multiply), `/` (divide) and `%` (modulus) operators have a higher
priority than the `+` (add) and `-` (subtract) operators; monadic operators
have an even higher priority.  So `A + B * C` performs the multiplication
before the addition.  Brackets can be used to override the usual order of
operations; (A + B) * C performs the addition before the multiplication.

If you do not use the `*` , `/` or `%` operators or perform any `INCREASE`s
with a limit, you can choose to make the runtime overhead smaller.

# VARIABLES

Game state registers are used for variables.  These may be referred to
directly as **B0..255**, **C0..C63**, **V1..V255** and **L0..L63** and some
others such as **VERB**, or via _symbolic constants_ such as `coin_found`.

## ASSIGNMENT

Variable are assigned using statements of the form

```
variable := value
```

The value can be any numeric expression.

### SPECIAL VARIABLES

**ROOM** is the current room.  (`R%` in BASIC)

**VERB*, **MOD** and **NOUN** are the indices of the parsed words from the command.

**DEST** is the destination room, if the command is a direction.

**C0-C63** are the character registers within the game state.

**L1-L127** are the locations of objects.

**NORTH NE EAST SE SOUTH SW WEST NW UP DOWN BACK** are the exits from the
current room in the corresponding directions.

**SHOW_DESC** is the "show description" flag, and should be set to 1 if the
player moves, in order to force a room description to be displayed.
(Direction commands do this automatically.)


## IF STATEMENT

The IF statement has the following syntax:

IF boolean_expression [ THEN statements ] 
{ [ ELIF boolean_expression [ THEN statements ] ] ..... }
[ ELSE statements ] FI

The syntax of the `IF` statement in BBC BASIC is extended to support multi-line
statements with proper nesting.  To mark the end of an `IF` statement, therefore,
a new keyword `FI` is required.  Another added keyword is `ELIF`, which allows
one `IF` to be executed if another `IF` tests false without increasing the nesting
level.

```
IF ROOM IS RM_STUDY AND bookcase_moved THEN
    NORTH := RM_PASSAGE
FI
```

In its simplest form, the **IF** statement looks like this:

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

Note that the indentation is purely for the sake of readability.  It is _not_
a requirement of the language; the compiler is only concerned with the words
`IF`, `THEN`, `ELIF`, `ELSE` and `FI`.  It _is_ necessary to use **FI** even
on a single-line **IF** statement; and note also that, unlike BBC BASIC,
**THEN** _is_ required.

An **ELSE** clause may be added between **THEN** and **FI**, providing a list
of statements which are to be executed if the test is FALSE:

```
IF test THEN
    statement
    another statement
ELSE
    different statement
    more statements
FI
```

.........!.........!.........!.........!.........!.........!.........!.........!

Note that every **IF** requires its own **FI**.  To avoid this sort of
ugliness when chaining one IF statement onto the ELSE clause of another:

```
IF ROOM IS RM_STUDY AND bookcase_moved THEN
    NORTH := RM_PASSAGE
ELSE
    IF ROOM IS 17 AND door17_open THEN
        EAST := 18
    ELSE
        IF ROOM IS 18 AND door17_open THEN
            WEST := 17
           ELSE
               IF ROOM IS 19 AND door19_open THEN
                   NORTH := 20
               ELSE
                   IF ROOM IS 20 AND door19_open THEN
                       SOUTH := 19
                   FI
               FI
           FI
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
ELIF ROOM IS 18 AND door17_open THEN
    WEST := 17
ELIF ROOM IS 19 AND door19_open THEN
    NORTH := 20
ELIF ROOM IS 20 AND door19_open THEN
    SOUTH := 19
FI
```

which is obviously more manageable if (when!) you need to add more tests and
conditional statements.  

The `test` is evaluated as a Boolean expression.  If it is TRUE then the
statement(s) between `THEN` and `ELSE`  (or `FI`, if there is no `ELSE`)
are executed.  If the expression is FALSE then the next ELIF is tested,
and its own `THEN` clause possibly executed; if there are no more `ELIF`s
then the statements between `ELSE` and `FI` are executed.  In any case,
execution proceeds after `FI`.

A chain of **OR**s is evaluated only as far as the first TRUE result, and
a chain of **AND**s is evaluated only as far as the first FALSE result;
at this point, 

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

## MONADIC (SINGLE-ENDED) RELATIONS

A monadic relation involves only one term  (and maybe an implied term).

### POZ : Positive Or Zero

```
POZ C3          \  TRUE if C3 is positive or zero
```

This relation is TRUE if the value given is positive  (including zero; the way
the 6502 handles numbers internally requires _everything_ to be treated as
_either_ positive _or_ negative, and it happens to be easiest to treat zero
as positive).  The spelling is deliberately contrived to prevent anyone from
carelessly spelling it `POS` without realising this, and wondering why it lets
zero through .....

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

### ISSET, UNSET : Whether or not a status bit is set

```
ISSET 6         \  TRUE if B6 is set
UNSET C4        \  TRUE if the status bit pointed to by C4 is unset
```

## DYADIC (DOUBLE-ENDED) RELATIONS

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

This relation is TRUE if the value of A is strictly smaller than the value of
B.

### GE : Greater than or Equal to

```
A GE B
```

This relation is TRUE if the value of A is greater than or equal to the value
of B.

.........!.........!.........!.........!.........!.........!.........!.........!

### GT : Greater Than

```
A GT B
```

This relation is TRUE if the value of A is strictly greater than the value of
B.  (Actually, if the value of B is strictly smaller than the value of A, due
to the 6502's internal architecture -- there is no test for strictly greater,
so it tests `B LT A`.)

### LE : Less Than or Equal To

```
A LE B
```

This relation is TRUE if the value of A is smaller than or equal to the value
of B. (But see above.)

### MULTOF : Multiple Of

```
A MULTOF B
```

This relation is TRUE if the value of A is an exact multiple of the value of
B; that is to say, if `A % B` is zero.  It can be thought of as a shortcut
for `ZERO (A % B)`.

## IMPLICIT RELATIONS

### CARRY

This is TRUE if the previous arithmetic operation resulted in a carry, or if
the carry was deliberately set in a `PROC`.  Note that the carry flag is apt
to change at any time, so use this with caution: test it immediately, and
set or clear it immediately before an `ENDPROC`.

Remember also that `INCREASE` does not affect the carry flag; you will need
to use something like
```
low_byte := low_byte + 1
IF CARRY THEN
    middle_byte := middle_byte + 1
    IF CARRY THEN
        INCREASE high_byte
    FI
FI
```
to increase a multi-byte value.

### NOCARRY

This is TRUE if the previous arithmetic operation resulted in a carry, or if
the carry was deliberately cleared in a `PROC`.

## TERMS WITHIN RELATIONS

Terms within relations may be literal values, symbolic constants or variables.

## SHORTCUTS

### B0 - B255

Short form of `ISSET 0 .. UNSET 255`.

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
memory and four ticks of the clock in the hand, and all that .....

Be very careful with _ elsewhere!

## NUMERIC OPERATIONS

```
INCREASE C3     \  add one to C3
INCREASE C4 6   \  add one to C4 and take the remainder modulo 6
DECREASE C9     \  subtract one from C9
```

### INCREASE variable [num_expr]

Adds one to a variable.  In its simplest form it would be used thus:

```
INCREASE air_used
```

It is possible to append a numeric value which will be treated as a
limit for the increased value; if it would have reached that value,
it will instead be reset to 0:

```
IF VERB IS VB_LISTEN AND NOUN IS radio THEN
    INCREASE radio_song 3
    MESSAGE radio_song + MSG_song0
FI
```

changes the value in `radio_song` from 0 to 1, 1 to 2 and then from 2
back to 0 again with successive calls.

### DECREASE

Subtracts one from a variable; if it goes negative, 256 is added.

An example to handle a light source with limited energy:

```
IF C9 GE 1 THEN
    DECREASE C9
ELSE
    UNSET B9
    LIGHT := 0
FI
```

### DOUBLE

Doubles the value by shifting it leftwards one bit; always importing zero into
bit 0.

### HALVE

Halves the value by shifting it rightwards one bit; always importing zero into
bit 7.

## OBJECT-RELATED COMMANDS

Commands relating to objects.

### DESTROY num_expr

Moves the object with the given number to room 254, effectively placing it out
of the game.

### DROP num_expr

Places the object with the given number in the player's room.

### MOVE num_expr TO num_expr

Places the object with the given number in the given room.

### TAKE num_expr

Adds the object with the given number to the player's inventory.

### BRIEF num_expr

Displays the brief ("carried") description for the object with the given ID number.

## MOVEMENT COMMANDS

### GOROOM num_expr

Moves the player to the given numbered room and forces a description to be
displayed.  Equivalent to

```
ROOM := num_expr
SHOW_EXITS := 1
```

## GAME COMMANDS

Commands related to progress within the game.

### MESSAGE num_expr

Displays the message with the given ID number.

### SHIFT

Forces the next letter printed to be capitalised.

### NEWLINE

Starts a new line.

### LIVE num_expr

Sets the verb to `VB_LIVE` and the message to the given number.  Any
error condition will be overridden when the command is actioned; the
message is displayed and the player gets another turn.

### DIE num_expr

Sets the verb to `VB_DIE` and the message to the given number.  Any
error condition will be overridden when the command is actioned; the
message is displayed and the game is over.

.........!.........!.........!.........!.........!.........!.........!.........!

## MISCELLANEOUS

### DONE
```
DONE
```

Return directly to BASIC without executing any more code.  An implied DONE
is automatically appended to a program.

## FOR LOOP

The `FOR` loop has the following syntax:

```
FOR num_expr [ASC|DESC] num_expr
    statements using _
NEXT
```

The statements within the loop will be executed repeatedly, each time with
the special variable `_` set to a value starting with the first num_expr
supplied, and then ascending or descending one at a time to the second
num_expr. 

## FOREACH LOOP

The `FOREACH` loop has the following syntax:

```
FOREACH [ROOM|OBJECT]
    statements using _
NEXT
```

The statements within the loop will be executed repeatedly, each time with
the special variable `_` set to the number of a room, or an object, in
turn.

Here is an example to list the contents of a bag, where the special room
represented by `RM_inbag` is used for objects that have been placed in the
bag:

```
SET bagempty
FOREACH OBJECT
    IF LOCOF _ IS RM_inbag THEN
        IF bagempty THEN
            SAY "The bag contains:"
            NEWLINE
            CLEAR bagempty
        FI
        SAY "* "
        BRIEF _
        NEWLINE
    FI
NEXT
IF bagempty THEN
    SAY "There is nothing in the bag."
    NEWLINE
FI
```

The state bit `bagempty` is initially set, and we iterate over the objects in
turn.  If an object is found in the bag, and the `bagempty` bit is set, we
display a short message and clear `bagempty`; this ensures the message will
be displayed the first time only.  Then we print a bullet point and the brief
description of the object.  After we have been around the loop for the last
time, if `bagempty` is still set then we display a message that there is
nothing in the bag.

`FOREACH ROOM` sets not only _ to the number of the room; but also all the
associated special variables `NORTH`, `SE`, `LIGHT` and so forth.  If all you
need to check is the visited state of each room, it would be quicker just to
use `FOR 1 ASC 15` or however many rooms you have.

**BE CAREFUL when iterating over rooms!**  The game engine allows for only one
room to be unpacked at a time, and direction commands rely on the _current_
room being unpacked _and_ its light status and exits updated as required _even
at the action_cmd stage_.  You should ensure only to do anything with rooms on
non-direction commands.

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


# IMPORTANT

After `action_cmd` has completed, it is possible for the player to have been
killed and the game ended.  You will either need to wrap
```
IF ERROR ISNT 10 THEN
FI
```
around any code that executes after `action_cmd`, or else only call it from
BASIC if the player is still alive:
```
 2010IFE%<>10CALLafter_cmd
```

# THE OUTPUT CODE

The output will be in the form of a BeebAsm source code file.


The code generation paradigm will be based on series of tests, falling
through if another test is required or branching away as soon as a definite
TRUE or FALSE is known.  The last test of an OR list, however, will be reversed
so as to jump away if FALSE or fall through if TRUE.  This keeps behaviour
consistent between AND and OR lists.

Operation lists are of type AND and OR.



# NOTE

YSON should have been called ABEL (for AdveBuilder Extension Language)  but
that acronym was already taken.  (cf. the manpage for the `dd` command).

.........!.........!.........!.........!.........!.........!.........!.........!

