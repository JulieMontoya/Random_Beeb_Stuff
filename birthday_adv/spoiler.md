# BIRTHDAY ADVENTURE

Please bear in mind that this will spoil any enjoyment you may have had from the game.

## The Game World

The game world consists of just 8 rooms.  These are a white room, a kitchen, a blue room, a room with bare brick walls, the top of a
ladder, a dark loft space, a back yard and a tiny henhouse which is also dark.

## Object of the Game

The object of the game is to bake a birthday cake.  This will require the player to collect some ingredients  (an instant cake mix and an egg)  and equipment
(baking tins)  as well as arranging an energy supply.

## Ways to Die

The player must avoid being pecked to death by a vicious mother hen, having the flesh eaten off their bones by dripping acid or falling and breaking their neck in
the dark.

## At the Start

The player begins in the white room and can reach the kitchen, blue room, backyard and henhouse.  

Rudimentary in-game assistance is provided by a `HELP` command; which generally just suggests `SEARCH`ing or `EXAMINE`ing things, but is also used to telegraph
specific part of the solution path to the player.

Discoveries can be made by `SEARCH`ing furniture mentioned in the descriptions.  In the kitchen, `SEARCH CUPBOARD` reveals a bag of bird seed and an instant cake
mix.  If the latter is `EXAMINE`d, the player will see:

```
Instant cake mix. Add one egg. Divide
mix evenly between two cake tins and
bake 15 minutes at no. 4.
```

This should show the steps towards the final goal:  the player needs to locate an egg and some baking tins.  It's not unreasonable for the player to suppose that
an egg is likely to be found in a henhouse.  However, this particular henhouse is dark, and any attempt to `TAKE` what is in there results in a suitably gory
ending:

```
You try to grab something in the dark,
but then some enormous angry creature
lunges at you and pecks you to death!
Game over!
```

`SEARCH SOFA` in the blue room reveals a pound coin between the cushions.  What could be the purpose of the coin?  It _must_ do something useful, otherwise the
author of the game would not have felt the need to hide it.

`SEARCH CUPBOARD` in the white room reveals that the cupboard is concealing a gas meter.  `EXAMINE METER` further shows that it is of the coin-operated type,
and requires a coin to be inserted to enable the gas supply.

## Puzzle One: the Dripping Acid

The doorway South from the white room, linking it to the bare brick room, has a strange liquid dripping from the lintel and into a drainage trough in the floor.
As the player will soon learn, this is a deadly corrosive acid.

```
The liquid must be some sort of acid! It
eats into your flesh ..... You are dead!
Game over!
```

To proceed past the acid, the player requires some protection.  In the kitchen is a colourful umbrella.  If the player picks up the umbrella and tries to pass
through the acid, a slightly different final message is displayed:

```
The dripping acid eats into your
flesh..... You notice, just before you
die, that it is taking a while to eat
through the fabric of the folded
umbrella.
Game over!
```

It is of course necessary to `OPEN UMBRELLA` before going South from the white room.

## Puzzle Two: Trapped

The umbrella having been destroyed by the acid, the player is now trapped in the white room.  There is a ladder which can be climbed, but the only room
accessible from there is dark, and any direction save `BACK` results in a grisly ending:

```
You stumble in the dark and break your
neck!
Game over!
```

The in-game HELP system will already have clued the player to the fact that `TAKE` without a noun will pick up the first object found.  And this is in fact the
key to solving this puzzle.  `TAKE` in the dark loft area picks up an unidentified object.  When the player returns into the light, it is revealed to be a small
plastic tube, which can be `EXAMINE`d:

```
The tube is made of soft translucent
white plastic. It contains a liquid and
a small glass vial.
```

In case it is still not obvious that this is a glowstick of the type beloved by ravers, attempting to `SHAKE` the tube produces this message:

```
You shake the tube, but the glass vial
inside does not break.
```

It is hoped that the player will then try `BEND TUBE` to produce this message:

```
You bend the tube and the glass vial
inside bursts. The chemicals mix and
react. It is now giving off a yellowish
glow.
```

Now the player has a light source, and will be able to see in the loft area a pair of baking tins  (which the player must `TAKE` to complete the game)  and an
exit, with a last hint that the player had better make sure to collect everything they need as there will be no return.  The return path, including landing on
the sofa in the blue room, might provide an additional hint to the player to `SEARCH` the sofa if they have not done so already.

## Puzzle Three: The Killer Hen

Now the player has a light source, the hen house can be revisited, and the vicious monster revealed as a mother hen being over-protective with an egg.  As a
reward for the hard work of finding and activating a light source (!), attempting to `TAKE` the egg is no longer fatal; just unsuccessful:

```
She won't let you get near enough to do
that!
```

(Let this stand as a piece of advice to game developers:  Remember that puzzles are intended to be solved.  Early deaths are fine, but try to avoid killing the
player off once they have made a certain amount of progress.)

As suggested by in-game HELP, `DROP`ping the bag of bird seed  (found in the kitchen cupboard; you might have to go `BACK` and `SEARCH` for it)  in the henhouse
distracts the mother hen, allowing the player to take the egg.

## The Final Act: BAKE CAKE

To complete the game, the player must return to the kitchen and enter the command `BAKE CAKE`.  If the player is not carrying the egg, cake mix and baking tins,
they must be present in the room; and the coin must have been inserted in the gas meter.

If any of the egg, cake mix or baking tins are absent, this message is displayed:

```
You are missing something important!
```

The player is expected at least to have found the cake mix  (and indeed must certainly have done so if they have already obtained the egg, since the cake mix
is found along with the bird seed that must be deployed as a distraction before the egg can be taken)  and so be able to work out what else they need .....

If the ingredients and tins are present and correct but the meter has not yet been fed, this is displayed instead:

```
The ignition sparks, but the oven will
not light!'
```

Only if the player has the cake mix, egg, baking tins, and the coin is inserted in the meter, is the winning text displayed:

```
Congratulations! You baked a beautiful
birthday cake!
Game over!
```



