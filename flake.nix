{
    description = "niri binding config generator with support for modes";
    inputs = {};
    outputs = { ... }: {
        homeManagerModules.default = args: {
            options.programs.niri.bind-modes = import ./options.nix args;
            config = import ./config.nix args;
        };
    };
}

