#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

# The feature should have backed up the pre-existing real ~/.codex dir (from
# the scenario Dockerfile) to .codex.bak before symlinking to /mnt/.codex.

check ".codex symlink exists" test -L "$HOME/.codex"
check ".codex points to /mnt/.codex" test "$(readlink "$HOME/.codex")" = "/mnt/.codex"

check "pre-existing .codex backed up to .codex.bak" test -d "$HOME/.codex.bak"
check "backup is not a symlink" test ! -L "$HOME/.codex.bak"
check "backup preserves original content" grep -q "pre-existing" "$HOME/.codex.bak/config.json"

# Idempotency: the postCreateCommand already re-ran setup-mounts.sh at container
# start (which must not have created a second backup). Run it once more and
# assert a single .codex.bak remains after all of them.
MOUNTS_PHASE=runtime /usr/local/share/devcontainer-features/codex-mounts/setup-mounts.sh \
    "$HOME" --pairs-file /usr/local/share/devcontainer-features/codex-mounts/mounts.txt

backup_count="$(find "$HOME" -maxdepth 1 -name '.codex.bak*' | wc -l)"
check "only one backup exists" test "$backup_count" = 1

reportResults
