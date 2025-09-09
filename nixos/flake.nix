{
  description = "An empty flake template that you can adapt to your own environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    {
      # NixOS configurations output by this flake
      nixosConfigurations.my-system = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Load the Determinate module, which provides Determinate Nix
          inputs.determinate.nixosModules.default

          ./hardware-configuration.nix
        ];
        specialArgs = {
          # Values to pass to modules
        };
      };
    };
}
