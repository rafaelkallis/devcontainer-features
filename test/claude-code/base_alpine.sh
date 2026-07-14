#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "alpine" grep -qi "alpine" /etc/os-release
check_claude_common

reportResults
