--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

with Character_Queues;   use Character_Queues;
with Ada.Text_IO;        use Ada.Text_IO;

procedure Demo_Queues with SPARK_Mode is


   --  procedure Put (This : Queue) is
   --  begin
   --     Put ('"');
   --     for C of This loop
   --        Put (C);
   --     end loop;
   --     Put ('"');
   --  end Put;

   --------------------
   -- Demo_Deletions --
   --------------------

   procedure Demo_Deletions is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Queue (Capacity => Size);
      Value : Character;
   begin
      Put_Line ("Demo Deletions");
      Put (Chars, 'a');
      Put (Chars, 'b');
      Put (Chars, 'c');
      Put (Chars, 'd');
      Put (Chars, 'e');
      Put (Chars, 'f');
      pragma Assert (Model (Chars) = "abcdef");
      Get (Chars, Value);
      pragma Assert (Value = 'a');
      pragma Assert (Model (Chars) = "bcdef");
      Delete (Chars, Number_To_Delete => 2);
      pragma Assert (Model (Chars) = "def");
      Delete (Chars, Number_To_Delete => 1);
      pragma Assert (Model (Chars) = "ef");
      Delete (Chars, Number_To_Delete => 2);
      pragma Assert (Model (Chars) = "");
   end Demo_Deletions;

   ---------------
   -- Demo_Copy --
   ---------------

   procedure Demo_Copy is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Queue (Capacity => Size);
   begin
      Put_Line ("Demo Copy");
      pragma Assert (Empty (Chars));
      for C in Character range 'a' .. 'j' loop
         Put (Chars, C);
      end loop;
      pragma Assert (Model (Chars) = "abcdefghij");
      pragma Assert (not Empty (Chars));
      pragma Assert (Full (Chars));
      pragma Assert (Extent (Chars) = Size);
      declare
         Temp : Queue (Capacity => Size);
      begin
         Copy (Chars, Target => Temp);
         pragma Assert (Chars = Temp);
         pragma Assert (Model (Temp) = "abcdefghij");
         pragma Assert (Full (Temp));
         pragma Assert (Extent (Temp) = Size);
      end;
   end Demo_Copy;

   -------------------
   -- Demo_Put_Loop --
   -------------------

   procedure Demo_Put_Loop is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Queue (Capacity => Size);
   begin
      Put_Line ("Demo Put in a loop");
      pragma Assert (Empty (Chars));
      for C in Character range 'a' .. 'j' loop
         Put (Chars, C);
      end loop;
      pragma Assert (Full (Chars));
      --  the first 10 characters are "abcdefghij"; Capacity is
      --  arbitrarily set to 10.
      pragma Assert (Model (Chars) = "abcdefghij");
   end Demo_Put_Loop;

   ----------------------
   -- Demo_Put_and_Get --
   ----------------------

   procedure Demo_Put_And_Get is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Queue (Capacity => Size);
      Value : Character;
   begin
      Put_Line ("Demo Get");
      pragma Assert (Empty (Chars));
      Put (Chars, 'a');
      Put (Chars, 'b');
      Put (Chars, 'c');
      Get (Chars, Value);
      pragma Assert (Value = 'a');
      Get (Chars, Value);
      pragma Assert (Value = 'b');
      Get (Chars, Value);
      pragma Assert (Value = 'c');
      pragma Assert (Empty (Chars));
   end Demo_Put_and_Get;

begin
   Demo_Copy;
   Demo_Deletions;
   Demo_Put_and_Get;
   Demo_Put_Loop;

   Put_Line ("Done");
end Demo_Queues;
