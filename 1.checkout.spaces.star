"""
Checkout rules for getting repos to build the devutils
"""

load("//@star/packages/star/llvm.star", "llvm_add")
load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/rust.star", "rust_add")
load(
    "//@star/packages/star/spaces-cli.star",
    "spaces_add_devutils",
    "spaces_add_star_formatter",
)
load("//@star/packages/star/starship.star", "starship_add_bash")
load(
    "//@star/prelude/info.star",
    "info_get_platform_name",
    "info_is_ci",
    "info_is_platform_linux",
    "info_is_platform_macos",
)
load(
    "//@star/prelude/rules/asset.star",
    "asset_hard_link",
)
load(
    "//@star/prelude/rules/checkout.star",
    "checkout_add_any_assets",
    "checkout_add_env_vars",
    "checkout_add_exec",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_asset",
)
load(
    "//@star/prelude/rules/env.star",
    "env_assign",
    "env_inherit",
    "env_prepend",
    "env_script",
)
load(
    "//@star/prelude/rules/ws.star",
    "workspace_get_absolute_path",
    "workspace_get_path_to_checkout",
)
load(
    "//@star/sdk/star/checkout-config.star",
    "checkout_config_add_markdown",
    "checkout_config_load_option",
    "checkout_config_register_optin",
    "checkout_config_register_optout",
)
load("star/internal/repos.star", "REPOS", "REPOS_INCLUDE_ALL", "repos_get_config_option", "repos_is_included")

# Configure the top level workspace

SPACES_CHECKOUT_PATH = workspace_get_path_to_checkout()

if not info_is_ci():
    SHORTCUTS = {}
    starship_add_bash("starship0", shortcuts = SHORTCUTS)

spaces_add_devutils(
    "spaces0",
    "v0.21.3",
    devutils_version = None,
    system_paths = ["/usr/bin", "/bin"],
)
spaces_add_star_formatter("star_formatter", configure_zed = True, deps = [":spaces0"])

package_add("github.com", "cli", "cli", "v2.87.3")
package_add("github.com", "Kitware", "CMake", "v4.4.2")
package_add("github.com", "ninja-build", "ninja", "v1.13.2")
llvm_add("llvm22", "llvmorg-22.1.8")
if info_is_platform_macos():
    checkout_add_env_vars(
        "sdk_root_var",
        vars = [
            env_script(
                "SDK_ROOT",
                script = "/usr/bin/xcrun --sdk macosx --show-sdk-path",
                help = "Set SDK_ROOT env variable to the macOS SDK path",
            ),
        ],
    )

RUST_TOOLCHAIN = "rust-linux-toolchain" if info_is_platform_linux() else "rust-macos-toolchain"

checkout_add_any_assets(
    "rust_toolchain_toml",
    assets = [
        asset_hard_link(
            source = "{}/{}.toml".format(SPACES_CHECKOUT_PATH, RUST_TOOLCHAIN),
            destination = "rust-toolchain.toml",
        ),
    ],
)

rust_add(
    "rust_toolchain",
    version = "1.94",
    deps = [":spaces0", ":rust_toolchain_toml"],
    rust_toolchain_toml_dir = "//.",
)

checkout_config_register_optout(
    REPOS_INCLUDE_ALL,
    help = "Include all devutils repos",
)

for (key, value) in REPOS.items():
    checkout_option_name = repos_get_config_option(key)
    checkout_config_register_optin(
        checkout_option_name,
        help = "Include {} repo".format(key),
    )

    if repos_is_included(key):
        checkout_add_repo(
            "repos/{}".format(key),
            url = value[0],
            rev = value[1],
            clone = "Shallow",
        )

checkout_config_register_optin(
    repos_get_config_option("fish"),
    help = "Include fish repo",
)

if repos_is_included("fish"):
    checkout_add_repo(
        "repos/fish",
        url = "https://github.com/fish-shell/fish-shell",
        rev = "4.9.3",
        clone = "Shallow",
    )

if info_is_platform_linux():
    checkout_add_platform_archive(
        "musl-gcc",
        platforms = {
            "linux-aarch64": {
                "add_prefix": "sysroot",
                "link": "Hard",
                "sha256": "45391baada5bd0b78fd888ae7ee45e4970aebee98f64dd9eb7717ecedcbfb0d6",
                "url": "https://github.com/work-spaces/devutils/releases/download/devutils-v0.1.9/aarch64-unknown-linux-musl.tar.xz",
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
    MUSL_SYSROOT_PATH = "{ws}/sysroot/{platform}/{platform}".format(
        ws = workspace_get_absolute_path(),
        platform = PATHS[PLATFORM],
    )

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
                "CFLAGS_{}_unknown_linux_musl".format(ARCH[PLATFORM]),
                value = "-Wno-incompatible-pointer-types",
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
            env_assign(
                "PKG_CONFIG_ALLOW_CROSS_{}_unknown_linux_musl".format(ARCH[PLATFORM]),
                value = "1",
                help = "Allow pkg-config to be used when cross-compiling for musl",
            ),
            env_assign(
                "PKG_CONFIG_SYSROOT_DIR_{}_unknown_linux_musl".format(ARCH[PLATFORM]),
                value = MUSL_SYSROOT_PATH,
                help = "Set the sysroot dir for pkg-config when cross-compiling for musl",
            ),
        ],
    )

checkout_config_add_markdown("checkout_config_markdown", deps = [":spaces0"])
