#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "ubuntu 24.04" grep -q "24.04" /etc/os-release
check_mounts_common

reportResults
