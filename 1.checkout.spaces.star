"""
Checkout rules for getting repos to build the devutils
"""

load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/rust.star", "rust_add")
load(
    "//@star/packages/star/spaces-cli.star",
    "spaces_add_star_formatter",
    "spaces_isolate_workspace",
)
load("//@star/packages/star/starship.star", "starship_add_bash")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_env_vars",
    "checkout_add_hard_link_asset",
    "checkout_add_platform_archive",
    "checkout_add_repo",
)
load(
    "//@star/sdk/star/env.star",
    "env_assign",
    "env_inherit",
    "env_prepend",
)
load(
    "//@star/sdk/star/info.star",
    "info_get_platform_name",
    "info_is_ci",
    "info_is_platform_linux",
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

package_add("github.com", "cli", "cli", "v2.87.3")

rust_add(
    "rust_toolchain",
    version = "1.93",
    deps = ["spaces0"],
)

RUST_TOOLCHAIN = "rust-linux-toolchain" if info_is_platform_linux() else "rust-macos-toolchain"

checkout_add_hard_link_asset(
    "rust_toolchain_toml",
    source = "{}/{}.toml".format(SPACES_CHECKOUT_PATH, RUST_TOOLCHAIN),
    destination = "rust-toolchain.toml",
)

for (key, value) in REPOS.items():
    checkout_add_repo(
        "repos/{}".format(key),
        url = value[0],
        rev = value[1],
        clone = "Shallow",
    )

if info_is_platform_linux():
    checkout_add_platform_archive(
        "musl-gcc",
        platforms = {
            "linux-aarch64": {
                "add_prefix": "sysroot",
                "link": "Hard",
                "sha256": "28a1d26f14f8ddc3aed31f20705fe696777400eb5952d90470a7e6e2dd1175bb",
                "url": "https://github.com/cross-tools/musl-cross/releases/download/20250929/aarch64-unknown-linux-musl.tar.xz",
            },
            "linux-x86_64": {
                "add_prefix": "sysroot",
                "link": "Hard",
                "sha256": "6534870abd7dc327fd2e14cc53972d0552b21f47db5769505534f788537e3544",
                "url": "https://github.com/cross-tools/musl-cross/releases/download/20250929/x86_64-unknown-linux-musl.tar.xz",
            },
        },
    )

    PATHS = {
        "linux-aarch64": "aarch64-unknown-linux-musl",
        "linux-x86_64": "x86_64-unknown-linux-musl",
    }

    ARCH = {
        "linux-aarch64": "aarch64",
        "linux-x86_64": "x86_64",
    }

    PLATFORM = info_get_platform_name()

    MUSL_BIN_PATH = "{}/sysroot/{}/bin".format(workspace_get_absolute_path(), PATHS[PLATFORM])

    checkout_add_env_vars(
        "musl-gcc-path",
        vars = [
            env_prepend(
                "PATH",
                value = MUSL_BIN_PATH,
                help = "Add the musl bins to the path",
            ),
            env_assign(
                "CC_{}_unknown_linux_musl".format(ARCH[PLATFORM]),
                value = "{}-unknown-linux-musl-gcc".format(ARCH[PLATFORM]),
                help = "Let cargo know what CC to use for musl",
            ),
            env_assign(
                "AR_{}_unknown_linux_musl".format(ARCH[PLATFORM]),
                value = "{}-unknown-linux-musl-ar".format(ARCH[PLATFORM]),
                help = "Let cargo know what AR to use for musl",
            ),
            env_assign(
                "CARGO_TARGET_{}_UNKNOWN_LINUX_MUSL_LINKER".format(ARCH[PLATFORM].upper()),
                value = "{}-unknown-linux-musl-gcc".format(ARCH[PLATFORM]),
                help = "Let cargo know what linker to use for musl",
            ),
            env_inherit(
                "GH_TOKEN",
                is_secret = True,
                help = "Add GH_TOKEN to env for use with gh publish",
            ),
        ],
    )
