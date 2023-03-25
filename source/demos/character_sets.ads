--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

pragma SPARK_Mode (On);

with Sequential_Discrete_Sets;

package Character_Sets is new Sequential_Discrete_Sets
  (Element           => Character,
   Set_Member_Extent => Integer);
