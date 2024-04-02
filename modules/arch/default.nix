{ ... }:
{
  nixpkgs = {
    hostPlatform = {
      system = "riscv64-linux";

      gcc = {
        arch = "rv64gc_zba_zbb";
        tune = "sifive-u74";
      };
    };
  };
}
