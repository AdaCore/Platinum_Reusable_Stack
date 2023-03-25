--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

pragma SPARK_Mode (On);

with Boolean_Array_Iteration;

package Character_Iterations is  -- just a test instance for proving Boolean_Array_Iteration

   type List is array (Character) of Boolean;

   package List_Iterations is new Boolean_Array_Iteration
     (Element => Character,
      List    => List,
      Cursor  => Integer);

end Character_Iterations;
