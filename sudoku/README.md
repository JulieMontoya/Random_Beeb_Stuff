# CONCEPTS

## VISION MAP

A cell's **vision map** is the set of cells it **sees**  (and which
therefore cannot contain another instance of that digit).

If there exist a set of cells such that at least one of them must contain
some digit, then any cell which sees all those cells  (i.e., belongs to
the intersection of their vision maps)  cannot contain that digit.

## OUTWARD ELIMINATION

**Outward elimination** is the process of eliminating a candidate from
every cell in the vision map of a solved cell containing that digit.

## INWARD ELIMINATION

**Inward elimination** is the process of eliminating as candidates from
an unsolved cell, the values of all solved cells in its vision map.

# OVERALL STRATEGY

In each group  (i.e., row, column and three-by-three box)  we perform an
inward or outward elimination on each cell, then tally up the possible
positions for each digit 1-9 and the number of solved cells.

If the digit has only one possible place within the group, we write it
into the grid as solved and perform an outward elimination.

If the digit has two or three possible places within the group, we take
the intersection of their vision maps with the complement of the group;
and if this is not empty, we eliminate that digit from any cells in that
intersection.
