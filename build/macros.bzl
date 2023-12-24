def tim011_emu_run(
        name,
        image,
        slowdown = True,
        debug = "",
        sleep = "5",
        program = "",
        romdir = "@mame_docker//:romdir"):
    sd = "false"
    if slowdown:
        sd = "true"
    native.sh_binary(
        name = name,
        srcs = ["//build:tim011_run_sh"],
        data = [
            "@gotopt2//cmd/gotopt2",
            image,
            romdir,
        ],
        visibility = ["//visibility:public"],
        deps = [
            "@bazel_tools//tools/bash/runfiles",
        ],
        args = [
            "--img-file",
            "$(location {})".format(image),
            "--rom-directory",
            "$(location {})".format(romdir),
            "--program-name",
            program,
            "--slowdown={}".format(sd),
            "--debug={}".format(debug),
            "--sleep={}".format(sleep),
        ],
    )
