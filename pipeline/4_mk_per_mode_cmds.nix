# 4_mk_per_mode_cmds
#
# now that we have a list of atomic binding attrsets,
# we start the process of converting them into niri config lines
#
# first, we take the 'binds' attrset from each binding:
# { mode1 = "action1"; mode2.sh = "shellscript --help"; }
#
# and, for every mode, convert the action to a shell command that executes it
# - for simple actions, prepend 'niri msg action'
# - for actions with arguments, use 'niri msg action ${action} -- ${arguments}'
# - for mode changes (lists with only one element), use the setMode function
# - for attrsets (this is when we use .sh) use the raw shellscript provided
#
# every cmd that isn't a mode change also runs ${setMode default}, to reset any possibly active mode

{ lib, setMode, ... }: prevStep: let
    bindToCmd = bind:
        if builtins.typeOf bind == "string" then
            "niri msg action ${bind} ; ${setMode "default"}"
        else if builtins.typeOf bind == "list" then
            if builtins.length bind == 1
            then setMode (builtins.head bind)
            else "niri msg action ${builtins.head bind} -- ${lib.concatStringsSep " " (map (arg: "'${arg}'") (builtins.tail bind))} ; ${setMode "default"}"
        else "${bind.sh}";

    modifyBind = bind: {
        cmds = lib.mapAttrs (_: b: bindToCmd b) bind.binds;
        inherit (bind) key mods;
    };
in map modifyBind prevStep
