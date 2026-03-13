self: super: let
  dontCheck = drv: drv.overrideAttrs (old: {
    doCheck = false;
  });

  dontInstallCheck = drv: drv.overrideAttrs (old: {
    doInstallCheck = false;
  });

  pyDontCheck = drv: drv.overridePythonAttrs (old: {
    doCheck = false;
  });

in {
  libbsd = dontCheck super.libbsd;
  libuv = dontCheck super.libuv;

  luajit_2_1 = (super.luajit_2_1.overrideAttrs (old: {
    version = "2.1.1770278820-plctlab-riscv64";

    src = old.src.override {
      rev = "e12d41f20f8d103e622c394b66a0d3c84925fcb8";
      hash = "sha256-3xEl2LRnlPYex+qFJzy4PcxoK2krA6d3jaYXFy16p+w=";
    };

    meta = old.meta // {
      badPlatforms = builtins.filter (p: p != "riscv64-linux") old.meta.badPlatforms;
    };
  })).override (old: {
    passthruFun = args: old.passthruFun (args // {
      self = self.luajit_2_1;
    });
  });

  meson = dontInstallCheck super.meson;

  mimalloc = dontCheck super.mimalloc;

  pixman = dontCheck super.pixman;
  protobuf = dontCheck super.protobuf;
  
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pySelf: pySuper: {
      mypy = pyDontCheck pySuper.mypy;

      numpy = pySuper.numpy.overrideAttrs {
        dontUsePytestCheck = true;
      };

      pytest-timeout = pyDontCheck pySuper.pytest-timeout;
      sphinx = pyDontCheck pySuper.sphinx;
    })
  ];
}
