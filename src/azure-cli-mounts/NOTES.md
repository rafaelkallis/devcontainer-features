# Notes

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the running tool (VS Code / devcontainer CLI) honoring the `mounts` array in `devcontainer-feature.json` to bind the host config onto `/mnt/.azure`. If the tool ignores feature `mounts`, the symlink created in the container will dangle. The install script prints a warning but continues.
- **Host config must exist.** At build time the bind mount source `~/.azure` on the host must exist. Tests create a mock version of it on the host beforehand.

## Permissions

`chown -h` only updates ownership of the symlink itself, not the mounted content on `/mnt`. The mounted directory keeps host-side ownership and permissions. If you hit permission errors inside the container, fix the ownership/permissions of `~/.azure` on the host.
