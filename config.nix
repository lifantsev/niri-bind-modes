{ lib, config, ... }@args: lib.mkMerge [
    {
        xdg.configFile."niri/config.kdl".text = config.programs.niri.extraConfig;
    }

    (lib.mkIf (config.programs.niri.bind.set != {}) {
        programs.niri.extraConfig = (lib.mkBefore ''
            include "binds.kdl"
        '');

        xdg.configFile."niri/binds.kdl".text = (import ./pipeline args {
            inherit (config.programs.niri.bind) set defaultModifiers;
        });
    })
]
