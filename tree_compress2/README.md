# Tree Compress 2

A compression scheme based around a Huffman tree generated directly from the character frequencies in the input text, and thus producing the shortest
possible codes.

## stream4.6502

This is the uncompression code, which reads the stream of bits generated in the compression process and displays the uncompressed characters represented by each bit pattern.

We keep a much simplified copy of the original tree, in the form of a simple table which can be accessed using the `long,X` addressing mode.  Each node on the tree has a record of 2 bytes.  A node with children has the indices of its left and right children.  A leaf node has &00 in the position where the left child should be, and the payload in the position where the right child should be.

Four bytes of zero page are used for workspace.  `stream_ptr` and `stream_ptr+1` are a pointer to the current _byte_ within the bit stream.  `stream_bit` indicates the bit within the byte.  `tree_pos` indicates the currently-selected node within the tree.  The last two could be anywhere, if zero page space is really at a premium, but this will incur speed and space penalties.

To display a message, we initialise `stream_ptr` and `stream_ptr+1` to point to the beginning of the bit stream representing the message and `stream_bit` to 0  (we are working left to right, so 0 means bit 7 &80, 1 means bit 6 &40 and so forth).  Then we read a character at a time from the stream and send it to OSASCI  (or a custom word-wrapped display routine .....)  If the value we read is less than 32, we return; otherwise, we go back and read another character from the stream until we reach a control character.  (The tree-generating script will use &0A, which moves the BBC cursor vertically down to the next line; you probably will want to change this to &0D, which moves the BBC cursor to the _beginning_ of the next line.)

To read a character, we first initialise `tree_pos` to point to the root node.  Then we extract a single bit from the stream.  If the bit is a 0, we descend to the left child node; if the bit is a 1, we descend to the right child node.  We then check the node on the tree where we just moved to.  If it is a leaf, we display the character and exit; otherwise we read another bit and descend another level, and keep going until we reach a leaf node.

To extract a bit from the stream, we read the byte in memory pointed to by `stream_ptr`, `AND` it with a value dependent on the value in `stream_bit` and store the processor status flags on the stack while we update `stream_bit` and maybe increase `stream_ptr` if we went past 7 and back to 0.  We then restore the processor status and update `tree_pos` with either the left or right child node, dependent on the result of the `AND` operation in the Z flag.  On return, the new position on the tree will be in `tree_pos`, and also in the accumulator.

## stream6.6502

This is an improved version of the uncompression code with a further optimisation, effectively extending it to support 127 leaf nodes.

This time, the tree table stores _either_ the index of the next node down the tree _or_, where the next node on one side would be a leaf, its payload  (so we do not actually need to store leaf nodes at all).  Since each node's record is 2 bytes long, we can use bit 0 = 0 to indicate a node with children, or bit 0 = 1 to indicate a payload.

After extracting each bit, we test bit 0 of `tree_pos`.  If 0, we read another bit.  If 1, we perform an `LSR A` and then display the character.

## make_huffman_tree

This is a Perl script to take some input data, and generate a Huffman tree and the compressed data using it, ready to paste into BeebAsm source code.

First of all, the frequency of each character is counted, and a leaf node is created for each individual character, with the character as its _payload_ and the number of times it occurred in the input file as its _freq_.

We then build the tree from the leaves towards the root, as follows.  First we select the two least-frequently occuring nodes; and then we create a new node, with those as its right and left children, the sum of their frequencies as its frequency and no payload of its own, and add it to the tree.  We keep going until we have only one node remaining, and then call that the root of the tree.

To generate the output, we reverse the tree so that node 0 is the root  (this means we can use 0, which is especially easy to spot, as a special value to indicate "no child node" since nothing should ever link back to the root, as a matter of definition)  and the leaves appear last.  Each node has a two-byte record representing its left and right children, if present; or &00 for the left child and the payload where the right child should be.  Since the records are 2 bytes long, the values we store are twice the node numbers to which they refer; so if node 0 has 01 is its left child and 02 as its right child, it will contain the values &02 and &04.  This allows us to load the value representing the current position on the tree straight into X; then `LDA tree,X` will load the accumulator with the position of the left child node, or `LDA tree+1,X` will load A with the position of the right child node.

The messages are compressed by looking up the path to the node representing each character, and appending this to the bit stream.  The resulting string of 1s and 0s has seven more zeros appended, and is then sliced up into eight-character chunks.  These are treated as binary bytes and appended to a string representing the compressed data.  Lastly, this is converted to EQUB statements and split into lines shorter than 80 characters for neatness.

## make_huffman_tree2

This is a modified Perl script to create the shortened version of the tree as used by `stream6.6502`.  Child nodes with children of their own are indicated by even values; child nodes which are leaf nodes are indicated by odd values.  This is done by doubling the ASCII code and adding 1, equivalent to `ORA #1` followed by `ROL A`.

### USAGE

```
$ make_huffman_tree -i INPUT_FILE -o OUTPUT_FILE
```

### INPUT FILE

The input file should consist of just a series of newline-separated messages.  It can be produced using any modern text editor with soft line wrapping.  Actually it can be produced using a text editor without soft line wrapping, but it won't be half as much fun.

### OUTPUT FILE

The output file will consist of two sections of BeebAsm source code; representing the tree which will be used to decode the compressed text, and the individual compressed messages themselves.  These can be pasted into `stream4.6502` (or your game code based on it).

## TEST7.bas

This is a simple BASIC wrapper around the tree and uncompression code.

### USAGE
```
RUN
A%=0
CALL select_msg
A%=A%+1
CALL select_msg
```

## advtest1

This is a message file containing some room descriptions from an unfinished game by the author, used as a real-life example to test the compression code.
