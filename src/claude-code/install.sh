#!/bin/bash

set -euo pipefail

cc_version="${VERSION:-"latest"}"
cc_install_script_url="https://claude.ai/install.sh"

echo "Activating feature 'claude-code'"

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Guard with `:-` so `set -u` does not abort before we can print a helpful message.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
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

# Validate the requested version so it cannot inject commands into the remote
# user's shell. 'latest' and 'stable' are explicit channel names; anything else
# must look like a semantic version (e.g. 2.1.50).
case "${cc_version}" in
  latest|stable)
    ;;
  [0-9]*.[0-9]*.[0-9]*)
    # Ensure only digits and '.' are present (a naive glob like [0-9]*.[0-9]*.
    # [0-9]* would also match e.g. "2x1x3" because '.' matches any char).
    if ! printf '%s' "${cc_version}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      echo "ERROR: Unsupported version '${cc_version}'. Use 'latest', 'stable', or a semantic version like '2.1.50'." >&2
      exit 1
    fi
    ;;
  *)
    echo "ERROR: Unsupported version '${cc_version}'. Use 'latest', 'stable', or a semantic version like '2.1.50'." >&2
    exit 1
    ;;
esac

# Escape before interpolating into the remote user's shell command. bash's %q
# produces a safely shell-quoted form for values such as URLs and versions.
printf -v cc_install_script_url_q '%q' "${cc_install_script_url}"
printf -v cc_version_q '%q' "${cc_version}"

# Run the native installer as the remote user so it installs to
# ~/.local/bin/claude and ~/.local/share/claude under the user's home.
echo "Installing Claude Code CLI as ${_REMOTE_USER} (version ${cc_version})..."
su -l "${_REMOTE_USER}" -c "${download_cmd} ${cc_install_script_url_q} | bash -s ${cc_version_q}"

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

# Ensure ~/.local/bin is on PATH for login shells (bash/sh).
cat > /etc/profile.d/claude-code.sh << 'PROFILE'
# Added by claude-code devcontainer feature
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  export PATH="$HOME/.local/bin:$PATH"
fi
PROFILE
chmod 644 /etc/profile.d/claude-code.sh

# Ensure ~/.local/bin is on PATH for zsh too (/etc/profile.d is not sourced by
# zsh login shells). Append idempotently to the global zsh rc if one exists.
for zshrc in /etc/zsh/zshrc /etc/zshrc; do
  if [ -e "${zshrc}" ]; then
    if ! grep -q 'claude-code devcontainer feature' "${zshrc}" 2>/dev/null; then
      cat >> "${zshrc}" <<'EOS'

# Added by claude-code devcontainer feature
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  export PATH="$HOME/.local/bin:$PATH"
fi
EOS
    fi
    break
  fi
done

echo "Claude Code CLI successfully installed!"
