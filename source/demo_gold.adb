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
