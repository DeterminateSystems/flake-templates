{
  description = "A flake template for Home Manager";

  # Flake inputs
  inputs = {
    # Stable Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    # Stable Home Manager
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
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

      # Your system type (x86 AMD Linux here but make sure to change to match your system if need be)
      system = "aarch64-darwin";

      # System-specific Nixpkgs
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      # nix-darwin configuration output
      homeConfigurations."${username}-${system}" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          (_: {
            home.homeDirectory = "/Users/${username}";
            home.stateVersion = "25.05";
            home.username = username;
          })
        ];
      };

      # Development environment
      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            # Shell script for applying the Home Manager configuration.
            # Run this to apply the configuration in this flake to your macOS system.
            (writeShellApplication {
              name = "reload-home-manager-configuration";
              runtimeInputs = [
                # Make the Home Manager package available in the script
                inputs.home-manager.packages.${system}.home-manager
              ];
              text = ''
                echo "> Applying Home Manager configuration..."

                echo "> Running home-manager switch..."
                home-manager switch --flake ".#${username}-${system}"

                echo "> home-manager switch was successful ✅"

                echo "> System home config was successfully applied 🚀"
              '';
            })
          ];
        };
    };
}
