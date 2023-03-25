--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

--  This generic package provides iterators for List objects, in which the type
--  List is a generic formal constrained array of Boolean components. The index
--  type for the array is a generic formal discrete type named Element.
--
--  You can use the functions defined by this package for the Iterable aspect
--  defined by GNAT.  See for example the generic package Discrete_Bounded_Sets.
--
--  Iteration over any List object provides individual Element values
--  representing those that are "contained" by the List object. Iteration does
--  not provide the Boolean values. Instead, for each Element provided by the
--  iteration, the corresponding List component at that Element index value
--  will be True (if any).

--  This generic package has been proven to the Gold level with SPARK.

generic

   type Element is (<>);
   --  The type of value contained by List objects.
   --
   --  NB: This type also determines how big a List object will be, because
   --  the type List is represented as an array of Boolean components, with
   --  Element as the index for that array type. Therefore, there will be
   --  Element'Range_Length Boolean components, so keep that in mind when
   --  you decide on the generic actual type.

   type List is array (Element) of Boolean;
   --  The type being iterated over, using logical cursors.

   type Cursor is range <>;
   --  The type used to range over the List array indexes (i.e., the Element
   --  values). The Cursor values must include at least one more value than
   --  that of Element.

package Boolean_Array_Iteration with SPARK_Mode is

   Required_Array_Extent : constant Cursor := Element'Range_Length;
   --  The maximum number of Element values held in a List object.
   --
   --  This declaration will fail, no later than run-time, if Cursor'Last
   --  is less than Element'Range_Length. The purpose is to verify that our
   --  type model will be sufficient. Given the successful elaboration of the
   --  declaration of Required_Array_Extent, we know that we can use Cursor to
   --  compute the number of elements in a List.

   pragma Assert (Required_Array_Extent < Cursor'Last);
   --  Given the successful elaboration of the declaration of
   --  Required_Array_Extent, we know we can use Cursor to compute the extents
   --  of List objects. But to do that without overflow, it will be convenient
   --  if we can be sure that there is one more value of Cursor above the max
   --  number of Element values possibly held.

   --  Iteration uses a "cursor" to walk over the data structure, providing
   --  individual contained values for individual cursor values. For
   --  the iteration to end, there must be some cursor value C for
   --  which Has_Element (C) returns False.
   --
   --  To iterate over List objects, the implementation cannot use the index
   --  type Element as the cursor. Clearly that's the List array index type so
   --  we will eventually use such values to access List components. Logically
   --  we'll iterate from Element'First to at most Element'Last, but not
   --  directly.
   --
   --  We can't use Element directly as the cursor because it would be
   --  possible, for some given List object, for there to be no cursor
   --  for which Has_Element() returns False. The iteration could not
   --  then complete.
   --
   --  That would be the case when the List S is Full, for example, but
   --  being Full is not required. The problem would appear when the Boolean
   --  component at Element'Last is True, even if that's the only member
   --  of S. There would be no other index (cursor) to use for the sake
   --  of Has_Element returning False to end the iteration.
   --
   --  Therefore, this iteration implementation uses Cursor values as the
   --  cursor values. As such we are not limited to Element'Range, and thus can
   --  have a cursor value for which Has_Element() always returns False. Cursor
   --  has already been verified to be able to represent all of Element values,
   --  plus one more value, so Cursor is guaranteed to suffice. (Verification
   --  is via an assertion to that effect in the package declaration's
   --  elaboration. If that assertion doesn't hold for a given instantiation,
   --  the instantiation won't compile.)
   --
   --  The cursor that indicates no further iteration, declared below as
   --  Sentinel, is therefore a Cursor object with the value of Element'Last
   --  + 1. As such, that value is outside the possible index range and so can
   --  serve as the indicator.

   function As_Cursor (E : Element) return Cursor is
     (Element'Pos (E));

   First_Cursor : constant Cursor := As_Cursor (Element'First);
   Last_Cursor  : constant Cursor := As_Cursor (Element'Last);

   function Valid_Cursor (C : Cursor) return Boolean is
     (C in First_Cursor .. Last_Cursor);
   --  Returns whether C is in Element'Range

   Sentinel : constant Cursor := Last_Cursor + 1;
   --  The cursor signaling iteration is complete.
   pragma Assert (not Valid_Cursor (Sentinel));

   function Is_Next_Cursor (This : List; Result, Start : Cursor) return Boolean;

   function First_Iter_Index (This : List) return Cursor with
     Post => First_Iter_Index'Result = Sentinel or else
             (Valid_Cursor (First_Iter_Index'Result) and then
              Is_Next_Cursor (This, First_Iter_Index'Result, Start => First_Cursor));
   --  Returns the first cursor C for which This (C) is True, or the
   --  Sentinel value indicating iteration completion.

   function Next_Iter_Index (This : List; Position : Cursor) return Cursor with
     Pre  => Position < Cursor'Last and then
             Valid_Cursor (Position),
     Post => Next_Iter_Index'Result = Sentinel or else
             (Valid_Cursor (Next_Iter_Index'Result) and then
              Next_Iter_Index'Result in Position + 1 .. Last_Cursor and then
              Is_Next_Cursor (This, Next_Iter_Index'Result, Start => Position + 1));
   --  Returns the next cursor C for which This (C) is True, starting after
   --  Position, or returns the Sentinel value indicating iteration completion.

   function Iter_Has_Element (Unused : List;  Position : Cursor) return Boolean  with
     Post => (if Iter_Has_Element'Result then Valid_Cursor (Position));
   --  Logically, returns whether Unused (Position) is True. However,
   --  First_Iter_Index and Next_Iter_Index only return cursor values for those
   --  components that are True, or the Sentinel value indicating the end of
   --  the iteration. Therefore all this function need do is check for the
   --  Sentinel.

   function Iter_Element (Unused : List; Position : Cursor) return Element with
     Pre => Iter_Has_Element (Unused, Position);
   --  Logically, Unused (Position) is True, so this function returns the
   --  Element value corresponding to Position (because iteration over List
   --  objects provides Element values).

private

   --------------------------
   -- As_Contained_Element --
   --------------------------

   function As_Contained_Element (N : Cursor) return Element is
     (Element'Val (Cursor'Pos (N)))
   with Pre => Valid_Cursor (N);

   ---------------
   -- None_True --
   ---------------

   function None_True (This : List; From : Cursor) return Boolean is
     (for all K in As_Contained_Element (From) .. Element'Last => not This (K))
   with Pre => Valid_Cursor (From);

   --------------------
   -- Is_Next_Cursor --
   --------------------

   function Is_Next_Cursor (This : List; Result, Start : Cursor) return Boolean is
     (Valid_Cursor (Result)                and then
      This (As_Contained_Element (Result)) and then
      --  there were no true components before Result, beginning at Start
      Valid_Cursor (Start) and then
      (if Result > Start then
         (for all K in Start .. Result - 1 => not This (As_Contained_Element (K)))));

   ---------------
   -- Next_True --
   ---------------

   function Next_True (This : List; Start : Cursor) return Cursor with
     Pre  => Valid_Cursor (Start) or else Start = Sentinel,
     Post => (if Start = Sentinel or else None_True (This, From => Start)
              then Next_True'Result = Sentinel
              else Valid_Cursor (Next_True'Result) and then
                   Next_True'Result in Start .. Last_Cursor and then
                   Is_Next_Cursor (This, Next_True'Result, Start));

end Boolean_Array_Iteration;
