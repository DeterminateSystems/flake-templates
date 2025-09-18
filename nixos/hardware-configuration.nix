{
  config,
  lib,
  modulesPath,
  ...
}:

{
  fileSystems."/".device = "/dev/disk/by-label/nixos";

  # Provide any other hardware configuration here
}
