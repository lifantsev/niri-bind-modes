{ ... }@args: { binds, defaultModifiers }:
import ./1_transpose_tree.nix (args // {
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
}) binds
