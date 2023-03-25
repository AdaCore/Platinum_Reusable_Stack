--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

package body Boolean_Array_Iteration with SPARK_Mode is

   ---------------
   -- Next_True --
   ---------------

   function Next_True (This : List; Start : Cursor) return Cursor is
      Result : Cursor := Sentinel;
   begin
      if Start /= Sentinel then
         for K in Element
            range As_Contained_Element (Start) .. Element'Last
         loop
            if This (K) then
               Result := As_Cursor (K);
               exit;
            end if;
            pragma Loop_Invariant (Result = Sentinel);
            pragma Loop_Invariant (for all J in Start .. As_Cursor (K) => not This (As_Contained_Element (J)));
         end loop;
      end if;
      return Result;
   end Next_True;

   ----------------------
   -- First_Iter_Index --
   ----------------------

   function First_Iter_Index (This : List) return Cursor is
      (Next_True (This, Start => First_Cursor));

   ---------------------
   -- Next_Iter_Index --
   ---------------------

   function Next_Iter_Index (This : List; Position : Cursor) return Cursor is
      (Next_True (This, Start => Position + 1));

   ----------------------
   -- Iter_Has_Element --
   ----------------------

   function Iter_Has_Element (Unused : List;  Position : Cursor) return Boolean is
     (Valid_Cursor (Position));

   ----------------
   -- Iter_Value --
   ----------------

   function Iter_Element (Unused : List; Position : Cursor) return Element is
     (As_Contained_Element (Position));

end Boolean_Array_Iteration;
