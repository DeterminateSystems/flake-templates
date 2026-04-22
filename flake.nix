{
  description = "Determinate Systems flake templates";

  outputs =
    { self, ... }@inputs:
    {
      templates =
        let
          defaultWelcomeText = ''
            # Welcome to your new Nix flake ❄️🍁

            To activate your new flake's development environment, run `nix develop` or `direnv allow` if you use direnv.

            For a more interactive flake initialization experience, delete the `flake.nix` that was just created and use fh, the CLI for FlakeHub:

                nix run "https://flakehub.com/f/DeterminateSystems/fh/0" -- init

            For more on flakes, check out **Zero to Nix**, our flake-forward guide to Nix:

                https://zero-to-nix.com
          '';
        in
        {
          default = self.templates.minimal;

          documented = {
            description = "Default flake template for Determinate Nix";
            path = ./documented;
            welcomeText = defaultWelcomeText;
          };

          home-manager = {
            description = "A flake template for Home Manager";
            path = ./home-manager;
            welcomeText = ''
              # Welcome to your new Home Manager configuration flake ❄️🍁🍎🐧

              Before applying this configuration, change the `username` and `system` to values that make sense for your machine.

              To apply the Home Manager configuration in this flake, run the supplied script:

                  nix develop --command apply-home-manager-configuration

              For ideas about how to configure your system, consult the Home Manager manual and reference documentation:

                  https://nix-community.github.io/home-manager
                  https://nix-community.github.io/home-manager/options.xhtml
            '';
          };

          minimal = {
            description = "Minimal flake template for Determinate Nix";
            path = ./minimal;
            welcomeText = defaultWelcomeText;
          };

          nix-darwin = {
            description = "A flake template for nix-darwin and Determinate Nix";
            path = ./nix-darwin;
            welcomeText = ''
              # Welcome to your new nix-darwin configuration flake ❄️🍁🍎

              Before applying this configuration, change the `username` and `system` to values that make sense for your macOS machine.

              To apply the nix-darwin configuration in this flake, run the supplied script:

                  nix develop --command apply-nix-darwin-configuration

              For ideas about how to configure your system, consult the nix-darwin reference documentation:

                  https://nix-darwin.github.io/nix-darwin/manual
            '';
          };

          nixos = {
            description = "A flake template for NixOS with Determinate Nix";
            path = ./nixos;
            welcomeText = ''
              # Welcome to your new NixOS configuration flake ❄️🍁

              The NixOS system output by this flake comes with Determinate Nix installed.
              You can build the toplevel for the configuration like this:

                  nix build .#nixosConfigurations.my-system.config.system.build.toplevel

              You can search for NixOS configuration options here:

                  https://search.nixos.org/options
            '';
          };

          rust = {
            description = "A flake template for Rust";
            path = ./rust;
            welcomeText = ''
              # Welcome to your new NixOS configuration flake ❄️🦀

              To activate your new flake's development environment, run `nix develop` or `direnv allow` if you use direnv.

              To run the Rust program in this template (you should see a warm greeting):

                  nix develop --command cargo run

              To build the Rust program using Nix:

                  nix build
            '';
          };

          flake-schemas = {
            description = "A template for flakes using non-default flake schemas";
            path = ./flake-schemas;
            welcomeText = ''
              # Welcome to your new flake with custom schemas ❄️🗺️

              This flake template shows you how to use non-default flake schemas.
              You can find the default schemas at https://github.com/DeterminateSystems/flake-schemas.
              If you have flake outputs that don't fit these defaults, this template is for you!

              To see the flake outputs:

                  nix flake show

              To see the flake outputs as JSON:

                  nix flake show --json
            '';
          };
        };
    };
}
