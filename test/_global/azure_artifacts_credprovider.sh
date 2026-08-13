#!/bin/bash

set -e

source dev-container-features-test-lib

check "credential provider plugin dir exists" test -d "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft"
check "credential provider plugin dll exists" test -f "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.dll"

reportResults
