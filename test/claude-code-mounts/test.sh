#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'claude-code-mounts' Feature with no options.
#
# This test can be run with the following command:
#
#    devcontainer features test \
#                   --features claude-code-mounts \
#                   --remote-user root \
#                   --skip-scenarios \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

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
