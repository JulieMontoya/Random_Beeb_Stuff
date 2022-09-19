# THE SYMBOL TABLE

Each plain variable has an entry in the symbol table as follows:

+ Variable name
+ &0D end-of-name marker
+ 2-byte value

Unlike BBC BASIC, `%` is a legal character anywhere in a variable name
(it has no special significance; they are all integers here anyway).

Each array variable has an entry in the symbol table as follows:

+ Variable name including `(`
+ &0D end-of-name marker
+ 2-byte base address

The base address points to the array's header record, which specifies its
dimensionality  (1 byte)  and dimensions  (2 bytes each)  and is then
followed by the array contents as 2-byte values. 

The static integer variables `@%` - `Z%` are not included in the symbol
table.  Instead, the expression parser generates their addresses directly.
These are coincident with the locations used by BBC BASIC  (but only the
bottom 16 bits will be used).



.........!.........!.........!.........!.........!.........!.........!.........!

For an interpreted version, arrays should be stored inline in the symbol
table.  The "value" can be repurposed as an offset past the array record
(header and elements)  to continue searching in the symbol table.


