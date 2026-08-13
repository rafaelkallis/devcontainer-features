#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "debian 12" grep -q "12" /etc/debian_version
check_mounts_common

reportResults
