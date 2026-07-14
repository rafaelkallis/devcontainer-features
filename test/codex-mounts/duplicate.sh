#!/bin/bash

set -e

source dev-container-features-test-lib

check ".codex symlink still exists after duplication" test -L "$HOME/.codex"
check ".codex still points to /mnt/.codex" test "$(readlink "$HOME/.codex")" = "/mnt/.codex"

reportResults
