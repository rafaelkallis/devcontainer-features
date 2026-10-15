# Dev Container Features

A collection of Dev Container Features for development environments.

## Features

### Claude Code CLI

Installs the Claude Code CLI tool for interacting with Anthropic's Claude language model.

> **Note:** This community feature installs the CLI from `https://claude.ai/install.sh` and is **separate
> from** the official `ghcr.io/anthropics/devcontainer-features/claude-code` feature. If you also use
> `claude-code-mounts`, install the `claude-code` feature from this repo so ordering and config symlinks
> stay consistent.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code:1": {}
  }
}
```

### Claude Code CLI Mounts

Mounts host Claude configuration directories `~/.claude.json` and `~/.claude/` into the dev container, enabling Claude Code CLI to use your existing authentication and settings.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code-mounts:1": {}
  }
}
```

**Prerequisites:**
- Claude Code CLI installed on host with existing configuration in `~/.claude/`
- Claude Code CLI installed in dev container (e.g. via the `claude-code` feature from this repo)

**Notes / limitations:**
- Requires tooling that supports **feature-level `mounts`** (VS Code or devcontainer CLI that honors the `mounts` field in the feature manifest) and host config present at build time.
- Symlinks are created at build time; a `postCreateCommand` re-runs the setup at container start and warns if a mount target is missing (i.e. feature `mounts` were not honored).
- `chown -h` updates the symlink only; the mounted content keeps host ownership/permissions. See the feature's `NOTES.md` for details.

---

### Azure Artifacts Credential Provider

Installs the [Azure Artifacts Credential Provider](https://github.com/microsoft/artifacts-credprovider) so `dotnet` / NuGet / MSBuild can authenticate to private Azure Artifacts feeds. Uses the official upstream installer (`aka.ms/install-artifacts-credprovider.sh`) and installs the self-contained .NET 8 plugin per-user (no .NET SDK required).

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/azure-artifacts-credprovider:1": {}
  }
}
```

**Options (highlights):**
- `version`: pin a release tag (e.g. `2.0.4`) or use `latest` (default)
- `installLibsecretAndXdgUtils`: install `libsecret-1-0` + `xdg-utils` on Debian/Ubuntu for interactive browser-based auth (default `true`)

**Prerequisites:**
- Debian/Ubuntu (glibc) base image. On Alpine (musl) a warning is printed and the install is attempted, but interactive OAuth may not work without extra .NET native libs.
- Network access to `aka.ms` / GitHub releases during image build.

**Notes / limitations:**
- Run `dotnet restore --interactive` against a private feed to trigger the (once-per-cache) OAuth flow.
- On a headless container the MSAL token cache falls back to a plaintext file at `~/.local/.IdentityService/msal.cache`; pair with `azure-artifacts-mounts` (below) to persist it across rebuilds.

---

### Azure Artifacts Credential Mount

Persists the Azure Artifacts Credential Provider **MSAL token cache** in a Docker named volume (`azure-artifacts-msal` mounted at `/mnt/.IdentityService`), so an interactive `dotnet restore --interactive` login on a private feed survives dev container rebuilds.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/azure-artifacts-mounts:1": {}
  }
}
```

**Prerequisites:**
- Tooling that supports **feature-level `mounts`** (VS Code or the devcontainer CLI). No host directory needs to exist — this feature uses a Docker named volume, auto-created on first start.
- The credential provider itself installed in the container (e.g. via `azure-artifacts-credprovider` from this repo; this feature declares `installsAfter` so it runs after).

**Notes / limitations:**
- On dev containers without a Linux keyring, the cache is a plaintext file at `~/.local/.IdentityService/msal.cache` (via a symlink into the volume). Credentials live only in the volume, never in image layers.
- The feature pre-creates the volume mount target as the remote user (and self-heals volumes created by older versions), so the provider can write `msal.cache` without root.

---

### Codex CLI Mounts

Mounts the host Codex CLI configuration directory `~/.codex/` into the dev container, enabling Codex CLI to use your existing authentication, configuration, and local state.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/codex-mounts:1": {}
  }
}
```

**Prerequisites:**
- Codex CLI installed on host with existing configuration in `~/.codex/`

**Notes / limitations:**
- Requires tooling that supports **feature-level `mounts`** and host config present at build time.
- Mounted content keeps host ownership/permissions; see the feature's `NOTES.md` for details.

---

### Azure CLI Mounts

Mounts the host Azure CLI configuration directory `~/.azure/` into the dev container, enabling `az` to use your existing authentication, configuration, and profiles.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/azure-cli-mounts:1": {}
  }
}
```

**Prerequisites:**
- Azure CLI installed on host with existing configuration in `~/.azure/`
- Azure CLI installed in dev container (e.g. via the `azure-cli` feature)

**Notes / limitations:**
- Requires tooling that supports **feature-level `mounts`** and host config present at build time.
- `chown -h` updates the symlink only; the mounted content keeps host ownership/permissions. See the feature's `NOTES.md` for details.
- **macOS/Windows caveat:** `az` stores its auth token in the OS Keychain / Credential Manager, not in `~/.azure`, so this mount may not transfer your login. You may need to `az login` again inside the container.

---

### GitHub CLI Mounts

Mounts the host GitHub CLI configuration directory `~/.config/gh/` into the dev container, enabling `gh` to use your existing authentication, configuration, and hosts.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/github-cli-mounts:1": {}
  }
}
```

**Prerequisites:**
- GitHub CLI installed on host with existing configuration in `~/.config/gh/`
- GitHub CLI installed in dev container (e.g. via the `github-cli` feature)

**Notes / limitations:**
- Requires tooling that supports **feature-level `mounts`** and host config present at build time.
- `chown -h` updates the symlink only; the mounted content keeps host ownership/permissions. See the feature's `NOTES.md` for details.
- **macOS/Windows caveat:** `gh` stores its auth token in the OS Keychain / Credential Manager by default, so this mount may not transfer your login. You may need to `gh auth login` again inside the container.
