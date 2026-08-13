#!/bin/bash

set -e

# Shared test helpers for azure-artifacts-mounts feature

check_mounts_common() {
    check "/mnt/.IdentityService exists" test -d "/mnt/.IdentityService"
    check ".local/.IdentityService symlink exists" test -L "$HOME/.local/.IdentityService"
    check ".local/.IdentityService points to /mnt/.IdentityService" test "$(readlink "$HOME/.local/.IdentityService")" = "/mnt/.IdentityService"
    check ".local/.IdentityService symlink not owned by root" test "$(stat -c '%U' "$HOME/.local/.IdentityService")" != "root"
    # The credential provider must be able to create msal.cache / msal.cache.lockfile
    # inside the volume, so the mount must be writable by the remote user.
    check "/mnt/.IdentityService is writable by remote user" test -w /mnt/.IdentityService
}
