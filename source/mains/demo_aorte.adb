--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

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
