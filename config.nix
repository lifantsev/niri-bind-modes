{ lib, cfg, ... }@args: lib.mkIf cfg.enable {
    programs.niri.settings = let
        pipe = import ./pipeline args;
        arguments = { inherit (cfg) binds defaultModifiers modeFile; };
    in pipe arguments;
}
