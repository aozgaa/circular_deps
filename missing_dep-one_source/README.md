# missing_dep-one_source

This scenario removes the explicit `B -> A` dependency while keeping every implementation in a
single translation unit.  Because the entire implementation of `A` lives inside `src/a.cpp`, the
static archive `libA.a` still carries both `a1()` and `a2()`.  When `main` links against both `A`
and `B`, the undefined `a2()` reference from `B` is satisfied even though `B` never advertises a
link requirement on `A`.

## Build

```
env A_KIND=STATIC B_KIND=STATIC cmake -S . -B build
cmake --build build
```

Run the resulting executable with:

```
./build/main
```

Even though this setup is technically missing a dependency edge, the build succeeds.  The
`missing_dep-multi_source` project shows why this becomes fragile as soon as the implementation is
split across files.
