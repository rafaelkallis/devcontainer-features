#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "running as vscode" test "$(whoami)" = "vscode"
check_credprovider_common
check "plugin dir lives under remote user's home" sh -c "echo \"\$HOME\" | grep -q '/home/vscode'"

reportResults
