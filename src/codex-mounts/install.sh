#!/bin/sh
set -eu

echo "Activating feature 'codex-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
fi

# Its behavior also depends on feature-level "mounts" being honored.
if [ ! -e "/mnt/.codex" ]; then
  cat <<EOF

WARNING: Mounted host config not found at /mnt/.codex.
This feature relies on a tool that supports feature-level "mounts" in devcontainer-feature.json.
The symlink will be created anyway, but it may point to a non-existent target if the
mount was not applied.

EOF
fi

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
if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "$path.bak" ]; then
    echo "Backing up existing $path to $path.bak"
    mv "$path" "$path.bak"
fi

# Create symlink from the user's home directory to the mounted location
ln -sfn /mnt/.codex "$path"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$path"
