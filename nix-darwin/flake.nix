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
      # Development environment
      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          darwin-rebuild = inputs.nixpkgs.lib.getExe inputs.nix-darwin.packages.${system}.darwin-rebuild;
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            # Shell script for applying the nix-darwin configuration.
            # Run this to apply the configuration in this flake to your macOS system.
            (writeShellApplication {
              name = "reload-nix-darwin-configuration";
              runtimeInputs = [
                darwin-rebuild
              ];
              text = ''
                echo "> Applying nix-darwin configuration..."

                echo "> Running darwin-rebuild switch as root..."
                sudo darwin-rebuild switch --flake .
                echo "> darwin-rebuild switch was successful ✅"

                echo "> macOS config was successfully applied 🚀"
              '';
            })
          ];
        };

      # nix-darwin configuration output
      darwinConfigurations."${username}-${system}" = inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Add the determinate nix-darwin module
          inputs.determinate.darwinModules.default
          # Apply the modules output by this flake
          self.darwinModules.base
          self.darwinModules.nixConfig
          # Apply other modules here

          # Inline module
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              # In addition to adding modules in the style above, you can also
              # add modules inline like this.
            }
          )
        ];
      };

      # nix-darwin module outputs
      darwinModules = {
        # Some base configuration
        base =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            # Required for nix-darwin to work
            system.stateVersion = 1;

            users.users.${username} = {
              name = username;
              # See the reference docs for more on user config:
              # https://nix-darwin.github.io/nix-darwin/manual/#opt-users.users
            };

            # Other configuration parameters
            # See here: https://nix-darwin.github.io/nix-darwin/manual
          };

        # Nix configuration
        nixConfig =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            # Let Determinate Nix handle your Nix configuration
            nix.enable = false;

            # Custom Determinate Nix settings written to /etc/nix/nix.custom.conf
            determinate-nix.customSettings = {
              # Enables parallel evaluation (remove this setting or set the value to 1 to disable)
              eval-core = 0;
              extra-experimental-features = [
                "build-time-fetch-tree" # Enables build-time flake inputs
                "parallel-eval" # Enables parallel evaluation
              ];
              # Other settings
            };
          };

        # Add other module outputs here
      };
    };
}
