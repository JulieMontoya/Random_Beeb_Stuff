# BIRTHDAY ADVENTURE

This is a simple test game to show how my adventure creation system works.

## The Game

The game is set in eight rooms.  The object of the game is to bake a birthday cake.  In order to acquire the ingredients, equipment and energy to complete this task, the player must search for items, solve puzzles and avoid flesh-burning acid, death at the beak of a misanthropic avian menace, or just by good old-fashioned falling over in the dark.

## BUILDING IT ##
```
$ sqlite3 birthday.sqlite3 < birthday.s3t
$ ./make_huffman_tree5 -qbirthday -w
$ ./pack_database -qbirthday -obirthday_data
$ beebasm -i abengine2.6502 -di birthday_base.ssd -do birthday_adv.ssd
```


## The Machine Code "Engine"

The "Engine" provides entry points to select and unpack the database record for a room, deal with a portable artificial light source the player may be carrying, show the room description, list objects in the room, list the available exits from the room, accept a command from the user and action the command.

### init_game

This subroutine sets all game state bits and characters to zero, all objects to their initial locations, sets `R%=1` so the player starts off in room 1, displays stock message #0 corresponding to **welcome** and sets the `show_desc` flag to force the room description to be displayed.

### select_room

This subroutine selects the rooms table entry for the current room, given in the BASIC variable `R%`; and expands its light status, exit destinations and the address of its description text from the bit-packed record.

### art_light

This subroutine overrides the dark status of a room **if** the light source  (by convention, object #9)  is active **and** the player is carrying it  (or it is in the current room).

### disp_desc

This subroutine displays the description text for the current room, **or** the **DARK** stock message.

### list_exits

This subroutine, which you might not need to call, lists the directions available from the current room.  All the room descriptions in Birthday Adventure already mention the exits in the text, so this feature is not used here.  A future version of the engine could include the facility for rooms to have an abbreviated description, which will be displayed if a room has been visited previously.

### list_obj

This subroutine lists the objects in the current room, if light is available; or else does nothing.

### get_cmd

This subroutine accepts a command typed by the player and performs some checks on it.  The first word is assumed to be a **verb**, and its index number will be passed back to BASIC through the variable `V%`.  The second word is assumed to be a **modifier** (e.g. an adjective as in `PRESS RED BUTTON` or a preposition as in `SWITCH ON 3`), passed to BASIC as `M%`; and the last word is assumed to be a **noun** which is passed to BASIC as `N%` and probably corresponds directly to an object in the game.  If the command is only two words long, the second word is treated as both the noun and the modifier; i.e., `N% = M%`.  A word is deemed matched as soon as it is matched in full against a listed word without caring to match the full length of the listed word, so words can be abbreviated to the shortest unique form.  There is one list of verbs and a separate list of nouns and modifiers, thus allowing nouns to be aligned as far as possible with objects.

At this stage, built-in commands -- the directions including `BACK`, `LOOK`, `EXAMINE`, `TAKE`, `DROP` and `INVENTORY` -- are tested roughly for feasibility  (for example, you can't `TAKE` an object which is not in the room, and not all objects are able to be picked up and carried)  and any error conditon indicated by setting the value of `E%`.  If the command is a direction, the destination room  (or 0, if there is no exit)  will be in `D%` and its light status in memory location `next_lt`. 

If the verb is on the verb list but not recognised as a built-in one, the command is effectively ignored: the BASIC program will have to deal with it.  Otherwise, a value of 1, corresponding to a **NONSENSE** error, is returned in E%.

The position in memory of the first character of the last word parsed is returned in `I%`, in case you wish to do any extended parsing of your own.  For instance, in a game featuring a telephone, the player might have to `DIAL` some number for a clue or to cause something to happen.  If the player enters `DIAL 6325` then `I%` will contain the location of the figure 6 in the command.  This can be read using the construct `$I%` in BASIC.  (Birthday Adventure does not make use of this.)

By the time the engine returns to BASIC,  `V%`, `M%`, `N%`, `I%`, `D%` and `E%` and the contents of `next_lt` will have been set to appropriate values.  However, `R%` will not have been altered yet, and the locations of any objects being picked up or deposited will not yet have been updated.  All that has happened so far is that it has determined exactly _how_ it is going to proceed once the command is actioned.

### action_cmd

This subroutine first looks at `E%` and determines whether or not an error message is required.  If so, it is displayed.  Otherwise, `V%` is examined and, if the verb is a built-in one, the game state is updated to reflect the actions oreviously determined when `get_cmd` was called.  For a direction, we set `R%` to the value in `D%`, update the light status and set the "show description" flag.  If the command is `LOOK`, we just set the "show description" flag.  If the command is `EXAMINE`, we display the "examine" message for the object. If the command is `TAKE`, we set the object's location to 0  (if the room is lit)  or 255  (if the room is in darkness).  If the command is `DROP`, we set the object's location to `R%`.  And if the command is `INVENTORY`, then we display a list of objects in location 0  (i.e., carried by the player) and the number, if any, of unidentified objects which have been picked up in the dark.

## The BASIC program

At its very simplest, the BASIC program could consist of just the following:
```
 1000CLS
 1010CALLinit_game
 1020REPEAT
 1030CALLselect_room
 1040CALLart_light
 1050CALLdisp_desc
 1060CALLlist_objects
 1070?&82=0
 1080W%=USRget_cmd
 1090IF?cmdbuf<33THENV%=12:E%=0
 1100IF?cmdbuf=81V%=0:E%=10
 1110REMPRINT"V%=";V%;" M%=";M%;" N%=";N%;" E%=";E%;" NR=";D%;" I%=&";~I%
 1120CALLaction_cmd
 1130UNTILE%=10
 1140END
```
And this would produce a sort-of playable game, especially if every room is specified as illuminated.  However, the entire point of breaking things up is to make it possible to interfere with the game state between any stages of the commands in the game loop.  If we need to affect the light status separately from the functionality provided by `art_light`  (perhaps a range of rooms are lit by a common power source, determined by a single game state bit)  we can do so after `select_room` but before `disp_desc`.  If we need to modify the exits  (if a door needs to be physically opened, or a passageway revealed)  we can do so, and display any message required, before calling `list_objects`, so the message about the additional exit follows on from the room description.  

The main magic happens between `get_cmd` and `action_cmd`.  At this stage, the user probably has entered a command such as `SEARCH CUPBOARD` which the engine does not know how to process on its own.  It is then for the BASIC program to deal with the command, by looking at the values returned by the parser in conjunction with the remainder of the game state, and act accordingly.

