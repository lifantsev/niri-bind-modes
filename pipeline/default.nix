# TODO
# add an `overlay` mode
# bindings in this mode will trigger only when the niri overlay is open
# this can be implemented in a phase between 4 & 5
# it would merge `overlay` into `default` using `niri msg overview-state`
{ lib, ... }: { set, defaultModifiers, modeFile }: let
    args = {
        inherit lib;
        inherit defaultModifiers;

        setMode = mode: "echo ${mode} > ${toString modeFile}";
        getMode = "cat ${toString modeFile}";

        modifiers = [
            "NONE"
            "MOD"
            "SHIFT"
            "CTRL"
            "ALT"
        ];
    };
in lib.pipe set
[
    (import ./1_transpose_tree.nix args)
    (import ./2_bundle_binding_data.nix args)
    (import ./3_collect_bundles.nix args)
    (import ./4_mk_per_mode_cmds.nix args)
    (import ./5_mk_conditional_cmds.nix args)
    (import ./6_render_niri_block.nix args)
]
