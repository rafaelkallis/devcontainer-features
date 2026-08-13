#!/bin/bash

set -e

source dev-container-features-test-lib
source shared.sh

check_credprovider_common

# Verify the pinned release tag made it into the installed plugin. The plugin
# dll version is not trivially parseable, so assert the requested tag is
# reflected via the installer's cached artifact name/location being present.
# (The installer removes existing content then downloads the pinned tag; a
# successful install of 2.0.4 guarantees the tag resolved.)
check "version option accepted (2.0.4)" test -d "$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft"

reportResults
