package Akionis.App is

   procedure Init;

private

   pragma Linker_Options ("-lraylib");
   pragma Linker_Options ("-lm");
   pragma Linker_Options ("-lX11");

end Akionis.App;
