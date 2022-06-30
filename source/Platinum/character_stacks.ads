--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

pragma Spark_Mode (On);

with Ada.Characters.Latin_1;

with Sequential_Bounded_Stacks;  --  the Platinum version
-- we use this unit name because this is the final version of the package

package Character_Stacks is new Sequential_Bounded_Stacks
  (Element       => Character,
   Default_Value => Ada.Characters.Latin_1.NUL);

