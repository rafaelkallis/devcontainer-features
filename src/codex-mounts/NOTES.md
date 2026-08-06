# Notes

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the running tool (VS Code / devcontainer CLI) honoring the `mounts` array in `devcontainer-feature.json` to bind the host config onto `/mnt/.codex`. If the tool ignores feature `mounts`, the symlink created in the container will dangle (point to a non-existent target).
- **Runtime check.** The symlink is created at build time (so the image is self-contained). Because feature mounts are only applied at container start, the build pass cannot verify them. A `postCreateCommand` re-runs the setup once the container exists and warns if `/mnt/.codex` is genuinely missing — that warning is the signal that feature `mounts` were not honored.
- **Host config must exist.** At build time the bind mount source `~/.codex` on the host must exist. Tests create a mock version of it on the host beforehand.

## Permissions

`chown -h` only updates ownership of the symlink itself, not the mounted content on `/mnt`. The mounted directory keeps host-side ownership and permissions. If you hit permission errors inside the container, fix the ownership/permissions of `~/.codex` on the host.
