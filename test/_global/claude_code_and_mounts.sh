#!/bin/bash

set -e

source dev-container-features-test-lib

check "claude" claude --version

check ".claude points to /mnt/.claude" test "$(readlink "$HOME/.claude")" = "/mnt/.claude"
check ".claude.json points to /mnt/.claude.json" test "$(readlink "$HOME/.claude.json")" = "/mnt/.claude.json"

reportResults
