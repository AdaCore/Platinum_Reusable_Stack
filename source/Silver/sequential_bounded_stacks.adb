--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

package body Sequential_Bounded_Stacks is

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Stack) is
   begin
      This.Top := 0;
   end Reset;

   ----------
   -- Push --
   ----------

   procedure Push (This : in out Stack; Item : in Element) is
   begin
      This.Top := This.Top + 1;
      This.Values (This.Top) := Item;
   end Push;

   ---------
   -- Pop --
   ---------

   procedure Pop (This : in out Stack; Item : out Element) is
   begin
      Item := This.Values (This.Top);
      This.Top := This.Top - 1;
   end Pop;

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

   ----------
   -- Copy --
   ----------

   procedure Copy (Destination : in out Stack; Source : Stack) is
      subtype Contained is Integer range 1 .. Source.Top;
   begin
      Destination.Top := Source.Top;
      Destination.Values (Contained) := Source.Values (Contained);
   end Copy;

end Sequential_Bounded_Stacks;
