--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

--  This is the test program used for the final two SPARK levels.

with Ada.Text_IO;       use Ada.Text_IO;
with Character_Stacks;  use Character_Stacks;

procedure Demo_Gold with SPARK_Mode is

   S1, S2 : Stack (Capacity => 10);  -- arbitrary

   X, Y : Character;

begin
   pragma Assert (Empty (S1) and Empty (S2));
   pragma Assert (S1 = S2);
   Push (S1, 'a');
   pragma Assert (not Empty (S1));
   pragma Assert (Top_Element (S1) = 'a');
   Push (S1, 'b');
   pragma Assert (S1 /= S2);

   Put_Line ("Top of S1 is '" & Top_Element (S1) & "'");

   Pop (S1, X);
   Put_Line ("Top of S1 is '" & Top_Element (S1) & "'");
   Pop (S1, Y);
   pragma Assert (X = 'b');
   pragma Assert (Y = 'a');
   pragma Assert (S1 = S2);
   Put_Line (X & Y);

   Push (S1, 'a');
   Copy (Source => S1, Destination => S2);
   pragma Assert (S1 = S2);
   pragma Assert (Top_Element (S1) = Top_Element (S2));
   pragma Assert (Extent (S1) = Extent (S2));

   Reset (S1);
   pragma Assert (Empty (S1));
   pragma Assert (S1 /= S2);

   Put_Line ("Done");
end Demo_Gold;
