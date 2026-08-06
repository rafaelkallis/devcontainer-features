#!/bin/bash

set -e

source dev-container-features-test-lib

# Check mount point exists
check "/mnt/.azure exists" test -d "/mnt/.azure"

# Check symlink exists and points to correct location
check ".azure symlink exists" test -L "$HOME/.azure"
check ".azure points to /mnt/.azure" test "$(readlink "$HOME/.azure")" = "/mnt/.azure"

reportResults
