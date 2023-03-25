--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--
--
--  This generic package provides an abstract data type (ADT) representing a
--  bounded, circular ring buffer. The physical capacity of each object of the
--  type is configured individually, via the object's discriminant. Objects of
--  the type are not thread-safe, hence the term "sequential" in the generic
--  unit's name.
--
--  There are two insertion routines. Procedure Put will overwrite the oldest
--  contained datum when the buffer object is full. Procedure Put_Preserving
--  has a precondition to check for the buffer being full, so it does
--  not overwrite any data. The most common use-case for ring buffers
--  is overwriting on full so we use the shorter name for that routine.
--
--  Read-only iteration is supported over any given buffer object, using the
--  generalized iterator syntax.
--
--  The implementation is backed by an array, as usual. Of the various
--  implementations possible, some do not utilize one of the array components
--  in order to distinguish between the Empty and Full states. Other use a
--  count of the number of elements currently contained for that purpose.
--  This implementation uses a counter, and, as a result, for any given buffer
--  object, all array components are available for use. In other words, all
--  array components can be used, and will be used when the buffer object
--  is logically full. That is an important consideration when the array
--  components contain many bytes each, as will happen if the generic package
--  is instantiated with a large generic actual type. The counter is an
--  integral part of the implementation, in fact, because when combined with
--  an index representing the front of the buffer, the rear of the buffer can
--  always be computed (e.g., for inserting a new element).

--  An instance of this package was successfully proven with SPARK Pro, using
--  the default gnatprove switches and the additional "--level=4" switch (which
--  is not the default).
--
--  Unless you prove clients too, you should not disable the routines'
--  preconditions at run-time, as they check any conditions required for
--  well-defined execution.

generic

   type Element is private;
   --  The type of values contained by objects of type Ring_Buffer.

   Default_Value : Element;
   --  The default value used for buffer contents. Used for initialization,
   --  but never acquired as a value from the API (unless inserted by the
   --  application).

