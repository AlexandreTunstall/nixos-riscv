{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    overlays.riscv-fixes = import ./overlays/riscv-fixes.nix;

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          # Needs to be built on x86_64-linux and copied to the RISC-V host
          boot = self.packages.x86_64-linux.boot.entries;
        };

        modules = [
          ({ ... }: {
            nixpkgs.overlays = [ self.overlays.riscv-fixes ];
          })
          ./modules
        ];
      };
    };

    packages = {
      x86_64-linux = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in {
        boot = pkgs.linkFarm "boot" {
          "ghc-9.4.8" = pkgs.pkgsCross.riscv64.haskell.compiler.native-bignum.ghc948;
        };
      };

      riscv64-linux = let
        inherit (self.nixosConfigurations.nixos) pkgs;

        usableMap = pkgs.lib.mapAttrs isUsable pkgs.haskellPackages // {
          # Needs cplex (unfree)
          cplex-hs = false;
          # Needs folly (unsupported)
          cabal2nix-unstable = false;
          # Needs imagemagick (insecure)
          HDRUtils = false;
          # Needs luajit (unsupported)
          gegl = false;
          # Needs mplayer (unsupported)
          mplayer-spot = false;
          # Needs nvidia-x11 (unfree)
          cuda = false;
          # Needs openjdk (unsupported)
          hzk = false;
          # Needs valgrind (unsupported)
          hgdal = false;
        };

        isDerivation = v: builtins.isAttrs v && (v.type or "") == "derivation";
        isUsable = name: drv: isDerivation drv && name == drv.pname
          && drv.meta.available && !drv.meta.broken && !drv.meta.unfree
          && pkgs.lib.all lookupUsable (drv.getBuildInputs.isHaskellPartition.right or []);
        lookupUsable = drv: drv != null && usableMap.${drv.pname};
      in {
        all-haskell = pkgs.linkFarm "all-haskell"
          (pkgs.lib.filterAttrs (name: _: usableMap.${name}) pkgs.haskellPackages);
      };
    };
  };
}
