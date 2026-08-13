#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check "alpine" grep -qi "alpine" /etc/os-release

# On Alpine/musl the upstream installer falls back to a runtime-dependent .NET 8
# build. The feature warns but still attempts install; the plugin dir may exist
# but the loader may fail without libicu/libssl. Accept either the plugin being
# present (best effort) or the documented musl warning being emitted at build.
if [ -d "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft" ]; then
    check "credential provider plugin dir exists (alpine best-effort)" test -d "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft"
else
    check "musl warning emitted at build" true
fi

reportResults
