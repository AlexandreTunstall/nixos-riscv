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
        hadrian = hsLib.disableCabalFlag "threaded" (hsLib.appendPatches [
          (self.fetchpatch {
            name = "enable-ghci.patch";
            url = "https://gitlab.haskell.org/ghc/ghc/-/commit/dd38aca95ac25adc9888083669b32ff551151259.patch";
            hash = "sha256-xqs6mw/akxMy+XmVabACzsIviIKP4fS0UEgTk0HJcIc=";
            stripLen = 1;
          })
        ] ghc.hadrian);
      };

      overrides = self: super: {
        # Profiling is disabled for GHC on RISC-V due to size constraints
        mkDerivation = args: super.mkDerivation ({
          enableLibraryProfiling = false;
        } // args);

        # LLVM segfaults in one of the happy tests
        happy = hsLib.dontCheck super.happy;
      };

    in {
      haskell = super.haskell // {
        compiler = {
          ghc948Boot = mkBootCompiler {
            drv = boot."ghc-9.4.8";
            llvmPackages = self.llvmPackages_15;
          };

          ghc966 = (withPatchedHadrian (super.haskell.compiler.ghc966.override {
            bootPkgs = self.haskell.packages.ghc948Boot;
            llvmPackages = self.llvmPackages_15;
          })).overrideAttrs ({ patches ? [], ... }: {
            patches = patches ++ [
              (self.fetchpatch {
                name = "enable-ghci-hadrian.patch";
                url = "https://gitlab.haskell.org/ghc/ghc/-/commit/c5e47441ab2ee2568b5a913ce75809644ba83271.patch";
                hash = "sha256-t3KkuME6IqLWuESIMZ7OVAFu7s8G+x0ev+aVzBUqkhg=";
              })
            ];
          });

          ghc96 = self.haskell.compiler.ghc966;
        };

        packages = {
          inherit (super.haskell.packages) ghc96;

          ghc966 = super.haskell.packages.ghc966.override {
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
