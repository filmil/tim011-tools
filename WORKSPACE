workspace(name = "tim011_tools")

register_toolchains(
    "//build:mescc_linux_toolchain",
)

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository", "git_repository")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "69de5c704a05ff37862f7e0f5534d4f479418afc21806c887db544a316f3cb6b",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.27.0/rules_go-v0.27.0.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.27.0/rules_go-v0.27.0.tar.gz",
    ],
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "62ca106be173579c0a167deb23358fdfe71ffa1e4cfdddf5582af26520f1c66f",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.23.0/bazel-gazelle-v0.23.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.23.0/bazel-gazelle-v0.23.0.tar.gz",
    ],
)

http_archive(
    name = "sdcc-linux",
    sha256 = "457bd88adefca41798b9415f7656b3bdd9cddb6962bc16193497c4b95546abc0",
    type = "tar.bz2",
    urls = [
        "http://sourceforge.net/projects/sdcc/files/snapshot_builds/amd64-unknown-linux2.5/sdcc-snapshot-amd64-unknown-linux2.5-20210827-12654.tar.bz2/download",
    ],
    build_file = "//third_party/sdcc:BUILD.bazel.sdcc",
)

register_toolchains(
    "//build:sdcc_z180_linux_toolchain",
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.16")

gazelle_dependencies()

new_git_repository(
  name = "mescc",
  remote = "https://github.com/MiguelVis/mescc",
  commit = "762ac3ba1c020352223831bc9faf26d57ecb5b8a",
  build_file = "//third_party/mescc:BUILD.bazel.mescc",
  shallow_since = "1610562846 +0100",
)

git_repository(
    name = "bazel_bats",
    remote = "https://github.com/filmil/bazel-bats",
    commit = "78da0822ea339bd0292b5cc0b5de6930d91b3254",
    shallow_since = "1569564445 -0700",
)

git_repository(
    name = "gotopt2",
    remote = "https://github.com/filmil/gotopt2",
    commit = "6eeeeb74c6dcd1a94a0daccccbda09b3ba7b2e51",
    shallow_since = "1593765180 -0700",
)

load("@gotopt2//build:deps.bzl", "gotopt2_dependencies")
gotopt2_dependencies()
