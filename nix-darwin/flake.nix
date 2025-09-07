{
  description = "A flake template for nix-darwin and Determinate Nix";

  # Flake inputs
  inputs = {
    # Stable Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    # Stable nix-darwin
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Determinate module
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    let
      # Your system username
      username = "just-me-123";

      # Your system type
      system = "aarch64-darwin"; # or use x86_64-linux for Intel macOS
    in
    {
      darwinConfigurations."${username}-${system}" = inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Add the determinate nix-darwin module
          inputs.determinate.darwinModules.default
          # Apply the modules output by this flake
          self.darwinModules.base
        ];
      };

      darwinModules = {
        base =
          { ... }:
          {
            # Let Determinate Nix handle your Nix configuration
            nix.enable = false;

            # Custom Determinate Nix settings written to /etc/nix/nix.custom.conf
            determinate-nix.customSettings = {
              eval-core = 0;
              extra-experimental-features = [
                "build-time-fetch-tree"
                "parallel-eval"
              ];
            };

            system.stateVersion = 1;

            users.users.${username} = {
              name = username;
            };

            # Other configuration parameters
            # See here: https://nix-darwin.github.io/nix-darwin/manual
          };
      };
    };
}
