# dict_compress

Host-side dictionary-based text compression for text adventure games or similar.

Perl scripts are used to create BeebAsm source code which can be `INCLUDE`d from the uncompression source.

The uncompression subroutine accepts a message number in A and displays the uncompressed form of the message.

## uncompress.6502

This is the uncompression code.

The start address for the message to be uncompressed should be stored in `text_ptr` and `text_ptr`+1.  The message itself is terminated by character &00 (`BRK`).  Within the message, ASCII codes &80-&7F are treated as tokens and expanded from a dictionary.  Codes &01-&7F are displayed "as normal" except that some shortcuts for characters with trailing spaces have been hard-coded in, as follows:
+ @ displays as "a "
+ { (which would display in MODE 7 as 1/4) displays as ". "
+ | (which would display in MODE 7 as ||) displays as "- "
+ } (which would display in MODE 7 as 3/4) displays as ". "
+ ~ (which would display in MODE 7 as ÷) displays as "? "

### The Dictionary

The dictionary has a table of offsets (up to 256 bytes long; shorter if fewer tokens are used) to the actual word definitions.  The lengths of "words" are not stored explicitly; instead, the last byte is indicated by having bit 7 set.

Since ASCII codes &00-&1F are non-printable, these codes appearing within a dictionary word are expanded as tokens &80-&9F respectively.  If the code for the last character of a word falls into the range &00-&1F, it will be `OR`ed with &60 to give an ASCII code in the range &60 to &7F (i.e., the lower case letters) and displayed with a trailing space.

For example, a dictionary entry such as `&6C &00 &03 &87` would be interpreted as:
+ &6C => lower case `l`
+ &00 => token &80  (whatever that means .....  let's suppose it points to `and`.)
+ &03 => token &83  (this points to `in`.)
+ &87 => last character &07 => lower case `g` with a trailing space.

The full expansion would be `landing `  (including the trailing space), occupying just 4 bytes instead of 8.

## dict2asm

This Perl script reads a message file and a dictionary file, and produces BeebAsm source code which can be combined with the uncompression routine. 

### Usage

`dict2asm -f message_file -d dictionary_file -o output_file`

### Message File

The message file simply contains the individual messages to be compressed, separated by newline characters.  These will be translated automatically to CR, which is the Beeb's usual end-of-line character.

### Dictionary File

The dictionary file is a text file on which each line contains a two-digit hex number 80-FF, separated by whitespace from the "word" represented by the token. Any spaces that are part of the word must be replaced by backquotes.  Example:
```
A0 You`are`in`     
A1 North           
A2 South           
A3 East            
A4 West            
A5 You`            
A6 are`            
A7 bed             
A8 bath            
A9 room            
```

