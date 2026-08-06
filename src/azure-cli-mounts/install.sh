#!/bin/sh
set -eu

echo "Activating feature 'azure-cli-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
fi

# Its behavior also depends on feature-level "mounts" being honored.
if [ ! -e "/mnt/.azure" ]; then
  cat <<EOF

WARNING: Mounted host config not found at /mnt/.azure.
This feature relies on a tool that supports feature-level "mounts" in devcontainer-feature.json.
The symlink will be created anyway, but it may point to a non-existent target if the
mount was not applied.

EOF
fi

# Check if Azure CLI is installed
if ! command -v az >/dev/null 2>&1; then
    cat <<EOF

WARNING: Azure CLI was not found.
Please ensure the Azure CLI is installed in your dev container.

  You can install it via:
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

Or add the azure-cli feature to your devcontainer.json:
    "ghcr.io/devcontainers/features/azure-cli:1": {}

EOF
fi

# Backup existing directory if it exists and is not already a symlink
target=".azure"
path="$_REMOTE_USER_HOME/$target"
if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "$path.bak" ]; then
    echo "Backing up existing $path to $path.bak"
    mv "$path" "$path.bak"
fi

# Create symlink from the user's home directory to the mounted location
ln -sfn /mnt/.azure "$path"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$path"
