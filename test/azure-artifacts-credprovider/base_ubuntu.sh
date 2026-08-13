#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "ubuntu" grep -qi "ubuntu" /etc/os-release
check_credprovider_common
check "libsecret installed" dpkg -s libsecret-1-0 >/dev/null 2>&1
check "xdg-utils installed" dpkg -s xdg-utils >/dev/null 2>&1

reportResults
