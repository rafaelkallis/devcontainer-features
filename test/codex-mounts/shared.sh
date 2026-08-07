#!/bin/bash

set -e

# Shared test helpers for codex-mounts feature

check_mounts_common() {
    check "/mnt/.codex exists" test -d "/mnt/.codex"
    check ".codex symlink exists" test -L "$HOME/.codex"
    check ".codex points to /mnt/.codex" test "$(readlink "$HOME/.codex")" = "/mnt/.codex"
    check ".codex symlink not owned by root" test "$(stat -c '%U' "$HOME/.codex")" != "root"
}
