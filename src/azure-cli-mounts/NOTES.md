# Notes

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the running tool (VS Code / devcontainer CLI) honoring the `mounts` array in `devcontainer-feature.json` to bind the host config onto `/mnt/.azure`. If the tool ignores feature `mounts`, the symlink created in the container will dangle. The install script prints a warning but continues.
- **Host config must exist.** At build time the bind mount source `~/.azure` on the host must exist. Tests create a mock version of it on the host beforehand.

## Permissions

`chown -h` only updates ownership of the symlink itself, not the mounted content on `/mnt`. The mounted directory keeps host-side ownership and permissions. If you hit permission errors inside the container, fix the ownership/permissions of `~/.azure` on the host.

## Platform caveats

- **macOS stores Azure auth in the Keychain, not `~/.azure`.** The Azure CLI keeps the refresh token in the macOS Keychain (via MSAL); `~/.azure` may only hold non-secret config and the token cache. Mounting `~/.azure` alone may therefore **not** transfer your `az` login into the container. Sign in again with `az login` inside the container, or configure the CLI to not use the OS keychain if you need file-based auth.
- **Windows** stores tokens in the Windows Credential Manager for the same reason; the same caveat applies.
