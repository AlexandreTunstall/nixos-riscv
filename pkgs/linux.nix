{ buildLinux
, lib
, src
, ...
} @ args:

let
  modDirVersion = "6.8.0";

in buildLinux (args // {
  inherit src modDirVersion;
  version = "${modDirVersion}-vf2";

  structuredExtraConfig = with lib.kernel; {
    CPU_FREQ = yes;
    CPUFREQ_DT = yes;
    CPUFREQ_DT_PLATDEV = yes;
    DMADEVICES = yes;
    GPIO_SYSFS = yes;
    HIBERNATION = yes;
    NO_HZ_IDLE = yes;
    POWER_RESET_GPIO_RESTART = yes;
    PROC_KCORE = yes;
    PWM = yes;
    PWM_STARFIVE_PTC = yes;
    RD_GZIP = yes;
    SENSORS_SFCTEMP = yes;
    SERIAL_8250_DW = yes;
    SIFIVE_CCACHE = yes;
    SIFIVE_PLIC = yes;

    RTC_DRV_STARFIVE = yes;
    SPI_PL022 = yes;
    SPI_PL022_STARFIVE = yes;

    I2C = yes;
    MFD_AXP20X = yes;
    MFD_AXP20X_I2C = yes;
    REGULATOR_AXP20X = yes;
    REGULATOR_AXP15060 = yes;

    # FATAL: modpost: drivers/gpu/drm/verisilicon/vs_drm: struct of_device_id is not terminated with a NULL entry!
    #DRM_VERISILICON = no;
    #DRM_VERISILICON = module;
    DRM_VERISILICON = yes;
    STARFIVE_HDMI = yes;
    # For DRM_VERISILICON=y
    DRM = yes;

    PL330_DMA = no;
  };

  preferBuiltin = true;

  extraMeta = {
    branch = "visionfive2";
    description = "Linux kernel for StarFive's VisionFive2";
    platforms = [ "riscv64-linux" ];
  };
})
