#!/bin/sh
set -eu

echo "Activating feature 'claude-code-mounts'"

# Create symlinks from the user's home directory to the mounted locations
ln -sf /mnt/.claude "$_REMOTE_USER_HOME/.claude"
ln -sf /mnt/.claude.json "$_REMOTE_USER_HOME/.claude.json"

chown -h "$_REMOTE_USER:$_REMOTE_USER" "$_REMOTE_USER_HOME/.claude" "$_REMOTE_USER_HOME/.claude.json"
