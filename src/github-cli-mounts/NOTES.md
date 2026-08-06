# Notes

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the running tool (VS Code / devcontainer CLI) honoring the `mounts` array in `devcontainer-feature.json` to bind the host config onto `/mnt/.config/gh`. If the tool ignores feature `mounts`, the symlink created in the container will dangle (point to a non-existent target).
- **Runtime check.** The symlink is created at build time (so the image is self-contained). Because feature mounts are only applied at container start, the build pass cannot verify them. A `postCreateCommand` re-runs the setup once the container exists and warns if `/mnt/.config/gh` is genuinely missing — that warning is the signal that feature `mounts` were not honored.
- **Host config must exist.** At build time the bind mount source `~/.config/gh` on the host must exist. Tests create a mock version of it on the host beforehand.

## Permissions

`chown -h` only updates ownership of the symlink itself, not the mounted content on `/mnt`. The mounted directory keeps host-side ownership and permissions. If you hit permission errors inside the container, fix the ownership/permissions of `~/.config/gh` on the host.

## Platform caveats

- **macOS stores GitHub auth in the Keychain, not `~/.config/gh`.** `gh auth login` stores your token in the macOS Keychain via the `osxkeychain` credential helper by default; `~/.config/gh/hosts.yml` only contains the token when the default keyring isn't used (e.g. `GH_TOKEN`, a custom credential helper, or a non-Keychain setup). Mounting `~/.config/gh` alone may therefore **not** transfer your `gh` authentication into the container. Re-authenticate with `gh auth login` inside the container if git/gh prompts for credentials.
- **Windows** uses the Windows Credential Manager in the same way; the same caveat applies.
