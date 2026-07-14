#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "claude cli installed" command -v claude
check "claude version 2.1.49" claude --version 2>&1 | grep -q "2.1.49"

reportResults
