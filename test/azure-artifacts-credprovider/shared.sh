#!/bin/bash

set -e

# Shared test helpers for azure-artifacts-credprovider feature

check_credprovider_common() {
    check "credential provider plugin dir exists" test -d "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft"
    check "credential provider plugin dll exists" test -f "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.dll"
    check "plugin dir not owned by root" test "$(stat -c '%U' "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft")" != "root"
}
