# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "dw_mmc_starfive" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1234-ABCD";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c7a797c9-a0b9-4cec-af99-7c17db5f114f"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.end0.useDHCP = lib.mkDefault true;
  # networking.interfaces.end1.useDHCP = lib.mkDefault true;
  # networking.interfaces.ip6tnl0.useDHCP = lib.mkDefault true;
  # networking.interfaces.sit0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
}
