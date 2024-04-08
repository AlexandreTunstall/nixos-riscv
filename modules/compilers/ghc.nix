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
        hashable = hsLib.dontCheck super.hashable;
        optparse-applicative = hsLib.dontCheck super.optparse-applicative;
        QuickCheck = hsLib.dontCheck super.QuickCheck;
        temporary = hsLib.dontCheck super.temporary;
        vector = hsLib.dontCheck super.vector;
      };

      unregOverrides = self: super: {
        extra = hsLib.dontCheck super.extra;
        unordered-containers = hsLib.dontCheck super.unordered-containers;
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

    in {
      haskell = super.haskell // {
        compiler = {
          ghc8107Boot = mkBootCompiler {
            drv = boot."ghc-8.10.7";
            llvmPackages = self.llvmPackages_12;
          };

          ghc928 = (super.haskell.compiler.ghc928.override {
            bootPkgs = self.haskell.packages.ghc8107Boot;
            # LLVM 12 is the highest supported, but it is broken.
            # GHC doesn't really use LLVM anyway, because it is unregisterised.
            llvmPackages = self.llvmPackages_15;
            buildTargetLlvmPackages = self.pkgsBuildTarget.llvmPackages_15;
          }).overrideAttrs ({ configureFlags ? [], passthru ? {}, ... }: {
            configureFlags = configureFlags ++ [ "--enable-unregisterised" ];

            passthru = passthru // {
              hasThreadedRuntime = false;
            };
          });

          ghc92 = self.haskell.compiler.ghc928;

          ghc964 = (withPatchedHadrian (super.haskell.compiler.ghc964.override {
            bootPkgs = self.haskell.packages.ghc928;
            llvmPackages = self.llvmPackages_15;
          })).overrideAttrs ({ patches, ... }: {
            patches = patches ++ [
              (self.fetchpatch {
                name = "enable-ghci-hadrian.patch";
                url = "https://gitlab.haskell.org/ghc/ghc/-/commit/c5e47441ab2ee2568b5a913ce75809644ba83271.patch";
                hash = "sha256-t3KkuME6IqLWuESIMZ7OVAFu7s8G+x0ev+aVzBUqkhg=";
              })
            ];
          });

          ghc96 = self.haskell.compiler.ghc964;
        };

        packages = {
          inherit (super.haskell.packages) ghc964 ghc96;

          ghc8107Boot = mkBootPackages {
            base = super.haskell.packages.ghc8107;
            ghc = self.pkgsBuildHost.haskell.compiler.ghc8107Boot;
          };

          ghc928 = super.haskell.packages.ghc928.override (old: {
            overrides = unregOverrides;
          });

          ghc92 = self.haskell.packages.ghc928;
        };
      };
    })
  ];
}
