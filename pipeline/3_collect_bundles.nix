# 3_collect_bundles.nix
#
# right now we have atomic bundles of info,
# scattered as leaf nodes in our big attrset (at arbitrary depths)
#
# let's collect these into a flat list

{ lib, modifiers, ... }: prevStep: let
    listBinds = attrs: lib.concatLists (lib.mapAttrsToList (name: value:
        if builtins.elem name modifiers then
            listBinds value
        else [ value ]
    ) attrs);
in listBinds prevStep


