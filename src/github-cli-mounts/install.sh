#!/bin/sh
set -eu

echo "Activating feature 'github-cli-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
fi

# Its behavior also depends on feature-level "mounts" being honored.
if [ ! -e "/mnt/.config/gh" ]; then
  cat <<EOF

WARNING: Mounted host config not found at /mnt/.config/gh.
This feature relies on a tool that supports feature-level "mounts" in devcontainer-feature.json.
The symlink will be created anyway, but it may point to a non-existent target if the
mount was not applied.

EOF
fi

# Check if GitHub CLI is installed
if ! command -v gh >/dev/null 2>&1; then
    cat <<EOF

WARNING: GitHub CLI was not found.
Please ensure the GitHub CLI is installed in your dev container.

  You can install it via:
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

Or add the github-cli feature to your devcontainer.json:
    "ghcr.io/devcontainers/features/github-cli:1": {}

EOF
fi

# Backup existing directory if it exists and is not already a symlink
target=".config/gh"
path="$_REMOTE_USER_HOME/$target"
if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "$path.bak" ]; then
    echo "Backing up existing $path to $path.bak"
    mv "$path" "$path.bak"
fi

# Create symlink from the user's home directory to the mounted location
mkdir -p "$_REMOTE_USER_HOME/.config"
ln -sfn /mnt/.config/gh "$path"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$path"
