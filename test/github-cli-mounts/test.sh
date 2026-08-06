#!/bin/bash

set -e

source dev-container-features-test-lib

# Check mount point exists
check "/mnt/.config/gh exists" test -d "/mnt/.config/gh"

# Check symlink exists and points to correct location
check ".config/gh symlink exists" test -L "$HOME/.config/gh"
check ".config/gh points to /mnt/.config/gh" test "$(readlink "$HOME/.config/gh")" = "/mnt/.config/gh"

reportResults