package Sequential_Bounded_Buffers with SPARK_Mode is

   pragma Unevaluated_Use_Of_Old (Allow);

   subtype Element_Count is Integer range 0 .. Integer'Last - 1;

   subtype Positive_Element_Count is Element_Count range 1 .. Element_Count'Last;

   type Ring_Buffer (Capacity : Positive_Element_Count) is private with
     Default_Initial_Condition => Empty (Ring_Buffer),
     Iterable => (First       => First_Iter_Index,
                  Next        => Next_Iter_Index,
                  Has_Element => Iter_Has_Element,
                  Element     => Iter_Value);

   procedure Insert (This : in out Ring_Buffer; Item : Element) with
     Post => not Empty (This)                                      and then
             Latest_Insertion (This) = Item                        and then
             (if Empty (This)'Old then Next_Element_Out (This) = Item) and then
             (if not Full (This)'Old then -- Item was appended
                 Extent (This) = Extent (This)'Old + 1             and then
                 Front (This) = Front (This)'Old                   and then
                 Model (This)'Length = Model (This)'Old'Length + 1 and then
                 (for all K in 1 .. Model (This)'Length =>
                    (if K = Model (This)'Last then Model (This)(K) = Item
                     else Model (This)(K) = Model (This)'Old (K)))
              else  -- Item overwrote the oldest entry
                 Extent (This) = Extent (This)'Old and then
                 --  The newest value overwrote the component at the front. The
                 --  front should designate the oldest item so it is incremented.
                 Front (This) = (Front (This)'Old mod This.Capacity) + 1  and then
                 Model (This)'Length = Model (This)'Old'Length            and then
                 --  Other than the newly inserted Item, all the other content
                 --  in This are unchanged from This'Old. The old model contents
                 --  have been "shifted left" one element in the new model to
                 --  accommodate the new item at the end of the model, thereby
                 --  "losing" the first (oldest) element of the old model.
                 --  The newest element is always at the end of a model.
                 (for all K in 1 .. Model (This)'Length =>
                    (if K = Model (This)'Length then Model (This) (K) = Item
                      else Model (This) (K) = Model (This)'Old (K + 1)))),
     Global => null;
   --  Inserts Item, overwriting the oldest contained element if This is Full
   --  when Put was called.

   procedure Insert_Preserving (This : in out Ring_Buffer; Item : Element) with
     Pre    => not Full (This),
     Post   => not Empty (This)                                      and then
               Extent (This) = Extent (This)'Old + 1                 and then
               Latest_Insertion (This) = Item                        and then
               (if Empty (This)'Old then Next_Element_Out (This) = Item) and then
               (for all K in 1 .. Model (This)'Length =>
                  (if K = Model (This)'Last then Model (This) (K) = Item
                     else Model (This)(K) = Model (This)'Old (K))),
     Global => null;
   --  Inserts Item only if This buffer is not already full, therefore never
   --  overwrites data.

   procedure Remove (This : in out Ring_Buffer; Item : out Element) with
     Pre    => not Empty (This),
     Post   => not Full (This)                       and then
               Extent (This) = Extent (This)'Old - 1 and then
               Item = Next_Element_Out (This)'Old        and then
               (if not Empty (This) then Next_Element_Out (This) = Model (This) (1))  and then
               Model (This)'Length = Model (This'Old)'Length - 1                  and then
               --  The rest of This is unchanged. The model is always ordered
               --  oldest to newest, and Get removes the oldest first.
               Model (This)'Old (1) = Item and then
               (for all K in 1 .. Model (This)'Length => Model (This)(K) = Model (This)'Old (K + 1)),
     Global => null;
   --  Gets the next Item from This, oldest first.

   overriding function "=" (Left, Right : Ring_Buffer) return Boolean with
     Post => ("="'Result = (Extent (Left) = Extent (Right) and then
                            Model (Left) = Model (Right)));
   --  A replacement for predefined equality, this routine only compares the
   --  parts of Left and Right that are logically contained.

   procedure Copy (Source : Ring_Buffer; Target : in out Ring_Buffer) with
     Pre    => Target.Capacity >= Extent (Source),
     Post   => Target = Source and then
               Model (Target) = Model (Source),
     Global => null;
   --  An alternative to assignment, this routine only copies to Target that
   --  part of Source which is logically contained at the time of the call.

   function Empty (This : Ring_Buffer) return Boolean with
     Post   => Empty'Result = (Extent (This) = 0 and then
                               Model (This) = Empty_Model),
     Global => null,
     Inline;

   function Full (This : Ring_Buffer) return Boolean with
     Post   => Full'Result = (Extent (This) = This.Capacity),
     Global => null,
     Inline;

   function Extent (This : Ring_Buffer) return Element_Count with
     Global => null,
     Inline;
   --  Returns the number of elements currently contained in This

   procedure Reset (This : out Ring_Buffer) with
     Post   => Empty (This)               and then
               Front (This) = 1           and then
               Extent (This) = 0          and then
               Model (This) = Empty_Model and then
               Model (This)'Length = 0,
     Global => null;

   procedure Delete (This : in out Ring_Buffer;  Number_To_Delete : Positive_Element_Count) with
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

   function Next_Element_Out (This : Ring_Buffer) return Element with
     Pre    => not Empty (This),
     Global => null,
     Inline;
   --  Returns the value that would be removed by a subsequent call to Get, or
   --  deleted via Delete, or overwritten via Put when This is full. The value
   --  is the oldest currently contained. This function allows clients to query
   --  the value without having to remove it.

   --  Proof functions and data  --------------------------------------------------------

   type Buffer_Model is array (Positive_Element_Count range <>) of Element with Ghost;

   function Model (This : Ring_Buffer) return Buffer_Model with
      Post => Model'Result'First = 1 and then
              Model'Result'Length = Extent (This),
      Ghost;
   --  Returns the current logical contents of This, ordered oldest to newest.

   function Latest_Insertion (This : Ring_Buffer) return Element with
     Pre => not Empty (This),
     Ghost;

   function Front (This : Ring_Buffer) return Positive_Element_Count with Ghost;

   Empty_Model : constant Buffer_Model (1 .. 0) := (others => Default_Value) with Ghost;

  --  Iterator functions  ---------------------------------------------------------------

  --  These functions are defined purely for iteration support and are not
  --  intended to be used by application code.

   function First_Iter_Index (This : Ring_Buffer) return Positive_Element_Count;

   function Next_Iter_Index (Unused : Ring_Buffer; Position : Positive_Element_Count) return Positive_Element_Count;

   function Iter_Has_Element (This : Ring_Buffer;  Position : Positive_Element_Count) return Boolean;

   function Iter_Value (This : Ring_Buffer; Position : Positive_Element_Count) return Element;

private

   type Element_Data is array (Positive_Element_Count range <>) of Element;

   type Ring_Buffer (Capacity : Positive_Element_Count) is record
      Content : Element_Data (1 .. Capacity) := (others => Default_Value);
      First   : Positive_Element_Count := 1;
      Length  : Element_Count := 0;
   end record with
     Predicate => First  in 1 .. Capacity and then
                  Length in 0 .. Capacity;

   -----------
   -- Empty --
   -----------

   function Empty (This : Ring_Buffer) return Boolean is
     (This.Length = 0);

   ----------
   -- Full --
   ----------

   function Full (This : Ring_Buffer) return Boolean is
     (This.Length = This.Capacity);

   ------------
   -- Extent --
   ------------

   function Extent (This : Ring_Buffer) return Element_Count is
     (This.Length);

   ----------------------
   -- Next_Element_Out --
   ----------------------

   function Next_Element_Out (This : Ring_Buffer) return Element is
     (This.Content (This.First));

   -----------
   -- Front --
   -----------

   function Front (This : Ring_Buffer) return Positive_Element_Count is
     (This.First);

   ----------------
   -- Next_Index --
   ----------------

   function Next_Index
     (This   : Ring_Buffer;
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

   overriding function "=" (Left, Right : Ring_Buffer) return Boolean is
     (Left.Length = Right.Length and then
     (for all Offset in 0 .. Left.Length - 1 =>
         Left.Content (Next_Index (Left, Offset)) = Right.Content (Next_Index (Right, Offset))));

   ----------------------
   -- Latest_Insertion --
   ----------------------

   function Latest_Insertion (This : Ring_Buffer) return Element is
     (This.Content (Next_Index (This, Offset => This.Length - 1)));

   --------------------------
   -- Content_Wraps_Around --
   --------------------------

   function Content_Wraps_Around (This : Ring_Buffer) return Boolean is
     (This.First > This.Capacity - This.Length + 1);
   --  Returns whether the logical content range spans the end of the array.

end Sequential_Bounded_Buffers;
