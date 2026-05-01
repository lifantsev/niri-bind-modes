# 4_mk_per_mode_cmds
#
# now that we have a list of atomic binding attrsets,
# we start the process of converting them into niri config lines
#
# first, we take the 'binds' attrset from each binding:
# { mode1 = "action1"; mode2 = { sh = "shellscript --help"; }; }
#
# and, for every mode, convert the action to a shell command that executes it
# - for simple actions, prepend 'niri msg action'
# - for actions with arguments, use 'niri msg action ${action} -- ${arguments}'
# - for attrsets
#   - if there's a `sh` key use its value as the cmd
#   - if there's a `mode` key switch mode to it
#
# every cmd that isn't a mode change also runs ${setMode default}, to reset any possibly active mode

{ lib, setMode, ... }: prevStep: let
    bindToCmd = bind:
        if builtins.typeOf bind == "string" then
            "niri msg action ${bind} ; ${setMode "default"}"
        else if builtins.typeOf bind == "list" then
            "niri msg action ${builtins.head bind} -- ${lib.concatStringsSep " " (map (arg: "'${arg}'") (builtins.tail bind))} ; ${setMode "default"}"
        else if builtins.typeOf bind == "set" then
            if builtins.attrNames bind == [ "sh" ] then
                bind.sh
            else if builtins.attrNames bind == [ "mode" ] then
                setMode bind.mode
            else "echo"
        else "echo";

    mkModeCmds = bind: {
        cmds = lib.mapAttrs (_: b: bindToCmd b) bind.binds;
        inherit (bind) key mods;
    };
in map mkModeCmds prevStep
