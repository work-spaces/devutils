"""
Building the tools
"""

load("//@star/sdk/star/run.star", "run_add_exec", "run_add_target")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")
load("repos.star", "REPOS")

def _build_and_publish(name, args):
    RULES = {
        "install": "{}_install".format(name),
    }

    run_add_exec(
        RULES["install"],
        command = "cargo",
        args = [
            "install",
            "--root={}/build/install".format(workspace_get_absolute_path()),
        ] + args,
        working_directory = "//repos/{}".format(name),
    )

    return RULES

install_deps = []

for (key, values) in REPOS.items():
    rules = _build_and_publish(key, values[2])
    install_deps.append(rules["install"])

run_add_target(
    "install",
    deps = install_deps,
)
