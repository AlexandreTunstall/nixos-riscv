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

  # Fails in ./configure when LuaJIT isn't available
  neovim-unwrapped = super.neovim-unwrapped.overrideAttrs ({ preConfigure ? "", ... }: {
    preConfigure = ''
      ${preConfigure}
      cmakeFlagsArray+=( -DPREFER_LUA=ON )
    '';
  });

  pixman = dontCheck super.pixman;
}
