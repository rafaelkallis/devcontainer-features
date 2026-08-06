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
- `chown -h` updates the symlink only; the mounted content keeps host ownership/permissions. See the feature's `NOTES.md` for details.

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
