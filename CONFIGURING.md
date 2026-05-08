# Configuring

All options are under `programs.niri.bind-modes`.

## enable

Whether to enable the module, which will populate `programs.niri.settings.binds`, and add to `programs.niri.settings.spawn-at-startup` to reset the mode on startup.

## modeFile

A filepath that the generated bindings will read/write to keep track of the currently active mode. By default it's `/tmp/niri-bind-mode`.

## defaultModifiers

A list of modifiers to apply to all bindings. To create bindings that don't include the `defaultModifiers`, use the `NONE` modifier:
``` nix
programs.niri.bind-modes = {
    defaultModifiers = [ "MOD" ];
    binds = { sh, mode, ... }: {
        default = {
            A           = sh "cmd"; # bound to MOD+A
            CTRL.A      = sh "cmd"; # bound to MOD+CTRL+A
            NONE.CTRL.A = sh "cmd"; # bound to CTRL+A
        };
    };
};
```

## binds

A function that returns an attrset describing all modes and bindings within them. The function should take an attrset: `{ sh, mode, ... }`, where `sh` and `mode` are functions that take strings.

The top level of the attrset should be the modes (where `default` is the default mode). Then, within a mode `<mode>`, to bind, for example `<key>` with `<MOD1>` and `<MOD2>` to the action `<action>`, you should set `<mode>.<MOD1>.<MOD2>.<key> = <action>` inside the returned attrset. The order and amount of modifiers is irrelevant.

The action should be one of the following:
- string: niri action to execute (eg `"focus-column-left"`)
- list of strings: niri action with arguments (eg `[ "set-column-width" "+5%" ]`)
- (sh *string*): shell command to execute (eg `sh "notify-send hello && notify-send bye"`)
- (mode *string*): mode to switch to (eg `mode "launcher"`)

``` nix
programs.niri.bind-modes.binds = { sh, mode, ... }: {
    default = {
        MOD.CTRL.A = "focus-window-up";
        CTRL.MOD.SHIFT.A = "move-window-up"; # order of mods doesn't matter
        SHIFT.XF86MonBrightnessUp = sh "setbright +1"; # this executes the a command
        XF86MonBrightnessUp = sh "setbright +5"; # binds can have 0 modifiers

        MOD.L = mode "launcher"; # this switches the mode
    };

    launcher = { # these binds are only active when we switch mode to `launcher` (using MOD+L)
        MOD.B = [ "spawn" "browser" ]; # niri action w/ arguments
        MOD.CTRL.A = [ "spawn" "allacrity" ]; # modes can override binds set in default mode
    };
};
```
