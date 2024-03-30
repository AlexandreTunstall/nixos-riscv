self: super: let
  dontCheck = drv: drv.overrideAttrs (old: {
    doCheck = false;
  });

in {
  libuv = dontCheck super.libuv;
  pixman = dontCheck super.pixman;
}
