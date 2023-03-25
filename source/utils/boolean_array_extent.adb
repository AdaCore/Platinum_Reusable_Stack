--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

package body Boolean_Array_Extent with SPARK_Mode is

   -----------------------
   -- Lemma_Extent_Zero --
   -----------------------

   procedure Lemma_Extent_Zero (S : List) is
   begin
      for C in reverse Element loop
         pragma Loop_Invariant (Sum (S, C) = 0);
      end loop;
   end Lemma_Extent_Zero;

   ------------------------------
   -- Lemma_Extent_Incremented --
   ------------------------------

   procedure Lemma_Extent_Incremented (Before, After : List; E : Element) is
   begin
      for C in reverse Element loop
         pragma Loop_Invariant (Sum (After, C) = (if C > E then Sum (Before, C) else Sum (Before, C) + 1));
      end loop;
   end Lemma_Extent_Incremented;

   ------------------------------
   -- Lemma_Extent_Decremented --
   ------------------------------

   procedure Lemma_Extent_Decremented (Before, After : List; E : Element) is
   begin
      for C in reverse Element loop
         pragma Loop_Invariant (Sum (After, C) = (if C > E then Sum (Before, C) else Sum (Before, C) - 1));
      end loop;
   end Lemma_Extent_Decremented;

   ------------------------
   -- Lemma_Extent_Equal --
   ------------------------

   procedure Lemma_Extent_Equal (Left, Right : List) is
   begin
      for C in reverse Element loop
         pragma Loop_Invariant (Sum (Left, C) = Sum (Right, C));
      end loop;
   end Lemma_Extent_Equal;

end Boolean_Array_Extent;
