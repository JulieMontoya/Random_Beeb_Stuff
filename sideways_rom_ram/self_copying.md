# SELF-COPYING ROM IMAGES

The BBC Model B does not include the `*SRLOAD` command in its operating system,
which predates the concept of sideways RAM.  A suitable utility program would have
been supplied with any sideways RAM upgrade -- either on disc or as a type-in
listing to be entered by the user -- for copying a ROM image file from disc to
sideways RAM.

The intended use case for BCP was on a Model B, to allow of more of the machine's
main memory to be used for the display and thus enable the use of `MODE 1`.
Therefore, some code was included in the BCP sideways ROM image allowing it to be
executed directly; with the reload address chosen so the image will be loaded into
main RAM just below the `MODE 7` display memory, and the execution address pointing
to the self-copying code.  This will read a parameter from the tail end of the
command line and copy the ROM image into the selected sideways RAM slot.

This code is shown below  (some variable assignments are omitted, but it is hoped
the variable names used should make everything obvious):

```
offset      = rom_img_begin - reload_addr

.exec_addr
    LDY #0              \  Y=0 => no file
    LDA #1              \  A=1 => get command tail address
    LDX #&70            \  X   => parameter block address
    JSR osargs
    LDA (&70), Y        \  First non-space char after command
    STA slot_ascii - offset     \  Store in success message
    CMP #71             \  "G"
    BCS not_hex
    CMP #48             \  "0"
    BCC not_hex
    CMP #58             \  ":"
    BCC is_digit09
    CMP #65             \  "A"
    BCC not_hex         \  If BCC falls through, we know C=1
    SBC #7              \  Now ABCDEF map to :;<=>?
.is_digit09
    AND #15             \  Store digit in a later LDA# instruction
    STA select_sw - offset + 1
    LDA romsel_cpy      \  Save current ROM number on stack
    PHA
    LDA #reload_addr DIV 256
    STA src_addr + 1
    LDA # rom_img_begin DIV 256
    STA dest_addr + 1
    LDY #0              \  Keep 00 in low bytes and use Y for offset
    STY src_addr
    STY dest_addr
.select_sw
    LDA #4              \  This will get overwritten
    STA romsel          \  Select destination sideways RAM slot
    STA romsel_cpy
.copy_to_sw
    LDA (src_addr), Y
    STA (dest_addr), Y
    INY                 \  Next byte
    BNE copy_to_sw
    INC dest_addr + 1   \  Increase the high bytes
    INC src_addr + 1
    LDA src_addr + 1
    CMP # (&C000 - offset) DIV 256
    BCC copy_to_sw
.success
    LDX #0
._succ_1
    LDA succ_msg - offset, X
    BEQ _succ_2
    JSR osasci
    INX
    BNE _succ_1
._succ_2
    JSR osnewl
    PLA                 \  Retrieve old ROM slot
    STA romsel
    STA romsel_cpy
    RTS

.not_hex
    BRK
    EQUB 28             \  = BASIC error "Bad hex"
    EQUS "Bad hex"
    BRK
    
.succ_msg
    EQUS "ROM image copied to slot "
.slot_ascii
    EQUS "?"            \  Will get overwritten
    BRK

```

When the ROM image is executed using something like `*MYROM 4`, the program does
the following:

+ Use OSARGS to get the address of the remainder of the command line
+ Read a hex digit for the slot number
+ Store the currently-selected sideways slot number  (Probably DFS)
+ Select the slot specified on the command line
+ Copy the entire ROM image to the selected sideways RAM slot
+ Display a success message
+ Re-select the previously-selected sideways slot
+ `RTS` back to the BASIC prompt.

As we know the code is definitely running from RAM, and is only going to be run once
(the original command line probably is no longer available)  it can safely self-modify.
The character read from the command line is poked directly into the success message
before its value is parsed  (since the message will never be displayed if it is not a
valid hex digit 0-9 or A-F)  and if valid, its value is then stored into a later
`LDA #` instruction.

Note that using indirect indexed addressing actually uses fewer bytes than altering
the code in place; since an `LDA (short, Y)` or `STA (short, Y)` instruction is only
two bytes long, and the addresses in the `INC` instructions which advance the high
bytes of the source and destination addresses can also be specified in short form.

Here `reload_addr` was set equal to &3C00, so the loaded 16KB image will finish just
shy of the screen memory in `MODE 7`.  In any other mode, the ROM image will intrude
into screen memory and be displayed as strange patterns; but it will be copied
safely to sideways RAM before anything gets printed to the screen.
