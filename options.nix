{ lib, ... }: {
    enable = lib.mkEnableOption "addition of binds to niri-flake settings attrset";

    defaultModifiers = lib.mkOption {
        description = "list of modifiers to use in all bindings unless they use the 'NONE' modifier";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "MOD" ];
    };

    modeFile = lib.mkOption {
        description = "temporary file to read/write current bind mode to";
        type = lib.types.path;
        default = /tmp/niri-bind-mode;
        example = /home/user/.local/state/niri-bind-mode;
    };

    binds = lib.mkOption {
        description = "function taking a set {sh, mode, ...} and returning a bind set with entries: <mode>.<MOD1>.<MOD2>.<key> = <action|sh 'shellscript'|mode 'modename'>";
        type = lib.types.functionTo (lib.types.attrsOf lib.types.anything);
        default = {};
        example = { sh, mode, ... }: {
            default = {
                Left = "focus-column-left";
                T = [ "spawn" "my-terminal" ];
                SHIFT.T = [ "spawn" "my-terminal" "--class" "scratch" ];
                CTRL.SHIFT.T = sh "killall my-terminal && notify-send 'cleared terminals!'";

                M = mode "my-mode";

                NONE.XF86AudioRaiseVolume.sh = "volume +5";
                NONE.XF86AudioLowerVolume.sh = "volume -5";

                NONE.SHIFT.XF86AudioRaiseVolume.sh = "volume +1";
                NONE.SHIFT.XF86AudioLowerVolume.sh = "volume -1";
            };

            my-mode = {
                A = sh "notify-send 'a'";
                SHIFT.A = sh "notify-send 'A'";
                B = [ "spawn" "my-browser" ];
            };
        };
    };
}
