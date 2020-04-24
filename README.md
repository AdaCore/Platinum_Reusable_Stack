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
