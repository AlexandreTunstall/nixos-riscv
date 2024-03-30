This configuration is written to be natively compiled for VisionFive2 boards.
It might not work on other RISC-V systems.

# Obtaining Boot Compilers

Building the system requires self-hosting compilers that Nixpkgs is not yet able
to bootstrap on RISC-V.

On an `x86_64-linux` host, run the following command.

```sh
nix copy --to ssh:root@$riscv_host --no-check-sigs .#boot
```

This will cross-compile the needed compilers and copy them to `$riscv_host`.
If done correctly, the build will no longer fail with "don't know how to build
`x86_64-linux`"
