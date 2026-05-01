{
    description = "niri binding config generator with support for modes";
    inputs = {};
    outputs = { ... }: {
        homeManagerModules.default = { lib, config, ... }@args: {
            config = lib.mkMerge [
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
            ];
            options.programs.niri = {
                extraConfig = lib.mkOption {
                    description = "lines to append to niri's config.kdl";
                    type = lib.types.lines;
                    default = "";
                    example = ''
                        workspace "dropdown" { }
                        window-rule {
                            match app-id=r#"^dropdown-"#
                            open-on-workspace "dropdown"

                            open-floating true
                            open-focused false
                        }
                    '';
                };
                bind.defaultModifiers = lib.mkOption {
                    description = "list of modifiers to use in all bindings unless they use the 'NONE' modifier";
                    type = lib.types.listOf lib.types.str;
                    default = [ "MOD" ];
                    example = [ ];
                };
                bind.set = lib.mkOption {
                    description = "set <mode>.<MOD1>.<MOD2>.<key> to either 1. a str: niri action, 2. a list of strs: niri action with args, 3. a list w/ one str: mode to enable, 4. an attrs with a string attr named `sh`: shellscript to run";
                    type = lib.types.attrsOf lib.types.anything;
                    default = {};
                    example = {
                        default = {
                            Left = "focus-column-left";
                            T = [ "spawn" "my-terminal" ];
                            SHIFT.T = [ "spawn" "my-terminal" "--class" "scratch" ];
                            CTRL.SHIFT.T.sh = "killall my-terminal && notify-send 'cleared terminals!'";

                            M = [ "my-mode" ];

                            NONE.XF86AudioRaiseVolume.sh = "volume +5";
                            NONE.XF86AudioLowerVolume.sh = "volume -5";

                            NONE.SHIFT.XF86AudioRaiseVolume.sh = "volume +1";
                            NONE.SHIFT.XF86AudioLowerVolume.sh = "volume -1";
                        };

                        my-mode = {
                            A.sh = "notify-send 'a'";
                            SHIFT.A.sh = "notify-send 'A'";
                            B = [ "spawn" "my-browser" ];
                        };
                    };
                };
            };
        };
    };
}

