#!/bin/sh
set -eu

echo "Activating feature 'claude-code-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME
# (e.g. VS Code or the devcontainer CLI). Bail out early rather than writing to a bogus path.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
fi

# Its behavior also depends on feature-level "mounts" being honored.
# Some tools/versions ignore a feature manifest's mounts, in which case /mnt/.claude and
# /mnt/.claude.json will NOT exist and the symlinks below would silently dangle.
if [ ! -e "/mnt/.claude" ] || [ ! -e "/mnt/.claude.json" ]; then
  cat <<EOF

WARNING: Mounted host config not found at /mnt/.claude or /mnt/.claude.json.
This feature relies on a tool that supports feature-level "mounts" in devcontainer-feature.json.
The symlinks will be created anyway, but they may point to non-existent targets if the
mounts were not applied.

EOF
fi

# Check if Claude Code CLI is installed
if ! command -v claude >/dev/null 2>&1; then
    cat <<EOF

WARNING: Claude Code CLI was not found.
Please ensure the Claude Code feature is added to your devcontainer.json:

  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code": {},
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code-mounts": {}
  }

EOF
fi

# Backup existing files/directories if they exist and are not already symlinks
for target in .claude .claude.json; do
    path="$_REMOTE_USER_HOME/$target"
    if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "$path.bak" ]; then
        echo "Backing up existing $path to $path.bak"
        mv "$path" "$path.bak"
    fi

done

# Create symlinks from the user's home directory to the mounted locations
ln -sfn /mnt/.claude "$_REMOTE_USER_HOME/.claude"
ln -sfn /mnt/.claude.json "$_REMOTE_USER_HOME/.claude.json"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$_REMOTE_USER_HOME/.claude" "$_REMOTE_USER_HOME/.claude.json"
