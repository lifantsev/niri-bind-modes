# 3_collect_bundles.nix
#
# right now the bindings are small attrsets (bundles),
# scattered as leaf nodes in our big attrset (at arbitrary depths)
# however, we want them collected into a list
#
# we do this by recursively traversing the tree,
# collecting the 'leaves' into a list,
# while discarding the 'branches'

{ lib, modifiers, ... }: prevStep: let
    listBinds = attrs: lib.concatLists (lib.mapAttrsToList (name: value:
        if builtins.elem name modifiers then
            listBinds value
        else [ value ]
    ) attrs);
in listBinds prevStep


