------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2020, AdaCore                          --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
------------------------------------------------------------------------------

package body Bounded_Stacks_Stone is

   -----------
   -- Reset --
   -----------

   procedure Reset (This : out Stack) is
   begin
      This.Top := 0;
   end Reset;

   ------------
   -- Extent --
   ------------

   function Extent (This : Stack) return Natural is
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

   procedure Copy (Destination : out Stack; Source : Stack) is
      subtype Contained is Integer range 1 .. Source.Top;
   begin
      Destination.Top := Source.Top;
      Destination.Values (Contained) := Source.Values (Contained);
   end Copy;

end Bounded_Stacks_Stone;
