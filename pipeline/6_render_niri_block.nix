# 6_render_niri_block
#
# at this point each binding is just a list of modifiers, a key, and a self contained shell cmd
# so, we compile each one into a niri configuration line,
# and wrap all of that into a binds {} block

{ lib, setMode, ... }: prevStep: let
    mkConfigLine = bind: ''${lib.concatStrings (map (s: s+"+") bind.mods)}${bind.key} { spawn-sh "${bind.cmd}"; }'';
    configLines = map mkConfigLine prevStep;
in ''
    spawn-sh-at-startup "${setMode "default"}"

    binds {
    ${lib.concatStringsSep "\n" configLines}
    }
''
