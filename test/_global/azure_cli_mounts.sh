#!/bin/bash

set -e

source dev-container-features-test-lib

check ".azure points to /mnt/.azure" test "$(readlink "$HOME/.azure")" = "/mnt/.azure"

reportResults
