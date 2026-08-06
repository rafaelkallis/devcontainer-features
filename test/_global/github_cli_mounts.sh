#!/bin/bash

set -e

source dev-container-features-test-lib

check ".config/gh points to /mnt/.config/gh" test "$(readlink "$HOME/.config/gh")" = "/mnt/.config/gh"

reportResults
