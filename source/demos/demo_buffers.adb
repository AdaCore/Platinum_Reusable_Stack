--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

with Character_Buffers;  use Character_Buffers;
with Ada.Text_IO;        use Ada.Text_IO;

procedure Demo_Buffers with SPARK_Mode is


   --  procedure Put (This : Ring_Buffer) is
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
      Chars : Ring_Buffer (Capacity => Size);
      Value : Character;
   begin
      Put_Line ("Demo Deletions");
      Insert (Chars, 'a');
      Insert (Chars, 'b');
      Insert (Chars, 'c');
      Insert (Chars, 'd');
      Insert (Chars, 'e');
      Insert (Chars, 'f');
      pragma Assert (Model (Chars) = "abcdef");
      Remove (Chars, Value);
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
      Chars : Ring_Buffer (Capacity => Size);
   begin
      Put_Line ("Demo Copy");
      pragma Assert (Empty (Chars));
      for C in Character range 'a' .. 'j' loop
         Insert_Preserving (Chars, C);  -- not intending to overwrite
      end loop;
      pragma Assert (Model (Chars) = "abcdefghij");
      pragma Assert (not Empty (Chars));
      pragma Assert (Full (Chars));
      pragma Assert (Extent (Chars) = Size);
      declare
         Temp : Ring_Buffer (Capacity => Size);
      begin
         Copy (Chars, Target => Temp);
         pragma Assert (Chars = Temp);
         pragma Assert (Model (Temp) = "abcdefghij");
         pragma Assert (Full (Temp));
         pragma Assert (Extent (Temp) = Size);
      end;
   end Demo_Copy;

   ---------------------------------
   -- Demo_Put_Preserving_and_Get --
   ---------------------------------

   procedure Demo_Put_Preserving_and_Get is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Ring_Buffer (Capacity => Size);
      Value : Character;
   begin
      Put_Line ("Demo Put_Preserving");
      pragma Assert (Empty (Chars));
      Insert_Preserving (Chars, 'a');
      Insert_Preserving (Chars, 'b');
      Insert_Preserving (Chars, 'c');
      Remove (Chars, Value);
      pragma Assert (Value = 'a');
      Remove (Chars, Value);
      pragma Assert (Value = 'b');
      Remove (Chars, Value);
      pragma Assert (Value = 'c');
      pragma Assert (Empty (Chars));
   end Demo_Put_Preserving_and_Get;

   -------------------------------
   -- Demo_Put_Overwriting_Loop --
   -------------------------------

   procedure Demo_Put_Overwriting_Loop is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Ring_Buffer (Capacity => Size);
   begin
      Put_Line ("Demo Put with overwriting, in a loop");
      pragma Assert (Empty (Chars));
      --  insert 20 chars, ie more than capacity, thus overwriting
      for C in Character range 'a' .. 't' loop
         Insert (Chars, C);
      end loop;
      pragma Assert (Full (Chars));
      --  the first 10 characters are "abcdefghij", because Capacity is
      --  arbitrarily set to 10. They are then replaced by 10 more, since
      --  we said Capacity + 10 (again arbitrarily), leaving the next 10
      --  characters in the buffer, ie "klmnopqrst"
      pragma Assert (Model (Chars) = "klmnopqrst");
   end Demo_Put_Overwriting_Loop;

   ---------------------------------
   -- Demo_Put_Overwriting_Noloop --
   ---------------------------------

   procedure Demo_Put_Overwriting_Noloop is
      Size  : constant Positive_Element_Count := 4; -- arbitrary
      Chars : Ring_Buffer (Capacity => Size);
   begin
      Put_Line ("Demo Put with overwriting");
      pragma Assert (Empty (Chars));
      Insert (Chars, 'a');
      pragma Assert (Model (Chars) = "a");
      Insert (Chars, 'b');
      pragma Assert (Model (Chars) = "ab");
      Insert (Chars, 'c');
      pragma Assert (Model (Chars) = "abc");
      Insert (Chars, 'd');
      pragma Assert (Model (Chars) = "abcd");
      --  now overwriting
      Insert (Chars, 'e');
      pragma Assert (Model (Chars) = "bcde");
   end Demo_Put_Overwriting_Noloop;

   ----------------------
   -- Demo_Put_and_Get --
   ----------------------

   procedure Demo_Put_And_Get is
      Size  : constant Positive_Element_Count := 10; -- arbitrary
      Chars : Ring_Buffer (Capacity => Size);
      Value : Character;
   begin
      Put_Line ("Demo Get");
      pragma Assert (Empty (Chars));
      Insert (Chars, 'a');
      Insert (Chars, 'b');
      Insert (Chars, 'c');
      Remove (Chars, Value);
      pragma Assert (Value = 'a');
      Remove (Chars, Value);
      pragma Assert (Value = 'b');
      Remove (Chars, Value);
      pragma Assert (Value = 'c');
      pragma Assert (Empty (Chars));
   end Demo_Put_and_Get;

begin
   Demo_Copy;
   Demo_Deletions;
   Demo_Put_Preserving_and_Get;
   Demo_Put_and_Get;
   Demo_Put_Overwriting_Loop;
   Demo_Put_Overwriting_Noloop;

   Put_Line ("Done");
end Demo_Buffers;
