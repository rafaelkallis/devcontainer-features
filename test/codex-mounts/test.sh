#!/bin/bash

set -e

source dev-container-features-test-lib

# Check mount points exist
check "/mnt/.codex exists" test -d "/mnt/.codex"

# Check symlinks exist and point to correct locations
check ".codex symlink exists" test -L "$HOME/.codex"
check ".codex points to /mnt/.codex" test "$(readlink "$HOME/.codex")" = "/mnt/.codex"

reportResults
