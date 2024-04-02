self: super: let
  dontCheck = drv: drv.overrideAttrs (old: {
    doCheck = false;
  });

in {
  # See https://github.com/catchorg/Catch2/issues/2808
  # Fixed by https://github.com/NixOS/nixpkgs/pull/295243
  catch2_3 = super.catch2_3.overrideAttrs ({ NIX_CFLAGS_COMPILE ? "", ... }: {
    NIX_CFLAGS_COMPILE = "${NIX_CFLAGS_COMPILE} -Wno-error=cast-align";
  });

  libbsd = dontCheck super.libbsd;
  libuv = dontCheck super.libuv;
  pixman = dontCheck super.pixman;
}
