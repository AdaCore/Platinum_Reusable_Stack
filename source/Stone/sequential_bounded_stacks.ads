--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

--  This is the Stone level version of the generic package

generic
   type Element is private;
package Sequential_Bounded_Stacks is

   type Stack (Capacity : Positive) is private;

   procedure Push (This : in out Stack; Item : Element) with
     Pre => not Full (This);

   procedure Pop (This : in out Stack; Item : out Element) with
     Pre => not Empty (This);

   function Top_Element (This : Stack) return Element with
     Pre => not Empty (This);
   --  Returns the value of the Element at the "top" of This
   --  stack, i.e., the most recent Element pushed. Does not
   --  remove that Element or alter the state of This stack
   --  in any way.

   overriding function "=" (Left, Right : Stack) return Boolean;

   procedure Copy (Destination : out Stack; Source : Stack) with
     Pre => Destination.Capacity >= Extent (Source);
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

private

   type Content is array (Positive range <>) of Element;

   type Stack (Capacity : Positive) is record
      Values : Content (1 .. Capacity);
      Top    : Natural := 0;
   end record;

end Sequential_Bounded_Stacks;
