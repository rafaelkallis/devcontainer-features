#!/bin/bash

set -e

source dev-container-features-test-lib

check ".config/gh symlink still exists after duplication" test -L "$HOME/.config/gh"
check ".config/gh still points to /mnt/.config/gh" test "$(readlink "$HOME/.config/gh")" = "/mnt/.config/gh"

reportResults
