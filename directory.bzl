load("@bazel_skylib//rules/directory:directory.bzl", _directory = "directory")
load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

# We want to put a source directory into the DefaultInfo but still propagate
# the DirectoryInfo for header inclusion checking.
def headers_directory(name, path, visibility = None):
    if path == ".":
        _directory(
            name = name + "_directory",
            srcs = native.glob(["**"]),
        )
    else:
        _directory(
            name = name + "_files",
            srcs = native.glob([path + "/**"]),
        )

        subdirectory(
            name = name + "_directory",
            path = path,
            parent = name + "_files",
        )

    native.filegroup(
        name = name + "_source_directory",
        srcs = [path],
    )

    _headers_directory(
        name = name,
        directory = name + "_directory",
        source_directory = name + "_source_directory",
        visibility = visibility,
    )

    # Keep the enumerated compiler inputs disjoint from the public source
    # directory artifact so actions may depend on both without an input-path
    # collision.
    _mirrored_headers_directory(
        name = name + "_expanded",
        directory = name + "_directory",
        visibility = visibility,
    )

def expanded_headers_directory(name, directory, visibility = None):
    _expanded_headers_directory(
        name = name,
        directory = directory,
        visibility = visibility,
    )

def _expanded_headers_directory_impl(ctx):
    directory = ctx.attr.directory[DirectoryInfo]
    return [
        directory,
        DefaultInfo(files = directory.transitive_files),
    ]

_expanded_headers_directory = rule(
    implementation = _expanded_headers_directory_impl,
    attrs = {
        "directory": attr.label(
            providers = [DirectoryInfo],
            mandatory = True,
        ),
    },
)

def _mirrored_headers_directory(name, directory, visibility = None):
    _mirror_directory(
        name = name + "_files",
        directory = directory,
        output_directory = name,
    )

    _directory(
        name = name + "_directory",
        srcs = [name + "_files"],
    )

    subdirectory(
        name = name,
        path = name,
        parent = name + "_directory",
        visibility = visibility,
    )

def _mirror_directory_impl(ctx):
    directory = ctx.attr.directory[DirectoryInfo]
    prefix = directory.path.rstrip("/") + "/"
    outputs = []
    for src in directory.transitive_files.to_list():
        if not src.path.startswith(prefix):
            fail("{} is not under {}".format(src.path, directory.path))
        relative = src.path[len(prefix):]
        output = ctx.actions.declare_file(ctx.attr.output_directory + "/" + relative)
        ctx.actions.symlink(output = output, target_file = src)
        outputs.append(output)
    return DefaultInfo(files = depset(outputs))

_mirror_directory = rule(
    implementation = _mirror_directory_impl,
    attrs = {
        "directory": attr.label(
            providers = [DirectoryInfo],
            mandatory = True,
        ),
        "output_directory": attr.string(mandatory = True),
    },
)

SourceDirectoryInfo = provider("Marker Provider", fields = [])

def _headers_directory_impl(ctx):
    return [
        ctx.attr.directory[DirectoryInfo],
        SourceDirectoryInfo(),
        DefaultInfo(
            files = ctx.attr.source_directory[DefaultInfo].files,
        ),
    ]

_headers_directory = rule(
    implementation = _headers_directory_impl,
    attrs = {
        "directory": attr.label(),
        "source_directory": attr.label(),
    },
    cfg = config.none(),
)
