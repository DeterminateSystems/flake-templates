{
  description = "Determinate Systems flake templates";

  outputs =
    { self, ... }@inputs:
    {
      templates = {
        default = {
          description = "Default flake template";
          path = ./default;
        };
      };
    };
}
