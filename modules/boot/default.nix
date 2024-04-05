{ config, pkgs, ... }:

{
  boot = {
    loader.systemd-boot = {
      enable = true;
      extraInstallCommands = ''
        set -euo pipefail
        ${pkgs.coreutils}/bin/cp --no-preserve=mode -r ${config.hardware.deviceTree.package} ${config.boot.loader.efi.efiSysMountPoint}/
        for filename in ${config.boot.loader.efi.efiSysMountPoint}/loader/entries/nixos*-generation-[1-9]*.conf; do
          if ! ${pkgs.gnugrep}/bin/grep -q 'devicetree' $filename; then
            echo "devicetree /dtbs/${config.hardware.deviceTree.name}" >> $filename
          fi
        done
      '';
    };

    kernelPackages = pkgs.linuxPackages_vf2;

    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
      "earlycon"
      "keep_bootcon"
      "boot.shell_on_fail"
    ];

    consoleLogLevel = 7;

    initrd.availableKernelModules = [
      "dw_mmc-starfive" "motorcomm"
      "cdns3-starfive"
      "clk-starfive-jh7110-vout"
      "clk-starfive-jh7110-isp"
      "nvme"
      "vs-drm"
      # Upstream modules
      "dwmac-starfive"
      "jh7110-trng"
      "phy-jh7110-usb"
      "phy-jh7110-dphy-rx"
      "clk-starfive-jh7110-aon"
      "clk-starfive-jh7110-stg"
      "pcie-starfive"
      #"starfive-hdmi"
      # Default modules
      "vfat"
      "nls_cp437"
    ];

    # Modules that cause system instability
    blacklistedKernelModules = [
      #"clk-starfive-jh7110-vout"
      "jh7110-crypto"
    ];
  };

  hardware.deviceTree.name = "starfive/jh7110-starfive-visionfive-2-v1.3b.dtb";
}
