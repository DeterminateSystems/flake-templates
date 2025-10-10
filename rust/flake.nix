{
  description = "A Rust flake template that you can adapt to your own environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # Unstable Nixpkgs
    # Rust toolchain
    fenix = {
      url = "https://flakehub.com/f/nix-community/fenix/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Rust builder
    crane.url = "https://flakehub.com/f/ipetkov/crane/0";
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    let
      # The systems supported for this flake's outputs
      supportedSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
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
              overlays = [ self.overlays.default ];
            };
          }
        );

      lastModifiedDate = inputs.self.lastModifiedDate or inputs.self.lastModified or "19700101";
      version = "${builtins.substring 0 8 lastModifiedDate}-${inputs.self.shortRev or "dirty"}";
      meta = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package;
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
              rustToolchain
            ];

            # Set any environment variables for your development environment
            env = {
              RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
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
          default = pkgs.buildRustPackage ./.;
        }
      );

      # An overlay that puts the Rust toolchain in `pkgs`
      overlays.default =
        final: prev:
        let
          rustToolchain =
            with inputs.fenix.packages.${prev.system};
            combine (
              with stable;
              [
                cargo
                clippy
                rustc
                rustfmt
                rust-src
                rust-analyzer
              ]
            );
        in
        {
          inherit rustToolchain;

          buildRustPackage =
            src:
            ((inputs.crane.mkLib final).overrideToolchain rustToolchain).buildPackage ({
              pname = meta.name;
              inherit (meta) version;
              src = builtins.path {
                name = "${meta.name}-source";
                path = src;
              };
            });
        };
    };
}
