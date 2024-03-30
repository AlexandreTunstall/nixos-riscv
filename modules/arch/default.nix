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

    config = {
      replaceStdenv = { pkgs }: pkgs.useMoldLinker pkgs.gcc13Stdenv;
    };
  };
}
