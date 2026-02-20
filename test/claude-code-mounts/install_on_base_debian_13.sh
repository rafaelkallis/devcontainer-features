#!/bin/bash

set -e

source dev-container-features-test-lib

# Check mount points exist
check "/mnt/.claude exists" test -d "/mnt/.claude"
check "/mnt/.claude.json exists" test -f "/mnt/.claude.json"

# Check symlinks exist and point to correct locations
check ".claude symlink exists" test -L "$HOME/.claude"
check ".claude.json symlink exists" test -L "$HOME/.claude.json"
check ".claude points to /mnt/.claude" test "$(readlink "$HOME/.claude")" = "/mnt/.claude"
check ".claude.json points to /mnt/.claude.json" test "$(readlink "$HOME/.claude.json")" = "/mnt/.claude.json"

reportResults
