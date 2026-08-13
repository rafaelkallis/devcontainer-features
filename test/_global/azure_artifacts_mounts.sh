#!/bin/bash

set -e

source dev-container-features-test-lib

check ".local/.IdentityService points to /mnt/.IdentityService" test "$(readlink "$HOME/.local/.IdentityService")" = "/mnt/.IdentityService"

reportResults
