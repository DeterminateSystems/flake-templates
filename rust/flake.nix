{
  description = "A Rust flake template that you can adapt to your own environment";

  # Flake inputs
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs (use 0.1 for unstable)

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    let
      # The systems supported for this flake's outputs
      supportedSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper for providing system-specific attributes
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            # Provides a system-specific, configured Nixpkgs
            pkgs = import inputs.nixpkgs {
              inherit system;
              # Enable using unfree packages
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      # Development environments output by this flake
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          # Run `nix develop` to activate this environment or `direnv allow` if you have direnv installed
          default = pkgs.mkShell {
            # The Nix packages provided in the environment
            packages = with pkgs; [
              cargo
              rustc
              clippy
              rustfmt
              rust-analyzer # Rust language server for IDEs
              # Uncomment the lines below for some helpful tools:
              # cargo-edit # Commands like `cargo add` and `cargo rm`
              # bacon # For iterative development
              # cargo-nextest # Rust testing tool
              # cargo-audit # Check dependencies for vulnerabilities
              # cargo-outdated # Show which dependencies have updates available
              # cargo-deny # Lint your dependency graph
              # cargo-expand # Show macro expansions
            ];

            # Set any environment variables for your development environment
            env = {
              RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
            };

            # Add any shell logic you want executed when the environment is activated
            shellHook = ''
              echo "Rust toolchain 🦀"
              cargo --version
            '';
          };
        }
      );

      # Package outputs
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          # Build the package using Nixpkgs' built-in Rust helpers
          default =
            let
              # Get information about the package from Cargo.toml
              meta = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package;
            in
            pkgs.rustPlatform.buildRustPackage {
              inherit (meta) name version;
              src = builtins.path {
                path = ./.;
              };
              cargoLock.lockFile = ./Cargo.lock;
            };
        }
      );

      # Nix formatter

      # This applies the formatter that follows RFC 166, which defines a standard format:
      # https://github.com/NixOS/rfcs/pull/166

      # To format all Nix files:
      # git ls-files -z '*.nix' | xargs -0 -r nix fmt
      # To check formatting:
      # git ls-files -z '*.nix' | xargs -0 -r nix develop --command nixfmt --check
      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}
