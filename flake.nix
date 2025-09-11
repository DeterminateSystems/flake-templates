{
  description = "Determinate Systems flake templates";

  outputs =
    { self, ... }@inputs:
    {
      templates = {
        default = {
          description = "Default flake template for Determinate Nix";
          path = ./default;
          welcomeText = ''
            # Welcome to your new Nix flake ❄️🍁

            To activate your new flake's development environment, run `nix develop` or `direnv allow` if you use direnv.

            For a more interactive flake initialization experience, delete the `flake.nix` that was just created and use fh, the CLI for FlakeHub:

                nix run "https://flakehub.com/f/DeterminateSystems/fh/0" -- init

            For more on flakes, check out **Zero to Nix**, our flake-forward guide to Nix:

                https://zero-to-nix.com
          '';
        };

        home-manager = {
          description = "TODO";
          path = ./home-manager;
          welcomeText = "TODO";
        };

        nix-darwin = {
          description = "A flake template for nix-darwin and Determinate Nix";
          path = ./nix-darwin;
          welcomeText = ''
            # Welcome to your new nix-darwin configuration flake ❄️🍁🍎

            Before applying this configuration, change the `username` and `system` to values that make sense for your macOS machine.

            To apply the nix-darwin configuration in this flake, run the supplied script:

                nix develop --command reload-nix-darwin-configuration

            For ideas on how to configure your system, consult the nix-darwin reference documentation:

                https://nix-darwin.github.io/nix-darwin/manual
          '';
        };
      };
    };
}
