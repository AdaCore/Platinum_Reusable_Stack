--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

generic

   type Element is private;
   --  The type of values contained by objects of type Queue.

   Default_Value : Element;
   --  The default value used for Queue contents. Used for initialization,
   --  but never acquired as a value from the API (unless inserted by the
   --  application).

package Sequential_Bounded_Queues with SPARK_Mode is

   pragma Unevaluated_Use_Of_Old (Allow);

   subtype Element_Count is Integer range 0 .. Integer'Last - 1;

   subtype Positive_Element_Count is Element_Count range 1 .. Element_Count'Last;

   type Queue (Capacity : Positive_Element_Count) is private with
     Default_Initial_Condition => Empty (Queue),
     Iterable => (First       => First_Iter_Index,
                  Next        => Next_Iter_Index,
                  Has_Element => Iter_Has_Element,
                  Element     => Iter_Value);

   procedure Put (This : in out Queue; Item : Element) with
     Pre    => not Full (This),
     Post   => not Empty (This)                                      and then
               Extent (This) = Extent (This)'Old + 1                 and then
               Latest_Insertion (This) = Item                        and then
               (if Empty (This)'Old then Next_Element_Out (This) = Item) and then
               (for all K in 1 .. Model (This)'Length =>
                  (if K = Model (This)'Last then Model (This) (K) = Item
                     else Model (This)(K) = Model (This)'Old (K))),
     Global => null;

   procedure Get (This : in out Queue; Item : out Element) with
     Pre    => not Empty (This),
     Post   => not Full (This)                       and then
               Extent (This) = Extent (This)'Old - 1 and then
               Item = Next_Element_Out (This)'Old    and then
               (if not Empty (This) then Next_Element_Out (This) = Model (This) (1))  and then
               Model (This)'Length = Model (This'Old)'Length - 1                      and then
               --  The rest of This is unchanged. The model is always ordered
               --  oldest to newest, and Get removes the oldest first.
               Model (This)'Old (1) = Item and then
               (for all K in 1 .. Model (This)'Length => Model (This)(K) = Model (This)'Old (K + 1)),
     Global => null;

   overriding function "=" (Left, Right : Queue) return Boolean with
     Post => ("="'Result = (Extent (Left) = Extent (Right) and then
                            Model (Left) = Model (Right)));
   --  A replacement for predefined equality, this routine only compares the
   --  parts of Left and Right that are logically contained.

   procedure Copy (Source : Queue; Target : in out Queue) with
     Pre    => Target.Capacity >= Extent (Source),
     Post   => Target = Source,
     Global => null;
   --  An alternative to assignment, this routine only copies to Target that
   --  part of Source which is logically contained at the time of the call.

   function Empty (This : Queue) return Boolean with
     Post   => Empty'Result = (Extent (This) = 0 and then
                               Model (This) = Empty_Model),
     Global => null,
     Inline;

   function Full (This : Queue) return Boolean with
     Post   => Full'Result = (Extent (This) = This.Capacity),
     Global => null,
     Inline;

   function Extent (This : Queue) return Element_Count with
     Global => null,
     Inline;
   --  Returns the number of elements currently contained in This

   procedure Reset (This : out Queue) with
     Post   => Empty (This)               and then
               Front (This) = 1           and then
               Extent (This) = 0          and then
               Model (This) = Empty_Model and then
               Model (This)'Length = 0,
     Global => null;

   procedure Delete (This : in out Queue;  Number_To_Delete : Positive_Element_Count) with
     Post   => not Full (This) and then
               Extent (This) = Extent (This)'Old - Integer'Min (Number_To_Delete, Extent (This)'Old) and then
               (if Number_To_Delete = Extent (This)'Old then Empty (This)) and then
               --  the remaining content is unchanged
               (for all K in 1 .. Extent (This) =>
                  Model (This) (K) = Model (This)'Old (K + Integer'Min (Number_To_Delete, Extent (This)'Old)))
               and then --  the next oldest element out is...
               (if not Empty (This) then Next_Element_Out (This) = Model (This) (1)),
     Global => null;
   --  Deletes the requested number of elements from This, starting with the
   --  oldest. At most the current number of contained elements are deleted.

   function Next_Element_Out (This : Queue) return Element with
     Pre    => not Empty (This),
     Global => null,
     Inline;
   --  Returns the value that would be removed by a subsequent call to Get, or
   --  deleted via Delete. The value is the oldest currently contained. This
   --  function allows clients to query the value without having to remove it.

   --  Proof functions and data  --------------------------------------------------------

   type Queue_Model is array (Positive_Element_Count range <>) of Element with Ghost;

   function Model (This : Queue) return Queue_Model with
      Post => Model'Result'First = 1 and then
              Model'Result'Length = Extent (This),
      Ghost;
   --  Returns the current logical contents of This, ordered oldest to newest.

   function Latest_Insertion (This : Queue) return Element with
     Pre => not Empty (This),
     Ghost;

   function Front (This : Queue) return Positive_Element_Count with Ghost;

   Empty_Model : constant Queue_Model (1 .. 0) := (others => Default_Value) with Ghost;

  --  Iterator functions  ---------------------------------------------------------------

  --  These functions are defined purely for iteration support and are not
  --  intended to be used by application code.

   function First_Iter_Index (This : Queue) return Positive_Element_Count;

   function Next_Iter_Index (Unused : Queue; Position : Positive_Element_Count) return Positive_Element_Count;

   function Iter_Has_Element (This : Queue;  Position : Positive_Element_Count) return Boolean;

   function Iter_Value (This : Queue; Position : Positive_Element_Count) return Element;

private

   type Element_Data is array (Positive_Element_Count range <>) of Element;

   type Queue (Capacity : Positive_Element_Count) is record
      Content : Element_Data (1 .. Capacity) := (others => Default_Value);
      First   : Positive_Element_Count := 1;
      Length  : Element_Count := 0;
   end record with
     Predicate => First  in 1 .. Capacity and then
                  Length in 0 .. Capacity;

   -----------
   -- Empty --
   -----------

   function Empty (This : Queue) return Boolean is
     (This.Length = 0);

   ----------
   -- Full --
   ----------

   function Full (This : Queue) return Boolean is
     (This.Length = This.Capacity);

   ------------
   -- Extent --
   ------------

   function Extent (This : Queue) return Element_Count is
     (This.Length);

   ----------------------
   -- Next_Element_Out --
   ----------------------

   function Next_Element_Out (This : Queue) return Element is
     (This.Content (This.First));

   -----------
   -- Front --
   -----------

   function Front (This : Queue) return Positive_Element_Count is
     (This.First);

   ----------------
   -- Next_Index --
   ----------------

   function Next_Index
     (This   : Queue;
      Offset : Element_Count)
     return Positive_Element_Count
   is
     (if This.First <= This.Capacity - Offset then
         This.First + Offset
      else -- wrapping around
         Offset - This.Capacity + This.First)
   with
     Pre  => Offset in 0 .. This.Capacity,
     Post => Next_Index'Result in 1 .. This.Capacity;
   --  Returns the value of This.First + Offset modulo This.Capacity.

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Queue) return Boolean is
     (Left.Length = Right.Length and then
     (for all Offset in 0 .. Left.Length - 1 =>
         Left.Content (Next_Index (Left, Offset)) = Right.Content (Next_Index (Right, Offset))));

   ----------------------
   -- Latest_Insertion --
   ----------------------

   function Latest_Insertion (This : Queue) return Element is
     (This.Content (Next_Index (This, Offset => This.Length - 1)));

   --------------------------
   -- Content_Wraps_Around --
   --------------------------

   function Content_Wraps_Around (This : Queue) return Boolean is
     (This.First > This.Capacity - This.Length + 1);
   --  Returns whether the logical content range spans the end of the array.

end Sequential_Bounded_Queues;
