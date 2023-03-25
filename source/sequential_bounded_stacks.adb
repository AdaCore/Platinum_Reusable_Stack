--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
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

   procedure Push (This : in out Stack; Item : Element) is
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

   ----------
   -- Copy --
   ----------

   procedure Copy (Destination : in out Stack; Source : Stack) is
      subtype Contained is Element_Count range 1 .. Source.Top;
   begin
      Destination.Top := Source.Top;
      Destination.Values (Contained) := Source.Values (Contained);
   end Copy;

end Sequential_Bounded_Stacks;
