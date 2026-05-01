{ lib, ... }: {
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
        default = [ ];
        example = [ "MOD" ];
    };

    bind.modeFile = lib.mkOption {
        description = "temporary file to read/write current bind mode to";
        type = lib.types.path;
        default = /tmp/niri-bind-mode;
        example = /home/user/.local/state/niri-bind-mode;
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
}
