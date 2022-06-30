--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

--  This is the Ada version of the generic package, used as the starting point
--  for the transition to the SPARK Platinum level. It is below the SPARK
--  Stone level.

generic
   type Element is private;
package Sequential_Bounded_Stacks is

   type Stack (Capacity : Positive) is private;

   procedure Push (This : in out Stack; Item : in Element) with
     Pre => not Full (This) or else raise Overflow;

   procedure Pop (This : in out Stack; Item : out Element) with
     Pre => not Empty (This) or else raise Underflow;

   function Top_Element (This : Stack) return Element with
     Pre => not Empty (This) or else raise Underflow;
   --  Returns the value of the Element at the "top" of This
   --  stack, i.e., the most recent Element pushed. Does not
   --  remove that Element or alter the state of This stack
   --  in any way.

   overriding function "=" (Left, Right : Stack) return Boolean;

   procedure Copy (Destination : out Stack; Source : Stack) with
     Pre => Destination.Capacity >= Extent (Source)
              or else raise Overflow;
   --  An alternative to predefined assignment that does not
   --  copy all the values unless necessary. It only copies
   --  the part "logically" contained, so is more efficient
   --  when Source is not full.

   function Extent (This : Stack) return Natural;
   --  Returns the number of Element values currently
   --  contained within This stack.

   function Empty (This : Stack) return Boolean;

   function Full (This : Stack) return Boolean;

   procedure Reset (This : out Stack);

   Overflow  : exception;
   Underflow : exception;

private

   type Content is array (Positive range <>) of Element;

   type Stack (Capacity : Positive) is record
      Values : Content (1 .. Capacity);
      Top    : Natural := 0;
   end record;

end Sequential_Bounded_Stacks;
