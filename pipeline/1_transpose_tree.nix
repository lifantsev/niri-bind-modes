# 1_transpose_tree
# 
# first, we take the base attrset (containing attrsets for each mode)
# and we 'tag' every binding (leaf node) with the name of the mode its in
#
# now the top separation is the key combo and lower separation is mode (instead of other way)
#
# this allows us to merge all of the previously separate mode attrsets
# so now we have one big attrset of key combos and each leaf node has different actions defined per mode
#
# instead of attrs.<mode>.<modifiers>.<key> = "some action"
# we now have attrs.<modifiers>.<key>.<mode> = "some action"

{ lib, modifiers, ... }: binds: let
    recursiveMergeAttrsList = lib.lists.foldr (a: b: lib.recursiveUpdate a b) {};
    tagAttrs = tag: attrs:
        builtins.mapAttrs (name: value:
            if builtins.elem name modifiers then # TODO ensure this works properly
                tagAttrs tag value
            else
                { "${tag}" = value; }
        ) attrs;
in recursiveMergeAttrsList (lib.mapAttrsToList (mode: bindset: tagAttrs mode bindset) binds)
