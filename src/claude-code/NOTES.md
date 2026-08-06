# Notes

## Installation

This feature uses Claude's native installer script (`https://claude.ai/install.sh`) rather than `npm install -g @anthropic-ai/claude-code`. The native installer is the currently recommended installation method (npm install is deprecated upstream) and it installs Claude Code **per-user** under the remote user's home:

- Binary: `~/.local/bin/claude`
- Shared data: `~/.local/share/claude`

The install runs as the remote user (`$_REMOTE_USER`) so those paths land in the user's home and not under `/root`.

## PATH

The feature adds `~/.local/bin` to `PATH` for **login shells** via `/etc/profile.d/claude-code.sh`. This covers `bash`/`sh` login shells. If the remote user's default shell is **zsh** (or fish), the profile script may not be sourced and `claude` may not be on `PATH`; add the path to the user's shell rc manually in that case.

## Requirements

- `bash` is required: the installer is executed with `bash -s`. Feature scripts run as root, and tools that implement the dev container spec set `_REMOTE_USER` / `_REMOTE_USER_HOME`.
- A download tool is needed: `wget`, `wcurl`, or `curl` (chosen in that order).
- The installer downloads a binary at build time, so network access to `claude.ai` is required during image build.

## Version

The `version` option defaults to `latest`. The installer's version-handling is best effort; validate a pin resolves cleanly before relying on it in production images. Tests pin a specific version (`2.1.50`) so manifest `proposals` and the pinned test version should be kept in sync when bumping.

## Relationship to the official Anthropic feature

This is a **separate** community feature from `ghcr.io/anthropics/devcontainer-features/claude-code`. If you also use `claude-code-mounts` from this repo, use this repo's `claude-code` feature so config symlinks and install ordering stay consistent.
