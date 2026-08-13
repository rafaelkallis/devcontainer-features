#!/bin/bash

set -e

source dev-container-features-test-lib

# Check the mount target exists (the named volume attached at /mnt/.IdentityService)
check "/mnt/.IdentityService exists" test -d "/mnt/.IdentityService"

# Check symlink exists and points to the volume mount
check ".local/.IdentityService symlink exists" test -L "$HOME/.local/.IdentityService"
check ".local/.IdentityService points to /mnt/.IdentityService" test "$(readlink "$HOME/.local/.IdentityService")" = "/mnt/.IdentityService"

reportResults
