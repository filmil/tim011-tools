MesccInfo = provider(
    doc = "Information on how to invoke the mscc compiler for CP/M",
    fields = [
       "compiler",
       "deps",
    ],
)

def _mescc_binary_impl(ctx):
    info = ctx.toolchains["//build:toolchain_type_mescc"].mesccinfo
    out_name = "{}.com".format(ctx.label.name)
    out_file = ctx.actions.declare_file(out_name)
    compiler = info.compiler.files.to_list()[1]
    runfiles_inputs, _, input_manifests = ctx.resolve_command(
         tools = [info.compiler])
    source = ctx.attr.srcs[0].files.to_list()[0]
    print("source: {}".format(source.basename))
    deps = []
    include_files = []
    for target in ctx.attr.deps:
        for file in target.files.to_list():
            deps += [file]
            include_files += [file.path]
    print("deps: {}".format(deps))
    print("include_files: {}".format(include_files))
    ctx.actions.run(
      outputs = [out_file],
      inputs = runfiles_inputs + [source] + deps,
      executable = compiler,
      input_manifests = input_manifests,
      arguments = [
        "--source-file={}".format(source.basename),
        "--source-path={}".format(source.path),
        "--include-files={}".format(",".join(include_files)),
        "--out-file={}".format(out_file.path),
      ],
    )
    return [
        DefaultInfo(files=depset([out_file])),
    ]

mescc_binary = rule(
    implementation = _mescc_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
    toolchains = ["//build:toolchain_type_mescc"],
)

def _mescc_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        mesccinfo = MesccInfo(
            compiler = ctx.attr.compiler,
        ),
    )
    return [toolchain_info]

mescc_toolchain = rule(
    implementation = _mescc_toolchain_impl,
    attrs = {
        "compiler": attr.label(
            cfg = "host",
            executable = True,
        ),
        "deps": attr.label_list(
        ),
    },
)
