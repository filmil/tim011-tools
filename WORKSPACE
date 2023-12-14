workspace(name = "tim011_tools")

register_toolchains(
    "//build:mescc_linux_toolchain",
)

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
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
    build_file = "//third_party/sdcc:BUILD.bazel.sdcc",
    strip_prefix = "sdcc-4.3.0",
    type = "tar.bz2",
    urls = [
        "https://sourceforge.net/projects/sdcc/files/sdcc-linux-amd64/4.3.0/sdcc-4.3.0-amd64-unknown-linux2.5.tar.bz2/download",
    ],
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
    build_file = "//third_party/mescc:BUILD.bazel.mescc",
    commit = "762ac3ba1c020352223831bc9faf26d57ecb5b8a",
    remote = "https://github.com/MiguelVis/mescc",
    shallow_since = "1610562846 +0100",
)

git_repository(
    name = "bazel_bats",
    commit = "78da0822ea339bd0292b5cc0b5de6930d91b3254",
    remote = "https://github.com/filmil/bazel-bats",
    shallow_since = "1569564445 -0700",
)

git_repository(
    name = "gotopt2",
    commit = "6eeeeb74c6dcd1a94a0daccccbda09b3ba7b2e51",
    remote = "https://github.com/filmil/gotopt2",
    shallow_since = "1593765180 -0700",
)

load("@gotopt2//build:deps.bzl", "gotopt2_dependencies")

gotopt2_dependencies()

http_archive(
    name = "cpmtools",
    build_file = "//third_party/cpmtools:BUILD.bazel.cpmtools",
    patch_args = ["-p1"],
    patches = [
        "//third_party/cpmtools:0001-fix-patch-diskdefs-for-tim011.patch",
    ],
    sha256 = "7839b19ac15ba554e1a1fc1dbe898f62cf2fd4db3dcdc126515facc6b929746f",
    strip_prefix = "cpmtools-2.23",
    type = ".tar.gz",
    urls = [
        "http://www.moria.de/~michael/cpmtools/files/cpmtools-2.23.tar.gz",
    ],
)

http_archive(
    name = "rules_foreign_cc",
    sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
    strip_prefix = "rules_foreign_cc-0.9.0",
    url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.9.0.tar.gz",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

new_git_repository(
    name = "zztim",
    build_file = "//third_party/zztim:BUILD.bazel.zztim",
    commit = "74a1d747535c4b052a6cbc9d59532029f60642f9",
    patch_args = ["-p1"],
    patches = [
        "//third_party/zztim:0001-fix-patch-for-bazel.patch",
    ],
    remote = "https://bitbucket.org/zzarko/tim011-tools",
    shallow_since = "1656647455 +0000",
)

# Hermetic Python.

rules_python_version = "93f5ea2f01ce7eb870d3ad3943eda5d354cdaac5"

http_archive(
    name = "rules_python",
    sha256 = "179541b519e8fd7c8fbfd0d2a2a51835cf7c83bd6a8f0f3fd599a0910d1a0981",
    strip_prefix = "rules_python-{}".format(rules_python_version),
    url = "https://github.com/bazelbuild/rules_python/archive/{}.zip".format(rules_python_version),
)

load("@rules_python//python:repositories.bzl", "py_repositories", "python_register_toolchains")

py_repositories()

python_register_toolchains(
    name = "python3_9",
    python_version = "3.9",
)

load("@python3_9//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_install", "pip_parse")

pip_parse(
    name = "pypi",
    python_interpreter_target = interpreter,
    requirements_lock = "//third_party:requirements_lock.txt",
)

load("@pypi//:requirements.bzl", "install_deps")

install_deps()

# Build tools.

http_archive(
    name = "com_google_protobuf",
    sha256 = "3bd7828aa5af4b13b99c191e8b1e884ebfa9ad371b0ce264605d347f135d2568",
    strip_prefix = "protobuf-3.19.4",
    urls = [
        "https://github.com/protocolbuffers/protobuf/archive/v3.19.4.tar.gz",
    ],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "ae34c344514e08c23e90da0e2d6cb700fcd28e80c02e23e4d5715dddcb42f7b3",
    strip_prefix = "buildtools-4.2.2",
    urls = [
        "https://github.com/bazelbuild/buildtools/archive/refs/tags/4.2.2.tar.gz",
    ],
)


# MAME emulator for TIM-011
new_git_repository(
    name = "mame_docker",
    build_file = "//third_party/mame-docker:BUILD.bazel.mame-docker",
    remote = "https://github.com/filmil/mame-docker",
    commit = "f06cee32d2079f10f826624a3fceb8dc55f09c75",
)


# C runtime library for CPM
new_git_repository(
    name = "libcpm3",
    build_file = "//third_party/libcpm3-z80:BUILD.bazel.libcpm3-z80",
    remote = "https://github.com/retro-vault/libcpm3-z80",
    commit = "982aad86671e01f11d5ad8c59dda0312832c1faf",
    patch_args = ["-p1"],
    patches = [
        "//third_party/libcpm3-z80:0001-fix-check-after-defining-the-binaries.patch",
    ],
    # for lib/libsdcc-z80
    init_submodules = True,
)

