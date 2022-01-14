# YSON

YSON is an extension language for AdveBuilder which allows machine code
subroutines to be created from human-readable source code.

### Example
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

The YSON compiler produces a BeebAsm source file which can be INCLUDEd with
the AdveBuilder engine.

# NOTE

YSON should have been called ABEL (for AdveBuilder Extension Language)  but
that acronym was already taken.  (cf. the manpage for the `dd` command).

.........!.........!.........!.........!.........!.........!.........!.........!


