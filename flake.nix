{
  inputs = {
    linux-vf2-src = {
      flake = false;
      url = "github:starfive-tech/linux?ref=JH7110_VisionFive2_upstream";
    };

    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-ghc-cross.url = "github:sternenseemann/nixpkgs?ref=ghc-cross";
  };

  outputs = { self, linux-vf2-src, nixpkgs, nixpkgs-ghc-cross }: {
    overlays.default = self: super: {
      linuxPackages_vf2 = self.linuxPackagesFor self.linux-vf2;
      linux-vf2 = self.callPackage ./pkgs/linux.nix {
        src = linux-vf2-src;
      };
    };

    overlays.riscv-fixes = import ./overlays/riscv-fixes.nix;

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          # Needs to be built on x86_64-linux and copied to the RISC-V host
          boot = self.packages.x86_64-linux.boot.entries;
        };

        modules = [
          ({ ... }: {
            nixpkgs.overlays = [ self.overlays.default self.overlays.riscv-fixes ];
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
          "ghc-9.4.8" = nixpkgs-ghc-cross.legacyPackages.x86_64-linux.pkgsCross.riscv64.haskell.compiler.native-bignum.ghc948;
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
          # Needs openjdk (unsuppported)
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
