--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

pragma SPARK_Mode (On);

with Sequential_Bounded_Queues;

package Character_Queues is new Sequential_Bounded_Queues
  (Element       => Character,
   Default_Value => ASCII.Nul);
