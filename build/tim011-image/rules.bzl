load("//build:sdcc.bzl", "CPMBinary")
load("@bazel_skylib//lib:paths.bzl", "paths")


def _tim011_disk_image(ctx):
    name = ctx.attr.name
    base_image = ctx.attr.base_image.files.to_list()[0]

    # tools
    timdisk = ctx.attr._timdisk.files.to_list()[0]
    cpmls = ctx.attr._cpmls.files.to_list()[0]
    cpmcp = ctx.attr._cpmcp.files.to_list()[0]
    gen_dir = ctx.attr._gen_dir.files.to_list()[0]
    empty_img = ctx.attr._empty_img.files.to_list()[0]
    env = {
        "CPMLS": cpmls.path,
        "CPMCP": cpmcp.path,
        "FORCE": "1",
        "DISKDEFS": "{}/share/diskdefs".format(gen_dir.path),
        "EMPTY": base_image.path,
    }

    image_dir = ctx.actions.declare_directory("{}.tim011.image_dir".format(name))

    # Unpack the base image in a directory.
    args = ctx.actions.args()
    args.add_all(["-e", base_image.path, image_dir.path])
    ctx.actions.run(
        mnemonic = "TIM011baseimg",
        executable = timdisk,
        arguments = [args],
        outputs = [image_dir],
        inputs = [base_image, gen_dir, empty_img],
        tools = [ cpmls, cpmcp],
        env = env,
    )

    # Copy the binaries into the directory.
    input_files = []
    for target in ctx.attr.binaries:
        cpm_binary = target[CPMBinary].binary
        input_files += [cpm_binary]
    tmp_dir = ctx.actions.declare_directory("{}.img_tempdir".format(name))
    ctx.actions.run_shell(
        mnemonic = "TIM011cpfile",
        inputs = input_files + [image_dir],
        outputs = [tmp_dir],
        command = """ \
            cp -R --dereference {image_dir}/* {destination} && \
            cp --dereference {source} {destination}
        """.format(
            source = " ".join([f.path for f in input_files]),
            destination = tmp_dir.path,
            image_dir = image_dir.path,
        ),
    )

    # Pack the result into a new image.
    final_image = ctx.actions.declare_file("{}.img".format(name))
    args = ctx.actions.args() 
    args.add_all(["-c", tmp_dir.path, final_image.path])

    # This run requries an actual empty image to operate.
    env["EMPTY"]=empty_img.path
    ctx.actions.run(
        mnemonic = "TIM011createImg",
        executable = timdisk,
        arguments = [args],
        inputs = [tmp_dir, gen_dir, empty_img],
        outputs = [final_image],
        tools = [cpmls, cpmcp],
        env = env,
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
        "_timdisk": attr.label(
            allow_files = True,
            cfg = "host",
            executable = True,
            default = Label("//third_party/zztim:timdisk"),
        ),
        "_cpmls": attr.label(
            allow_files = True,
            cfg = "host",
            executable = True,
            default = Label("@cpmtools//:cpmls"),
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
        "_empty_img": attr.label(
            allow_files = True,
            cfg = "host",
            default = Label("@zztim//:empty.img"),
        ),
    },
)
