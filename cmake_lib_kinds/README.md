# cmake_lib_kinds

This project parametrises the library kind of two circularly dependent libraries (see the root
README for the required environment variables). It reproduces the CMake configuration errors that
occur when the pair contains non-static libraries in a cycle.

## Configure and build

```
env A_KIND=STATIC B_KIND=STATIC cmake -S . -B build
cmake --build build
```

Try other combinations to see how CMake responds.  For example:

```
env A_KIND=STATIC B_KIND=OBJECT cmake -S . -B build-object
```

## CMake presets

The presets in `CMakePresets.json` apply consistent warning flags and optional IPO/LTO settings.
Invoke them from this directory, for example:

```
env A_KIND=STATIC B_KIND=STATIC cmake --preset base
cmake --build --preset base
```

## Scripted sweep

`./test_combinations.sh` iterates over the unique `{STATIC, OBJECT}` choices (ignoring symmetric
duplicates) and records whether configuration or compilation succeeds.  Sample output:

```
./test_combinations.sh
```
