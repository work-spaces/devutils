"""
Building the tools
"""

load(
    "//@star/prelude/info.star",
    "info_get_platform_name",
    "info_is_platform_aarch64",
    "info_is_platform_linux",
    "info_set_max_queue_count",
)
load("//@star/prelude/rules/rules.star", "rules_as_rule", "rules_new")
load(
    "//@star/prelude/rules/run.star",
    "run_add",
    "run_add_exec",
)
load("//@star/prelude/rules/visibility.star", "visibility_private")
load("//@star/prelude/rules/ws.star", "workspace_get_absolute_path")
load("//@star/sdk/star/cmake.star", "cmake_add_configure_build_install")
load("//@star/sdk/star/gh.star", "gh_add_publish_archive")
load("star/internal/repos.star", "REPOS", "repos_is_included")

DEVUTILS_VERSION = "0.1.16"

info_set_max_queue_count(1)

def _build_and_publish(name, first_dep, args):
    extra_args = []
    if info_is_platform_linux():
        ARCH = {
            "linux-aarch64": "aarch64",
            "linux-x86_64": "x86_64",
        }
        PLATFORM = info_get_platform_name()

        extra_args.append("--target={}-unknown-linux-musl".format(ARCH[PLATFORM]))

    run_add_exec(
        name,
        command = "cargo",
        args = [
            "install",
            "--root={}/build/install".format(workspace_get_absolute_path()),
        ] + extra_args + args,
        env = {"RUSTUP_TOOLCHAIN": "stable"},
        working_directory = "//repos/{}".format(name),
        visibility = visibility_private(),
        deps = [first_dep] if first_dep != None else [],
    )

install_deps = []
first_dep = None

rustup_dep = None

if info_is_platform_linux():
    arch = "aarch64" if info_is_platform_aarch64() else "x86_64"
    run_add_exec(
        "rustup_add_musl",
        command = "rustup",
        args = ["target", "add", "{}-unknown-linux-musl".format(arch)],
    )
    rustup_dep = ":rustup_add_musl"

last_dep = rustup_dep

if repos_is_included("fish"):
    run_add_exec(
        "patch_fish",
        command = "devutils/scripts/patch-fish.exec.star",
    )

    extra_deps = [last_dep] if last_dep != None else []
    cmake_add_configure_build_install(
        "fish_shell",
        source_directory = "repos/fish",
        configure_args = [
            "-DCMAKE_BUILD_TYPE:STRING=Release",
            "-DFISH_USE_SYSTEM_PCRE2:BOOL=OFF",
        ],
        deps = [":patch_fish"] + extra_deps,
    )
    last_dep = ":fish_shell"
    install_deps.append(":fish_shell")

for (key, values) in REPOS.items():
    # Force all other to depend on the first dep so that
    # cargo install will run with rustup on the first go
    if repos_is_included(key):
        _build_and_publish(key, last_dep, values[2])
        last_dep = key
        install_deps.append(key)

run_add(
    "install",
    deps = install_deps,
    visibility = visibility_private(),
)

gh_add_publish_archive(
    "devutils",
    input = "//build/install",
    version = DEVUTILS_VERSION,
    deploy_repo = "https://github.com/work-spaces/devutils",
    deps = install_deps,
    visibility = visibility_private(),
)
