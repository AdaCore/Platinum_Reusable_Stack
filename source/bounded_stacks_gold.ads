------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2020, AdaCore                          --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

generic
   type Element is private;
   --  The type of values contained by objects of type Stack

   Default_Value : Element;
   --  The default value used for stack contents. Never
   --  acquired as a value from the API, but required for
   --  initialization in SPARK.
package Bounded_Stacks_Gold is

   pragma Unevaluated_Use_of_Old (Allow);

   subtype Element_Count is Integer range 0 .. Integer'Last - 1;
   --  The number of Element values currently contained
   --  within any given stack. The lower bound is zero
   --  because a stack can be empty. We limit the upper
   --  bound (minimally) to preclude overflow issues.

   subtype Physical_Capacity is Element_Count range 1 .. Element_Count'Last;
   --  The range of values that any given stack object can
   --  specify (via the discriminant) for the number of
   --  Element values the object can physically contain.
   --  Must be at least one.

   type Stack (Capacity : Physical_Capacity) is private
      with Default_Initial_Condition => Empty (Stack);

   procedure Push (This : in out Stack;  Item : Element) with
     Pre    => not Full (This),
     Post   => not Empty (This)
               and then Top_Element (This) = Item
               and then Extent (This) = Extent (This)'Old + 1
               and then Unchanged (This'Old, Within => This),
     Global => null;

   procedure Pop (This : in out Stack;  Item : out Element) with
     Pre    => not Empty (This),
     Post   => not Full (This)
               and Item = Top_Element (This)'Old
               and Extent (This) = Extent (This)'Old - 1
               and Unchanged (This, Within => This'Old),
     Global => null;

   function Top_Element (This : Stack) return Element with
     Pre    => not Empty (This),
     Global => null;
   --  Returns the value of the Element at the "top" of This
   --  stack, i.e., the most recent Element pushed. Does not
   --  remove that Element or alter the state of This stack
   --  in any way.

   overriding function "=" (Left, Right : Stack) return Boolean with
     Post   => "="'Result = (Extent (Left) = Extent (Right)
                             and then Unchanged (Left, Right)),
     Global => null;

   procedure Copy (Destination : in out Stack; Source : Stack) with
     Pre    => Destination.Capacity >= Extent (Source),
     Post   => Destination = Source,
     Global => null;
   --  An alternative to predefined assignment that does not
   --  copy all the values unless necessary. It only copies
   --  the part "logically" contained, so is more efficient
   --  when Source is not full.

   function Extent (This : Stack) return Element_Count with
     Global => null;
   --  Returns the number of Element values currently
   --  contained within This stack.

   function Empty (This : Stack) return Boolean with
     Post   => Empty'Result = (Extent (This) = 0),
     Global => null;

   function Full (This : Stack) return Boolean with
     Post   => Full'Result = (Extent (This) = This.Capacity),
     Global => null;

   procedure Reset (This : in out Stack) with
     Post   => Empty (This),
     Global => null;

   function Unchanged (Invariant_Part, Within : Stack) return Boolean
     with Ghost;
   --  Returns whether the Element values of Invariant_Part
   --  are unchanged in the stack Within, e.g., that inserting
   --  or removing an Element value does not change the other
   --  Element values held.

private

   type Content is array (Physical_Capacity range <>) of Element;

   type Stack (Capacity : Physical_Capacity) is record
      Values : Content (1 .. Capacity) := (others => Default_Value);
      Top    : Element_Count := 0;
   end record with
     Predicate => Top in 0 .. Capacity;

   ------------
   -- Extent --
   ------------

   function Extent (This : Stack) return Element_Count is
     (This.Top);

   -----------
   -- Empty --
   -----------

   function Empty (This : Stack) return Boolean is
     (This.Top = 0);

   ----------
   -- Full --
   ----------

   function Full (This : Stack) return Boolean is
     (This.Top = This.Capacity);

   -----------------
   -- Top_Element --
   -----------------

   function Top_Element (This : Stack) return Element is
     (This.Values (This.Top));

   ---------
   -- "=" --
   ---------

   function "=" (Left, Right : Stack) return Boolean is
     (Left.Top = Right.Top and then
      Left.Values (1 .. Left.Top) = Right.Values (1 .. Right.Top));

   ---------------
   -- Unchanged --
   ---------------

   function Unchanged (Invariant_Part, Within : Stack) return Boolean is
     (Invariant_Part.Top <= Within.Top and then
        (for all K in 1 .. Invariant_Part.Top =>
            Within.Values (K) = Invariant_Part.Values (K)));

end Bounded_Stacks_Gold;
