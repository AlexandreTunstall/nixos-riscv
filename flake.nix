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

    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      boot = pkgs.linkFarm "boot" {
        "ghc-9.4.8" = nixpkgs-ghc-cross.legacyPackages.x86_64-linux.pkgsCross.riscv64.haskell.compiler.native-bignum.ghc948;
      };
    };
  };
}
