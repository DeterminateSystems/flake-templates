{
  description = "Determinate Systems flake templates";

  outputs =
    { self, ... }@inputs:
    {
      templates = {
        default = {
          description = "Default flake template";
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
      };
    };
}
