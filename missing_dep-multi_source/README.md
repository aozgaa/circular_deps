# missing_dep-multi_source

This scenario extends `missing_dep-one_source` by splitting `A` across multiple translation
units (`a1.cpp` and `a2.cpp`).  The missing `B -> A` dependency is now observable: `libA.a` no
longer contains `a2()` in the same object file as `a1()`, so the link line that omits `A` after
`B` fails to resolve the symbol.

## Expected failure

```
env A_KIND=STATIC B_KIND=STATIC cmake -S . -B build
cmake --build build
```

The build fails during the final link step:

```
/usr/bin/ld: libB.a(b.cpp.o): in function `b()':
b.cpp:(.text+0x9): undefined reference to `a2()'
collect2: error: ld returned 1 exit status
```

Re-introducing `target_link_libraries(B PUBLIC A)` or adjusting the library order resolves the
issue, but the aim here is to highlight how seemingly harmless refactors (splitting files or
enabling IPO/LTO) expose the missing dependency.
