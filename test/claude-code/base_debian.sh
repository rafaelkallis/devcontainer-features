#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "debian" grep -qi "debian" /etc/os-release
check_claude_common

reportResults
