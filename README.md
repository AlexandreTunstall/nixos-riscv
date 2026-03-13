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

# Memory Constraints

While building, some packages may require a significant amount of memory.
In particular, `clang` builds tend to require all available memory near the end
of the `buildPhase`.

For these builds, use `-j1 --cores 1` to avoid OoM kills.
These flags will reduce the level of parallelism, so it comes at the cost of
taking longer to build.
