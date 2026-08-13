#!/bin/bash

set -euo pipefail

cp_version="${VERSION:-"latest"}"
cp_install_script_url="https://aka.ms/install-artifacts-credprovider.sh"
cp_install_libsecret="${INSTALLLIBSECRETANDXDGUTILS:-"true"}"

echo "Activating feature 'azure-artifacts-credprovider'"

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Guard with `:-` so `set -u` does not abort before we can print a helpful message.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo -e 'Feature script must be executed by a tool that implements the dev container specification. See https://containers.dev/ for more information.'
  exit 1
fi

# Detect OS / libc for messaging and prereqs. The upstream installer provides
# self-contained .NET 8 builds for glibc (Debian/Ubuntu), but falls back to a
# runtime-dependent build on Alpine (musl) which needs extra .NET runtime libs.
# We scope full support to Debian/Ubuntu and degrade gracefully elsewhere.
os_id=""
if [ -r /etc/os-release ]; then
  os_id="$(. /etc/os-release && printf '%s' "${ID:-}")"
fi

if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl; then
  is_musl=1
else
  is_musl=0
fi

case "${os_id}" in
  debian | ubuntu)
    distro="debian"
    ;;
  alpine)
    distro="alpine"
    ;;
  *)
    distro="other"
    ;;
esac

if [ "${is_musl}" -eq 1 ] || [ "${distro}" = "alpine" ]; then
  cat >&2 <<'EOF'

WARNING: This feature is fully supported on Debian/Ubuntu (glibc) base images.
On Alpine/musl the upstream installer falls back to a runtime-dependent .NET 8
credential provider, which requires .NET native libraries (libicu, libssl) that
this feature intentionally does not install. The install will still be attempted,
but interactive OAuth may not work unless you provide those libraries yourself.

EOF
fi

# Install interactive-auth prereqs on Debian/Ubuntu when requested.
# libsecret-1-0 persists the MSAL token cache; xdg-utils opens the browser.
if [ "${cp_install_libsecret}" = "true" ] && [ "${distro}" = "debian" ]; then
  if command -v apt-get >/dev/null 2>&1; then
    echo "Installing libsecret-1-0 and xdg-utils (interactive auth prereqs)..."
    export DEBIAN_FRONTEND=noninteractive
    if ! apt-get update -qq >/dev/null 2>&1; then
      echo "WARNING: apt-get update failed; skipping libsecret/xdg-utils install." >&2
    else
      apt-get install -y -qq --no-install-recommends libsecret-1-0 xdg-utils >/dev/null 2>&1 || \
        echo "WARNING: failed to install libsecret-1-0 / xdg-utils." >&2
      rm -rf /var/lib/apt/lists/*
    fi
  fi
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
# user's shell. 'latest' is an explicit channel; anything else must look like a
# semantic version tag (e.g. 2.0.4), optionally prefixed with 'v' (v2.0.4).
case "${cp_version}" in
  latest)
    ;;
  v[0-9]*.[0-9]*.[0-9]* | [0-9]*.[0-9]*.[0-9]*)
    if ! printf '%s' "${cp_version}" | grep -Eq '^v?[0-9]+\.[0-9]+\.[0-9]+$'; then
      echo "ERROR: Unsupported version '${cp_version}'. Use 'latest' or a semantic version like '2.0.4'." >&2
      exit 1
    fi
    ;;
  *)
    echo "ERROR: Unsupported version '${cp_version}'. Use 'latest' or a semantic version like '2.0.4'." >&2
    exit 1
    ;;
esac

# Escape before interpolating into the remote user's shell command. bash's %q
# produces a safely shell-quoted form for values such as URLs and versions.
printf -v cp_install_script_url_q '%q' "${cp_install_script_url}"
printf -v cp_version_q '%q' "${cp_version}"

# Run the upstream installer as the remote user so the plugin lands under
# $HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft (not /root).
# The installer reads AZURE_ARTIFACTS_CREDENTIAL_PROVIDER_VERSION to pin a
# release tag; unset means "latest".
echo "Installing Azure Artifacts Credential Provider as ${_REMOTE_USER} (version ${cp_version})..."
su -l "${_REMOTE_USER}" -c "AZURE_ARTIFACTS_CREDENTIAL_PROVIDER_VERSION='${cp_version_q}' ${download_cmd} '${cp_install_script_url_q}' | bash"

# Verify the installation: the netcore plugin binary must exist and be runnable.
cp_plugin_bin="${_REMOTE_USER_HOME}/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.dll"
cp_plugin_dir="$(dirname "${cp_plugin_bin}")"
if [ ! -d "${cp_plugin_dir}" ]; then
  echo "ERROR: Azure Artifacts Credential Provider installation failed, plugin directory not found: ${cp_plugin_dir}" >&2
  exit 1
fi
if [ ! -f "${cp_plugin_bin}" ]; then
  echo "ERROR: Azure Artifacts Credential Provider installation failed, plugin binary not found: ${cp_plugin_bin}" >&2
  exit 1
fi

# Fix ownership in case any install artifact landed as root (belt and braces:
# the install ran as the remote user, but chown -h style safety is cheap).
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${cp_plugin_dir}"

echo "Azure Artifacts Credential Provider successfully installed for ${_REMOTE_USER}!"
