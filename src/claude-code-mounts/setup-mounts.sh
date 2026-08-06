#!/bin/sh
set -eu

# setup-mounts.sh — idempotently symlink host config mounts into the remote
# user's home.
#
# Two phases:
#   1. Build time (from install.sh, as root): creates the symlinks so the image
#      is self-contained. The /mnt targets may not exist yet — feature mounts
#      are only applied at container start, not during the build.
#   2. Runtime (from the feature's postCreateCommand, as the remote user):
#      re-runs the same idempotent setup once the mounts exist. Only then do we
#      warn if a mount target is genuinely missing (e.g. the tool ignored
#      feature mounts).
#
# The helper is installed to a persistent directory by install.sh, because the
# staged feature folder is removed from the image after the build.
#
# Usage:
#   setup-mounts.sh <home> <target> <mount-path> [<target> <mount-path> ...]

home="$1"
shift

# Guard: we need a real home to write into.
if [ -z "$home" ] || [ ! -d "$home" ]; then
    echo "ERROR: Remote user home '$home' does not exist." >&2
    exit 1
fi

while [ "$#" -ge 2 ]; do
    target="$1"
    mount_path="$2"
    shift 2

    dest="$home/$target"

    # At build time the mounts don't exist yet, so only warn at runtime when the
    # mount should actually be present. install.sh runs as root with
    # _REMOTE_USER_HOME set; the postCreateCommand runs as the remote user with
    # $HOME set, so we can tell the two phases apart by the env it was invoked
    # under — but this helper is called from install.sh with an explicit phase.
    mount_should_exist="${MOUNTS_PHASE:-build}"
    if [ "$mount_should_exist" = "runtime" ] && [ ! -e "$mount_path" ]; then
        cat <<EOF

WARNING: Mounted host config not found at $mount_path.
This feature relies on a tool that supports feature-level "mounts" in
devcontainer-feature.json. The symlink below will point to a non-existent
target.

EOF
    fi

    if [ -e "$dest" ] && [ ! -L "$dest" ] && [ ! -e "$dest.bak" ]; then
        echo "Backing up existing $dest to $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sfn "$mount_path" "$dest"

    # chown only at build time (running as root); at runtime the remote user
    # already owns the symlink.
    if [ "$(id -u)" -eq 0 ] && [ -n "${_REMOTE_USER:-}" ] && [ "$mount_should_exist" = "build" ]; then
        chown -h "$_REMOTE_USER:$_REMOTE_USER" "$dest"
    fi
done
