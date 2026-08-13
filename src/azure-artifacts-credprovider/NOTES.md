# Notes

## Installation

This feature installs the [Azure Artifacts Credential Provider](https://github.com/microsoft/artifacts-credprovider)
using the official upstream installer (`https://aka.ms/install-artifacts-credprovider.sh`)
rather than the .NET global tool. This is the recommended approach for dev
containers: the installer fetches **self-contained** .NET 8 `netcore` plugin
binaries, so **no .NET SDK is required** on glibc (Debian/Ubuntu) images.

The plugin is installed **per-user** as the `$_REMOTE_USER`:

```
$HOME/.nuget/plugins/netcore/CredentialProvider.Microsoft/
  CredentialProvider.Microsoft.dll
```

`dotnet`, `nuget.exe` (via partial support), and MSBuild discover the plugin
through NuGet's plugin-search path (`~/.nuget/plugins/netcore`), so no `PATH`
change is needed. Running `dotnet restore --interactive` against a private
Azure Artifacts feed will then trigger (once) an OAuth flow.

## Prerequisites

- Runs on **Debian/Ubuntu (glibc)** base images. On **Alpine (musl)** the
  installer falls back to a runtime-dependent .NET 8 build that needs
  `libicu`/`libssl` which this feature intentionally does not install —
  interactive auth may not work there unless you provide those libraries.
- A download tool is needed: `wget`, `wcurl`, or `curl` (chosen in that order).
- Network access to `aka.ms` / GitHub releases is required during image build.
- A working OAuth flow needs browser access; on a dev container that typically
  means `--network host` and the remote user's credentials being forwarded.

## Interactive-auth packages

By default (`installLibsecretAndXdgUtils: true`) this feature installs
`libsecret-1-0` and `xdg-utils` on Debian/Ubuntu:
- `libsecret-1-0` lets the MSAL cache persist via the system keyring when one is
  present (otherwise MSAL falls back to an unprotected file in
  `~/.local/.IdentityService`, which the companion `azure-artifacts-mounts`
  feature can persist in a Docker volume).
- `xdg-utils` provides `xdg-open`, which the credential provider uses to launch
  the browser for interactive authentication.

Set `installLibsecretAndXdgUtils: false` to skip if you manage these yourself.

## Version

The `version` option defaults to `latest`. It accepts a semantic release tag of
the credential provider (e.g. `2.0.4`, optionally `v2.0.4`) which is passed to
the installer via `AZURE_ARTIFACTS_CREDENTIAL_PROVIDER_VERSION`. The installer
requires .NET 8 builds to be **1.3.0 or greater**, and self-contained RID builds
**1.4.0 or greater**; pin accordingly. Keep the manifest `proposals` and the
pinned test version (`version_specific` scenario) in sync when bumping.

## Relationship to azure-artifacts-mounts

This feature **installs** the credential provider. The companion
[`azure-artifacts-mounts`](https://github.com/rafaelkallis/devcontainer-features/tree/main/src/azure-artifacts-mounts)
feature **persists** the credential cache (the MSAL token cache at
`~/.local/.IdentityService`) across dev container rebuilds in a Docker volume.
Use both together for a container that authenticates once and keeps the login:
```json
"features": {
    "ghcr.io/rafaelkallis/devcontainer-features/azure-artifacts-credprovider:1": {},
    "ghcr.io/rafaelkallis/devcontainer-features/azure-artifacts-mounts:1": {}
}
```

A completely different, Microsoft-maintained option is
[`artifacts-helper`](https://github.com/microsoft/codespace-features/tree/main/src/artifacts-helper),
which targets GitHub Codespaces auth; this feature is a lighter, general dev
container install that pairs with `azure-artifacts-mounts`.
