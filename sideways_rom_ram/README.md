# SIDEWAYS ROM AND RAM STUFF

## make_rfs

A Perl script to create the data stream for a Rom Filing System ROM, including headers and CRCs,
from a collection of files on the host.

These files may consist of object code assembled with BeebASM, or snippets taken using `csplit`
or similar from the verbose output when the object code was assembled, by judicious insertion of
`PRINT` statements.  (See the Makefiles used in BCP.)  This allows for the possibility of using
a "stub" program resident in main RAM to call routines in sideways ROM through a static address
table.  A service call must be provided to obtain the current ROM number by reading &F4; this may
then be poked directly into an `LDA #` instruction in the stub code, to initialise it.

### Command line options

In the simplest case, the command may be invoked as

```
$ make_rfs [ -t title ] [ -b begin_addr ] [ -v ] [ -o output_file ] filename1 filename2 filename3 .....
```

The `t` option generates a zero-byte **title file** which will appear in `*CAT` listings, for
identification purposes.  The `-b` option specifies the address in memory at which the stream
should begin, as a hexadecimal number with no prefix.  If not specified, the default value of
&8400 will be used  (to allow some room for the ROM header, possibly self-copying code and the
service code necessary for reading the RFS stream).  If no output file is specified, the
stream will be discarded  (but the script will still crash if anything goes wrong; this may
prove useful for smoke testing.)

The files will be treated as binary files with load and execution addresses of &0000.  Note
that the BBC micro expects lines to end with `\r`, not `\n`.  Filenames will be used verbatim
in the RFS stream, so they must be legal according to the BBC micro.

### Using a control file

To overcome the aforementioned filename, address and line ending limitations, a control file
may be specified instead, specifying the host-side filenames and their corresponding target-side
filenames, load and execution addresses and file types.

When using a control file, the command is invoked as

```
$ make_rfs [ -b begin_addr ] [ -v ] [ -o output_file] -i control_file
```

The control file has the following general format:

```
# comment; ignored
*              TITLE
host_filename1 [ rfs_filename1 [ load_addr [exec_addr ] ] ] [T]
host_filename2 [ rfs_filename2 [ load_addr [exec_addr ] ] ] [T]
```

+ Lines beginning with a comment mark are ignored
+ If the target-side filename is *, a zero-byte title file will be created on the target side
+ If no target-side filename is specified, the host-side filename will be used
+ If no execution address is specified, the load address will be used
+ If no load address is specified, &0000 will be used
+ A final "T" indicates a text file; this will have all `\n`characters translated to `\r` to match the BBC's expectations

And here is a specific example showing how to create an RFS image with a zero-byte
title file, a BASIC program, a machine code file intended to be loaded at and
executed from particular addresses, a couple of MODE 7 screen saves and a text file:

```
#  Create a title file with no content
*               **TEST1**
hello1.bas      HELLO       1900  8023
#  Execution address is different from load address
hello1.o        MCODE       2E00  2E16
pic1.m7         PIC1        7C00  7C00
pic2.m7         PIC2        7C00  7C00
#  T at end means translate line endings
instructions    !INSTR                  T
```


