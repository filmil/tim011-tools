SdccInfo = provider(
    doc = "Information on how to invoke the SDCC compiler for CPM",
    fields = [
        "assembler",
        "compiler",
        "crt0",
        "deps",
        "hextocom",
        "objcopy",
        "includes",
        "librarian",
        "libs",
        "linker",
        "preprocessor",
        "runtime_libs",
    ],
)

SdccHeaders = provider(
    doc = "Transitive information about headers",
    fields = ["headers", "rels"],
)

CPMBinary = provider(
    doc = "Information about a generated CP/M binary",
    fields = ["binary"],
)

_SDCC_OPTIONS = [
    "-mz180",
    "--std-c11",
    # 16-bit I/O space of the HD64180
    "--codeseg",
    "CODE",
    "--dataseg",
    "CODE",
    "--constseg",
    "CODE",
    "--code-loc",
    "0x100",
    "--nostdinc",
    "--no-std-crt0",
    "--nostdlib",
]

# Declare all the interesting files that sdcc produces.
def declare_sdcc_extensions(declare_file_action, label_name, extensions):
    return [declare_file_action("{}.{}".format(label_name, extension)) for extension in extensions]

def resolve_command(ctx, info):
    runfiles_inputs, _, input_manifests = ctx.resolve_command(
        tools = [
            info.compiler,
            info.preprocessor,
            info.hextocom,
            info.assembler,
            info.linker,
            info.librarian,
            info.objcopy,
        ],
    )
    return (runfiles_inputs, input_manifests)

def get_compiler(info):
    return info.compiler.files.to_list()[0]

def get_assembler(info):
    return info.assembler.files.to_list()[0]

def get_librarian(info):
    return info.librarian.files.to_list()[0]

def get_lib_args(libs):
    dirs = []
    lib_args = []
    for file in libs.files.to_list():
        dirname = file.dirname
        basename = file.basename
        if not dirname in dirs:
            lib_args += ["-L", dirname]
            dirs += [dirname]
        lib_args += ["-l", basename]
    return lib_args

def get_incl_args(incls):
    dirs = []
    incl_args = ["-I", "."]
    for file in incls.files.to_list():
        dirname = file.dirname
        if not dirname in dirs:
            incl_args += ["-I", dirname]
            dirs += [dirname]
    return incl_args

# Extracts all headers from the dependencies, and the .rel files to use with
# the linker.
#
# Args:
#   deps: Target: a list of dependencies to extract the headers and the rel
#   files from.
def dep_and_rel(deps):
    dep_headers = []
    rel_files = []
    for dep in deps:
        if not SdccHeaders in dep:
            continue
        sdcc_headers = dep[SdccHeaders]
        dep_headers += sdcc_headers.headers.to_list()
        rel_files += sdcc_headers.rels.to_list()
    return (dep_headers, rel_files)

def get_sdcc_info(ctx):
    return ctx.toolchains["//build:toolchain_type_sdcc_z180"].sdccinfo

def get_declared_headers(ctx):
    declared_headers = []
    for target in ctx.attr.hdrs:
        files = target.files.to_list()
        declared_headers += files
    return declared_headers

def get_source_files(ctx):
    source_files = []
    for source in ctx.attr.srcs:
        files = source.files.to_list()
        source_files += files
    return source_files

def _sdcc_z180_c_library_impl(ctx):
    info = get_sdcc_info(ctx)
    compiler = get_compiler(info)
    runfiles_inputs, input_manifests = resolve_command(ctx, info)

    # Add libs and library directories
    libs = info.libs
    lib_args = []
    libs_files = []
    if libs:
        lib_args = get_lib_args(libs)
        libs_files = lib_args.files.to_list()

    # Add all needed include files.
    includes = info.includes
    incl_args = get_incl_args(includes)

    # Needs to add all include files and dirs from the dependencies.
    declared_headers = get_declared_headers(ctx)

    # continue building
    source_files = get_source_files(ctx)
    sources = [file.path for file in source_files]

    # TODO(filmil): Actually, each source file needs to be compiled individually.

    all_rel_files = []
    for source_file in source_files:
        # Compile each file to a .rel individually.
        single_rel_file = ctx.actions.declare_file("{}.rel".format(source_file.basename))
        all_rel_files += [single_rel_file]
        all_args = _SDCC_OPTIONS + [
            "--nostdinc",
        ] + lib_args + incl_args + [
            "-c",
            "-o",
            single_rel_file.path,
            source_file.path,
        ]
        ctx.actions.run(
            mnemonic = "SDCC",
            outputs = [single_rel_file] + declare_sdcc_extensions(
                ctx.actions.declare_file,
                source_file.basename,
                ["rel", "sym", "asm", "lst"],
            ),
            inputs = (runfiles_inputs + [source_file] + declared_headers + libs_files +
                      includes.files.to_list()),
            executable = compiler,
            input_manifests = input_manifests,
            arguments = all_args,
        )

    # Create a library.
    lib_file = ctx.actions.declare_file("{}.lib".format(ctx.label.name))
    ctx.actions.run(
        mnemonic = "LIB",
        outputs = [lib_file],
        inputs = all_rel_files,
        executable = get_librarian(info),
        input_manifests = input_manifests,
        arguments = [
            "-rc",
            lib_file.path,
        ] + [rel_file.path for rel_file in all_rel_files],
    )

    return [
        DefaultInfo(files = depset(all_rel_files + [lib_file])),
        SdccHeaders(headers = depset(declared_headers), rels = depset([lib_file])),
    ]

