{
  description = "A full flake template showing many different output types";

  # Flake inputs
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    let
      linuxSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
      ];

      darwinSystems = [
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # The systems supported for this flake's outputs
      supportedSystems = linuxSystems ++ darwinSystems;

      # Helpers for providing system-specific attributes
      forEachSystem =
        systems: f:
        inputs.nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            # Provides a system-specific, configured Nixpkgs
            pkgs = import inputs.nixpkgs {
              inherit system;
              # Enable using unfree packages
              config.allowUnfree = true;
            };
          }
        );

      forEachSupportedSystem = forEachSystem supportedSystems;
      forEachLinuxSystem = forEachSystem linuxSystems;
      forEachDarwinSystem = forEachSystem darwinSystems;
    in
    {
      # Development environments output by this flake
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          # Run `nix develop` to activate this environment or `direnv allow` if you have direnv installed
          default = pkgs.mkShell {
            # The Nix packages provided in the environment
            packages = with pkgs; [
              self.formatter.${system}
            ];

            # Set any environment variables for your development environment
            env = { };

            # Add any shell logic you want executed when the environment is activated
            shellHook = "";
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);

      # Packages output by this flake
      packages = forEachSupportedSystem (
        { pkgs, ... }:
        rec {
          default = helloTxt;

          helloTxt = pkgs.stdenv.mkDerivation {
            name = "hello-txt";
            src = null;
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/share
              echo "Hello" > $out/share/hello.txt
            '';
          };
        }
      );

      # NixOS configurations output by this flake
      nixosConfigurations = forEachLinuxSystem (
        { pkgs, system }:
        {
          default = inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              (
                { config, lib, ... }:
                {
                  fileSystems."/".device = "/dev/disk/by-label/nixos";
                  boot.loader.systemd-boot.enable = true; # UEFI systems only
                  system.stateVersion = "25.05";
                }
              )
            ];
          };
        }
      );

      darwinConfigurations = forEachDarwinSystem (
        { pkgs, system }:
        {
          default = inputs.nix-darwin.lib.darwinSystem { };
        }
      );

      homeConfigurations = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = inputs.home-manager.lib.homeConfiguration { };
        }
      );
    };
}
