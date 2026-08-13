# Notes

## Purpose

Persists the **MSAL token cache** used by the [Azure Artifacts Credential
Provider](https://github.com/microsoft/artifacts-credprovider) across dev
container rebuilds, so that an interactive login acquired via
`dotnet restore --interactive` on a private Azure Artifacts feed survives
recreating the container.

On Linux the credential provider stores a long-lived OAuth refresh token in:

```
$HOME/.local/.IdentityService/msal.cache
```

When no Linux keyring (SecretService) is available — the normal state in a dev
container unless `libsecret`/`gnome-keyring` is running — the MSAL library falls
back to persisting this cache as a plaintext file at that path. The provider
reads the cache on startup, so a persisted file means previously authenticated
feeds authenticate silently on rebuild.

## How it works

- The feature declares a **Docker named volume**, not a host bind mount:
  - `mounts`: `{ "type": "volume", "source": "azure-artifacts-msal", "target": "/mnt/.IdentityService" }`
  - If the volume does not exist yet, the Docker engine auto-creates it on
    container start. No host directory needs to be pre-created.
  - The volume is mounted at `/mnt/.IdentityService`, and a (one-time)
    symlink `$HOME/.local/.IdentityService` → `/mnt/.IdentityService` is created
    (at build time, and re-created idempotently from the `postCreateCommand`).
  - The named volume persists across container rebuilds, so the MSAL cache
    written through the symlink survives.
- Credentials are not written into the image layers; they live only in the
  mounted volume.

## Requirements

- **Tooling must support feature-level `mounts`.** This feature relies on the
  running tool (VS Code / devcontainer CLI) honoring the `mounts` array in
  `devcontainer-feature.json` to attach the named volume onto `/mnt/.IdentityService`.
  If the tool ignores feature `mounts`, the symlink created in the container
  will dangle (point to a non-existent target). The `postCreateCommand` re-runs
  the setup once the container exists and warns if `/mnt/.IdentityService` is
  genuinely missing — that warning is the signal that feature `mounts` were not
  honored.

## Volume ownership

The named volume is attached at container start and must be writable by the
remote user, because the credential provider writes
`~/.local/.IdentityService/msal.cache` (via the symlink) and a
`msal.cache.lockfile` into it.

- **Fresh volumes** are initialized by Docker from the directory already present
  at the mount target in the image. `install.sh` pre-creates
  `/mnt/.IdentityService` owned by the remote user, so a newly created volume is
  writable by the remote user out of the box.
- **Existing volumes** that were created before this behavior (e.g. root-owned)
  are fixed automatically by the `postCreateCommand`: it detects that the mount
  is not writable by the remote user and runs
  `sudo chown <remote-user> /mnt/.IdentityService` (the remote user has
  passwordless sudo in the dev container base images). Existing cached tokens in
  the volume are preserved.
- If you hit `Access to the path '.../.IdentityService/msal.cache.lockfile' is
  denied` on a volume created before the fix, either rebuild/recreate the
  container once (the `postCreateCommand` will repair ownership), or reset the
  (ephemeral) cache volume manually:
  ```sh
  docker volume rm azure-artifacts-msal
  ```
  The next container start will recreate it writable.

- **Prerequisite: the Azure Artifacts Credential Provider must be installed.**
  This feature only persists the credential cache; it does not install the
  provider or .NET. Install it separately, e.g. with:
  ```sh
  dotnet tool install --global Microsoft.Artifacts.CredentialProvider.NuGet.Tool
  ```
  See the
  [artifacts-credprovider README](https://github.com/microsoft/artifacts-credprovider)
  for details and `libsecret-1-0`/`xdg-utils` requirements for interactive
  browser auth.

## Platform caveats

- **macOS stores the MSAL cache in the Keychain**, not at
  `~/.local/.IdentityService/msal.cache`. On macOS the credential provider does
  not fall back to a plaintext file (no unprotected-file fallback is used there),
  so this feature will not capture the token; sign in interactively inside the
  container instead.
- **Windows** stores tokens in the Windows Credential Manager and
  `%LocalAppData%\.IdentityService`; this feature targets Linux dev containers.
- **Session token cache** (`$HOME/.local/share/MicrosoftCredentialProvider/`)
  is *not* mounted. It holds a short-lived access token (PAT ~90 days / JWT ~4
  hours) that is re-derived from the MSAL refresh token, so persisting only the
  MSAL cache is normally sufficient. If you also want that directory persisted,
  you can add it manually in `devcontainer.json`.

## The volume name is global

The Docker volume `azure-artifacts-msal` is a fixed name, scoped to the Docker
engine, not to a project. Two *unrelated* dev containers that both enable this
feature on the same host will share the same volume (and therefore the same
credentials). For a single user this is usually fine; if you need per-project
isolation, instead declare the volume in your `docker-compose.yml`:

```yaml
volumes:
  azure-artifacts-msal:
```

## Alternative: host bind mount

If you want the container and your **host** dotnet CLI to share the same MSAL
cache (so a login done in the container is also valid on the host), replace the
`mounts` entry with a bind mount:

```json
"mounts": [
    {
        "type": "bind",
        "source": "${localEnv:HOME}/.local/.IdentityService",
        "target": "/mnt/.IdentityService"
    }
]
```

Note this requires the host directory `~/.local/.IdentityService` to exist,
else the container will fail to start (Docker: `bind source path does not exist`).
