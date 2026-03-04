"""
Spaces starlark checkout/run script to make changes to spaces, printer, and archiver.
With VSCode/Zed integration
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
    "checkout_update_asset",
    "checkout_update_env",
)
load(
    "//@star/sdk/star/info.star",
    "info_get_path_to_store",
    "info_is_ci",
)
load(
    "//@star/sdk/star/ws.star",
    "workspace_get_absolute_path",
    "workspace_get_path_to_checkout",
)

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

REPOS = {
    "coreutils": ["https://github.com/uutils/coreutils", "0.6.0"],
    "findutils": ["https://github.com/uutils/findutils", "0.8.0"],
    "fd-find": ["https://github.com/sharkdp/fd", "v0.23.4"],
    "bat": ["https://github.com/rivy/rust.bat", "v0.15.4.2"],
    "xh": ["https://github.com/ducaale/xh", "v0.25.3"],
    "ripgrep": ["https://github.com/BurntSushi/ripgrep", "15.1.0"],
    "rm-improved": ["https://github.com/nivekuil/rip", "v0.13.1"],
    "hyperfine": ["https://github.com/sharkdp/hyperfine", "v1.20.0"],
}

for (key, value) in REPOS.items():
    checkout_add_repo(
        key,
        url = value[0],
        rev = value[1],
        clone = "Shallow"
    )
