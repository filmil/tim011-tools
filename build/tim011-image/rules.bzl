load("//build:sdcc.bzl", "CPMBinary")
load("@bazel_skylib//lib:paths.bzl", "paths")


def _tim011_disk_image(ctx):
    name = ctx.attr.name
    base_image = ctx.attr.base_image.files.to_list()[0]

    # tools
    cpmcp = ctx.attr._cpmcp.files.to_list()[0]
    gen_dir = ctx.attr._gen_dir.files.to_list()[0]
    input_files = []
    for target in ctx.attr.binaries:
        cpm_binary = target[CPMBinary].binary
        input_files += [cpm_binary]

    final_image = ctx.actions.declare_file("{}.tim011.img".format(name))
    tmp_dir = ctx.actions.declare_directory("{}.tmp_dir".format(name))
    diskdefs = "{}/share/diskdefs".format(gen_dir.path)
    cpmcp_cmdline = ""
    if len(input_files) > 0:
        cpmcp_cmdline = """&& env DISKDEFS="{diskdefs}" {cpmcp} -f tim011 {tmp_dir}/temp.img {files} 0: """.format(files=" ".join([
        f.path for f in input_files]), 
        tmp_dir=tmp_dir.path, 
        diskdefs=diskdefs,
        cpmcp=cpmcp.path)

    ctx.actions.run_shell(
        mnemonic = "TIM011img",
        inputs = [base_image, gen_dir] + input_files,
        outputs = [final_image, tmp_dir],
        tools = [cpmcp],
        command = """ \
            cp --dereference {base_image} {tmp_dir}/temp.img \
            {cpmcp_cmdline} \
            && cp --dereference {tmp_dir}/temp.img {output_file} \
            && chmod a+w {output_file} \
        """.format(
            base_image = base_image.path,
            tmp_dir = tmp_dir.path,
            cpmcp = cpmcp.path,
            files = " ".join([f.path for f in input_files]),
            output_file = final_image.path,
            diskdefs = diskdefs,
            cpmcp_cmdline=cpmcp_cmdline,
        ),
    )

    return [
        DefaultInfo(files=depset([final_image])),
    ]


tim011_disk_image = rule(
    implementation = _tim011_disk_image,
    attrs = {
        "base_image": attr.label(
            allow_files = True,
            default = Label("@mame_docker//:TIM011-Kit.img")
        ),
        "binaries" : attr.label_list(
            providers = [CPMBinary],
        ),
        "_cpmcp": attr.label(
            allow_files = True,
            cfg = "host",
            executable = True,
            default = Label("@cpmtools//:cpmcp"),
        ),
        "_gen_dir": attr.label(
            allow_files = True,
            cfg = "host",
            default = Label("@cpmtools//:gen_dir"),
        ),
    },
)
