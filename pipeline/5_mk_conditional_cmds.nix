# 5_mk_conditional_cmds.nix
#
# right now each binding has a shell cmd per mode,
# but we need to turn that into a single cmd that decides what to do on its own
#
# if a binding is only defined for the default mode, we just run the command whenever the key is hit
# otherwise, we use a case statement to decide which cmd to run

{ lib, getMode, ... }: prevStep: let
    mkCase = mode: cmd: "${if mode == "default" then "''|default" else mode}) ${cmd} ;;";

    mkConditionalCmd = bind: {
        inherit (bind) key mods;
        cmd = if builtins.attrNames bind.cmds == [ "default" ] then
            bind.cmds.default
        else
            "case $(${getMode}) in "
            + lib.concatStringsSep " " (lib.mapAttrsToList mkCase bind.cmds)
            + " esac";
    };
in map mkConditionalCmd prevStep
