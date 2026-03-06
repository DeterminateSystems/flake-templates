{
  # This flake template shows you how to use non-default flake schemas.
  # Check the default schemas to see if your output types are already covered:
  # https://github.com/DeterminateSystems/flake-schemas

  description = "A template for flakes using non-default flake schemas";

  # Flake inputs
  inputs = {
    # Other inputs (Nixpkgs, etc)

    # A pinned version of the default schemas
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    {
      # The schemas output tells Nix which schemas to use for the outputs of
      # this flake. Here, the default schemas are loaded and can be extended
      # if desired. If you don't need to extend the default schemas, you can
      # omit both this output and the flake-schemas input above.
      schemas = inputs.flake-schemas.schemas // {
        # Add any custom schemas here
      };

      # Define your flake outputs here. These could be outputs that conform to
      # the default schemas (packages, dev shells, NixOS configurations, etc.)
      # or they could be custom output types or a mix of both.
    };
}
