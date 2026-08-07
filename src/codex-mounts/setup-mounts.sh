#!/bin/sh
set -eu

# setup-mounts.sh <home> --pairs-file <file>
#
# Reads <relative-target> <mount-path> pairs (one per line) from <file> and
# idempotently symlinks each mount into <home>. Lines beginning with '#' and
# blank lines are ignored.
#
# Two phases (controlled by the MOUNTS_PHASE env var):
#   1. build  (from install.sh, as root): creates the symlinks so the image is
#      self-contained. The /mnt targets may not exist yet — feature mounts are
#      only applied at container start, not during the build.
#   2. runtime (from the feature's postCreateCommand, as the remote user):
#      re-runs the same idempotent setup once the mounts exist. Only then do we
#      warn if a mount target is genuinely missing (e.g. the tool ignored
#      feature mounts).
#
# The helper is installed to a persistent directory by install.sh, because the
# staged feature folder is removed from the image after the build.

home="${1:-}"
if [ -z "$home" ] || [ ! -d "$home" ]; then
    echo "ERROR: Remote user home '$home' does not exist." >&2
    exit 1
fi
shift

pairs_file=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --pairs-file)
            pairs_file="${2:-}"
            shift 2
            ;;
        *)
            echo "ERROR: Unknown argument '$1'." >&2
            exit 1
            ;;
    esac
done

if [ -z "$pairs_file" ] || [ ! -r "$pairs_file" ]; then
    echo "ERROR: Mounts pairs file '$pairs_file' is not readable." >&2
    exit 1
fi

mount_should_exist="${MOUNTS_PHASE:-build}"

while read -r target mount_path _rest; do
    case "$target" in
        '' | \#*) continue ;;
    esac

    if [ -z "$mount_path" ]; then
        echo "WARNING: Ignoring malformed mounts entry for '$target'." >&2
        continue
    fi

    dest="$home/$target"

    # At build time the mounts don't exist yet, so only warn at runtime when the
    # mount should actually be present.
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
done < "$pairs_file"
