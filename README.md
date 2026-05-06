# niri-bind-modes

Niri [doesn't offer](https://github.com/niri-wm/niri/issues/846) mode-based keybinds out of the box (also called layers or submaps). This flake helps by compiling an easy to read, mode-based keybind definition into a `binds.kdl` file. Fully native and static: no scripts, daemons, or external tools.

### how it works

A temporary file contains the name of the current mode. Keys are bound using `spawn-sh`, and they read/write this file to determine what to do.

### limitations

- Modes are only 'one-shot', if you want modes that persist for multiple key presses, open an issue or email me and I'll implement it.
- Keys that are bound in any mode are bound globally. This means that if you bind `Mod+R` to a resizing mode, and within that mode you bind `hjkl` to resizing actions, `hjkl` will be bound (and therefore intercepted) even if their mode isn't active. You can work around this by binding them to [wtype](https://github.com/atx/wtype) in other modes. This could be added to this flake as some sort of passthrough option; if you would like that, open an issue or email me.

### planned features

- Aside from `default`, add another special mode called `overview` with binds that are activated when the overview is open.

## Quickstart

For a description of all options, see [CONFIGURING.md](CONFIGURING.md). To use `niri-bind-modes`, add this flake as an input, import the home manager module, and set up your bind attrset:
``` nix
# flake.nix
inputs.niri-bind-modes.url = "github:lifantsev/niri-bind-modes";

# home.nix
imports = [ inputs.niri-bind-modes.homeManagerModules.default ]

programs.niri.bind-modes = {
    enableBindsFile = true;
    enableConfigFile = true;

    defaultModifiers = [ "MOD" ];
    binds = { sh, mode, ... }: {
        default = { # default submap/mode
            H = "focus-column-left";
            J = "focus-window-down";
            K = "focus-window-up";
            L = "focus-column-right";

            CTRL.H = [ "set-column-width" "-5%" ];
            CTRL.L = [ "set-column-width" "+5%" ];

            CTRL.SHIFT.Q = "quit";

            O = mode "open";

            # use 'NONE' to create binds that don't include `defaultModifiers`
            NONE.XF86MonBrightnessUp = sh "brightnessctl set 3%+";
            NONE.SHIFT.XF86MonBrightnessUp = sh "brightnessctl set 10%+";
        };

        open = { # submap for opening apps
            T = [ "spawn" "kitty" ];
        };
    };
};
```

## Resulting .kdl
For the curious, here is the `binds.kdl` produced by this flake when used with the above configuration (with added indentation & newlines for readability). You can see it uses case statements for any binds that appear in modes other than `default`.

``` kdl
spawn-sh-at-startup "echo default > /tmp/niri-bind-mode"

binds {
    MOD+H { spawn-sh "niri msg action focus-column-left ; echo default > /tmp/niri-bind-mode"; }
    MOD+J { spawn-sh "niri msg action focus-window-down ; echo default > /tmp/niri-bind-mode"; }
    MOD+K { spawn-sh "nirimsg action focus-window-up ; echo default > /tmp/niri-bind-mode"; }
    MOD+L { spawn-sh "niri msg action focus-column-right ; echo default > /tmp/niri-bind-mode"; }

    MOD+CTRL+H { spawn-sh "niri msg action set-column-width -- -5% ; echo default > /tmp/niri-bind-mode"; }
    MOD+CTRL+L { spawn-sh "niri msg action set-column-width -- +5% ; echo default > /tmp/niri-bind-mode"; }

    MOD+CTRL+SHIFT+Q { spawn-sh "niri msg action quit ; echo default > /tmp/niri-bind-mode"; }

    SHIFT+XF86MonBrightnessUp { spawn-sh "brightnessctl set 10%+"; }
    XF86MonBrightnessUp { spawn-sh "brightnessctl set 3%+"; }

    MOD+O { spawn-sh "echo open > /tmp/niri-bind-mode"; }
    MOD+T { spawn-sh "case $(cat /tmp/niri-bind-mode) in open) niri msg action spawn -- kitty ; echo default > /tmp/niri-bind-mode ;; esac"; }
}
````
