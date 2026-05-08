# 6_render_niri_attrs
#
# at this point each binding is just a list of modifiers, a key, and a self contained shell cmd
# so, we add all of that into a niri-flake settings attrset

{ lib, setMode, ... }: prevStep: let
    mkKey = bind: "${lib.concatStrings (map (s: s+"+") bind.mods)}${bind.key}";
in {
    spawn-at-startup = [ { sh = setMode "default"; } ];

    binds = lib.mergeAttrsList (map (bind: {
        "${mkKey bind}".action.spawn-sh = bind.cmd;
    }) prevStep);
}
