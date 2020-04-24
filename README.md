# Platinum_Reusable_Stack

This project contains the generic package and main program for a
sequential, bounded stack abstraction in Ada 2012 that has been
transformed into a completely proven SPARK implementation relying on
static verification instead of run-time enforcement of the abstraction’s
semantics. The code is proven to be free of reads of unassigned
variables, array indexing errors, range errors, numeric overflow errors,
attempts to push onto a full stack, attempts to pop from an empty stack,
subprogram bodies implement their functional requirements, and so on.
These proofs are applied to a full, complete sequential bounded stack
abstraction providing all the facilities required for production use.

## Source Files

The main program declares objects of a type Stack able to contain character
values. That Stack type is provided by the package Character_Stacks, which
is an instantiation of a generic package defining a stack abstract data type.
The instantiation is specified such that objects of the resulting Stack type
can contain character values.

Logically, there are four source files in the application: two (declaration
and body) for the generic package, one for the instantiation of that generic
package, and one containing the demonstration main subprogram. Operationally,
however, there are multiple source files for the generic package. Rather
than have one implementation that we alter as we progress through the SPARK
adoption levels, we have chosen to have a distinct generic package for each
level. Each generic package implements a common stack ADT in a manner consistent
with an adoption level. The differences among them reflect the changes required
for the different levels. This approach makes it easier to keep the differences
straight when examining the code. Furthermore, we can apply the proof analyses
to a conceptually common abstraction at arbitrary adoption levels without
having to alter the code.

In addition to the content differences required by the adoption levels, each
generic package name reflects the corresponding level. We have generic package
Bounded_Stacks_Stone for the Stone level, Bounded_Stacks_Gold for the Gold
level, and so on. Therefore, although the instantiation is always named
Character_Stacks, we have multiple generic packages available to declare the
one instantiation used by the main procedure.

There are also multiple files for the instantiations. Each instantiation is
located within a dedicated source file corresponding to a given adoption level.
The file names for these instances must be unique but are otherwise arbitrary.
For the above, the file name is “character_stacks-stone.ads” because it is the
instance of the Stone level generic. Only one of these instances can be used
when GNATprove analyzes the code (or when building the executable). To select
among them we use a “scenario variable” defined in the GNAT project file that
has scenario values matching the adoption level names. In the IDE this scenario
variable is presented with a pull-down menu so all we must do to work at a given
level is select the adoption level name in the pull-down list. The project file
then selects the instantiation file corresponding to the level, e.g.,
“character_stacks-silver.ads” when the Silver level is selected.

There are also multiple source files for the main program. Rather than have one
file that must be edited as we prove the higher levels, we have two: one for all
levels up to and including the Silver level, and one for all levels above that.
The scenario variable also determines which of these two source files is active.
