"""
Checkout rules for getting repos to build the devutils
"""

load("//@star/packages/star/coreutils.star", "coreutils_add_rs_tools")
load("//@star/packages/star/rust.star", "rust_add")
load("//@star/packages/star/sccache.star", "sccache_add")
load("//@star/packages/star/spaces-cli.star", "spaces_add_star_formatter", "spaces_isolate_workspace")
load("//@star/packages/star/starship.star", "starship_add_bash")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_hard_link_asset",
    "checkout_add_repo",
)
load(
    "//@star/sdk/star/info.star",
    "info_is_ci",
)
load(
    "//@star/sdk/star/ws.star",
    "workspace_get_absolute_path",
    "workspace_get_path_to_checkout",
)
load("repos.star", "REPOS")

# Configure the top level workspace

SPACES_CHECKOUT_PATH = workspace_get_path_to_checkout()

if not info_is_ci():
    SHORTCUTS = {}

    starship_add_bash("starship0", shortcuts = SHORTCUTS)

spaces_isolate_workspace("spaces0", "v0.15.27", system_paths = ["/usr/bin", "/bin"])
spaces_add_star_formatter("star_formatter", configure_zed = True, deps = ["spaces0"])

rust_add(
    "rust_toolchain",
    version = "1.93",
    deps = ["spaces0"],
)

checkout_add_hard_link_asset(
    "rust_toolchain_toml",
    source = "{}/rust-toolchain.toml".format(SPACES_CHECKOUT_PATH),
    destination = "rust-toolchain.toml",
)

for (key, value) in REPOS.items():
    checkout_add_repo(
        "repos/{}".format(key),
        url = value[0],
        rev = value[1],
        clone = "Shallow",
    )
