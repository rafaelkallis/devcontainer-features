#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "debian 13" grep -q "13" /etc/debian_version
check_mounts_common

reportResults
