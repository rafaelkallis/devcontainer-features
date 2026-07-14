#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "ubuntu" grep -qi "ubuntu" /etc/os-release
check_claude_common

reportResults
