# Tree Compress 2

A compression scheme based around a Huffman tree generated directly from the character frequencies in the input text, and thus producing the shortest
possible codes.

After each bit is read from the stream, the code so far is tested against each of the known codes.  If a match is found, the character is printed and
we start again.  Codes can be up to 12 bits long; an additional 4 bits are used to represent the length, and fit neatly into 2 bytes.  We need to
know the length to be matched because if we align to the left, we cannot tell the incomplete code 10 from a child node such as 1000 or 100; and if
we align to the right, we cannot tell 10 from 010 or 0010.

