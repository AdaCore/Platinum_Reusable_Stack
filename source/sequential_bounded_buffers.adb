--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

package body Sequential_Bounded_Buffers with SPARK_Mode is

   ------------
   -- Insert --
   ------------

   procedure Insert (This : in out Ring_Buffer; Item : Element) is
   begin
      This.Content (Next_Index (This, This.Length)) := Item;
      if Full (This) then
         --  full on entry, so the above overwrote the component at First
         This.First := (This.First mod This.Capacity) + 1;
      else  -- not full on entry
         This.Length := This.Length + 1;
      end if;
   end Insert;

   -----------------------
   -- Insert_Preserving --
   -----------------------

   procedure Insert_Preserving (This : in out Ring_Buffer; Item : Element) is
   begin
      This.Content (Next_Index (This, This.Length)) := Item;
      This.Length := This.Length + 1;
   end Insert_Preserving;

   ------------
   -- Remove --
   ------------

   procedure Remove (This : in out Ring_Buffer; Item : out Element) is
   begin
      Item := This.Content (This.First);
      This.Length := This.Length - 1;
      This.First := Next_Index (This, Offset => 1);
   end Remove;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : out Ring_Buffer) is
   begin
      This := (This.Capacity, First => 1, Length => 0, Content => (others => Default_Value));
   end Reset;

   ------------
   -- Delete --
   ------------

   procedure Delete (This : in out Ring_Buffer;  Number_To_Delete : Positive_Element_Count) is
      Actual_Deletions : constant Integer := Integer'Min (Number_To_Delete, This.Length);
   begin
      This.First := Next_Index (This, Actual_Deletions);
      This.Length := This.Length - Actual_Deletions;
   end Delete;

   ----------
   -- Copy --
   ----------

   procedure Copy (Source : Ring_Buffer; Target : in out Ring_Buffer) is
   begin
      Target.Length := Source.Length;
      Target.First := 1;

      for J in 1 .. Source.Length loop
         Target.Content (J) := Source.Content (Next_Index (Source, J - 1));

         pragma Loop_Invariant
           (for all K in 1 .. J =>
              Target.Content (K) = Source.Content (Next_Index (Source, K - 1)));
      end loop;
   end Copy;

   -----------
   -- Model --
   -----------

   function Model (This : Ring_Buffer) return Buffer_Model with
     Refined_Post =>
        Model'Result'First = 1 and then
        Model'Result'Length = This.Length and then
        (for all J in 1 .. This.Length =>
            Model'Result (J) = This.Content (Next_Index (This, Offset => J - 1)))
   is
      Result : Buffer_Model (1 .. This.Length) := (others => Default_Value);
   begin
      for K in 1 .. This.Length loop
         Result (K) := This.Content (Next_Index (This, Offset => K - 1));
         pragma Loop_Invariant
           (for all J in 1 .. K =>
               Result (J) = This.Content (Next_Index (This, Offset => J - 1)));
      end loop;
      return Result;
   end Model;

   --  Iterator routines  -------------------------------------------------------------------

   ----------------------
   -- First_Iter_Index --
   ----------------------

   function First_Iter_Index (This : Ring_Buffer) return Positive_Element_Count is
     (This.First);

   ---------------------
   -- Next_Iter_Index --
   ---------------------

   function Next_Iter_Index (Unused : Ring_Buffer; Position : Positive_Element_Count) return Positive_Element_Count is
     (if Position = Positive_Element_Count'Last then 1 else Position + 1);
   --  Position will never go past 2 * Capacity - 1 because of the way the
   --  potential wrap-around of the Content array works. Specifically, when
   --  wrapping around past Capacity, the last used index will go no further
   --  than First - 1. But the provers are concerned with overflow so we
   --  prevent that.

   ----------------
   -- Iter_Value --
   ----------------

   function Iter_Value (This : Ring_Buffer; Position : Positive_Element_Count) return Element is
     (if Position > This.Capacity then
        (if Position mod This.Capacity = 0 then
           This.Content (Position mod This.Capacity + 1)
         else This.Content (Position mod This.Capacity))
      else
        This.Content (Position));
   --  Position will never go past 2 * Capacity - 1 because of the way the
   --  potential wrap-around of the Content array works. Specifically, when
   --  wrapping around past Capacity, the last used index will go no further
   --  than First - 1 so it will never reach Capacity the second time. Hence
   --  once Position is greater than Capacity, Position mod Capacity would be
   --  greater than zero and thus safe.
   --
   --  But the provers are concerned with array index checks so we handle
   --  it anyway. Note that we cannot use preconditions to say that Position
   --  will be in the range 1 .. 2 * Capacity - 1, although that would allow
   --  simplifying the function expression, because that precondition wouldn't
   --  be provable at the call sites in the "for of" iterations.

   ----------------------
   -- Iter_Has_Element --
   ----------------------

   function Iter_Has_Element (This : Ring_Buffer;  Position : Positive_Element_Count) return Boolean is
      Result           : Boolean;
      Pos              : Positive_Element_Count := Position;
      Iterator_Wrapped : Boolean := False;
   begin
      if Position > This.Capacity then
         if Position mod This.Capacity = 0 then
            Pos := Position mod This.Capacity + 1;
         else
            Pos := Position mod This.Capacity;
         end if;
         Iterator_Wrapped := True;
      end if;
      if not Content_Wraps_Around (This) then
         Result := not Iterator_Wrapped and then Pos in This.First .. This.First + This.Length - 1;
      else
         --  we check the "upper part" of First .. Capacity unless we have
         --  already been there in this iteration
         if not Iterator_Wrapped then
            Result := Pos in This.First .. This.Capacity;
         else -- we check the "lower part" up to but not including First
            Result := Pos in 1 .. (This.Length - This.Capacity) + This.First - 1;
         end if;
      end if;
      return Result;
   end Iter_Has_Element;
   --  Position will never go past 2 * Capacity - 1 because when wrapping around
   --  past Capacity, the last used index will go no further than First - 1.
   --  Hence once Position is greater than Capacity, Position mod Capacity
   --  would be greater than zero and thus safe.
   --
   --  But the provers are concerned with range checks so we handle it.

end Sequential_Bounded_Buffers;
