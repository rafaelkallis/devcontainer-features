#!/bin/bash

set -e

source dev-container-features-test-lib

check ".azure symlink still exists after duplication" test -L "$HOME/.azure"
check ".azure still points to /mnt/.azure" test "$(readlink "$HOME/.azure")" = "/mnt/.azure"

reportResults
