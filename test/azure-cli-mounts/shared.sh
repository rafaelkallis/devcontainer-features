#!/bin/bash

set -e

# Shared test helpers for azure-cli-mounts feature

check_mounts_common() {
    check "/mnt/.azure exists" test -d "/mnt/.azure"
    check ".azure symlink exists" test -L "$HOME/.azure"
    check ".azure points to /mnt/.azure" test "$(readlink "$HOME/.azure")" = "/mnt/.azure"
    check ".azure symlink not owned by root" test "$(stat -c '%U' "$HOME/.azure")" != "root"
}
