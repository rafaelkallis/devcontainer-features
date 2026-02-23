#!/bin/bash

set -e

source dev-container-features-test-lib

check "claude cli installed" command -v claude
check "claude version" claude --version
check "claude update check" claude update

reportResults
