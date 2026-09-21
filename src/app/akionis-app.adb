with Ada.Wide_Text_IO;

use Ada;

package body Akionis.App is

   procedure Init is
   begin
      Ada.Wide_Text_IO.Put_Line ("Test łóąźż");
   end Init;

end Akionis.App;
