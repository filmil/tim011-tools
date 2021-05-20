BarcInfo = provider(
    doc = "Information about how to invoke the barc compiler.",
    # In the real world, compiler_path and system_lib might hold File objects,
    # but for simplicity they are strings for this example. arch_flags is a list
    # of strings.
    fields = ["compiler_path", "system_lib", "arch_flags"],
)

def _bar_binary_impl(ctx):
    info = ctx.toolchains["//build:toolchain_type"].barcinfo
    outfile = ctx.actions.declare_file("yoda.txt")
    inputs = ctx.attr.srcs[0].files.to_list()

    command = "%s -l %s %s %s" % (
        info.compiler_path,
        info.system_lib,
        " ".join(info.arch_flags),
        " ".join([x.path for x in inputs]),
    )
    command = "echo '{cmd}' > {out}".format(cmd=command,out=outfile.path)

    print(info)
    print(inputs)
    print(outfile)
    print(command)
    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [outfile],
        command = command,
    )
    return [DefaultInfo(files=depset([outfile]))]

bar_binary = rule(
    implementation = _bar_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
    toolchains = ["//build:toolchain_type"]
)

def _bar_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        barcinfo = BarcInfo(
            compiler_path = ctx.attr.compiler_path,
            system_lib = ctx.attr.system_lib,
            arch_flags = ctx.attr.arch_flags,
        ),
    )
    return [toolchain_info]

bar_toolchain = rule(
    implementation = _bar_toolchain_impl,
    attrs = {
        "compiler_path": attr.string(),
        "system_lib": attr.string(),
        "arch_flags": attr.string_list(),
    },
)

