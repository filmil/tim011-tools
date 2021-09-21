#! /bin/bash

# This will have to do until I implement "bazel run"

bazel build //...

cd ./bazel-bin/tests/hello
../../CPMEmulator/cpm hello

echo "This was a quick TIM 011 demo.  It will be replaced by a proper bazel run command"
