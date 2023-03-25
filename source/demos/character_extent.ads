--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--
--  Author: Patrick Rogers, rogers@adacore.com, progers@classwide.com
--

pragma SPARK_Mode (On);

with Boolean_Array_Extent;

package Character_Extent is  -- just a test instance for proving Boolean_Array_Extent

   type List is array (Character) of Boolean;

   package List_Properties is new Boolean_Array_Extent
     (Element => Character,
      List    => List,
      Counter => Integer);

end Character_Extent;
