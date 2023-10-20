# SIDEWAYS ROM AND RAM STUFF

There are basically two ways in which you can use sideways RAM on the BBC Micro, where fitted
(i.e. a Model B with a sideways RAM upgrade, B+ or Master series machine).

# AS NORMAL MEMORY

Once a 16K bank of sideways RAM is paged in, it occupies addresses &8000 - &BFFF  (where
BASIC normally would be located)  and can be read and written just like "normal" memory.
The only important things to remember are that you must page BASIC back in before you can
return to it; and if you need to throw an error with BRK, this must be done from within
main RAM because the BRK handler in the MOS will page BASIC back in, and the error message
will no longer be visible.

This method requires you to know the sideways RAM slot number, and also to have some code
running in main RAM, which must page in the desired slot before calling the routine in
sideways memory, then page BASIC back before returning.

This is the simplest way of using sideways RAM, but it all feels a bit manual; a bit
breadboard and Dymo tape.  But it's great if you want to store _data_ in sideways RAM.

# AS A "PROPER" SIDEWAYS ROM

Creating a "proper" ROM image which conforms to the format expected by Acorn and provides
service calls which can be accessed via the MOS requires more work at build time, but allows
code within the image to be accessed using the MOS API more or less transparently.  It is
necessary for the ROM image to have a special header which can be recognised by the MOS, and
to include code which responds to service calls issued _inter alia_ whenever the MOS passes
on an unrecognised `OSBYTE`, `OSWORD` or star command to see whether any other sideways ROM
knows how to deal with it.  You do not need to worry about the slot number at all:  the MOS
will take care of all that for you.  It is even possible to serve files from ROM.

The biggest worry when using this method is likely to be choosing `OSBYTE` and `OSWORD`
calls and `*COMMANDS` which are not going to clash with other ROMs.  

This method has more of a "finished product" feel about it, insofar as it is easy to imagine
a real ROM chip in a retail box with cover artwork, a printed manual and one or more
accompanying discs.

## ROM FILING SYSTEM

The Acorn ROM Filing System allows a stream of bytes from ROM to be treated effectively as a
tape, from which files can be accessed sequentially and which can be wound under precise control
of the MOS to any desired counter position.  The data is split into blocks with CRCs and headers,
with the possibility of abbreviating the header on all but the first and last blocks.

The `make_rfs` script is a utility for generating this byte stream from one or more files on
the host, intended for use in the process of developing software to run on an emulated BBC
Micro or Acorn Electron.

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
+ Fields are separated by any whitespace  (spaces or tabs)
+ If the target-side filename is *, a zero-byte title file will be created on the target side
+ If no target-side filename is specified, the host-side filename will be used
+ Addresses are in hex, 1-4 digits, with no prefix
+ If no execution address is specified, the load address will be used
+ If no load address is specified, &0000 will be used
+ A final "T" indicates a text file; this will have all `\n`characters translated to `\r` to match the BBC's expectations

And here is a specific example showing how to create an RFS image with a zero-byte
title file, a BASIC program, a machine code file intended to be loaded at and
executed from particular addresses, a couple of MODE 7 screen saves and a text file:

```
#  Create a title file with no content
*                **HELLO1**
# host_filename  beeb_name   load  exec  [T]
hello1.bas       HELLO       1900  8023
#  Execution address is different from load address
hello1.o         MCODE       2E00  2E16
pic1.m7          PIC1        7C00
pic2.m7          PIC2        7C00
#  T at end means translate line endings
instructions     !INSTR                   T
```

### The Output File

The output file is suitable for inclusion directly into a sideways ROM image, which must
already respond appropriately to service calls &0D  (by initialising a pointer at &F6-F7
with the beginning of the RFS data stream)  and &0E  (by returning the byte pointed to by
&F6-&F7 and advancing the pointer).  In BeebASM, use an `INCBIN` statement for this.

```
ORG &8000

reload_addr = &3C00     \  Address for ROM image to reload if *RUN

.rom_img_begin

offset      = rom_img_begin - reload_addr

.lang_entry
    BRK: BRK: BRK       \  00, 01, 02 => Language entry (null here)
.svc_entry
    JMP service         \  03, 04, 05 => Service entry
.rom_type
    EQUB &82            \  %1000 0010 => Has service entry, 6502
.copy_offset
    EQUB pre_copy - rom_img_begin
.version_no
    EQUB &01
.title
    EQUS "BCP DESIGN"
    BRK
.version_text
    EQUS "0.10"
.pre_copy
    BRK
.copy
    EQUS "(C) Nobody -- Public Domain"
    BRK
    
\  .....  stuff omitted

\  Service routine code as shown here is not complete, but shows the most
\  important instructions .....

.do_svc13
    LDA #rfs_data MOD 256
    STA &F6
    LDA #rfs_data DIV 256
    STA &F7

\  .....  stuff omitted

.do_svc14
    LDX #&F6
    LDA (&00, X)
    INC &F6
    BNE _svc14_1
    INC &F7
._svc14_1

\  .....  stuff omitted

.rfs_data       \  This is where service &0D sets &F6, &F7 to

INCBIN "hello1.rfs"

.rom_img_end

SAVE "ROM_IMG", rom_img_begin, rom_img_end, self_copy - offset, reload_addr;

```

## ADDING FILES TO AN EXISTING ROM IMAGE

As the files are stored strictly sequentially, you can easily add more files to an existing ROM
Filing System stream.  Just find the "next file" address in the header of the last block; this
will point to the "+" sign which is the end-of-stream marker.  Now specify this address as the
`-b` parameter when building your extension stream, and `*LOAD` it on the target beginning at
this address minus the appropriate offset.  The closing "+" will be overwritten with the "*"
marking the beginning of the first added file, and the "+" at the end of the new stream will
mark the end of the whole stream.

_(This is already suggests an obvious improvement to the script's behaviour, which will find_
_its way into the code in due course -- J.M.)_
