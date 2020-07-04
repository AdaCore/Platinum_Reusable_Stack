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

--  This is the test program used for the initial levels.

with Ada.Text_IO;       use Ada.Text_IO;
with Character_Stacks;  use Character_Stacks;

procedure Demo_AoRTE with SPARK_Mode is

   S1, S2 : Stack (Capacity => 10);  -- arbitrary

   X, Y : Character;

begin
   pragma Assert (Empty (S1) and Empty (S2));
   pragma Assert (S1 = S2);
   Push (S1, 'a');
   Push (S1, 'b');
   Put_Line ("Top of S1 is '" & Top_Element (S1) & "'");

   Pop (S1, X);
   Put_Line ("Top of S1 is '" & Top_Element (S1) & "'");
   Pop (S1, Y);
   pragma Assert (Empty (S1) and Empty (S2));
   Put_Line (X & Y);

   Reset (S1);
   Put_Line ("Extent of S1 is" & Extent (S1)'Image);

   Put_Line ("Done");
end Demo_AoRTE;
