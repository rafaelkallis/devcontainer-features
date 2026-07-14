#!/bin/bash

set -e

# Shared test helpers for claude-code feature

check_claude_common() {
    check "claude cli installed" command -v claude
    check "claude version" claude --version
}
