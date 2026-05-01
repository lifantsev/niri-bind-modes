{ lib, ... }: { set, defaultModifiers }: let
    args = {
        inherit lib;
        inherit defaultModifiers;

        setMode = mode: "echo ${mode} > /tmp/niri.mode";
        getMode = "cat /tmp/niri.mode";

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
