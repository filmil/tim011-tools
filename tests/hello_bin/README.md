An example self-contained binary.

Compile with:

```
bazel build //tests/hello_bin
```

The executable will be in
`$WORKSPACE_DIR/bazel-bin/tests/hello_bin/hello_bin.com`.  The directory
`$WORKSPACE_DIR/bazel-bin/tests/hello_bin` will contain other outputs and
report files produced by SDCC.

## What doesn't work

* Compiling multiple files correctly. SDCC can compile only one source file at
  a time.  So, a multi-file binary will need to compile each file into its
  own `.rel`,  and then link them together.
* Dependencies.  Stay tuned.
