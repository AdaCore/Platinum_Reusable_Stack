--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

with Character_Sets; use Character_Sets;
with Ada.Text_IO;    use Ada.Text_IO;

procedure Demo_Sets with SPARK_Mode is

   Vowels : constant Set := New_Set (Content => ('a', 'e', 'i', 'o', 'u'));

   S : Set;

   procedure Print (Prompt : String;  This : Set) is
   begin
      Put (Prompt & """");
      for C : Character of This loop
         Put (C);
      end loop;

      --  this is the expanded code for the loop above. We used this to debug proof.
      --
      --  B9b : declare
      --     cC : character_sets.cursor := character_sets.first_iter_index (this);
      --  begin
      --     --  pragma Assert (cC = Iteration_Complete or else Valid_Cursor (cC));
      --
      --     L10b : while character_sets.iter_has_element (this, cC) loop
      --        B11b : declare
      --           c : constant character := character_sets.iter_element (this, cC);
      --        begin
      --           Put (C);
      --           cC := character_sets.next_iter_index (this, cC);
      --
      --           --  pragma Loop_Invariant (CC = Iteration_Complete or else Valid_Cursor (CC));
      --        end B11b;
      --     end loop L10b;
      --  end B9b;

      Put ("""");
   end Print;

begin
   Put_Line ("Cardinality of Null_Set is" & Cardinality (Null_Set)'Image);
   pragma Assert (Cardinality (Null_Set) = 0);

   Print ("Vowels contains ", Vowels);
   New_Line;
   Put_Line ("Cardinality of Vowels is" & Cardinality (Vowels)'Image);
   pragma Assert (Cardinality (Vowels) = 5);

   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   pragma Assert (Empty (S));
   --  pragma Assert (Cardinality (S) = 0); -- Cardinality not yet proven on this operation

   Put_Line ("Setting S to new set containing one element 'e'");
   S := New_Set ('e');
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   pragma Assert (Cardinality (S) = 1);

   Put_Line ("Setting S to new set containing elements 'a' and 'b'");
   S := New_Set (Content => ('a', 'b'));
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   pragma Assert (Cardinality (S) = 2);

   Put_Line ("Adding new member 'e' to S");
   S := S + 'e';
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   pragma Assert (Cardinality (S) = 3);

   Put_Line ("Removing member 'a' from S");
   S := S - 'a';
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   pragma Assert (Cardinality (S) = 2);

   Put_Line ("Forming intersection of S and Vowels");
   S := S and Vowels;
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   --  pragma Assert (Cardinality (S) = 1); -- Cardinality not yet proven on this operation

   Put_Line ("Forming union of S and Vowels");
   S := S or Vowels;
   Print ("S contains ", S);
   New_Line;
   Put_Line ("Cardinality of S is" & Cardinality (S)'Image);
   --  pragma Assert (Cardinality (S) = 5); -- Cardinality not yet proven on this operation

   Put_Line ("Done");
end Demo_Sets;

