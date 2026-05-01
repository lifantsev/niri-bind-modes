# niri-bind-modes

niri doesn't offer mode-based keybinds out of the box (also called layers or submaps). this flake helps by compiling a mode-based binding attribute set into a binds.kdl file. fully native and static: no scripts/daemons required.

### how it works

A temporary file contains the name of the current mode (TODO: will be configurable but currently it's `/tmp/niri.mode`). Keys are bound using `spawn-sh`, and they write to or read from this file to determine what to do.

### limitations

- Modes are only 'one-shot', if you want modes that persist for multiple key presses, open an issue or email me and I'll implement it.
- Keys that are bound in any mode are bound permanently. This means that if you bind `Mod+R` to a resizing mode, and within that mode you bind `hjkl` to resizing actions, `hjkl` will be bound (and therefore intercepted) even if their mode isn't active. You can work around this by binding them to [wtype](https://github.com/atx/wtype) in other modes. This could be added to this flake as some sort of passthrough option, if you would like that open an issue or email me.

## Usage

Add this flake as an input, and import the home manager module:
``` nix
# flake.nix
inputs.niri-bind-modes.url = "github:lifantsev/niri-bind-modes";

# home.nix
imports = [ inputs.niri-bind-modes.homeManagerModules.default ]
```

Define keybindings as follows:
``` nix
programs.niri.bind.set = {
    default = {
        MOD.Right = "swap-window-right";
        MOD.SHIFT.CTRL.T = [ "spawn" "kitty" ];
        XF86MonBrightnessUp.sh = "brightnessctl set 3%+";
        MOD.A = [ "mymode" ];
    };

    mymode = {
        MOD.B = "close-window";
        MOD.C = [ "othermode" ];
    };

    othermode.MOD.D = "quit";
};
```
Any binding must exist in the `bind.set` attrset as `set.<mode>.<MOD1>.<MOD2>.<key> = val` (number of mods is arbitrary, can be 0) and `val` is one of:
- string: niri action
- list of strings: niri action with arguments
- list of one string: a mode to change to (cannot contain spaces)
- attrset: must contain a `sh` key with value being string shell command

To make your config cleaner you may set the `defaultModifiers` option. Then you can omit those mods from all binds. To create binds that don't include the `defaultModifiers`, use the `NONE` modifier:
``` nix
programs.niri.bind.defaultModifiers = [ "MOD" ];

programs.niri.bind.set.default = {
    NONE.XF86MonBrightnessUp.sh = "brightnessctl set 3%+";
    A = "close-window"; # this is bound as MOD+A
};
```

This flake uses `xdg.configFile."niri/config.kdl"` to point niri to the `binds.kdl` file. If your configuration already sets this, `binds.kdl` won't be included in `config.kdl` and your bindings won't be registered. Use `extraConfig` instead:
``` nix
```
