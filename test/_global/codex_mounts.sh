#!/bin/bash

set -e

source dev-container-features-test-lib

check ".codex points to /mnt/.codex" test "$(readlink "$HOME/.codex")" = "/mnt/.codex"

reportResults
