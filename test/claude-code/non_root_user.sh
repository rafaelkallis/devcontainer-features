#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "running as vscode" test "$(whoami)" = "vscode"
check_claude_common
check "profile.d script exists" test -f /etc/profile.d/claude-code.sh
check "profile.d has .local/bin path" grep -q "local/bin" /etc/profile.d/claude-code.sh

reportResults
