------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2020, AdaCore                          --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

generic
   type Element is private;
package Bounded_Stacks_Stone is

   type Stack (Capacity : Positive) is private;

   procedure Push (This : in out Stack; Item : in Element) with
     Pre => not Full (This);

   procedure Pop (This : in out Stack; Item : out Element) with
     Pre => not Empty (This);

   function Top_Element (This : Stack) return Element with
     Pre => not Empty (This);
   --  Returns the value of the Element at the "top" of This
   --  stack, i.e., the most recent Element pushed. Does not
   --  remove that Element or alter the state of This stack
   --  in any way.

   overriding function "=" (Left, Right : Stack) return Boolean;

   procedure Copy (Destination : out Stack; Source : Stack) with
     Pre => Destination.Capacity >= Extent (Source);
   --  An alternative to predefined assignment that does not
   --  copy all the values unless necessary. It only copies
   --  the part "logically" contained, so is more efficient
   --  when Source is not full.

   function Extent (This : Stack) return Natural;
   --  Returns the number of Element values currently
   --  contained within This stack.

   function Empty (This : Stack) return Boolean;

   function Full (This : Stack) return Boolean;

   procedure Reset (This : out Stack);

private

   type Content is array (Positive range <>) of Element;

   type Stack (Capacity : Positive) is record
      Values : Content (1 .. Capacity);
      Top    : Natural := 0;
   end record;

end Bounded_Stacks_Stone;
