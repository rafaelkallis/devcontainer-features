#!/bin/bash

set -e

# Shared test helpers for claude-code-mounts feature

check_mounts_common() {
    check "/mnt/.claude exists" test -d "/mnt/.claude"
    check "/mnt/.claude.json exists" test -f "/mnt/.claude.json"
    check ".claude symlink exists" test -L "$HOME/.claude"
    check ".claude.json symlink exists" test -L "$HOME/.claude.json"
    check ".claude points to /mnt/.claude" test "$(readlink "$HOME/.claude")" = "/mnt/.claude"
    check ".claude.json points to /mnt/.claude.json" test "$(readlink "$HOME/.claude.json")" = "/mnt/.claude.json"
    check ".claude symlink not owned by root" test "$(stat -c '%U' "$HOME/.claude")" != "root"
    check ".claude.json symlink not owned by root" test "$(stat -c '%U' "$HOME/.claude.json")" != "root"
}
