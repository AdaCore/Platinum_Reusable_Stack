--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

package body Sequential_Discrete_Sets with SPARK_Mode is

   --------------
   -- Null_Set --
   --------------

   function Null_Set return Set is
      Result : constant Set := (Members => (others => False));
   begin
      Lemma_Extent_Zero (Result.Members);
      return Result;
   end Null_Set;

   -------------
   -- New_Set --
   -------------

   function New_Set (Content : Element) return Set is
      Result : Set := Null_Set;
      Shadow : constant Set := Result with Ghost;
   begin
      Lemma_Extent_Zero (Shadow.Members);
      Result.Members (Content) := True;
      Lemma_Extent_Incremented (Shadow.Members, Result.Members, Content);
      return Result;
   end New_Set;

   -------------
   -- New_Set --
   -------------

   function New_Set (Content : Set_Literal) return Set is
      Result : Set := Null_Set;
      Shadow : Set := Null_Set with Ghost;
   begin
      Lemma_Extent_Zero (Shadow.Members);
      for K in Content'Range loop
         Shadow := Result;
         if not Result.Members (Content (K)) then
            Result.Members (Content (K)) := True;
            Lemma_Extent_Incremented (Shadow.Members, Result.Members, Content (K));
         end if;

         pragma Loop_Invariant
           (for all C in Element =>
              Contains (Content (Content'First .. K), C) = Member (Result, C));

         pragma Loop_Invariant (Extent (Result) = Unique_Element_Count (Content (Content'First .. K)));
      end loop;
      return Result;
   end New_Set;

   ---------
   -- "+" --
   ---------

   function "+" (Left : Set; Right : Element) return Set is
      Result : Set := Left;
   begin
      Result.Members (Right) := True;
      if not Left.Members (Right) then
         Lemma_Extent_Incremented (Left.Members, Result.Members, Right);
      end if;
      return Result;
   end "+";

   ---------
   -- "+" --
   ---------

   function "+" (Left : Element; Right : Set) return Set is
      Result : Set := Right;
   begin
      Result.Members (Left) := True;
      if not Right.Members (Left) then
         Lemma_Extent_Incremented (Right.Members, Result.Members, Left);
      end if;
      return Result;
   end "+";

   ---------
   -- "-" --
   ---------

   function "-" (Left : Set; Right : Element) return Set is
      Result : Set := Left;
   begin
      Result.Members (Right) := False;
      if Left.Members (Right) then
         Lemma_Extent_Decremented (Left.Members, Result.Members, Right);
      end if;
      return Result;
   end "-";

end Sequential_Discrete_Sets;
