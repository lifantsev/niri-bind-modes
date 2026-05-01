# 1_transpose_tree
# 
# first, we take the base attrset (containing bind attrsets for each mode)
# and we 'tag' every leaf (a terminal node: one that isn't an attrset) with the name of the mode
#
# that way, instead of the top separation being mode and lower separation being key combo
# now the top separation is the key combo and lower separation is mode
# (because for end user configuration it makes sense to separate modes, but in niri each key can only be bound once)
#
# this allows is to merge all of the previously separate mode attrsets
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
