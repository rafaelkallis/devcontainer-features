#!/bin/sh
set -eu

echo "Activating feature 'codex-mounts'"

# Check if Codex CLI is installed
if ! command -v codex >/dev/null 2>&1; then
    cat <<EOF

WARNING: Codex CLI was not found.
Please ensure the Codex CLI is installed in your dev container.

  You can install it via:
    curl -fsSL https://chatgpt.com/codex/install.sh | bash

Or add the following to your Dockerfile:
    RUN curl -fsSL https://chatgpt.com/codex/install.sh | bash

EOF
fi

# Backup existing directory if it exists and is not already a symlink
target=".codex"
path="$_REMOTE_USER_HOME/$target"
if [ -e "$path" ] && [ ! -L "$path" ]; then
    echo "Backing up existing $path to $path.bak"
    mv "$path" "$path.bak"
fi

# Create symlink from the user's home directory to the mounted location
ln -sf /mnt/.codex "$path"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$path"
