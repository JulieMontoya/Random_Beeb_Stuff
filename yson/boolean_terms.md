## GENERAL LISTS

Operation lists are generally constructed so that we fall through to the
next test in the list if the result is still indeterminate, or branch to
some target as soon as the result is known  (the first TRUE in an OR list
or the first FALSE in an AND list).  If we reach the last test in a list,
its result is the result for the whole list.



If there are still more tests to be done, we fall through the bottom of
the list to the next test in the parent list.  (If there is no parent, and
no more tests to be done, the whole list has succeeded.)

This allows the `THEN` code to follow immediately after the `IF` or
`ELIF` with which it is associated.  We do not know how big the `THEN`
code will be, so we defensively use a JMP whenever exiting to an `ELIF`
or `ELSE` clause; but we assume all the `IF` / `ELIF` tests will be
short enough for a branch instruction to reach the `THEN` clause
directly.





## OR LISTS

An OR list succeeds as soon as any test within the list returns a TRUE
result.

In the below, `BFA` means "Branch if FAlse" and `BTR` means "Branch if
TRUE" -- the pair of actual instructions being determined by the
relationship being tested.  For instance, if we are testing a GE
relationship, `BCS` branches if TRUE and `BCC` branches if FALSE; but
if we are testing an ISNT relationship then the instruction to branch
if TRUE is `BNE` and branch if false is `BEQ`.

```
.or1_0
    \ TEST
    BTR or1_end
.or1_1
    \ TEST
    BTR or1_end
.or1_2
    \ TEST
    BTR or1_end
.or1_3
    \ TEST
    BTR or1_end
    JMP dest_false
.or1_end
```

```
.and1_0
    \ TEST
    BFA and1_f
.and1_1
    \ TEST
    BFA and1_f
.and1_2
    \ TEST
    BFA and1_f
.and1_3
    \ TEST
    BTR and1_end
.and1_f
    JMP dest_false
.and1_end
```




### AND LIST WITHIN AN OR LIST

The parent list is an OR list; meaning we want to fall through to the
next test in the outer list if the AND list returns false, or branch
away to the outer list's TRUE destination if the AND list returns true.

### AND LIST WITHIN AN AND LIST

The parent list is an AND list; meaning we want to fall through to the
next test in the outer list if the AND list returns true, or jump away
to the outer list's FALSE destination if the AND list returns false.

### AND LIST NOT WITHIN A LIST

We want to fall through to the `THEN` clause if the AND list returns
true, or jump away to an `ELIF` or `ELSE` clause if the AND list
returns false.


### OR LIST WITHIN AN OR LIST

The parent list is an OR list; meaning we want to fall through to the
next test in the outer list if the OR list returns false, or branch
away to the outer list's TRUE destination if the OR list returns false.

### OR LIST WITHIN AN AND LIST

The parent list is an AND list; meaning we want to fall through to the
next test in the outer list if the OR list returns true, or jump away
to the outer list's FALSE destination if the OR list returns false.

### OR LIST NOT WITHIN A LIST

We want to fall through to the `THEN` clause if the OR list returns true,
or jump away to an `ELIF` or `ELSE` clause if the OR list returns false.


## LOGIC TABLE

Result          | Not in list  | in AND list  | in OR list
----------------|--------------|--------------|--------------
OR list: false  | jump away    | jump away    | fall through
OR list: true   | fall through | fall through | branch away
AND list: false | jump away    | jump away    | fall through
AND list: true  | fall through | fall through | branch away






Result                    | Not in list           | in AND list           | in OR list
--------------------------|-----------------------|-----------------------|---------------------
Middle of OR list: false  | fall through          | fall through          | fall through
Middle of OR list: true   | branch to end of list | branch to end of list | branch away
End of OR list: false     | jump away             | jump away             | fall through and out
End of OR list: true      | fall through and out  | fall through and out  | branch away
Middle of AND list: false | jump away             | jump away             | branch to end of list
Middle of AND list: true  | fall through          | fall through          | fall through
End of AND list: false    | jump away             | jump away             | fall through and out
End of AND list: true     | fall through and out  | fall through and out  | branch away

