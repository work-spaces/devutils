"""
Define the:
    [url, commit or tag, args to cargo install]

for each tool to build and publish
"""

REPOS = {
    "bat": ["https://github.com/rivy/rust.bat", "v0.15.4.2", ["--path=.", "--profile=release"]],
    "coreutils": ["https://github.com/uutils/coreutils", "0.10.0", ["--path=.", "--profile=release-small", "--features=feat_os_unix_musl"]],
    "diffutils": ["https://github.com/uutils/diffutils", "v0.5.0", ["--path=.", "--profile=release-fast"]],
    "eza": ["https://github.com/eza-community/eza", "v0.23.5", ["--path=.", "--no-default-features", "--profile=release", "--locked"]],
    "fd-find": ["https://github.com/sharkdp/fd", "v10.4.2", ["--path=.", "--profile=release"]],
    "findutils": ["https://github.com/uutils/findutils", "0.10.0", ["--path=.", "--profile=dist"]],
    "hyperfine": ["https://github.com/sharkdp/hyperfine", "v1.20.0", ["--path=.", "--profile=release"]],
    "ouch": ["https://github.com/ouch-org/ouch", "0.8.1", ["--path=.", "--profile=release"]],
    "ripgrep": ["https://github.com/BurntSushi/ripgrep", "15.2.0", ["--path=.", "--profile=release-lto"]],
    "rm-improved": ["https://github.com/nivekuil/rip", "0.13.1", ["--path=.", "--profile=release", "--locked"]],
    "sccache": ["https://github.com/mozilla/sccache", "v0.17.0", ["--path=.", "--profile=release"]],
    "sed": ["https://github.com/uutils/sed", "0.1.1", ["--path=.", "--profile=release-fast"]],
    "starship": ["https://github.com/starship/starship", "v1.26.0", ["--path=.", "--profile=release"]],
    "xh": ["https://github.com/ducaale/xh", "v0.26.2", ["--path=."]],
    "zoxide": ["https://github.com/ajeetdsouza/zoxide", "v0.10.0", ["--path=.", "--profile=release"]],
}