sdcc_z180_c_library = rule(
    implementation = _sdcc_z180_c_library_impl,
    attrs = {
        # This does not need to include any header files. Put headers in "hdrs".
        "srcs": attr.label_list(allow_files = True),
        # This should list all the headers defined by this library.
        "hdrs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
    toolchains = ["//build:toolchain_type_sdcc_z180"],
)

def _sdcc_z180_c_binary_impl(ctx):
    info = get_sdcc_info(ctx)
    ihx_file = ctx.actions.declare_file("{}.ihx".format(ctx.label.name))
    out_name = "{}".format(ihx_file.path)
    compiler = get_compiler(info)
    runfiles_inputs, input_manifests = resolve_command(ctx, info)

    # Add libs and library flags
    libs = info.libs
    lib_args = []
    libs_files = []
    if libs:
        lib_args = get_lib_args(libs)
        libs_files = lib_args.files.to_list()

    # Make a list of runtime libraries.
    runtime_libs_files = []
    runtime_libs = info.runtime_libs
    for rtlib_target in runtime_libs:
        runtime_libs_files += [f for f in rtlib_target.files.to_list()]
    runtime_libs_flags = []
    for file in runtime_libs_files:
        runtime_libs_flags += ["-l", file.path]

    # Add all needed include flags.
    includes = info.includes
    incl_args = get_incl_args(includes)

    deps_headers = []
    deps_rels = []
    for lib_target in ctx.attr.deps:
        provider = lib_target[SdccHeaders]
        deps_headers += provider.headers.to_list()
        deps_rels += provider.rels.to_list()
    deps_headers_files = [f.path for f in deps_headers]
    deps_rels_files = [f.path for f in deps_rels]
    deps_headers_dirs = [f.dirname for f in deps_headers]

    # Needs to add all include files and dirs from the dependencies.
    dep_headers, dep_rel_files = dep_and_rel(ctx.attr.deps)

    # C runtime library setup code. This should be placed at the beginning of
    # the program.
    crt0 = info.crt0.files.to_list()[0]

    ## First, build object files from the sources.
    obj_files = []
    for src_target in ctx.attr.srcs:
        for src_file in src_target.files.to_list():
            # Compile src_file here.
            obj = ctx.actions.declare_file("{}.rel".format(src_file.basename))
            obj_files += [obj]
            args = ctx.actions.args()
            args.add("-o", obj.path)
            args.add("-c", src_file.path)
            args.add_all(deps_rels_files, before_each = "-l")
            args.add_all(deps_headers_dirs, before_each = "-I")

            added_outputs = declare_sdcc_extensions(
                ctx.actions.declare_file,
                src_file.basename,
                ["rel", "sym", "asm", "lst"],
            )
            ctx.actions.run(
                progress_message = "compiling {}".format(src_file.basename),
                mnemonic = "SDCC",
                inputs = (
                    [src_file] +
                    dep_headers +
                    includes.files.to_list() +
                    deps_headers + deps_rels
                ),
                outputs = [obj] + added_outputs,
                executable = compiler,
                input_manifests = input_manifests,
                arguments = _SDCC_OPTIONS + incl_args + [args],
                tools = info.preprocessor.files.to_list() +
                        info.assembler.files.to_list(),
            )

    # continue building
    source_files = [crt0] + dep_rel_files + obj_files
    sources = [file.path for file in source_files]
    all_args = _SDCC_OPTIONS + runtime_libs_flags + [
    ] + lib_args + incl_args + [
        "-o",
        out_name,
    ] + sources

    linker_script = ctx.actions.declare_file("{}.lk".format(ctx.label.name))
    ctx.actions.run(
        mnemonic = "SDCClink1",
        progress_message = "linking 1 {}".format(ihx_file.basename),
        outputs = [linker_script],
        inputs = (runtime_libs_files + runfiles_inputs +
                  source_files +
                  dep_headers +
                  libs_files +
                  includes.files.to_list()),
        executable = compiler,
        input_manifests = input_manifests,
        arguments = all_args,
    )

    linker_script_2 = ctx.actions.declare_file("{}.2.lk".format(ctx.label.name))
    ctx.actions.run_shell(
        mnemonic = "SDCClink2",
        inputs = [linker_script],
        outputs = [linker_script_2],
        command = """\
            sed '/-b _DATA = 0x8000/d' {l1} > {l2}
        """.format(l1 = linker_script.path, l2 = linker_script_2.path),
    )

    linker = info.linker
    ctx.actions.run(
        mnemonic = "SDCClink1",
        progress_message = "linking 2 {}".format(ihx_file.basename),
        outputs = [ihx_file] + declare_sdcc_extensions(
            ctx.actions.declare_file,
            ctx.label.name,
            ["map", "noi"],
        ),
        inputs = (runtime_libs_files + runfiles_inputs +
                  source_files +
                  dep_headers +
                  libs_files +
                  [linker_script_2] +
                  includes.files.to_list()),
        executable = linker.files.to_list()[0],
        input_manifests = input_manifests,
        arguments = [
            "-nf",
            linker_script_2.path,
        ],
    )

    com_file = ctx.actions.declare_file("{}.com".format(ctx.label.name))
    outputs = [com_file]
    objcopy = info.objcopy.files.to_list()[0]

    ctx.actions.run(
        mnemonic = "OBJCOPY",
        outputs = outputs,
        inputs = [ihx_file],
        executable = objcopy,
        arguments = [
            "-I",
            "ihex",
            "-O",
            "binary",
            ihx_file.path,
            com_file.path,
        ],
    )
    return [
        DefaultInfo(files = depset(outputs)),
        CPMBinary(binary = com_file),
    ]

sdcc_z180_c_binary = rule(
    implementation = _sdcc_z180_c_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
    toolchains = ["//build:toolchain_type_sdcc_z180"],
)

def _sdcc_z180_asm_library_impl(ctx):
    info = get_sdcc_info(ctx)
    source_files = get_source_files(ctx)
    all_rel_files = []
    for source_file in source_files:
        single_rel_file = ctx.actions.declare_file("{}.rel".format(source_file.basename))
        all_rel_files += [single_rel_file]
        all_args = [
            "-l",  # generate lst file
            "-o",  # generate object (rel) file
            "-s",  # generate symbol (sym) file
            single_rel_file.path,
            source_file.path,
        ]
        ctx.actions.run(
            mnemonic = "ZASM",
            outputs = [single_rel_file] + declare_sdcc_extensions(
                ctx.actions.declare_file,
                source_file.basename,
                ["sym", "lst"],
            ),
            inputs = [source_file],
            executable = get_assembler(info),
            arguments = all_args,
        )
    return [
        DefaultInfo(files = depset(all_rel_files)),
        SdccHeaders(headers = depset([]), rels = depset(all_rel_files)),
    ]

sdcc_z180_asm_library = rule(
    implementation = _sdcc_z180_asm_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
    toolchains = ["//build:toolchain_type_sdcc_z180"],
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
            librarian = ctx.attr.librarian,
            runtime_libs = ctx.attr.runtime_libs,
            deps = ctx.attr.deps,
            crt0 = ctx.attr.crt0,
            objcopy = ctx.attr.objcopy,
        ),
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
        "librarian": attr.label(
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
        "runtime_libs": attr.label_list(
            cfg = "host",
            allow_files = True,
            default = [],
        ),
        "includes": attr.label(
            cfg = "host",
        ),
        "objcopy": attr.label(
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

def sdcc_z180_cpm_emu_run(name, binary, visibility = None, rule = native.sh_binary, env = {}):
    rule(
        name = name,
        srcs = [Label("//build:gen_runner.sh")],
        data = [
            "//CPMEmulator:cpm",
            binary,
        ],
        deps = [
            # To detect the runfiles dir.
            "@bazel_tools//tools/bash/runfiles",
        ],
        visibility = visibility,
        env = {
            "CPM_BINARY": "$(location //CPMEmulator:cpm)",
            "RUN_BINARY": "$(location {})".format(binary),
        },
    )

def sdcc_z180_cpm_test(name, binary, visibility = None):
    sdcc_z180_cpm_emu_run(
        name,
        binary,
        visibility,
        native.sh_test,
    )
