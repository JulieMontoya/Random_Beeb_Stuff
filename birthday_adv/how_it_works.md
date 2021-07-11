The Huffman tree text compression scheme used is bit-oriented rather than byte-oriented, and the code to extract individual bits from a stream was easily repurposed to `ROL` the decoded bits into a destination byte rather than descending a tree.  This enables truly-variable length records.

## The Rooms Table

Each record in the rooms table contains a light status, ten exit destinations and a compressed textual description.

The light status is simply a single bit; 1 for light, 0 for dark.

Each exit can consist of any of the following:

Type      | Bits
----------|-------------------------------------------------
No exit   | 0
Near Exit | 10 + 4 bit signed difference from current room
Far exit  | 11 + 8-bit signed absolute destination

The vast majority of possible connections simply will not be available.  Of the available exits, most will be to a room with a number close to the number of the 
current room, and only a few will be to rooms with a difference of 8 or more from the current room.  Only a single bit 0 is required to indicate no exit, since no 
additional information is required.  For an exit to a numerically-nearby room, we store 10 followed by four more bits representing a value between -8 and +7 which 
is added to the current room; and if the destination cannot be expressed in this way, we store 11 followed by eight more bits representing the actual destination.  
If all ten exits are connected to far-away rooms, then this will require 1 + 10 * (2 + 8) = 101 bits = 13 bytes, which is more than the 11 bytes that would be 
required to store the same data uncompressed; on the other hand, a corridor section with just two near exits and eight no-exits requires only 1 + 2 * (2 + 4) + 8 * 
1 = 31 bits = 4 bytes, which is a considerable saving against the 11 bytes of uncompressed data.

The description data begins on the next byte boundary after the exits, and end with the encoded representation of a CR.

Each room also requires a 2-byte pointer to its record.  Since the first bit is always the light status, this can be read directly without unpacking anything by 
reading just the first byte of the record, and using `BMI` or `BPL` to jump to code for "lit" or "unlit" respectively.

## The Objects Table

Each record in the objects table contains "carryability" (1 => object can be picked up and carried; 0 => object cannot be carried), "statefulness", possibly
"state register", "examinability", possibly "examine message", descripton as displayed when carried and description as displayed when seen in a room.

The first (leftmost) bit of an object's record indicates its carryability.  This allows it to be determined quickly without unpacking in full.

Type      | Bits
----------|--------------------------
Stateless | 0
Bi-state  | 10
Polystate | 11 + 6 bit state register

For a bi-state object, if the game state bit flag with the same number as the object is 1, then the examine message and description text from the next object in
the table are used as a surrogate whenever this object is called for.  That object need never be referred to explicitly.  The umbrella in _Birthday Adventure_ is
an example of a bi-state object.  Object 1 is the umbella in its folded state; object 2 is the umbrella in its open state.  It is always referred to as object 1
by the game engine, although if state bit 1 is set then it will be described as though it were object 2.

For a polystate object, a byte register within in the game state area is used to indicate any surrogate object.  (If this byte contains 0, then the object's own description will be used, not the non-existent object 0.)

The message displayed by the built-in `EXAMINE` command is indicated as follows:

Type                  | Bits
----------------------|---------------------------
Nothing special       | 0
Same-numbered message | 10
Any numbered message  | 11 + 6-bit message number

At the next byte boundary is a single byte indicating the length of the compressed stream for the object's short description; then the compressed short description; and finally, on the next byte boundary, the compressed long description.



