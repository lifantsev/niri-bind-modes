{
    description = "niri binding config generator with support for modes";

    inputs = { };

    outputs = { ... }: {
        homeManagerModules.default = args: let
            args' = args // { cfg = args.config.programs.niri.bind-modes; };
        in {
            options.programs.niri.bind-modes = import ./options.nix args';
            config = import ./config.nix args';
        };
    };
}

