"""
Building the tools
"""

load("//@star/sdk/star/gh.star", "gh_add_publish_archive")
load(
    "//@star/sdk/star/info.star",
    "info_get_platform_name",
    "info_is_platform_linux",
)
load(
    "//@star/sdk/star/run.star",
    "run_add_archive",
    "run_add_exec",
    "run_add_target",
)
load("//@star/sdk/star/visibility.star", "visibility_private")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")
load("repos.star", "REPOS")

DEVUTILS_VERSION = "0.1.0"

def _build_and_publish(name, args):
    RULES = {
        "install": "{}_install".format(name),
    }

    extra_args = []
    if info_is_platform_linux():
        ARCH = {
            "linux-aarch64": "aarch64",
            "linux-x86_64": "x86_64",
        }
        PLATFORM = info_get_platform_name()

        extra_args.append("--target={}-unknown-linux-musl".format(ARCH[PLATFORM]))

    run_add_exec(
        RULES["install"],
        command = "cargo",
        args = [
            "install",
            "--root={}/build/install".format(workspace_get_absolute_path()),
        ] + extra_args + args,
        working_directory = "//repos/{}".format(name),
        visibility = visibility_private(),
    )

    return RULES

install_deps = []

for (key, values) in REPOS.items():
    rules = _build_and_publish(key, values[2])
    install_deps.append(rules["install"])

run_add_target(
    "install",
    deps = install_deps,
    visibility = visibility_private(),
)

gh_add_publish_archive(
    "devutils",
    input = "build/install",
    version = DEVUTILS_VERSION,
    deploy_repo = "https://github.com/work-spaces/devutils",
    deps = install_deps,
    visibility = visibility_private(),
)
