#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

# The feature should have backed up the pre-existing real
# ~/.local/.IdentityService dir (from the scenario Dockerfile) to
# .IdentityService.bak before symlinking to /mnt/.IdentityService.

check ".local/.IdentityService symlink exists" test -L "$HOME/.local/.IdentityService"
check ".local/.IdentityService points to /mnt/.IdentityService" test "$(readlink "$HOME/.local/.IdentityService")" = "/mnt/.IdentityService"

check "pre-existing .local/.IdentityService backed up to .IdentityService.bak" test -d "$HOME/.local/.IdentityService.bak"
check "backup is not a symlink" test ! -L "$HOME/.local/.IdentityService.bak"
check "backup preserves original content" grep -q "pre-existing" "$HOME/.local/.IdentityService.bak/msal.cache"

# Idempotency: the postCreateCommand already re-ran setup-mounts.sh at container
# start (which must not have created a second backup). Run it once more and
# assert a single .IdentityService.bak remains after all of them.
MOUNTS_PHASE=runtime /usr/local/share/devcontainer-features/azure-artifacts-mounts/setup-mounts.sh \
    "$HOME" --pairs-file /usr/local/share/devcontainer-features/azure-artifacts-mounts/mounts.txt

backup_count="$(find "$HOME/.local" -maxdepth 1 -name '.IdentityService.bak*' | wc -l)"
check "only one backup exists" test "$backup_count" = 1

reportResults
