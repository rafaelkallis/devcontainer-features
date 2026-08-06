#!/bin/bash

set -e

# Shared test helpers for github-cli-mounts feature

check_mounts_common() {
    check "/mnt/.config/gh exists" test -d "/mnt/.config/gh"
    check ".config/gh symlink exists" test -L "$HOME/.config/gh"
    check ".config/gh points to /mnt/.config/gh" test "$(readlink "$HOME/.config/gh")" = "/mnt/.config/gh"
}
