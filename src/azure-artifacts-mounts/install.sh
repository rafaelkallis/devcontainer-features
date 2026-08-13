#!/bin/sh
set -eu

echo "Activating feature 'azure-artifacts-mounts'"

# This feature relies on the dev container tooling setting _REMOTE_USER/_REMOTE_USER_HOME.
if [ -z "${_REMOTE_USER:-}" ] || [ -z "${_REMOTE_USER_HOME:-}" ]; then
  echo "ERROR: Feature script must be executed by a tool that implements the dev container spec." >&2
  exit 1
fi

# Install the mount-setup helper and the runtime re-run script to a persistent
# directory. The staged feature folder is removed from the image after the
# build, and the postCreateCommand needs to survive to container start.
feature_dir="/usr/local/share/devcontainer-features/azure-artifacts-mounts"
install -d -m 0755 "$feature_dir"
install -m 0755 "$(dirname "$0")/setup-mounts.sh" "$feature_dir/setup-mounts.sh"

# <relative-target> <mount-path> pairs consumed by setup-mounts.sh
cat > "$feature_dir/mounts.txt" <<'EOF'
.local/.IdentityService /mnt/.IdentityService
EOF

# The mount target lives at $HOME/.local/.IdentityService, and base images do
# not ship a ~/.local. If we let setup-mounts.sh create .local during the
# build-time pass (running as root) it would be root-owned, and the runtime
# postCreateCommand (running as the remote user) would not be able to write its
# symlink inside it. Pre-create .local owned by the remote user so the runtime
# re-run is idempotent and succeeds.
mkdir -p "$_REMOTE_USER_HOME/.local"
chown "$_REMOTE_USER:$_REMOTE_USER" "$_REMOTE_USER_HOME/.local"

cat > "$feature_dir/post-create.sh" <<EOF
#!/bin/sh
set -eu
home="\${HOME:-}"
if [ -z "\$home" ]; then
  echo "ERROR: \$HOME is not set; cannot set up azure-artifacts-mounts." >&2
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
