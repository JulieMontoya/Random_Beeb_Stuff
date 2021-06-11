# Tree Compress 1

A compression scheme based around decorating a ready-made tree contrived to produce codes of known lengths.

The tree has 8 main branches; each of which can have a total length between 3 and 8 bits, giving 1-32 leaves respectively.  Since we know in advance
whether or not a code is complete, and the longest code is 8 bits, we can use a direct lookup table.  The possibility exists to interleave multiple
sections for branches of the same length, and to use the spaces not required by the shortest branches for sections of code; this should afford a
further economy.
