--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

pragma Spark_Mode (On);

with Ada.Characters.Latin_1;
with Sequential_Bounded_Stacks;

package Character_Stacks is new Sequential_Bounded_Stacks
  (Element       => Character,
   Default_Value => Ada.Characters.Latin_1.NUL);
