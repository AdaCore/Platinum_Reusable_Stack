--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

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
   --  The type for which Extent is computed, i.e., the number of components in
   --  a List object that are True.

   type Counter is range <>;
   --  The integer type used for counting the number of components of a List
   --  object, and so on. Must include zero.

package Boolean_Array_Extent with SPARK_Mode is

   function Extent (This : List) return Counter;
   --  Returns the current number of True components in This.
   --  Note this is not a ghost routine.

   procedure Lemma_Extent_Zero (S : List) with
     Pre => (for all K in Element => not S (K)),
     Post => Extent (S) = 0,
     Ghost;

   procedure Lemma_Extent_Incremented (Before, After : List; E : Element) with
     Pre  => (for all K in Element => (if K /= E then Before (K) = After (K))) and then
             Before (E) = False and then
             After (E) = True,
     Post => Extent (After) = Extent (Before) + 1,
     Ghost;

   procedure Lemma_Extent_Decremented (Before, After : List; E : Element) with
     Pre  => (for all K in Element => (if K /= E then Before (K) = After (K))) and then
             Before (E) = True and then
             After (E) = False,
     Post => Extent (After) = Extent (Before) - 1,
     Ghost;

   procedure Lemma_Extent_Equal (Left, Right : List) with
     Pre  => (for all C in Element => (Left (C) = Right (C))),
     Post => Extent (Left) = Extent (Right),
     Ghost;

private

   function Sum (This : List; From : Element) return Counter with
     Post => Sum'Result <= Element'Pos (Element'Last) - Element'Pos (From) + 1,
     Subprogram_Variant => (Increases => From);

   function Sum (This : List; From : Element) return Counter is
     (if From = Element'Last
      then Boolean'Pos (This (From))
      else Boolean'Pos (This (From)) + Sum (This, Element'Succ (From)));
   pragma Annotate (GNATprove, Terminating, Sum);

   function Extent (This : List) return Counter is
      (Sum (This, From => Element'First));

end Boolean_Array_Extent;
