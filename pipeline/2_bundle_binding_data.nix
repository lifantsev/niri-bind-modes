# 2_bundle_binding_data
#
# currently our attrset has the modifiers & key as a 'path' to get to the action:
# attrs.MOD.SHIFT.CTRL.A.mode = "action"
#
# but we want a list of atomic bundles contianing the key, mods, and actions per mode:
# {
#     mods = [ "MOD" "SHIFT" "CTRL" ];
#     key = "A";
#     binds.mode = "action";
# }
#
# we achieve this by recursively traversing the attrset,
# collecting the modifiers into a list as we descend,
# and depositing all of the information at the leaf nodes
#
# we will extract the leaf nodes into a list next...

{ lib, modifiers, defaultModifiers, ... }: prevStep: let 
    collectModsInAttrs = mods: attrs:
        builtins.mapAttrs (name: value:
            if builtins.elem name modifiers then
                collectModsInAttrs (mods ++ [name]) value
            else {
                mods = if builtins.elem "NONE" mods
                    then lib.lists.remove "NONE" mods
                    else lib.unique (defaultModifiers ++ mods);
                key = name;
                binds = value;
            }
        ) attrs;

in collectModsInAttrs [] prevStep
