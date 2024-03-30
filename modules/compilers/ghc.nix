{ boot, ... }:

{
  nixpkgs.overlays = [
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

      unregOverrides = self: super: { };

    in {
      haskell = super.haskell // {
        compiler = {
          ghc8107Boot = mkBootCompiler {
            drv = boot."ghc-8.10.7";
            llvmPackages = self.llvmPackages_12;
          };

          ghc928 = (super.haskell.compiler.ghc928.override {
            bootPkgs = self.haskell.packages.ghc8107Boot;
          }).overrideAttrs ({ configureFlags ? [], passthru ? {}, ... }: {
            configureFlags = configureFlags ++ [ "--enable-unregisterised" ];

            passthru = passthru // {
              hasThreadedRuntime = false;
            };
          });

          ghc92 = self.haskell.compiler.ghc928;

          ghc964 = super.haskell.compiler.ghc964.override {
            bootPkgs = self.haskell.packages.ghc928;
            llvmPackages = self.llvmPackages_15;
          };

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