"""
Define the:
    [url, commit or tag, args to cargo install]

for each tool to build and publish
"""

load("//@star/sdk/star/checkout-config.star", "checkout_config_load_option")

REPOS_INCLUDE_ALL = "DEVUTILS_INCLUDE_ALL"

REPOS = {
    "bat": ["https://github.com/rivy/rust.bat", "v0.15.4.2", ["--path=.", "--profile=release"]],
    "coreutils": ["https://github.com/uutils/coreutils", "0.11.0", ["--path=.", "--profile=release-small", "--features=feat_os_unix_musl", "--locked"]],
    "diffutils": ["https://github.com/uutils/diffutils", "v0.5.0", ["--path=.", "--profile=release-fast", "--locked"]],
    "eza": ["https://github.com/eza-community/eza", "v0.23.5", ["--path=.", "--no-default-features", "--profile=release", "--locked"]],
    "fd-find": ["https://github.com/sharkdp/fd", "v10.5.0", ["--path=.", "--profile=release", "--locked"]],
    "findutils": ["https://github.com/uutils/findutils", "0.10.0", ["--path=.", "--profile=dist", "--locked"]],
    "hyperfine": ["https://github.com/sharkdp/hyperfine", "v1.20.0", ["--path=.", "--profile=release", "--locked"]],
    "ouch": ["https://github.com/ouch-org/ouch", "0.8.3", ["--path=.", "--profile=release", "--locked"]],
    "ripgrep": ["https://github.com/BurntSushi/ripgrep", "15.2.0", ["--path=.", "--profile=release-lto", "--locked"]],
    "rm-improved": ["https://github.com/nivekuil/rip", "0.13.1", ["--path=.", "--profile=release", "--locked"]],
    "sccache": ["https://github.com/mozilla/sccache", "v0.17.0", ["--path=.", "--profile=release", "--features=vendored-openssl", "--locked"]],
    "sed": ["https://github.com/uutils/sed", "0.1.1", ["--path=.", "--profile=release-fast", "--locked"]],
    "starship": ["https://github.com/starship/starship", "v1.26.0", ["--path=.", "--profile=release", "--locked"]],
    "xh": ["https://github.com/ducaale/xh", "v0.26.2", ["--path=.", "--locked"]],
    "zoxide": ["https://github.com/ajeetdsouza/zoxide", "v0.10.0", ["--path=.", "--profile=release", "--locked"]],
}

def repos_get_config_option(repo_name: str):
    return "DEVUTILS_INCLUDE_{}".format(repo_name.upper())

def repos_is_included(repo_name: str) -> bool:
    option_name = repos_get_config_option(repo_name)
    return checkout_config_load_option(option_name) or checkout_config_load_option(REPOS_INCLUDE_ALL)
