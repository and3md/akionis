with Ada.Wide_Text_IO;
use Ada;
with Raylib;

with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
use Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

with Interfaces.C; use Interfaces.C;

package body Akionis.App is

   procedure Init is
   begin
      Ada.Wide_Text_IO.Put_Line ("Test łóąźż");

      Raylib.InitWindow
        (width => 1670, height => 800, title => Encode ("Test łóążź 🚀"));
      Raylib.SetExitKey (key => Raylib.KEY_ESCAPE);

      while Raylib.WindowShouldClose = False loop
         Raylib.BeginDrawing;

         if Raylib.IsKeyDown (Raylib.KEY_ESCAPE) then
            Wide_Text_IO.Put_Line ("Close");
         end if;
         Raylib.EndDrawing;
      end loop;

      Raylib.CloseWindow;

   end Init;

end Akionis.App;
