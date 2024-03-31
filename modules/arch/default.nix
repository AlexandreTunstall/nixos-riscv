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
      # Using mold might not be worth it, because it requires building 80+ more
      # packages just for the stdenv. On the other hand, mold is much faster.
      replaceStdenv = { pkgs }: pkgs.useMoldLinker pkgs.gcc13Stdenv;
    };
  };
}
