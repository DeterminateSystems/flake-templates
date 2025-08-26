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
            # Your new flake

            To get started with your brand new flake...
          '';
        };
      };
    };
}
