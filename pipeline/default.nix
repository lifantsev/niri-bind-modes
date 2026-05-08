# TODO
# add an `overlay` mode
# bindings in this mode will trigger only when the niri overlay is open
# this can be implemented in a phase between 4 & 5
# it would merge `overlay` into `default` using `niri msg overview-state`
{ lib, ... }: arguments: let
    args = {
        inherit lib;
        inherit (arguments) defaultModifiers;

        setMode = mode: "echo ${mode} > ${toString arguments.modeFile}";
        getMode = "cat ${toString arguments.modeFile}";

        modifiers = [
            "NONE"
            "MOD"
            "SHIFT"
            "CTRL"
            "ALT"
        ];
    };

    input = arguments.binds {
        sh = str: { sh = str; };
        mode = str: { mode = str; };
    };

    call = lib.flip import args;
in lib.pipe input [
    (call ./1_transpose_tree.nix)
    (call ./2_bundle_binding_data.nix)
    (call ./3_collect_bundles.nix)
    (call ./4_mk_per_mode_cmds.nix)
    (call ./5_mk_conditional_cmds.nix)
    (call ./6_render_niri_attrs.nix)
]
