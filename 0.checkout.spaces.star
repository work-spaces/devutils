"""
Load the spaces starlark SDK and packages repositories.
"""

load("//@star/prelude/info.star", "info_is_ci")
load("//@star/prelude/rules/checkout.star", "checkout_add_env_vars", "checkout_add_repo")
load("//@star/prelude/rules/env.star", "env_append", "env_inherit")

# Ensure tools checked out to sysroot/bin are available
# during checkout_add_exec() calls
checkout_add_env_vars(
    "sysroot_env_path",
    vars = [
        env_append("PATH", "{}/sysroot/bin".format(workspace.get_absolute_path()), help = "Add sysroot/bin to the PATH"),
        env_append("PATH", "/bin", help = "Add /bin to the PATH"),
        env_inherit(
            "GH_TOKEN",
            is_secret = True,
            is_required = info_is_ci(),
            help = "Add GH_TOKEN to env for use with gh publish",
        ),
    ],
)

checkout_add_repo(
    "@star/sdk",
    url = "https://github.com/work-spaces/sdk",
    rev = "v0.4.0",
)

checkout_add_repo(
    "@star/packages",
    url = "https://github.com/work-spaces/packages",
    rev = "v0.2.66",
)
