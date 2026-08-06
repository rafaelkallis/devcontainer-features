# Notes

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the running tool (VS Code / devcontainer CLI) honoring the `mounts` array in `devcontainer-feature.json` to bind the host config onto `/mnt/.claude` and `/mnt/.claude.json`. If the tool ignores feature `mounts`, the symlinks created in the container will dangle (point to non-existent targets).
- **Runtime check.** The symlinks are created at build time (so the image is self-contained). Because feature mounts are only applied at container start, the build pass cannot verify them. A `postCreateCommand` re-runs the setup once the container exists and warns if `/mnt/.claude` or `/mnt/.claude.json` is genuinely missing — that warning is the signal that feature `mounts` were not honored.
- **Host config must exist.** At build time the bind mount source (`~/.claude` and `~/.claude.json` on the host) must exist, or container/tooling that applies feature mounts will fail to start. Tests create mock versions of these on the host beforehand.

## Permissions

`chown -h` only updates ownership of the symlink itself, not the mounted content on `/mnt`. The mounted files keep host-side ownership and permissions. If you hit permission errors inside the container, fix the ownership/permissions of `~/.claude` and `~/.claude.json` on the host (or remount with relaxed options).
