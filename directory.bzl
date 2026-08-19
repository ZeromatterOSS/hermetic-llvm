load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

# We want to put a source directory into the DefaultInfo but still propagate
# the DirectoryInfo for header inclusion checking.
def headers_directory(name, path, visibility = None):
    if path == ".":
        directory(
            name = name + "_directory",
            srcs = native.glob(["**"]),
        )
    else:
        directory(
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

    # Some remote repository-content caches cannot materialize a source
    # directory artifact. Provide an equivalent target whose DefaultInfo
    # enumerates the files while preserving DirectoryInfo for path formatting.
    expanded_headers_directory(
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
