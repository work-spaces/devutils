#!/usr/bin/env spaces

"""
Patch fish shell to not build the MacApp.
"""

load("//@star/prelude/exec/fs.star", "fs_read_text", "fs_write_text")
load("//@star/prelude/exec/log.star", "log_fatal", "log_info")
load("//@star/prelude/exec/string.star", "string_replace")
load("//@star/prelude/exec/sys.star", "sys_exit")

_TARGET_FILE = "repos/fish/CMakeLists.txt"
_OLD_TEXT = "# Mac app.\ninclude(cmake/MacApp.cmake)"
_NEW_TEXT = "# Mac app.\n# include(cmake/MacApp.cmake)"

def main() -> int:
    content = fs_read_text(_TARGET_FILE)
    patched = string_replace(content, _OLD_TEXT, _NEW_TEXT, count = 1)

    if patched == content:
        if _NEW_TEXT in content:
            log_info("No changes needed: {} is already patched".format(_TARGET_FILE))
            return 0
        log_fatal("Expected text block not found in {}".format(_TARGET_FILE))
        return 1

    fs_write_text(_TARGET_FILE, patched)
    log_info("Patched {}".format(_TARGET_FILE))
    return 0

exit_code = main()
sys_exit(exit_code)
