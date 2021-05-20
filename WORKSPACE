workspace(name = "tim011_tools")

register_toolchains("//build:barc_linux_toolchain")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

new_git_repository(
  name = "mescc",
  remote = "https://github.com/MiguelVis/mescc",
  commit = "762ac3ba1c020352223831bc9faf26d57ecb5b8a",
  build_file = "//third_party/mescc:BUILD.bazel.mescc",
)

