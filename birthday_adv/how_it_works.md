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



