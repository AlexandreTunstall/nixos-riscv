{ config, pkgs, ... }:

{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_6_12;

    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
      "earlycon"
      "keep_bootcon"
      "boot.shell_on_fail"
    ];

    consoleLogLevel = 7;

    initrd.availableKernelModules = [
      # Upstream modules
      "cdns3-starfive"
      "clk-starfive-jh7110-aon"
      "clk-starfive-jh7110-isp"
      "clk-starfive-jh7110-stg"
      "clk-starfive-jh7110-vout"
      "dw_mmc-starfive"
      "dwmac-starfive"
      "jh7110-trng"
      "motorcomm"
      "nvme"
      "pcie-starfive"
      "phy-jh7110-dphy-rx"
      "phy-jh7110-pcie"
      "phy-jh7110-usb"
      #"starfive-hdmi"
      # Default modules
      "vfat"
      "nls_cp437"
    ];
  };

  hardware.deviceTree.name = "starfive/jh7110-starfive-visionfive-2-v1.3b.dtb";

  hardware.deviceTree.overlays = [
    {
      name = "8gb-patch";
      dtsFile = ./8gb-patch.dts;
    }
    # https://github.com/starfive-tech/linux/pull/99
    {
      name = "qspi-patch";
      dtsFile = ./qspi-patch.dts;
    }
  ];
}
