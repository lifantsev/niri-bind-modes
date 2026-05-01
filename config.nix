{ lib, config, ... }@args: let cfg = config.programs.niri.bind-modes; in lib.mkMerge [
    (lib.mkIf cfg.enableConfigFile {
        xdg.configFile."niri/config.kdl".text = cfg.extraConfig;
    })

    (lib.mkIf cfg.enableBindsFile {
        programs.niri.bind-modes.extraConfig = (lib.mkBefore ''
            include "binds.kdl"
        '');

        xdg.configFile."niri/binds.kdl".text = (import ./pipeline args {
            inherit (cfg) binds defaultModifiers modeFile;
        });
    })
]
