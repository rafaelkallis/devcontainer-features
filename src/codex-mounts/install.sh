#!/bin/sh
set -eu

echo "Activating feature 'codex-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
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

# Install the mount-setup helper and the runtime re-run script to a persistent
# directory. The staged feature folder is removed from the image after the
# build, and the postCreateCommand needs to survive to container start.
feature_dir="/usr/local/share/devcontainer-features/codex-mounts"
install -d -m 0755 "$feature_dir"
install -m 0755 "$(dirname "$0")/setup-mounts.sh" "$feature_dir/setup-mounts.sh"

# <relative-target> <mount-path> pairs consumed by setup-mounts.sh
cat > "$feature_dir/mounts.txt" <<'EOF'
.codex /mnt/.codex
EOF

cat > "$feature_dir/post-create.sh" <<EOF
#!/bin/sh
set -eu
home="\${HOME:-}"
if [ -z "\$home" ]; then
  echo "ERROR: \$HOME is not set; cannot set up codex-mounts." >&2
  exit 1
fi
MOUNTS_PHASE=runtime "$feature_dir/setup-mounts.sh" "\$home" --pairs-file "$feature_dir/mounts.txt"
EOF
chmod 0755 "$feature_dir/post-create.sh"

# Build-time pass: create the symlinks now so the image is self-contained even
# if feature lifecycle hooks are not run. The /mnt targets usually do not exist
# yet (feature mounts are applied at container start), so setup-mounts.sh is
# invoked in build phase, which skips the missing-mount warning.
MOUNTS_PHASE=build "$feature_dir/setup-mounts.sh" "$_REMOTE_USER_HOME" --pairs-file "$feature_dir/mounts.txt"
