"""
Building the tools
"""

load("//@star/packages/star/musl-gcc.star", "musl_gcc_get_env")
load("//@star/sdk/star/gh.star", "gh_add_publish_archive")
load(
    "//@star/sdk/star/info.star",
    "info_get_platform_name",
    "info_is_platform_linux",
    "info_set_max_queue_count",
)
load("//@star/sdk/star/rules.star", "rules_as_rule", "rules_new")
load(
    "//@star/sdk/star/run.star",
    "run_add_exec",
    "run_add_target",
)
load("//@star/sdk/star/visibility.star", "visibility_private")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")
load("repos.star", "REPOS")

DEVUTILS_VERSION = "0.1.13"

info_set_max_queue_count(1)

def _build_and_publish(name: str, first_dep, args):
    RULES = rules_new(name, ["install"])

    extra_args = []
    extra_env = {}
    if info_is_platform_linux():
        ARCH = {
            "linux-aarch64": "aarch64",
            "linux-x86_64": "x86_64",
        }
        PLATFORM = info_get_platform_name()

        extra_env = musl_gcc_get_env()
        extra_args.append("--target={}-unknown-linux-musl".format(ARCH[PLATFORM]))

    run_add_exec(
        rules_as_rule(RULES, "install"),
        command = "cargo",
        args = [
            "install",
            "--root={}/build/install".format(workspace_get_absolute_path()),
        ] + extra_args + args,
        working_directory = "//repos/{}".format(name),
        visibility = visibility_private(),
        deps = [first_dep] if first_dep != None else [],
        env = extra_env,
    )

    return RULES

install_deps = []
first_dep = None

for (key, values) in REPOS.items():
    # Force all other to depend on the first dep so that
    # cargo install will run with rustup on the first go
    rules = _build_and_publish(key, first_dep, values[2])
    if first_dep == None:
        first_dep = rules.get("install")
    else:
        install_deps.append(rules.get("install"))

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
