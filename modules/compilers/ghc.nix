{ boot, lib, ... }:

{
  nixpkgs.overlays = lib.mkBefore [
    (self: super: let
      mkBootCompiler = { drv, llvmPackages }: drv.overrideAttrs ({ passthru ? {}, ... }: {
        passthru = passthru // {
          inherit llvmPackages;
        };
      });

      mkBootPackages = { base, ghc }: let
        buildHaskellPackages = base.override (old: {
          inherit buildHaskellPackages ghc;

          overrides = bootOverrides;
        });
      in buildHaskellPackages;

      hsLib = self.haskell.lib.compose;

      bootOverrides = self: super: {
        mkDerivation = args: super.mkDerivation ({
          enableLibraryProfiling = false;
        } // args);

        alex = hsLib.dontCheck super.alex;
        data-array-byte = hsLib.dontCheck super.data-array-byte;
        doctest = hsLib.dontCheck super.doctest;
        extra = hsLib.dontCheck super.extra;
        hashable = hsLib.dontCheck super.hashable;
        optparse-applicative = hsLib.dontCheck super.optparse-applicative;
        QuickCheck = hsLib.dontCheck super.QuickCheck;
        temporary = hsLib.dontCheck super.temporary;
        unordered-containers = hsLib.dontCheck super.unordered-containers;
        vector = hsLib.dontCheck super.vector;
      };

      # There is no neater way of overriding Hadrian
      withPatchedHadrian = ghc: ghc.override {
        hadrian = hsLib.disableCabalFlag "threaded" (hsLib.doJailbreak ghc.hadrian);
      };

      overrides = self: super: {
        # Profiling is disabled for GHC on RISC-V due to size constraints
        mkDerivation = args: super.mkDerivation ({
          enableLibraryProfiling = false;
        } // args);

        # LLVM segfaults in one of the happy tests
        happy = hsLib.dontCheck super.happy;

        # Test suite uses inspection-testing, which is marked broken
        optics = hsLib.dontCheck super.optics;
      };

    in {
      haskell = super.haskell // {
        compiler = {
          ghc948Boot = mkBootCompiler {
            drv = boot."ghc-9.4.8";
            llvmPackages = self.llvmPackages_15;
          };

          ghc984 = withPatchedHadrian (super.haskell.compiler.ghc984.override {
            bootPkgs = self.haskell.packages.ghc948Boot;
          });

          ghc9103 = withPatchedHadrian (super.haskell.compiler.ghc9103.override {
            bootPkgs = self.haskell.packages.ghc984;
          });

          ghc98 = self.haskell.compiler.ghc984;
          ghc910 = self.haskell.compiler.ghc9103;
        };

        packages = {
          inherit (super.haskell.packages) ghc98 ghc910;

          ghc984 = super.haskell.packages.ghc984.override {
            # GHC 9.8 does not have the interpreter enabled.
            # We could apply the patch below, but it would slow down the build
            # and we only care about being able to build later versions of GHC.
            # https://gitlab.haskell.org/ghc/ghc/-/commit/dd38aca95ac25adc9888083669b32ff551151259.patch
            overrides = bootOverrides;
          };

          ghc9103 = super.haskell.packages.ghc9103.override {
            inherit overrides;
          };

          ghc948Boot = mkBootPackages {
            base = super.haskell.packages.ghc948;
            ghc = self.pkgsBuildHost.haskell.compiler.ghc948Boot;
          };
        };
      };
    })
  ];
}
