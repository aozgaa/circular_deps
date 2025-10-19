# Circular Dependencies

This repo collects several small scenarios highlighting circular-dependency pathologies with CMake
and static libraries.

Each scenario is placed in a self-contained subdirectory:

- `cmake_lib_kinds/` – explores how different target types influence CMake’s
  ability to configure a (symmetric) circular dependency.
- `missing_dep-one_source/` – removes the `B -> A` link but keeps `A` in a single translation
  unit, so the static link still succeeds.
- `missing_dep-multi_source/` – splits `A` into multiple translation units, exposing the missing
  dependency during static linking via an `undefined reference`.

# Building

Once a toolchain is available you can build any scenario with a standard CMake invocation. All
projects *require* the environment variables `A_KIND` and `B_KIND` to be set before configuration;
each variable selects whether the corresponding library (`A` or `B`) is built as `STATIC`, `SHARED`,
or `OBJECT`. For example, to configure the `cmake_lib_kinds` project:

```
env A_KIND=STATIC B_KIND=STATIC cmake -S cmake_lib_kinds -B build
cmake --build build
```

## Presets

The file `presets/CMakePresets.json` holds reusable configure/build combinations. Each scenario
directory exposes it via a symlink, so you can run the same presets everywhere. Configure commands
must always provide a build directory with `-B …`, and presets assume you choose a compiler (for
example via `pixi run -- env CC=clang ...`).

### Baseline (all compilers)

````text
A_KIND=STATIC B_KIND=STATIC cmake --preset base -S cmake_lib_kinds -B build/kinds-base
cmake --build build/kinds-base
````
Adds `-Wall -Wextra -Werror` to the C++ build.

### IPO / LTO (Clang)

````text
A_KIND=STATIC B_KIND=STATIC cmake --preset ipo-clang -S cmake_lib_kinds -B build/kinds-ipo-clang
cmake --build build/kinds-ipo-clang
````
Inherits the baseline warnings, enables `CMAKE_INTERPROCEDURAL_OPTIMIZATION`, and forces Clang’s
linker driver to use `lld` so the LLVM LTO plugin is present.

### IPO / LTO (GCC)

````text
A_KIND=STATIC B_KIND=STATIC cmake --preset ipo-gcc -S cmake_lib_kinds -B build/kinds-ipo-gcc
cmake --build build/kinds-ipo-gcc
````
Inherits the baseline warnings and enables `CMAKE_INTERPROCEDURAL_OPTIMIZATION` while keeping GCC’s
default linker.

## Reproducible environment via `pixi-build`

Install [pixi-build](https://pixi.sh/latest/installation/) and run:

```
pixi install
```

The `pixi.toml` manifest provides CMake, Ninja, Clang, GCC, and related tools. Example usage with a
preset:

```
pixi run -- env CC=clang CXX=clang++ A_KIND=STATIC B_KIND=STATIC cmake --preset base -S cmake_lib_kinds -B build/kinds-base
pixi run -- cmake --build build/kinds-base
```

You can also launch `pixi shell` to obtain an interactive environment before invoking CMake
manually.

Run `./test_combinations.sh --results <csv>` to sweep library-kind pairings across every scenario and record configure/build/run success/failure.
