# niri-bind-modes

Niri [doesn't offer](https://github.com/niri-wm/niri/issues/846) mode-based keybinds out of the box (also called layers or submaps). This flake helps by compiling an easy to read, mode-based keybind definition into a `binds.kdl` file. Fully native and static: no scripts, daemons, or external tools.

### how it works

A temporary file contains the name of the current mode. Keys are bound using `spawn-sh`, and they read/write this file to determine what to do.

### limitations

- Modes are only 'one-shot', if you want modes that persist for multiple key presses, open an issue or email me and I'll implement it.
- Keys that are bound in any mode are bound globally. This means that if you bind `Mod+R` to a resizing mode, and within that mode you bind `hjkl` to resizing actions, `hjkl` will be bound (and therefore intercepted) even if their mode isn't active. You can work around this by binding them to [wtype](https://github.com/atx/wtype) in other modes. This could be added to this flake as some sort of passthrough option; if you would like that, open an issue or email me.

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

To make your config cleaner you may set the `defaultModifiers` option. Then you can omit those modifiers from all binds:
``` nix
programs.niri.bind.defaultModifiers = [ "MOD" ];
programs.niri.bind.set.default.A = "close-window"; # this is bound as MOD+A
```

To create binds that don't include the `defaultModifiers`, use the `NONE` modifier:
``` nix
programs.niri.bind.set.default = {
    NONE.XF86MonBrightnessUp.sh = "brightnessctl set 3%+"; # this is bound without MOD
};
```

This flake uses `xdg.configFile."niri/config.kdl"` to point niri to the `binds.kdl` file. If your configuration already sets this, `binds.kdl` won't be included in `config.kdl` and your bindings won't be registered. Use `extraConfig` instead:
``` nix
programs.niri.extraConfig = ''
    animations {
        slowdown 0.5;
    }
'';
```

By default the current mode is saved to `/tmp/niri-bind-mode`. This can be changed using the following option (just make sure the parent directory exists):
``` nix
programs.niri.bind.modeFile = /home/user/.local/state/niri-bind-mode;
```

## Resulting .kdl
For the curious, here is a snippet of the `binds.kdl` produced by this flake in my personal configuration. You can see it uses case statements for any binds that appear in modes other than `default`.

``` kdl
spawn-sh-at-startup "echo default > /tmp/niri-bind-mode"

binds {
XF86MonBrightnessUp { spawn-sh "brightnessctl -e3 set 3%+"; }
MOD+A { spawn-sh "niri msg action focus-window-or-workspace-up ; echo default > /tmp/niri-bind-mode"; }
MOD+Period { spawn-sh "echo dropdown > /tmp/niri-bind-mode"; }
MOD+T { spawn-sh "case $(cat /tmp/niri-bind-mode) in ''|default) niri msg action spawn -- 'kitty' ; echo default > /tmp/niri-bind-mode ;; dropdown) niridrop term ;; esac"; }
MOD+W { spawn-sh "case $(cat /tmp/niri-bind-mode) in dropdown) niridrop ;; esac"; }
}
````
