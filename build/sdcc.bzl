SdccInfo = provider(
  doc = "Information on how to invoke the SDCC compiler for CPM",
  fields = [
    "assembler",
    "compiler",
    "crt0",
    "deps",
    "hextocom",
    "includes",
    "libs",
    "linker",
    "preprocessor",
  ],
)

def _sdcc_z180_c_binary_impl(ctx):
    info = ctx.toolchains["//build:toolchain_type_sdcc_z180"].sdccinfo
    out_name = "{}.ihx".format(ctx.label.name)
    ihx_file = ctx.actions.declare_file("{}.ihx".format(ctx.label.name))
    out_name = "{}".format(ihx_file.path)
    compiler = info.compiler.files.to_list()[0]
    runfiles_inputs, _, input_manifests = ctx.resolve_command(
        tools = [
            info.compiler,
            info.preprocessor,
            info.hextocom,
            info.assembler,
            info.linker,
       ])

    # Add libs and library directories
    libs = info.libs
    all_libs_files = [file.path for file in libs.files.to_list()]
    dirs = []
    lib_args = []
    for file in libs.files.to_list():
        dirname = file.dirname
        basename = file.basename
        if not dirname in dirs:
            lib_args += ["-L", dirname]
            dirs += [dirname]
        lib_args += ["-l", basename]

    # Add all needed include files.
    includes = info.includes
    all_incl_files = [file.path for file in includes.files.to_list()]
    dirs = []
    incl_args = []
    for file in includes.files.to_list():
        dirname = file.dirname
        if not dirname in dirs:
            incl_args += ["-I", dirname]
            dirs += [dirname]

    # continue building
    source_files = []
    for source in ctx.attr.srcs:
        files = source.files.to_list()
        source_files += files
    sources = [file.path for file in source_files]
    all_args = [
          "--no-std-crt0",
          "-mz180",
          # Once crt0.s is available, this can go.
          "--code-loc", "0x100",
    ] + lib_args + incl_args + [
          "-o",
          out_name,
    ] + sources
    ctx.actions.run(
        outputs = [
            ihx_file,
            ctx.actions.declare_file("{}.rel".format(ctx.label.name)),
            ctx.actions.declare_file("{}.sym".format(ctx.label.name)),
            ctx.actions.declare_file("{}.asm".format(ctx.label.name)),
            ctx.actions.declare_file("{}.lst".format(ctx.label.name)),
        ],
        inputs = runfiles_inputs + source_files + libs.files.to_list() + includes.files.to_list(),
        executable = compiler,
        input_manifests = input_manifests,
        arguments = all_args,
    )
    com_file = ctx.actions.declare_file("{}.com".format(ctx.label.name))
    hextocom = info.hextocom.files.to_list()[0]
    ctx.actions.run(
        outputs = [com_file],
        inputs = [ihx_file],
        executable = hextocom,
        arguments = [
          ihx_file.path,
          com_file.path,
        ],
    )
    return [
        DefaultInfo(files=depset([com_file]))
    ]

sdcc_z180_c_binary = rule(
    implementation = _sdcc_z180_c_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
    toolchains = [ "//build:toolchain_type_sdcc_z180"]
)

def _sdcc_z180_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        sdccinfo = SdccInfo(
            compiler = ctx.attr.compiler,
            linker = ctx.attr.linker,
            assembler = ctx.attr.assembler,
            preprocessor = ctx.attr.preprocessor,
            hextocom = ctx.attr.hextocom,
            libs = ctx.attr.libs,
            includes = ctx.attr.includes,
        )
    )
    return [toolchain_info]

sdcc_z180_toolchain = rule(
  implementation = _sdcc_z180_toolchain_impl,
  attrs = {
    "compiler": attr.label(
      allow_files = True,
      cfg = "host",
      executable = True,
    ),
    "linker": attr.label(
      allow_files = True,
      cfg = "host",
      executable = True,
    ),
    "assembler": attr.label(
      allow_files = True,
      cfg = "host",
      executable = True,
    ),
    "preprocessor": attr.label(
      allow_files = True,
      cfg = "host",
      executable = True,
    ),
    "hextocom": attr.label(
      cfg = "host",
      executable = True,
    ),
    "libs": attr.label(
      cfg = "host",
    ),
    "includes": attr.label(
      cfg = "host",
    ),
    "crt0": attr.label(
      allow_files = True,
      cfg = "host",
      executable = False,
    ),
    "deps": attr.label_list(),
  },
)
