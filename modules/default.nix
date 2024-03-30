{ ... }:
{
  imports = [
    ./arch
    ./boot
    ./compilers
    ./environment
    ./hardware-configuration.nix
    ./security
    ./services
  ];

  system.stateVersion = "22.11";
}
