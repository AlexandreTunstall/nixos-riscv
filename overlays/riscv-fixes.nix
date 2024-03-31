self: super: let
  dontCheck = drv: drv.overrideAttrs (old: {
    doCheck = false;
  });

in {
  libbsd = dontCheck super.libbsd;
  libuv = dontCheck super.libuv;
  pixman = dontCheck super.pixman;
}
