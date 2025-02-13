self: super: let
  dontCheck = drv: drv.overrideAttrs (old: {
    doCheck = false;
  });

  pyDontCheck = drv: drv.overridePythonAttrs (old: {
    doCheck = false;
  });

  hsLib = self.haskell.lib.compose;

in {
  haskell = super.haskell // {
    packages = super.haskell.packages // {
      ghc964 = super.haskell.packages.ghc964.override {
        overrides = hsSelf: hsSuper: {
          # enableSeparateBinOutput causes cyclic references in build outputs
          mkDerivation = self.lib.makeOverridable (args: hsSuper.mkDerivation (args // {
            enableSeparateBinOutput = false;
          }));
          # Tests fail
          happy = hsLib.dontCheck hsSuper.happy;
        };
      };
    };
  };

  libbsd = dontCheck super.libbsd;
  libuv = dontCheck super.libuv;

  # Fails in ./configure when LuaJIT isn't available
  neovim-unwrapped = super.neovim-unwrapped.overrideAttrs ({ preConfigure ? "", ... }: {
    preConfigure = ''
      ${preConfigure}
      cmakeFlagsArray+=( -DPREFER_LUA=ON )
    '';
  });

  pixman = dontCheck super.pixman;
  protobuf = dontCheck super.protobuf;
  
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pySelf: pySuper: {
      sphinx = pyDontCheck pySuper.sphinx;
    })
  ];
}
