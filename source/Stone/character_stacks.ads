--
--  Copyright (C) 2020, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

pragma Spark_Mode (On);

with Sequential_Bounded_Stacks;

package Character_Stacks is new Sequential_Bounded_Stacks
  (Element => Character);
