#!/bin/bash

set -euo pipefail

cc_version="${VERSION:-"latest"}"
cc_install_script_url="https://claude.ai/install.sh"

echo "Activating feature 'claude-code'"

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

if [ -z "${_REMOTE_USER}" ]; then
  echo -e 'Feature script must be executed by a tool that implements the dev container specification. See https://containers.dev/ for more information.'
  exit 1
fi

# Determine available download command
if command -v wget >/dev/null 2>&1; then
  download_cmd="wget -q -O -"
elif command -v wcurl >/dev/null 2>&1; then
  download_cmd="wcurl -fsSL"
elif command -v curl >/dev/null 2>&1; then
  download_cmd="curl -fsSL"
else
  echo "ERROR: Either wget, wcurl, or curl is required but none are installed" >&2
  exit 1
fi

# Run the native installer as the remote user so it installs to
# ~/.local/bin/claude and ~/.local/share/claude under the user's home.
echo "Installing Claude Code CLI as ${_REMOTE_USER}..."
su -l "${_REMOTE_USER}" -c "${download_cmd} '${cc_install_script_url}' | bash -s '${cc_version}'"

# Verify the installation
cc_bin_path="${_REMOTE_USER_HOME}/.local/bin/claude"
if ! [ -x "${cc_bin_path}" ]; then
  echo "ERROR: Claude Code CLI installation failed, binary not found or not executable: ${cc_bin_path}" >&2
  exit 1
fi

cc_share_path="${_REMOTE_USER_HOME}/.local/share/claude"
if ! [ -d "${cc_share_path}" ]; then
  echo "ERROR: Claude Code CLI installation failed, share directory not found: ${cc_share_path}" >&2
  exit 1
fi

# Ensure ~/.local/bin is on PATH for login shells
cat > /etc/profile.d/claude-code.sh << 'PROFILE'
# Added by claude-code devcontainer feature
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  export PATH="$HOME/.local/bin:$PATH"
fi
PROFILE
chmod 644 /etc/profile.d/claude-code.sh

echo "Claude Code CLI successfully installed!"
