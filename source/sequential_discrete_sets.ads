--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

with Boolean_Array_Iteration;
with Boolean_Array_Extent;

generic

   type Element is (<>);
   --  The type of value contained by Set objects and literals. NB: This type
   --  also determines how much memory a Set object will require, because
   --  the type Set is represented as an array of Boolean components, with
   --  Element as the index for that array type. Therefore, there will be
   --  Element'Range_Length Boolean components, so keep that in mind when
   --  you decide on the generic actual type.

   type Set_Member_Extent is range <>;
   --  The integer type used for counting the number of members of a Set
   --  object, et al. The non-negative range must be greater than
   --  Element'Range_Length. That requirement is tested at compile-time.

package Sequential_Discrete_Sets with SPARK_Mode is

   Required_Array_Extent : constant Set_Member_Extent := Element'Range_Length;
   --  The maximum number of Element values held in a Set object.
   --
   --  This declaration will fail, no later than run-time, if the generic
   --  actual parameter passed to Formal_Integer cannot support the value
   --  Element'Range_Length. The purpose is to verify that Formal_Integer will
   --  be sufficient. Given the successful elaboration of the declaration of
   --  Required_Array_Extent, we know that we can use the generic actual type
   --  passed to Formal_Integer to compute the number of Elements in a Set.

   pragma Assert (Required_Array_Extent < Set_Member_Extent'Last);
   --  Given the successful elaboration of the declaration of
   --  Required_Array_Extent, we know we can use Formal_Integer to compute
   --  the extents of Set values. But to do that without overflow, it will
   --  be convenient if we can be sure that there is one more value of
   --  Formal_Integer above the max number of Element values possibly held.

   subtype Element_Count is Set_Member_Extent range 0 .. Required_Array_Extent;
   --  The result type for the Extent functions for Set etc.

   type Set is private with
     Default_Initial_Condition => Empty (Set),
     Iterable => (First       => First_Iter_Index,
                  Next        => Next_Iter_Index,
                  Has_Element => Iter_Has_Element,
                  Element     => Iter_Element);

   pragma Unevaluated_Use_Of_Old (Allow);

   function New_Set (Content : Element) return Set with
     Post => not Empty (New_Set'Result)            and then
             Only_Member (New_Set'Result, Content) and then
             Extent (New_Set'Result) = 1;

   subtype Set_Literal_Index is Set_Member_Extent range 1 .. Set_Member_Extent'Last - 1;

   type Set_Literal is array (Set_Literal_Index range <>) of Element;
   --  For example, given a declaration of a type passed to Element like so:
   --     type Colors is (Red, Orange, Yellow, Green, Blue, Indigo, Violet);
   --  we could have a set literal declared like this:
   --     Additive_Primary_Colors : constant Set := (Red, Blue, Yellow);

   function New_Set (Content : Set_Literal) return Set with
     Pre  => Unique_Element_Count (Content) = Content'Length,  --  no duplicate elements allowed
     Post => (if Content'Length = 0 then Empty (New_Set'Result)) and then
             (for all C in Element => Contains (Content, C) = Member (New_Set'Result, C)) and then
             Extent (New_Set'Result) = Content'Length;

   function Null_Set return Set with
     Post => Extent (Null_Set'Result) = 0 and then
             (for all C in Element => not Member (Null_Set'Result, C));

   function Member (This : Set;  Item : Element) return Boolean;

   function Empty (This : Set) return Boolean;

   function Extent (This : Set) return Element_Count;

   function Cardinality (This : Set) return Element_Count renames Extent;
   --  This is the domain-specific name for this function. We use Extent as
   --  the primary name for the sake of consistency across the various reusable
   --  components.

   function "or" (Left : Set; Right : Set) return Set with
     Post => (for all E in Element =>
                 Member ("or"'Result, E) = (Member (Left, E) or else Member (Right, E)));
   --  Returns the union of Left and Right

   function "xor" (Left : Set; Right : Set) return Set with
     Post => (for all E in Element =>
                 Member ("xor"'Result, E) = (Member (Left, E) xor Member (Right, E)));
   --  Returns the difference of Left and Right

   function "and" (Left : Set; Right : Set) return Set with
     Post => (for all E in Element =>
                 Member ("and"'Result, E) = (Member (Left, E) and then Member (Right, E)));
   --  Returns the intersection of Left and Right

   function Union        (Left : Set; Right : Set) return Set renames "or";
   function Difference   (Left : Set; Right : Set) return Set renames "xor";
   function Intersection (Left : Set; Right : Set) return Set renames "and";

   function "+" (Left : Set; Right : Element) return Set with
     Post => Member ("+"'Result, Right) and then
             --  exactly every member of Left is a member of the resulting set, not counting Right
             (for all C in Element => C = Right or else (Member (Left, C) = Member ("+"'Result, C))) and then
             --  if Right was not already a member of Left, then the extent of the result is that of Left plus 1
             (if not Member (Left, Right) then Extent ("+"'Result) = Extent (Left) + 1);

   function "+" (Left : Element; Right : Set) return Set with
     Post => Member ("+"'Result, Left) and then
             --  exactly every member of Right is a member of the resulting set, not counting Left
             (for all C in Element => C = Left or else (Member (Right, C) = Member ("+"'Result, C))) and then
             --  if Left was not already a member of Right, then the extent of the result is that of Right plus 1
             (if not Member (Right, Left) then Extent ("+"'Result) = Extent (Right) + 1);

   function "-" (Left : Set; Right : Element) return Set with
     Post => not Member ("-"'Result, Right) and then
             --  exactly every member of Left is a member of the resulting set, except for Right
             (for all C in Element => C = Right or else Member (Left, C) = Member ("-"'Result, C)) and then
             --  if Right was indeed a member of Left, then the extent of the result is that of Left minus 1
             (if Member (Left, Right) then Extent ("-"'Result) = Extent (Left) - 1);

   --  Proof functions  ---------------------------------------------------------------------

   function Only_Member (This : Set; Content : Element) return Boolean with
     Pre => not Empty (This),
     Ghost;

   function Contains (Within : Set_Literal;  This : Element) return Boolean with
     Ghost;

   function Unique_Element_Count (This : Set_Literal) return Element_Count with
     Post => Unique_Element_Count'Result <= Element'Range_Length,
     Subprogram_Variant => (Decreases => This'Length),
     Ghost;

   --  Iterator functions  ---------------------------------------------------------------

   --  These functions are defined purely for iteration support and are not
   --  intended to be used by application code.
   --
   --  Iteration over any Set object provides individual Element values
   --  representing those that are members of (contained by) the Set.

   subtype Cursor is Set_Member_Extent;

   function Valid_Cursor (C : Cursor) return Boolean;

   function First_Iter_Index (This : Set) return Cursor;

   function Next_Iter_Index  (This : Set;  Position : Cursor) return Cursor with
     Pre => Valid_Cursor (Position);

   function Iter_Has_Element (Unused : Set;  Position : Cursor) return Boolean;

   function Iter_Element (Unused : Set; Position : Cursor) return Element with
     Pre => Iter_Has_Element (Unused, Position);

private

   type Membership is array (Element) of Boolean with Pack;
   --  A value of the Set_Values type is an array of Boolean components, indexed by
   --  the Element generic formal discrete type. Each Boolean is indexed by
   --  a single Element value, thereby providing a 1:1 mapping. The mapped
   --  Booleans indicate whether the corresponding Element (index) values
   --  are members of the Set object.

   pragma Assert (Membership'Length = Required_Array_Extent);

   type Set is record
      Members : Membership := (others => False);
   end record;
   --  The Set type is not simply a direct array type, i.e., type Set_Values,
   --  because we define type Set in the partial view as Iterable. The intent
   --  is that clients can iterate over the logical members of Set values
   --  (i.e., the generic actual type for generic formal type Element), rather
   --  than the Boolean components that indicate membership. If we simply
   --  defined type Set as is done for Set_Values the language would provide
   --  iteration automatically (but over the Boolean values), thus leading to
   --  confusion. The language therefore requires an alternative implementation
   --  in the full view.

   ------------
   -- Member --
   ------------

   function Member (This : Set;  Item : Element) return Boolean is
     (This.Members (Item));

   -----------
   -- Empty --
   -----------

   function Empty (This : Set) return Boolean is
     (This = Null_Set);

   ----------
   -- "or" --
   ----------

   function "or" (Left : Set; Right : Set) return Set is
     (Members => Left.Members or Right.Members);

   -----------
   -- "xor" --
   -----------

   function "xor" (Left : Set; Right : Set) return Set is
     (Members => Left.Members xor Right.Members);

   -----------
   -- "and" --
   -----------

   function "and" (Left : Set; Right : Set) return Set is
     (Members => Left.Members and Right.Members);

   --------------
   -- Contains --
   --------------

   function Contains (Within : Set_Literal;  This : Element) return Boolean is
     (for some W of Within => W = This);

   -----------------
   -- Only_Member --
   -----------------

   function Only_Member (This : Set; Content : Element) return Boolean is
     (for all E in Element =>
        ((E = Content) = Member (This, E)));

   --------------------
   -- Has_Duplicates --
   --------------------

   function Has_Duplicates (L : Set_Literal; Item_At : Set_Literal_Index) return Boolean is
      (Contains (L (L'First .. Item_At - 1), L (Item_At)))
   with Pre => L'Length > 0 and then
               Item_At in L'Range,
        Ghost;

   --------------------
   -- Count_For_Last --
   --------------------

   function Count_For_Last (L : Set_Literal) return Element_Count is
     (Boolean'Pos (not Has_Duplicates (L, Item_At => L'Last)))
   with Pre => L'Length > 0,
        Ghost;
   --  If L (L'Last) is a duplicate of one of the Element components of L with
   --  an index less than L'Last, we ignore this occurrence by returning a
   --  zero. If L (L'Last) is the earliest of one or more duplicates ignored
   --  in previous calls (making it effectively unique for this call), or it
   --  is initially unique, then we count it by returning a one for it. In that
   --  case the Element component in L is never counted again because it never
   --  occurs again.

   --------------------------
   -- Unique_Element_Count --
   --------------------------

   function Unique_Element_Count (This : Set_Literal) return Element_Count is
     (if This'Length = 0 then 0
      else Element_Count'Min
             (Element'Range_Length,
              Count_For_Last (This) + Unique_Element_Count (This (This'First .. This'Last - 1))));
   pragma Annotate (GNATprove, Terminating, Unique_Element_Count);
   --  Logical members of Set objects are values of type Element. Sets are
   --  represented as constrained arrays of Booleans, indexed by type Element.
   --  Hence every Element value is a unique valid index.
   --
   --  A Set_Literal value is allowed to contain duplicate logical Set
   --  members (unlike the Set object itself). For example, if Element was
   --  an enumeration type defining colors, the following would be allowed:
   --      Set_Literal'(Red, Green, Blue, Red)
   --
   --  The Unique_Element_Count function computes the number of unique Element
   --  values within a Set_Literal, i.e., those that have no duplicates in the
   --  literal. The result for the literal above would be three, rather than
   --  four, because Red is present twice.
   --
   --  If a given Set_Literal contained every value of Element, even if there
   --  were duplicates the maximum possible count would be Element'Range_Length
   --  since every value would be present and any duplicates would be ignored.
   --
   --  Therefore, the maximum possible number of unique Element values
   --  in any Set_Literal is the total number of Element values, i.e.,
   --  Element'Range_Length.

   -------------------
   -- Set_Iteration --
   -------------------

   package Set_Iteration is new Boolean_Array_Iteration
     (Element, Membership, Cursor);

   Iteration_Complete : constant Cursor := Set_Iteration.Sentinel;

   ----------------------
   -- First_Iter_Index --
   ----------------------

   function First_Iter_Index (This : Set) return Cursor is
     (Set_Iteration.First_Iter_Index (This.Members));

   ---------------------
   -- Next_Iter_Index --
   ---------------------

   function Next_Iter_Index (This : Set; Position : Cursor) return Cursor is
     (Set_Iteration.Next_Iter_Index (This.Members, Position));

   ----------------------
   -- Iter_Has_Element --
   ----------------------

   function Iter_Has_Element (Unused : Set;  Position : Cursor) return Boolean is
     (Set_Iteration.Iter_Has_Element (Unused.Members, Position));

   ------------------
   -- Iter_Element --
   ------------------

   function Iter_Element (Unused : Set; Position : Cursor) return Element is
     (Set_Iteration.Iter_Element (Unused.Members, Position));

   ------------------
   -- Valid_Cursor --
   ------------------

   function Valid_Cursor (C : Cursor) return Boolean renames Set_Iteration.Valid_Cursor;

   ----------------
   -- Set_Extent --
   ----------------

   package Set_Extent is new Boolean_Array_Extent
     (Element, Membership, Element_Count);
   use Set_Extent;

   ------------
   -- Extent --
   ------------

   function Extent (This : Set) return Element_Count is
     (Extent (This.Members));

end Sequential_Discrete_Sets;
