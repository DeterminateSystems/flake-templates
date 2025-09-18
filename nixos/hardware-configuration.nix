{
  config,
  lib,
  modulesPath,
  ...
}:

{
  fileSystems."/".device = "/dev/disk/by-label/nixos";

  # Provide any other hardware configuration here. To automate this process, you can use
  # `nixos-generate-config`, which comes installed on NixOS. For more information:
  # https://nixos.org/manual/nixos/stable/#sec-installation-manual-installing
}
